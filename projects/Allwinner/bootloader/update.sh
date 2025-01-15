#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})

# identify the boot device
if [ -z "$BOOT_DISK" ]; then
  case $BOOT_PART in
    /dev/mmcblk*)
      BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g")
      ;;
  esac
fi

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

echo "Updating device trees..."
cp -f $SYSTEM_ROOT/usr/share/bootloader/device_trees/* $BOOT_ROOT/device_trees

DT_ID=$(cat /proc/device-tree/rocknix-dt-id)
UPDATE_DTB_SOURCE="$BOOT_ROOT/device_trees/$DT_ID.dtb"
if [ -f "$UPDATE_DTB_SOURCE" ]; then
  echo "Updating dtb.img from $(basename $UPDATE_DTB_SOURCE)..."
  cp -f "$UPDATE_DTB_SOURCE" "$BOOT_ROOT/dtb.img"
fi

# update bootloader
if [ -f $SYSTEM_ROOT/usr/share/bootloader/u-boot-sunxi-with-spl.bin ]; then
  echo "Updating u-boot on: $BOOT_DISK..."
  dd if=$SYSTEM_ROOT/usr/share/bootloader/u-boot-sunxi-with-spl.bin of=$BOOT_DISK bs=1K seek=8 conv=fsync,notrunc &>/dev/null
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
