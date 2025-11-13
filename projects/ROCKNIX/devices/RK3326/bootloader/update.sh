#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

# Setup logging
echo -n > $BOOT_ROOT/update.log
log() { echo $*; echo $* >> $BOOT_ROOT/update.log; }
log "Starting bootloader update"

# identify the boot device
if [ -z "$BOOT_DISK" ]; then
  case $BOOT_PART in
    /dev/mmcblk*) BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g");;
  esac
fi

SUBDEVICE=$(sed -n 's|^.* uboot.hwid_adc=\([^, ]\),.*$|\1|p' /proc/cmdline)
if [ -n "$SUBDEVICE" ]; then
  log "Subdevice from cmdline: $SUBDEVICE"
elif [ -f $BOOT_ROOT/boot.scr ]; then
  grep -q "rk3326-anbernic-rg351m.dtb" $BOOT_ROOT/boot.scr && SUBDEVICE=a || SUBDEVICE=b
  log "Subdevice from boot.scr: $SUBDEVICE"
elif [ -f $BOOT_ROOT/boot.ini ]; then
  grep -q "rk3326-anbernic-rg351m.dtb" $BOOT_ROOT/boot.ini && SUBDEVICE=a || SUBDEVICE=b
  log "Subdevice from boot.ini: $SUBDEVICE"
else
  SUBDEVICE=a
  log "Subdevice fallback: $SUBDEVICE"
fi

log "Updating device trees..."
if [ -d "$BOOT_ROOT/device_trees" ]; then
  mv $BOOT_ROOT/device_trees/*.dtb $BOOT_ROOT
  rm -rf $BOOT_ROOT/device_trees
fi
cp -f $SYSTEM_ROOT/usr/share/bootloader/device_trees/* $BOOT_ROOT

if [ -d $SYSTEM_ROOT/usr/share/bootloader/overlays ]; then
  log "Updating device tree overlays..."
  mkdir -p $BOOT_ROOT/overlays
  cp -f $SYSTEM_ROOT/usr/share/bootloader/overlays/* $BOOT_ROOT/overlays
fi

if [ ! -f $BOOT_ROOT/extlinux/extlinux.conf ]; then
  log "Creating extlinux.conf..."
  mkdir -p $BOOT_ROOT/extlinux
  cp -f $SYSTEM_ROOT/usr/share/bootloader/extlinux/* $BOOT_ROOT/extlinux/
fi

for BOOT_IMAGE in uboot.bin; do
  if [ -f "$SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE" ]; then
    log "Updating $BOOT_IMAGE on $BOOT_DISK..."
    # instead of using small bs, read the missing part from target and do a perfectly aligned write
    {
      dd if=$BOOT_DISK bs=32K count=1
      cat $SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE
    } | dd of=$BOOT_DISK bs=4M conv=fsync &>/dev/null
    break
  fi
done

log "Updating boot.scr from ${SUBDEVICE}_boot.scr..."
cp -f $SYSTEM_ROOT/usr/share/bootloader/${SUBDEVICE}_boot.scr $BOOT_ROOT/boot.scr

log "Finishing bootloader update..."
# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
log "DONE"
