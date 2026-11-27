#!/usr/bin/env bash
set -Eeuo pipefail

# CentOS 7.7 Linux memory image -> Volatility 3 symbol table
# Run: sudo bash setup.sh

BASE="/home/kali/Documents/temp_extract_dir"
KVER="3.10.0-1062.el7.x86_64"
RPM="kernel-debuginfo-${KVER}.rpm"
URL="https://buildlogs.centos.org/c7.1908.00.x86_64/kernel/20190808101829/${KVER}/${RPM}"

VMLINUX="$BASE/extracted/usr/lib/debug/lib/modules/$KVER/vmlinux"
SYSMAP="$BASE/boot/System.map-$KVER"
REPO="$BASE/dwarf2json"
BIN="$REPO/dwarf2json"
OUTDIR="$BASE/vol3-symbols/linux"
OUT="$OUTDIR/centos-7.json"
TMP=""

R=$'\033[0m'
C=$'\033[1;36m'
G=$'\033[1;32m'
Y=$'\033[1;33m'
E=$'\033[1;31m'

step() { printf '\n%b▶ %s%b\n' "$C" "$1" "$R"; }
ok()   { printf '%b[OK]%b %s\n' "$G" "$R" "$1"; }
info() { printf '%b[INFO]%b %s\n' "$Y" "$R" "$1"; }
fail() { printf '%b[ERROR]%b %s\n' "$E" "$R" "$1" >&2; exit 1; }
cleanup() { [[ -z "$TMP" ]] || rm -f -- "$TMP"; }
trap cleanup EXIT

[[ "$EUID" -eq 0 ]] || fail "Run as root: sudo bash setup.sh"
[[ -s "$BASE/dump.mem" ]] || fail "Memory image not found: $BASE/dump.mem"
[[ -d "$BASE" ]] || fail "Working directory does not exist: $BASE"

cd "$BASE"
printf '%bCENTOS 7.7 — VOLATILITY 3 SYMBOL SETUP%b\n' "$C" "$R"

# -----------------------------------------------------------------------------
# 1. Install only missing command-line tools/packages.
# Existing commands are kept; apt is not run when everything is present.
# -----------------------------------------------------------------------------
step "1/5 — Check required tools"

declare -A PACKAGE_FOR_COMMAND=(
    [wget]="wget"
    [rpm2cpio]="rpm2cpio"
    [cpio]="cpio"
    [git]="git"
    [go]="golang-go"
    [python3]="python3"
    [vol]="volatility3"
)

# Install only commands needed by the work that remains.
required_commands=(python3 vol)
if [[ ! -s "$VMLINUX" ]]; then
    required_commands+=(wget rpm2cpio cpio)
fi
if [[ ! -x "$BIN" ]]; then
    required_commands+=(go)
    if [[ ! -d "$REPO" ]]; then
        required_commands+=(git)
    fi
fi

missing_packages=()
for cmd in "${required_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        ok "$cmd is already available — skipping"
    else
        info "$cmd is missing; package '${PACKAGE_FOR_COMMAND[$cmd]}' is required"
        missing_packages+=("${PACKAGE_FOR_COMMAND[$cmd]}")
    fi
done

need_tls_tools=0
for cmd in "${required_commands[@]}"; do
    if [[ "$cmd" == "wget" || "$cmd" == "git" ]]; then
        need_tls_tools=1
    fi
done
if (( need_tls_tools )) && [[ ! -s /etc/ssl/certs/ca-certificates.crt ]]; then
    missing_packages+=(ca-certificates)
fi

if ((${#missing_packages[@]} > 0)); then
    mapfile -t missing_packages < <(printf '%s\n' "${missing_packages[@]}" | sort -u)
    info "Installing missing packages only: ${missing_packages[*]}"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends "${missing_packages[@]}"
else
    ok "All required tools are already installed — skipping apt update/install"
fi

# Recheck after apt so failures are clear.
for cmd in "${required_commands[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || fail "Required command is still unavailable after package check: $cmd"
done

# dwarf2json currently requires Go 1.18 or newer, but only when it must be built.
if [[ ! -x "$BIN" ]]; then
    GO_VERSION="$(go version | awk '{print $3}' | sed 's/^go//')"
    IFS=. read -r GO_MAJOR GO_MINOR _ <<< "$GO_VERSION"
    [[ "${GO_MAJOR:-}" =~ ^[0-9]+$ && "${GO_MINOR:-}" =~ ^[0-9]+$ ]] || fail "Could not parse Go version: $GO_VERSION"
    if (( GO_MAJOR < 1 || (GO_MAJOR == 1 && GO_MINOR < 18) )); then
        fail "Go 1.18 or newer is required by dwarf2json; found Go $GO_VERSION. Update Go, then rerun."
    fi
    ok "Go $GO_VERSION is compatible"
fi

# -----------------------------------------------------------------------------
# 2. Obtain/extract the exact CentOS kernel debuginfo vmlinux.
# -----------------------------------------------------------------------------
step "2/5 — Check matching CentOS vmlinux"

rpm_is_valid() {
    [[ -s "$BASE/$RPM" ]] || return 1
    # Read the RPM payload and verify that it is a traversable cpio archive.
    rpm2cpio "$BASE/$RPM" 2>/dev/null | cpio -it >/dev/null 2>&1
}

if [[ -s "$VMLINUX" ]]; then
    ok "Matching vmlinux already exists — skipping RPM download/extraction"
else
    if rpm_is_valid; then
        ok "Existing $RPM is valid — skipping download"
    else
        if [[ -e "$BASE/$RPM" ]]; then
            info "Existing RPM is incomplete/invalid; trying to resume its download"
        else
            info "Kernel debuginfo RPM is missing; downloading it"
        fi

        (cd "$BASE" && wget -c --progress=bar:force:noscroll "$URL") || {
            fail "RPM download failed. Check network access and rerun; wget will try to resume."
        }

        if ! rpm_is_valid; then
            info "Resumed file is still invalid; removing it and retrying a clean download"
            rm -f -- "$BASE/$RPM"
            (cd "$BASE" && wget --progress=bar:force:noscroll "$URL") || fail "RPM download failed"
            rpm_is_valid || fail "Downloaded RPM is not a valid RPM/cpio archive: $BASE/$RPM"
        fi
        ok "Kernel debuginfo RPM downloaded and validated"
    fi

    mkdir -p "$BASE/extracted"
    (
        cd "$BASE/extracted"
        rpm2cpio "$BASE/$RPM" |
            cpio -idm -u "./usr/lib/debug/lib/modules/$KVER/vmlinux"
    )
fi

[[ -s "$VMLINUX" ]] || fail "Matching vmlinux was not extracted: $VMLINUX"
ok "Matching vmlinux is ready: $VMLINUX"

# -----------------------------------------------------------------------------
# 3. Get/build dwarf2json only when its executable is not already available.
# -----------------------------------------------------------------------------
step "3/5 — Check dwarf2json"

if [[ -x "$BIN" ]]; then
    ok "dwarf2json binary already exists — skipping clone/build"
else
    if [[ ! -d "$REPO" ]]; then
        git clone https://github.com/volatilityfoundation/dwarf2json.git "$REPO"
    elif [[ -s "$REPO/go.mod" ]]; then
        ok "dwarf2json source directory already exists — skipping clone"
    else
        fail "$REPO exists but does not look like a dwarf2json source checkout (go.mod missing)"
    fi

    (
        cd "$REPO"
        go build -o dwarf2json .
    )
fi

[[ -x "$BIN" ]] || fail "dwarf2json executable was not created: $BIN"
ok "dwarf2json is ready"

# -----------------------------------------------------------------------------
# 4. Generate/validate the Volatility 3 Linux ISF JSON.
# -----------------------------------------------------------------------------
step "4/5 — Prepare Volatility 3 symbol table"

mkdir -p "$OUTDIR"

validate_isf() {
    python3 - "$1" <<'PY'
import json
import sys

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as handle:
        data = json.load(handle)
except (OSError, json.JSONDecodeError) as exc:
    raise SystemExit(f"Invalid JSON: {exc}")

required = ("metadata", "symbols", "user_types", "base_types")
missing = [key for key in required if key not in data]
if missing:
    raise SystemExit("Not a valid-looking Volatility ISF; missing: " + ", ".join(missing))
if not isinstance(data["metadata"], dict) or not isinstance(data["symbols"], dict):
    raise SystemExit("Invalid ISF structure: metadata/symbols must be JSON objects")
print("ISF JSON structure check: OK")
PY
}

if [[ -s "$OUT" ]] && validate_isf "$OUT"; then
    ok "Existing ISF JSON is valid — skipping regeneration"
else
    [[ ! -e "$SYSMAP" || -s "$SYSMAP" ]] || fail "System.map exists but is empty: $SYSMAP"
    TMP="$OUT.tmp.$$"

    if [[ -s "$SYSMAP" ]]; then
        info "Using System.map: $SYSMAP"
        "$BIN" linux --elf "$VMLINUX" --system-map "$SYSMAP" > "$TMP"
    else
        info "System.map not found at $SYSMAP; generating from vmlinux DWARF/symbol data only"
        "$BIN" linux --elf "$VMLINUX" > "$TMP"
    fi

    [[ -s "$TMP" ]] || fail "dwarf2json generated an empty JSON file"
    validate_isf "$TMP" || fail "Generated JSON did not pass ISF validation"
    mv -f -- "$TMP" "$OUT"
    TMP=""
    ok "Linux ISF JSON generated: $OUT"
fi

[[ -s "$OUT" ]] || fail "Symbol JSON is missing: $OUT"

# -----------------------------------------------------------------------------
# 5. Test Volatility 3 with the custom symbol directory.
# -----------------------------------------------------------------------------
step "5/5 — Test Volatility 3"

vol --symbol-dirs "$BASE/vol3-symbols" \
    -f "$BASE/dump.mem" \
    linux.pslist.PsList

printf '\n%bSETUP COMPLETE%b\n' "$G" "$R"
ls -lh "$VMLINUX" "$OUT"
printf '\nSymbol directory: %s\n' "$BASE/vol3-symbols"
printf 'Test completed successfully.\n'
