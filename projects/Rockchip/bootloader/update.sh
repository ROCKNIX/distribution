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
  for dtb in $SYSTEM_ROOT/usr/share/bootloader/overlays/*.dtb; do
    cp -p $dtb $BOOT_ROOT/overlays
  done
fi

# update bootloader
DT_SOC=$($SYSTEM_ROOT/usr/bin/dtsoc)
case ${DT_SOC} in
  *rk35*) IDBSEEK="bs=512 seek=64";;
  *) IDBSEEK="bs=32k seek=1";;
esac

for IDBLOADER in ${SUBDEVICE}_idbloader.img idbloader.img; do
  if [ -f "$SYSTEM_ROOT/usr/share/bootloader/$IDBLOADER" ]; then
    echo "Updating $IDBLOADER on $BOOT_DISK..."
    dd if=$SYSTEM_ROOT/usr/share/bootloader/$IDBLOADER of=$BOOT_DISK $IDBSEEK conv=fsync &>/dev/null
    break
  fi
done

for BOOT_IMAGE in ${SUBDEVICE}_u-boot.itb u-boot.itb u-boot.img; do
  if [ -f "$SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE" ]; then
    echo "Updating $BOOT_IMAGE on $BOOT_DISK..."
    dd if=$SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE of=$BOOT_DISK bs=512 seek=16384 conv=fsync &>/dev/null
    break
  fi
done

if [ -f $SYSTEM_ROOT/usr/share/bootloader/rk3399-uboot.bin ]; then
  echo "Updating rk3399-uboot.bin on $BOOT_DISK..."
  dd if=$SYSTEM_ROOT/usr/share/bootloader/rk3399-uboot.bin of=$BOOT_DISK bs=512 seek=64 conv=fsync &>/dev/null
fi

if [ -f $SYSTEM_ROOT/usr/share/bootloader/trust.img ]; then
  echo "Updating trust.img on $BOOT_DISK..."
  dd if=$SYSTEM_ROOT/usr/share/bootloader/trust.img of=$BOOT_DISK bs=512 seek=24576 conv=fsync &>/dev/null
elif [ -f $SYSTEM_ROOT/usr/share/bootloader/resource.img ]; then
  echo "Updating resource.img on $BOOT_DISK..."
  dd if=$SYSTEM_ROOT/usr/share/bootloader/resource.img of=$BOOT_DISK bs=512 seek=24576 conv=fsync &>/dev/null
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
