#!/bin/bash
# Author: m.manikandan
# Usage:  sudo ./mount_evidence.sh            -> mount everything (read-only)
#         sudo ./mount_evidence.sh cleanup    -> unmount and detach everything

IMG="/home/kali/Documents/forensic /temp_extract_dir (3)/Webserver.E01"
EWF=/mnt/ewf
ROOT=/mnt/hacked-root
BOOT=/mnt/hacked-boot
VG=VulnOSv2-vg
LV=/dev/mapper/VulnOSv2--vg-root

[ "$EUID" -ne 0 ] && { echo "Run as root (sudo)."; exit 1; }

# Mount read-only; add noload only for ext3/ext4
ro_mount() {
    local dev="$1" dir="$2" fs opts="ro"
    fs=$(blkid -o value -s TYPE "$dev")
    case "$fs" in ext3|ext4) opts="ro,noload" ;; esac
    echo "    $dev ($fs) -> $dir [$opts]"
    mountpoint -q "$dir" || mount -o "$opts" "$dev" "$dir"
}

cleanup() {
    echo "[*] Cleaning up..."
    umount "$ROOT" 2>/dev/null
    umount "$BOOT" 2>/dev/null
    vgchange -an "$VG" 2>/dev/null
    for L in $(losetup -j "$EWF/ewf1" | cut -d: -f1); do losetup -d "$L"; done
    umount "$EWF" 2>/dev/null
    echo "[+] Done."
}

if [ "$1" = "cleanup" ]; then
    cleanup
    exit 0
fi

set -e
mkdir -p "$EWF" "$ROOT" "$BOOT"

echo "[*] Mounting E01 image..."
[ -e "$EWF/ewf1" ] || ewfmount "$IMG" "$EWF"

echo "[*] Creating read-only loop device..."
LOOP=$(losetup -j "$EWF/ewf1" | cut -d: -f1 | head -n1)
[ -z "$LOOP" ] && LOOP=$(losetup --find --show --read-only --partscan "$EWF/ewf1")
echo "    Loop device: $LOOP"
sleep 1

echo "[*] Activating LVM..."
pvscan >/dev/null 2>&1
vgscan >/dev/null 2>&1
vgchange -ay "$VG"
sleep 1

echo "[*] Mounting root filesystem..."
ro_mount "$LV" "$ROOT"

echo "[*] Mounting /boot..."
ro_mount "${LOOP}p1" "$BOOT"

echo
echo "[+] Mounted. Quick checks:"
ls "$ROOT"
echo "--- timezone ---"
cat "$ROOT/etc/timezone" 2>/dev/null || ls -l "$ROOT/etc/localtime"
echo "--- OS release ---"
head -n 3 "$ROOT/etc/os-release" 2>/dev/null