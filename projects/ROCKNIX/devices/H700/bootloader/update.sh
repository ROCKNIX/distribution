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
mkdir -p $BOOT_ROOT/overlays
cp -f $SYSTEM_ROOT/usr/share/bootloader/overlays/* $BOOT_ROOT/overlays

DT_ID=$(cat /proc/device-tree/rocknix-dt-id)

UPDATE_DTB_SOURCE="$BOOT_ROOT/device_trees/$DT_ID.dtb"
if [ -f "$UPDATE_DTB_SOURCE" ]; then
  echo "Updating dtb.img from $(basename $UPDATE_DTB_SOURCE)..."
  cp -f "$UPDATE_DTB_SOURCE" "$BOOT_ROOT/dtb.img"
fi

# detect DDR3/DDR4
for r in /sys/class/regulator/regulator.*/; do
  [[ "$(cat "$r/name" 2>/dev/null)" == "vdd-dram" ]] && VDD_REG_PATH=$r
done

if [ -n "${VDD_REG_PATH:-}" ]; then
  DCDC3_MICROVOLTS=$(cat "$VDD_REG_PATH/microvolts")
  case "$DCDC3_MICROVOLTS" in
    1200000)
      UBOOT_BIN="H700_DDR3_u-boot-sunxi-with-spl.bin"
      ;;
    1100000)
      UBOOT_BIN="H700_DDR4_u-boot-sunxi-with-spl.bin"
      ;;
  esac
fi

# update bootloader
if [ -n "${UBOOT_BIN:-}" ]; then
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/$UBOOT_BIN ]; then
    echo "Updating u-boot on: $BOOT_DISK..."
    dd if=$SYSTEM_ROOT/usr/share/bootloader/$UBOOT_BIN of=$BOOT_DISK bs=1K seek=8 conv=fsync,notrunc &>/dev/null
  fi
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
