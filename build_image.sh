#!/bin/bash
set -e

# P4wnP1 Image Builder
# Usage: sudo ./build_image.sh
# Requirements: Linux host (Kali/Ubuntu), qemu-user-static, kpartx, git

VERSION="2025.1"
IMAGE_NAME="P4wnP1_aloa_rpi0w_${VERSION}.img"
RPI_OS_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf-lite.img.xz"
BASE_IMAGE_NAME="raspios_lite.img"

echo "[*] P4wnP1 Image Builder v${VERSION}"

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check for dependencies
deps=("kpartx" "qemu-arm-static" "git" "xz")
for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "Error: $dep is not installed. Please install it."
        exit 1
    fi
done

# 1. Download Base Image
if [ ! -f "$BASE_IMAGE_NAME" ]; then
    echo "[*] Downloading Raspberry Pi OS Lite..."
    wget -O base.img.xz "$RPI_OS_URL"
    echo "[*] Extracting..."
    unxz -c base.img.xz > "$BASE_IMAGE_NAME"
    rm base.img.xz
else
    echo "[*] Using existing base image: $BASE_IMAGE_NAME"
fi

# 2. Copy to target image
if [ ! -f "$IMAGE_NAME" ]; then
    echo "[*] Creating working copy: $IMAGE_NAME"
    cp "$BASE_IMAGE_NAME" "$IMAGE_NAME"
    # Resize (add 2GB)
    echo "[*] Expanding image..."
    dd if=/dev/zero bs=1M count=2048 >> "$IMAGE_NAME"
    # Find loop device
    LOOP_DEV=$(losetup -f --show "$IMAGE_NAME")
    # Fix partition table
    parted "$LOOP_DEV" resizepart 2 100%
    losetup -d "$LOOP_DEV"
else
    echo "[*] Target image exists, skipping creation."
fi

# 3. Mount Image
echo "[*] Mounting image..."
LOOP_DEV=$(losetup -f --show "$IMAGE_NAME")
# Map partitions
kpartx -av "$LOOP_DEV"
MAPPER_PATH="/dev/mapper/$(basename $LOOP_DEV)"
ROOT_PART="${MAPPER_PATH}p2"
BOOT_PART="${MAPPER_PATH}p1"

MOUNT_DIR="mnt_p4wnp1"
mkdir -p "$MOUNT_DIR"

# Resize filesystem before mounting
e2fsck -f "$ROOT_PART"
resize2fs "$ROOT_PART"

mount "$ROOT_PART" "$MOUNT_DIR"
mount "$BOOT_PART" "$MOUNT_DIR/boot"

# 4. Prepare Chroot
echo "[*] Setting up Chroot..."
cp /usr/bin/qemu-arm-static "$MOUNT_DIR/usr/bin/"
mount --bind /dev "$MOUNT_DIR/dev"
mount --bind /sys "$MOUNT_DIR/sys"
mount --bind /proc "$MOUNT_DIR/proc"
mount --bind /dev/pts "$MOUNT_DIR/dev/pts"

# Copy Install Script
cp fix_pi_install.sh "$MOUNT_DIR/root/"
chmod +x "$MOUNT_DIR/root/fix_pi_install.sh"

# Enable SSH
touch "$MOUNT_DIR/boot/ssh"
echo "p4wnp1" > "$MOUNT_DIR/etc/hostname"

# 5. Run Installation inside Image
echo "[*] Running installation inside image (this will take a while)..."
chroot "$MOUNT_DIR" /bin/bash -c "
    export DEBIAN_FRONTEND=noninteractive
    /root/fix_pi_install.sh
    # Cleanup
    rm /root/fix_pi_install.sh
    rm /usr/bin/qemu-arm-static
    apt-get clean
"

# 6. Unmount and Cleanup
echo "[*] Unmounting..."
umount "$MOUNT_DIR/dev/pts"
umount "$MOUNT_DIR/dev"
umount "$MOUNT_DIR/sys"
umount "$MOUNT_DIR/proc"
umount "$MOUNT_DIR/boot"
umount "$MOUNT_DIR"

kpartx -d "$LOOP_DEV"
losetup -d "$LOOP_DEV"
rmdir "$MOUNT_DIR"

echo "[SUCCESS] Image built: $IMAGE_NAME"
echo "You can now flash this image to an SD card using Raspberry Pi Imager."
