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

DT_SOC=$($SYSTEM_ROOT/usr/bin/dtsoc | cut -f2 -d,)
DT_ID=$($SYSTEM_ROOT/usr/bin/dtname)
if [ -n "$DT_ID" ]; then
  case $DT_ID in
    powkiddy,x55) SUBDEVICE="Powkiddy_x55";;
    *) SUBDEVICE="Generic";;
  esac
fi

### Migrate device trees to subfolder (except RK326) - remove in the future
if [ "$DT_SOC" = "rk3326" ]; then
  if [ -d "$BOOT_ROOT/device_trees" ]; then
    mv $BOOT_ROOT/device_trees/*.dtb $BOOT_ROOT
    rm -rf $BOOT_ROOT/device_trees
  fi
  if [ -f "$BOOT_ROOT/boot.ini" ]; then
    grep -q "device_trees" $BOOT_ROOT/boot.ini &&
      sed -i 's/${dtb_loadaddr} device_trees\//${dtb_loadaddr} /g' $BOOT_ROOT/boot.ini
  fi
else
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
fi
###

echo "Updating device trees..."
[ "$DT_SOC" = "rk3326" ] && DT_LOC=$BOOT_ROOT || DT_LOC=$BOOT_ROOT/device_trees
cp -f $SYSTEM_ROOT/usr/share/bootloader/device_trees/* $DT_LOC

if [ -d $SYSTEM_ROOT/usr/share/bootloader/overlays ]; then
  echo "Updating device tree overlays..."
  mkdir -p $BOOT_ROOT/overlays
  cp -f $SYSTEM_ROOT/usr/share/bootloader/overlays/* $BOOT_ROOT/overlays
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
