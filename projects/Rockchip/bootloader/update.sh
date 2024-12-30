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

### Migrate device trees to subfolder - remove in the future
if [ ! -d "$BOOT_ROOT/device_trees" ]; then
  mkdir $BOOT_ROOT/device_trees
  mv $BOOT_ROOT/*.dtb $BOOT_ROOT/device_trees
  if [ -f "$BOOT_ROOT/boot.ini" ]; then
    ! grep -q "device_trees" $BOOT_ROOT/boot.ini &&
      sed -i 's/${dtb_loadaddr} /${dtb_loadaddr} device_trees\//g' $BOOT_ROOT/boot.ini
  fi
  if [ -f "$BOOT_ROOT/extlinux/extlinux.conf" ]; then
    if ! grep -q "device_trees" $BOOT_ROOT/extlinux/extlinux.conf; then
      sed -i 's/FDT /FDT \/device_trees/g' $BOOT_ROOT/extlinux/extlinux.conf
      sed -i 's/FDTDIR \//FDTDIR \/device_trees/g' $BOOT_ROOT/extlinux/extlinux.conf
    fi
  fi
fi
###

echo "Updating device trees..."
for dtb in $SYSTEM_ROOT/usr/share/bootloader/device_trees/*.dtb; do
  cp -p $dtb $BOOT_ROOT/device_trees
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
    # instead of using small bs, read the missing part from target and do a perfectly aligned write
    {
      dd if=$BOOT_DISK bs=32K count=1
      cat $SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE
    } | dd of=$BOOT_DISK bs=4M conv=fsync &>/dev/null
    break
  fi
done

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
