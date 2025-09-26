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

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/bootaa64.efi" ]; then
  echo "Updating EFI..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/bootaa64.efi $BOOT_ROOT/EFI/BOOT
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/grub.cfg" ]; then
  echo "Updating grub.cfg..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/grub.cfg $BOOT_ROOT/EFI/BOOT
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/dejavu-mono.pf2" ]; then
  echo "Updating dejavu-mono.pf2..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/dejavu-mono.pf2 $BOOT_ROOT/EFI/BOOT
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/grubenv" ]; then
  if [ ! -f "$BOOT_ROOT/efi/boot/grubenv" ]; then
    echo "Installing grubenv..."
    cp -p $SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/grubenv $BOOT_ROOT/EFI/BOOT
  fi
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/u-boot-nodtb.bin" ]; then
  mkdir -p $BOOT_ROOT/boot
  echo "Updating u-boot-nodtb.bin..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/boot/u-boot-nodtb.bin $BOOT_ROOT/boot
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/u-boot.dtb" ]; then
  mkdir -p $BOOT_ROOT/boot
  echo "Updating u-boot.dtb..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/boot/u-boot.dtb $BOOT_ROOT/boot
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
