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

if [ ! -d "$BOOT_ROOT/device_trees" ]; then
  mkdir $BOOT_ROOT/device_trees
  mv $BOOT_ROOT/*.dtb $BOOT_ROOT/device_trees
  if [ -f "$BOOT_ROOT/extlinux/extlinux.conf" ]; then
    if ! grep -q "device_trees" $BOOT_ROOT/extlinux/extlinux.conf; then
      sed -i 's/FDT /FDT \/device_trees/g' $BOOT_ROOT/extlinux/extlinux.conf
      sed -i 's/FDTDIR \//FDTDIR \/device_trees/g' $BOOT_ROOT/extlinux/extlinux.conf
    fi
  fi
fi

echo "Updating device trees..."
cp -f $SYSTEM_ROOT/usr/share/bootloader/device_trees/* $BOOT_ROOT/device_trees

if [ -d $SYSTEM_ROOT/usr/share/bootloader/overlays ]; then
  echo "Updating device tree overlays..."
  mkdir -p $BOOT_ROOT/overlays
  cp -f $SYSTEM_ROOT/usr/share/bootloader/overlays/* $BOOT_ROOT/overlays
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/uboot.bin" ]; then
  echo "Updating uboot.bin on $BOOT_DISK..."
  {
    dd if=$BOOT_DISK bs=32K count=1
    cat $SYSTEM_ROOT/usr/share/bootloader/uboot.bin
  } | dd of=$BOOT_DISK bs=4M conv=fsync &>/dev/null
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
