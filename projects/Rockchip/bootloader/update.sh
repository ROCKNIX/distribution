#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2021 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)


if [ -z "${1}" ]
then
  [ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
  [ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
  [ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})
  if [ -z "$BOOT_DISK" ]; then
    case $BOOT_PART in
      /dev/sd[a-z][0-9]*)
        BOOT_DISK=$(echo $BOOT_PART | sed -e "s,[0-9]*,,g")
        ;;
      /dev/mmcblk*)
        BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g")
        ;;
    esac
  fi

  # mount $BOOT_ROOT r/w
    mount -o remount,rw $BOOT_ROOT

  for arg in $(cat /proc/cmdline); do
    case $arg in
      boot=*)
        boot="${arg#*=}"
        case $boot in
          /dev/mmc*)
            UUID_SYSTEM="$(blkid $boot | sed 's/.* UUID="//;s/".*//g')"
            ;;
          UUID=*|LABEL=*)
            UUID_SYSTEM="$(blkid | sed 's/"//g' | grep -m 1 -i " $boot " | sed 's/.* UUID=//;s/ .*//g')"
            ;;
          FOLDER=*)
            UUID_SYSTEM="$(blkid ${boot#*=} | sed 's/.* UUID="//;s/".*//g')"
            ;;
        esac
      ;;
      disk=*)
        disk="${arg#*=}"
        case $disk in
          /dev/mmc*)
            UUID_STORAGE="$(blkid $disk | sed 's/.* UUID="//;s/".*//g')"
            ;;
          UUID=*|LABEL=*)
            UUID_STORAGE="$(blkid | sed 's/"//g' | grep -m 1 -i " $disk " | sed 's/.* UUID=//;s/ .*//g')"
            ;;
          FOLDER=*)
            UUID_STORAGE="$(blkid ${disk#*=} | sed 's/.* UUID="//;s/".*//g')"
            ;;
        esac
      ;;
    esac
  done
else
  BOOT_DISK="${1}"
  BOOT_ROOT="${2}"
  UUID_SYSTEM="${3}"
  UUID_STORAGE="${4}"
fi

CONFS=$SYSTEM_ROOT/usr/share/bootloader/extlinux/*.conf

for all_conf in $CONFS; do
  conf="$(basename ${all_conf})"
  echo "Updating ${conf}..."
  if [ ! -d "${BOOT_ROOT}/extlinux" ]
  then
    mkdir "${BOOT_ROOT}/extlinux"
  fi
  cp -p $SYSTEM_ROOT/usr/share/bootloader/extlinux/${conf} $BOOT_ROOT/extlinux/${conf} &>/dev/null
  sed -e "s/@UUID_SYSTEM@/${UUID_SYSTEM}/" \
      -e "s/@UUID_STORAGE@/${UUID_STORAGE}/" \
      -i $BOOT_ROOT/extlinux/${conf}
done

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

if [ -f $SYSTEM_ROOT/usr/share/bootloader/boot.ini ]; then
  echo "Updating boot.ini..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/boot.ini $BOOT_ROOT/boot.ini &>/dev/null
    sed -e "s/@UUID_SYSTEM@/${UUID_SYSTEM}/" \
      -e "s/@UUID_STORAGE@/${UUID_STORAGE}/" \
      -i $BOOT_ROOT/boot.ini

  # Set correct R3xS dtb in boot.ini
  DTB_NAME=$(cat $BOOT_ROOT/device.name)
  if [ $DTB_NAME = 'R33S' ]; then
    echo "Setting R33S dtb in boot.ini..."
    sed -i '/rk3326-gameconsole-r3/c\  load mmc 1:1 ${dtb_loadaddr} rk3326-gameconsole-r33s.dtb' $BOOT_ROOT/boot.ini
  elif [ $DTB_NAME = 'R36S' ]; then
    echo "Setting R36S/R35S dtb in boot.ini..."
    sed -i '/rk3326-gameconsole-r3/c\  load mmc 1:1 ${dtb_loadaddr} rk3326-gameconsole-r36s.dtb' $BOOT_ROOT/boot.ini
  fi
fi

# update device tree
for all_dtb in $SYSTEM_ROOT/usr/share/bootloader/*.dtb; do
  dtb="$(basename ${all_dtb})"
    echo -n "Updating $dtb... "
    cp -p $SYSTEM_ROOT/usr/share/bootloader/$dtb $BOOT_ROOT &>/dev/null
    echo "done"
done

echo "UPDATE" > /storage/.boot.hint

# update bootloader

MYDEV=$(awk '/^Hardware/ {print $4}' /proc/cpuinfo)
case ${MYDEV} in
  RK35*)
    IDBSEEK="bs=512 seek=64"
  ;;
  *)
    IDBSEEK="bs=32k seek=1"
  ;;
esac

if [ -f $SYSTEM_ROOT/usr/share/bootloader/idbloader.img ]; then
  echo -n "Updating idbloader.img... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/idbloader.img of=$BOOT_DISK ${IDBSEEK} conv=fsync &>/dev/null
  echo "done"
fi

for BOOT_IMAGE in u-boot.itb u-boot.img
do
  if [ -f "$SYSTEM_ROOT/usr/share/bootloader/${BOOT_IMAGE}" ]; then
    echo "Updating ${BOOT_IMAGE}..."
    dd if=$SYSTEM_ROOT/usr/share/bootloader/${BOOT_IMAGE} of=$BOOT_DISK bs=512 seek=16384 conv=fsync &>/dev/null
    break
  fi
done

if [ -f $SYSTEM_ROOT/usr/share/bootloader/rk3399-uboot.bin ]; then
  echo -n "Updating uboot.bin... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/rk3399-uboot.bin of=$BOOT_DISK bs=512 seek=64 conv=fsync &>/dev/null
  echo "done"
fi

if [ -f $SYSTEM_ROOT/usr/share/bootloader/trust.img ]; then
  echo -n "Updating trust.img... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/trust.img of=$BOOT_DISK bs=512 seek=24576 conv=fsync &>/dev/null
  parted $BOOT_DISK name 2 trust &>/dev/null ||:
  echo "done"
elif [ -f $SYSTEM_ROOT/usr/share/bootloader/resource.img ]; then
  echo -n "Updating resource.img... "
  dd if=$SYSTEM_ROOT/usr/share/bootloader/resource.img of=$BOOT_DISK bs=512 seek=24576 conv=fsync &>/dev/null
  parted $BOOT_DISK name 2 resource &>/dev/null ||:
  echo "done"
fi

# mount $BOOT_ROOT r/o
  sync
  mount -o remount,ro $BOOT_ROOT &>/dev/null

sync
