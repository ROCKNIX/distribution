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
    /dev/mmcblk*)
      BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g")
      ;;
  esac
fi

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

DT_ID=$($SYSTEM_ROOT/usr/bin/dtname)

if [ -n "$DT_ID" ]; then
  case $DT_ID in
    *odroid-go-ultra|*rgb10-max-3-pro)
      SUBDEVICE="Odroid_GOU"
      ;;
    *odroid-n2*)
      SUBDEVICE="Odroid_N2"
      ;;
  esac
fi

for all_dtb in $BOOT_ROOT/*.dtb; do
  dtb=$(basename $all_dtb)
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/$dtb ]; then
    echo "Updating $dtb..."
    cp -p $SYSTEM_ROOT/usr/share/bootloader/$dtb $BOOT_ROOT
  fi
done

# Only update the bootloader for the Odroid Go Ultra and RGB10MAX3 Pro
if [ $SUBDEVICE = "Odroid_GOU" ]; then
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/u-boot.bin ]; then
    echo "Updating u-boot on: $BOOT_DISK..."
    dd if=$SYSTEM_ROOT/usr/share/bootloader/u-boot.bin of=$BOOT_DISK conv=fsync,notrunc bs=512 seek=1 &>/dev/null
  fi
fi

# REMOVE ME IN THE FUTURE!
# Convert from boot.ini to extlinux and cleanup
  [ -e /flash/boot.ini ] && rm -f /flash/boot.ini
  if [ ! -e /flash/extlinux/extlinux.conf ]; then
    mkdir -p /flash/extlinux
    cat <<EOF >/flash/extlinux/extlinux.conf
LABEL ROCKNIX
  LINUX /KERNEL
  FDTDIR /
  APPEND boot=LABEL=ROCKNIX disk=LABEL=STORAGE rootwait quiet systemd.debug_shell=ttyAML0 console=ttyAML0,115200n8 console=tty0 no_console_suspend net.ifnames=0 consoleblank=0 video=HDMI-A-1:1920x1080@60
EOF
  fi
  [ -e /flash/ODROIDBIOS.BIN ] && rm -f /flash/ODROIDBIOS.BIN
  [ -d /flash/res ] && rm -rf /flash/res
# END

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
