#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2021 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

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

for all_dtb in $BOOT_ROOT/*.dtb; do
  dtb=$(basename $all_dtb)
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/$dtb ]; then
    echo "Updating $dtb..."
    cp -p $SYSTEM_ROOT/usr/share/bootloader/$dtb $BOOT_ROOT
  fi
done

if [ -f $BOOT_ROOT/extlinux/extlinux.conf ]; then
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/extlinux/extlinux.conf ]; then
    echo "Updating extlinux.conf..."
    cp -p $SYSTEM_ROOT/usr/share/bootloader/extlinux/extlinux.conf $BOOT_ROOT/extlinux
  fi

  # Set correct FDT boot dtb for RK3588
  DT_ID=$($SYSTEM_ROOT/usr/bin/dtname)
  if [ -n "${DT_ID}" ]; then
    case ${DT_ID} in
      *gameforce,ace)
        echo "Setting boot FDT to GameForce Ace..."
        sed -i '/FDT/c\  FDT /rk3588s-gameforce-ace.dtb' $BOOT_ROOT/extlinux/extlinux.conf
        ;;
      *orangepi-5)
        echo "Setting boot FDT to Orange Pi 5..."
        sed -i '/FDT/c\  FDT /rk3588s-orangepi-5.dtb' $BOOT_ROOT/extlinux/extlinux.conf
        sed -i 's/ fbcon=rotate:1//' $BOOT_ROOT/extlinux/extlinux.conf
        ;;
      *rock-5)
        echo "Setting boot FDT to Rock 5B..."
        sed -i '/FDT/c\  FDT /rk3588-rock-5b.dtb' $BOOT_ROOT/extlinux/extlinux.conf
        sed -i 's/ fbcon=rotate:1//' $BOOT_ROOT/extlinux/extlinux.conf
        ;;
    esac
  fi
fi

if [ -f $BOOT_ROOT/boot.ini ]; then
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/boot.ini ]; then
    echo "Updating boot.ini"
    cp -p $SYSTEM_ROOT/usr/share/bootloader/boot.ini $BOOT_ROOT/boot.ini

    if [ -f $BOOT_ROOT/device.name ]; then
      # Set correct R3xS dtb in boot.ini
      DTB_NAME=$(cat $BOOT_ROOT/device.name)
      case ${DTB_NAME} in
        R33S)
          echo "Setting R33S dtb in boot.ini..."
          sed -i '/rk3326-gameconsole-r3/c\  load mmc 1:1 ${dtb_loadaddr} rk3326-gameconsole-r33s.dtb' $BOOT_ROOT/boot.ini
          ;;
        R36S)
          echo "Setting R36S/R35S dtb in boot.ini..."
          sed -i '/rk3326-gameconsole-r3/c\  load mmc 1:1 ${dtb_loadaddr} rk3326-gameconsole-r36s.dtb' $BOOT_ROOT/boot.ini
          ;;
      esac
    fi
  fi
fi

# update bootloader
DT_SOC=$($SYSTEM_ROOT/usr/bin/dtsoc)
case ${DT_SOC} in
  *rk35*) IDBSEEK="bs=512 seek=64";;
  *) IDBSEEK="bs=32k seek=1";;
esac

if [ -f $SYSTEM_ROOT/usr/share/bootloader/idbloader.img ]; then
  echo -n "Updating idbloader.img on $BOOT_DISK... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/idbloader.img of=$BOOT_DISK $IDBSEEK conv=fsync &>/dev/null
fi

for BOOT_IMAGE in u-boot.itb u-boot.img; do
  if [ -f "$SYSTEM_ROOT/usr/share/bootloader/${BOOT_IMAGE}" ]; then
    echo -n "Updating $BOOT_IMAGE on $BOOT_DISK..."
    dd if=$SYSTEM_ROOT/usr/share/bootloader/$BOOT_IMAGE of=$BOOT_DISK bs=512 seek=16384 conv=fsync &>/dev/null
    break
  fi
done

if [ -f $SYSTEM_ROOT/usr/share/bootloader/rk3399-uboot.bin ]; then
  echo -n "Updating rk3399-uboot.bin on $BOOT_DISK... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/rk3399-uboot.bin of=$BOOT_DISK bs=512 seek=64 conv=fsync &>/dev/null
fi

if [ -f $SYSTEM_ROOT/usr/share/bootloader/trust.img ]; then
  echo -n "Updating trust.img on $BOOT_DISK... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/trust.img of=$BOOT_DISK bs=512 seek=24576 conv=fsync &>/dev/null
elif [ -f $SYSTEM_ROOT/usr/share/bootloader/resource.img ]; then
  echo -n "Updating resource.img on $BOOT_DISK... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/resource.img of=$BOOT_DISK bs=512 seek=24576 conv=fsync &>/dev/null
fi

# Update system partition label to ROCKNIX
[ ! -z "$(blkid | grep JELOS)" ] && ${SYSTEM_ROOT}/usr/sbin/dosfslabel $BOOT_PART ROCKNIX

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
