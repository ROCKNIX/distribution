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

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/bootaa64.efi" ]; then
  mkdir -p $BOOT_ROOT/EFI/BOOT
  echo "Updating EFI..."
  cp $SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/bootaa64.efi $BOOT_ROOT/EFI/BOOT
fi

if [ -d "$SYSTEM_ROOT/usr/share/bootloader/boot/grub" ]; then
  mkdir -p $BOOT_ROOT/boot/grub
  echo "Updating grub dtbs..."
  cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/*.dtb $BOOT_ROOT/boot/grub
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/grub/grub.cfg" ]; then
  mkdir -p $BOOT_ROOT/boot/grub
  echo "Updating grub.cfg..."
  cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/grub.cfg $BOOT_ROOT/boot/grub
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/grub/dejavu-mono.pf2" ]; then
  mkdir -p $BOOT_ROOT/boot/grub
  echo "Updating dejavu-mono.pf2..."
  cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/dejavu-mono.pf2 $BOOT_ROOT/boot/grub
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/grub/grubenv" ]; then
  if [ ! -f "$BOOT_ROOT/boot/grub/grubenv" ]; then
    mkdir -p $BOOT_ROOT/boot/grub
    echo "Installing grubenv..."
    cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/grubenv $BOOT_ROOT/boot/grub
  fi
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/rocknix-u-boot.img" ]; then
  echo "Updating rocknix-u-boot.img..."
  cp $SYSTEM_ROOT/usr/share/bootloader/rocknix-u-boot.img $BOOT_ROOT
fi

if [ -d "$SYSTEM_ROOT/usr/share/bootloader/device_trees" ]; then
  mkdir -p $BOOT_ROOT/device_trees
  echo "Updating u-boot dtbs..."
  cp $SYSTEM_ROOT/usr/share/bootloader/device_trees/*.dtb $BOOT_ROOT/device_trees
fi

U_BOOT_DT_ID=$(cat /proc/device-tree/rocknix-u-boot-dt-id)
UPDATE_DTB_SOURCE="$BOOT_ROOT/device_trees/$U_BOOT_DT_ID.dtb"
if [ -f "$UPDATE_DTB_SOURCE" ]; then
  echo "Updating dtb.img from $(basename $UPDATE_DTB_SOURCE)..."
  cp "$UPDATE_DTB_SOURCE" "$BOOT_ROOT/dtb.img"
fi

if [ -d "$SYSTEM_ROOT/usr/share/bootloader/rocknix_abl" ]; then
  mkdir -p $BOOT_ROOT/rocknix_abl
  echo "Updating ROCKNIX ABL..."
  cp $SYSTEM_ROOT/usr/share/bootloader/rocknix_abl/* $BOOT_ROOT/rocknix_abl
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
