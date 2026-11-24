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

if [ -d $SYSTEM_ROOT/usr/share/bootloader/dtbs ]; then
  echo "Updating device trees..."
  mkdir -p $BOOT_ROOT/dtbs
  cp -f $SYSTEM_ROOT/usr/share/bootloader/dtbs/* $BOOT_ROOT/dtbs
fi

if [ -d "$SYSTEM_ROOT/usr/share/bootloader/loader" ]; then
  echo "Updating BLS configuration..."
  mkdir -p $BOOT_ROOT/loader
  cp -r $SYSTEM_ROOT/usr/share/bootloader/loader/* $BOOT_ROOT/loader
fi

if [ -d "$SYSTEM_ROOT/usr/share/bootloader/openabl" ]; then
  mkdir -p $BOOT_ROOT/openabl
  echo "Updating OpenABL on SD..."
  cp $SYSTEM_ROOT/usr/share/bootloader/openabl/* $BOOT_ROOT/openabl
fi

$SYSTEM_ROOT/usr/bin/updateabl

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
