#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})

# identify the boot device
if [ -z "$BOOT_DISK" ]; then
  case $BOOT_PART in
    /dev/mmcblk*) BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g");;
  esac
fi

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

echo "Updating device trees..."
for dtb in $SYSTEM_ROOT/usr/share/bootloader/*.dtb; do
  cp -p $dtb $BOOT_ROOT
done

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/bootaa64.efi" ]; then
  echo "Updating EFI..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/bootaa64.efi $BOOT_ROOT/efi/boot
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/grub.cfg" ]; then
  echo "Updating GRUB..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/grub.cfg $BOOT_ROOT/efi/boot
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
