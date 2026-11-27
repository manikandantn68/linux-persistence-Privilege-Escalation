#!/usr/bin/env bash
set -Eeuo pipefail

# Ulysses (Debian 2.6.26-2-686) -> Volatility 3 Linux ISF setup
# Run from anywhere:
#   sudo bash setup_ulysses_vol3.sh
# Optional explicit debug ELF:
#   sudo VMLINUX=/absolute/path/to/matching-vmlinux bash setup_ulysses_vol3.sh
#
# Important:
# Debian5_26.zip contains a Volatility 2 text DWARF dump (module.dwarf),
# not an ELF file that dwarf2json can consume. This script will not pretend
# that file is a Volatility 3 symbol source. It searches for a matching ELF
# carrying DWARF and the exact kernel banner before generating an ISF.

# -----------------------------------------------------------------------------
# Paths and target kernel
# -----------------------------------------------------------------------------
BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MEMORY="${MEMORY:-$BASE/victoria-v8.memdump.img}"
PROFILE_ZIP="${PROFILE_ZIP:-$BASE/Debian5_26.zip}"
WORK="$BASE/vol3-ulysses-work"
PROFILE_DIR="$WORK/legacy-profile"
SYMBOL_ROOT="$BASE/vol3-symbols"
OUTDIR="$SYMBOL_ROOT/linux"
OUT="$OUTDIR/debian-2.6.26-2-686.json"
LOG="$WORK/linux-pslist.txt"

EXPECTED_BANNER='Linux version 2.6.26-2-686 (Debian 2.6.26-26lenny1) (dannf@debian.org) (gcc version 4.1.3 20080704 (prerelease) (Debian 4.1.2-25)) #1 SMP Thu Nov 25 01:53:57 UTC 2010'
BANNER_PREFIX='Linux version 2.6.26-2-686 '
VMLINUX_INPUT="${VMLINUX:-}"
VMLINUX_FOUND=""
SYSMAP=""
TMP_JSON=""

# -----------------------------------------------------------------------------
# Console helpers
# -----------------------------------------------------------------------------
R=$'\033[0m'
C=$'\033[1;36m'
G=$'\033[1;32m'
Y=$'\033[1;33m'
E=$'\033[1;31m'

step() { printf '\n%b▶ %s%b\n' "$C" "$1" "$R"; }
ok()   { printf '%b[OK]%b %s\n' "$G" "$R" "$1"; }
info() { printf '%b[INFO]%b %s\n' "$Y" "$R" "$1"; }
warn() { printf '%b[WARN]%b %s\n' "$Y" "$R" "$1" >&2; }
fail() { printf '%b[ERROR]%b %s\n' "$E" "$R" "$1" >&2; exit 1; }
cleanup() { [[ -z "$TMP_JSON" ]] || rm -f -- "$TMP_JSON"; }
trap cleanup EXIT

# -----------------------------------------------------------------------------
# 1. Validate this Ulysses directory and inputs
# -----------------------------------------------------------------------------
step '1/6 — Validate Ulysses files'

[[ -d "$BASE" ]] || fail "Lab directory not found: $BASE"
[[ -s "$MEMORY" ]] || fail "Memory image not found: $MEMORY"
[[ -s "$PROFILE_ZIP" ]] || fail "Profile ZIP not found: $PROFILE_ZIP"

if ! command -v vol >/dev/null 2>&1; then
    fail "Volatility 3 command 'vol' is not installed or not in PATH. This script will not install another Volatility version."
fi

VOL_VERSION="$(vol --version 2>&1 | head -n 1 || true)"
ok "Using $VOL_VERSION"
ok "Memory image: $MEMORY"
ok "Profile archive: $PROFILE_ZIP"

# Commands needed before we can inspect/extract the supplied profile.
MISSING_BASE_PACKAGES=()
check_base_command() {
    local command_name="$1"
    local package_name="$2"
    if command -v "$command_name" >/dev/null 2>&1; then
        ok "$command_name already exists — skipping"
    else
        info "$command_name is missing; package required: $package_name"
        MISSING_BASE_PACKAGES+=("$package_name")
    fi
}
check_base_command python3 python3
check_base_command unzip unzip
check_base_command readelf binutils
check_base_command strings binutils

if ((${#MISSING_BASE_PACKAGES[@]} > 0)); then
    if [[ "$EUID" -ne 0 ]]; then
        fail 'Missing base packages detected. Re-run with sudo so apt can install only the missing packages.'
    fi
    mapfile -t MISSING_BASE_PACKAGES < <(printf '%s\n' "${MISSING_BASE_PACKAGES[@]}" | sort -u)
    info "Installing only missing base packages: ${MISSING_BASE_PACKAGES[*]}"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends "${MISSING_BASE_PACKAGES[@]}"
else
    ok 'All base tools are already installed — skipping apt update/install'
fi

mkdir -p "$WORK" "$PROFILE_DIR"

# -----------------------------------------------------------------------------
# 2. Extract the supplied ZIP only when needed and find System.map
# -----------------------------------------------------------------------------
step '2/6 — Reuse supplied Debian profile files'

if [[ ! -s "$PROFILE_DIR/boot/System.map-2.6.26-2-686" || \
      ! -s "$PROFILE_DIR/volatility-master/tools/linux/module.dwarf" ]]; then
    info 'Extracting Debian5_26.zip into the work directory'
    unzip -oq "$PROFILE_ZIP" -d "$PROFILE_DIR"
else
    ok 'Profile archive already extracted — skipping'
fi

LEGACY_DWARF="$PROFILE_DIR/volatility-master/tools/linux/module.dwarf"
ZIP_SYSMAP="$PROFILE_DIR/boot/System.map-2.6.26-2-686"
LOCAL_SYSMAP="$BASE/boot/System.map-2.6.26-2-686"

if [[ -s "$LOCAL_SYSMAP" ]]; then
    SYSMAP="$LOCAL_SYSMAP"
elif [[ -s "$ZIP_SYSMAP" ]]; then
    SYSMAP="$ZIP_SYSMAP"
else
    SYSMAP="$(find "$BASE/boot" "$PROFILE_DIR" -type f -name 'System.map-2.6.26-2-686' -print -quit 2>/dev/null || true)"
fi

[[ -n "$SYSMAP" && -s "$SYSMAP" ]] || fail 'Could not locate System.map-2.6.26-2-686 in the lab folder or supplied ZIP.'

if [[ -s "$LEGACY_DWARF" ]]; then
    info "Supplied legacy file: $LEGACY_DWARF"
    if readelf -h "$LEGACY_DWARF" >/dev/null 2>&1; then
        ok 'module.dwarf is an ELF file; it may be examined as a candidate'
    else
        info 'module.dwarf is a text DWARF dump from the Volatility 2 profile, not an ELF input for dwarf2json.'
    fi
else
    warn 'The legacy module.dwarf file was not found in the ZIP; continuing to search for a matching kernel ELF.'
fi
ok "System.map selected: $SYSMAP"

# -----------------------------------------------------------------------------
# 3. Locate an ELF with DWARF and the exact banner
# -----------------------------------------------------------------------------
step '3/6 — Locate exact Debian kernel debugging ELF'

is_elf_with_dwarf() {
    local candidate="$1"
    readelf -h "$candidate" >/dev/null 2>&1 || return 1
    readelf -S "$candidate" 2>/dev/null | grep -Eq '\.(z?debug_info|debug_types)([[:space:]]|$)'
}

has_exact_banner() {
    local candidate="$1"
    local found
    found="$(strings -a "$candidate" 2>/dev/null | grep -F "$BANNER_PREFIX" | head -n 1 || true)"
    [[ "$found" == "$EXPECTED_BANNER" ]]
}

if [[ -n "$VMLINUX_INPUT" ]]; then
    [[ -s "$VMLINUX_INPUT" ]] || fail "VMLINUX path does not exist or is empty: $VMLINUX_INPUT"
    is_elf_with_dwarf "$VMLINUX_INPUT" || fail "VMLINUX is not an ELF containing DWARF sections: $VMLINUX_INPUT"
    VMLINUX_FOUND="$VMLINUX_INPUT"
    if ! has_exact_banner "$VMLINUX_FOUND"; then
        warn 'The supplied ELF does not contain the complete expected banner as a string. The generated ISF will still be checked for an exact banner; split debug files may need their matching kernel ELF as well.'
    fi
else
    # Search likely local paths; only accept a candidate that embeds the exact
    # banner and has DWARF sections. Do not select an unrelated Kali .debug file.
    while IFS= read -r -d '' candidate; do
        if is_elf_with_dwarf "$candidate" && has_exact_banner "$candidate"; then
            VMLINUX_FOUND="$candidate"
            break
        fi
    done < <(
        find "$BASE" /usr/lib/debug /mnt/ulysses \
            -type f \( -name 'vmlinux' -o -name 'vmlinux-*' -o -name '*.debug' \) \
            -print0 2>/dev/null || true
    )
fi

if [[ -z "$VMLINUX_FOUND" ]]; then
    cat >&2 <<EOF

[STOP] No exact matching kernel debugging ELF was found.

The memory image banner is:
$EXPECTED_BANNER

The supplied Debian5_26.zip contains:
  - module.dwarf: Volatility 2 text DWARF dump (not an ELF for dwarf2json)
  - System.map-2.6.26-2-686: reusable kernel symbol map

Volatility 3's dwarf2json needs an ELF/DWARF kernel debugging file. A System.map
alone provides symbol addresses, not the kernel structure/type definitions
required by linux.pslist. This script therefore stops instead of creating an
incomplete or misleading ISF.

When you obtain the matching unstripped vmlinux/debug ELF, run:
  sudo VMLINUX='/absolute/path/to/matching-vmlinux' bash '$BASE/$(basename -- "${BASH_SOURCE[0]}")'

Do not use a random Kali .debug file or a different Debian kernel build:
Volatility 3 requires the exact kernel banner.
EOF
    exit 2
fi

ok "Matching ELF candidate: $VMLINUX_FOUND"

# -----------------------------------------------------------------------------
# 4. Install dwarf2json only if an exact matching debug ELF was found
# -----------------------------------------------------------------------------
step '4/6 — Check dwarf2json; install only if missing'

# Volatility 3 itself must already exist. Do not install Volatility 2 or 3 here.
if command -v dwarf2json >/dev/null 2>&1; then
    ok 'dwarf2json already exists — skipping installation'
else
    if [[ "$EUID" -ne 0 ]]; then
        fail 'dwarf2json is missing. Re-run with sudo so apt can install only the missing package.'
    fi
    info 'dwarf2json is missing; installing that package only'
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends dwarf2json
fi

for command_name in python3 unzip readelf strings dwarf2json vol; do
    command -v "$command_name" >/dev/null 2>&1 || fail "Required command is unavailable after setup: $command_name"
done

# -----------------------------------------------------------------------------
# 5. Generate and validate Volatility 3 ISF JSON
# -----------------------------------------------------------------------------
step '5/6 — Generate and validate Volatility 3 Linux ISF'

mkdir -p "$OUTDIR"

validate_isf() {
    python3 - "$1" "$EXPECTED_BANNER" <<'PY'
import json
import sys

path, expected_banner = sys.argv[1], sys.argv[2]
try:
    with open(path, "r", encoding="utf-8") as stream:
        data = json.load(stream)
except (OSError, json.JSONDecodeError) as exc:
    raise SystemExit(f"Invalid JSON: {exc}")

required = ("metadata", "symbols", "user_types", "base_types")
missing = [key for key in required if key not in data]
if missing:
    raise SystemExit("Not a valid-looking Volatility ISF; missing: " + ", ".join(missing))

metadata = data.get("metadata", {})
linux_metadata = metadata.get("linux", {}) if isinstance(metadata, dict) else {}
actual_banner = linux_metadata.get("banner") if isinstance(linux_metadata, dict) else None
if actual_banner != expected_banner:
    raise SystemExit(
        "Kernel banner mismatch.\n"
        f"Expected: {expected_banner}\n"
        f"Actual:   {actual_banner!r}"
    )

if not isinstance(data["symbols"], dict) or not isinstance(data["user_types"], dict):
    raise SystemExit("Invalid ISF structure: symbols/user_types must be JSON objects")

print("ISF structure: OK")
print("Exact Linux kernel banner: OK")
print(f"Symbols: {len(data['symbols'])}; user types: {len(data['user_types'])}")
PY
}

if [[ -s "$OUT" ]] && validate_isf "$OUT"; then
    ok 'Existing exact-banner ISF is valid — skipping regeneration'
else
    TMP_JSON="$OUT.tmp.$$"
    rm -f -- "$TMP_JSON"
    info 'Running dwarf2json with matching ELF and supplied System.map'
    if ! dwarf2json linux --elf "$VMLINUX_FOUND" --system-map "$SYSMAP" > "$TMP_JSON"; then
        fail 'dwarf2json failed. Check the ELF/debug sections and available RAM (dwarf2json may need 8 GB or more for large DWARF input).'
    fi
    [[ -s "$TMP_JSON" ]] || fail 'dwarf2json produced an empty file'
    validate_isf "$TMP_JSON" || fail 'Generated ISF did not match the exact memory-image banner; refusing to install it.'
    mv -f -- "$TMP_JSON" "$OUT"
    TMP_JSON=""
    ok "ISF generated: $OUT"
fi

# -----------------------------------------------------------------------------
# 6. Run Volatility 3 linux.pslist against the Ulysses memory image
# -----------------------------------------------------------------------------
step '6/6 — Test Volatility 3 linux.pslist'

PSLIST_PLUGIN='linux.pslist.PsList'
info "Running: vol --symbol-dirs '$SYMBOL_ROOT' -f '$MEMORY' $PSLIST_PLUGIN"
if ! vol --symbol-dirs "$SYMBOL_ROOT" -f "$MEMORY" "$PSLIST_PLUGIN" 2>&1 | tee "$LOG"; then
    fail "Volatility 3 linux.pslist failed. Review output above and log: $LOG"
fi

if grep -Eiq '(^|[[:space:]])nc([[:space:]]|$)' "$LOG"; then
    printf '\n%b[FOUND]%b Netcat process entry detected in the Volatility 3 process list:\n' "$G" "$R"
    grep -Ei '(^|[[:space:]])nc([[:space:]]|$)' "$LOG" || true
else
    warn "No process named 'nc' was found in this memory image's linux.pslist output. Review: $LOG"
fi

printf '\n%bVOLATILITY 3 SETUP COMPLETE%b\n' "$G" "$R"
printf 'Symbol JSON : %s\n' "$OUT"
printf 'Process log : %s\n' "$LOG"
printf 'Symbol root : %s\n' "$SYMBOL_ROOT"
