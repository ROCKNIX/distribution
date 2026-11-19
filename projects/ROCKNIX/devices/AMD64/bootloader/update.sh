#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

# Update EFI bootloader
if [ -d "$SYSTEM_ROOT/usr/share/bootloader" ]; then
  echo "Updating AMD64 bootloader..."
  cp -r $SYSTEM_ROOT/usr/share/bootloader/* $BOOT_ROOT/
  rm -r $BOOT_ROOT/update.sh
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT
echo "UPDATE" > /storage/.boot.hint
