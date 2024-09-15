#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
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

DT_ID=$($SYSTEM_ROOT/usr/bin/dtname)
if [ -n "$DT_ID" ]; then
  case $DT_ID in
    powkiddy,x55) SUBDEVICE="Powkiddy_x55";;
    *) SUBDEVICE="Generic";;
  esac
fi

echo "Updating device trees..."
for dtb in $SYSTEM_ROOT/usr/share/bootloader/*.dtb; do
  cp -p $dtb $BOOT_ROOT
done

if [ -d $SYSTEM_ROOT/usr/share/bootloader/overlays ]; then
  echo "Updating device tree overlays..."
  mkdir -p $BOOT_ROOT/overlays
  for dtb in $SYSTEM_ROOT/usr/share/bootloader/overlays/*.dtbo; do
    cp -p $dtb $BOOT_ROOT/overlays
  done
fi

for BOOT_IMAGE in ${SUBDEVICE}_uboot.bin uboot.bin; do
  if [ -f "$SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE" ]; then
    echo "Updating $BOOT_IMAGE on $BOOT_DISK..."
    dd if=$SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE of=$BOOT_DISK bs=512 seek=64 conv=fsync &>/dev/null
    break
  fi
done

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
