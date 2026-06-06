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

# User must touch this file to opt-in to ROCKNIX ABL with direct boot
UPDATE_ABL="/storage/update.abl"

# Figure out UPDATE_DIR
[ -z "$UPDATE_DIR" ] && UPDATE_DIR="/storage/.update"
if ls -d ${UPDATE_DIR}/.tmp/avfs/*/target 1>/dev/null 2>/dev/null; then
  UPDATE_DIR=$(ls -d -1 "${UPDATE_DIR}"/.tmp/avfs/*/target 2>/dev/null | head -n 1)
elif ls -d ${UPDATE_DIR}/.tmp/*/target 1>/dev/null 2>/dev/null; then
  UPDATE_DIR=$(ls -d -1 "${UPDATE_DIR}"/.tmp/*/target 2>/dev/null | head -n 1)
elif ls -d ${UPDATE_DIR}/.tmp/mnt 1>/dev/null 2>/dev/null; then
  UPDATE_DIR=$(ls -d -1 "${UPDATE_DIR}"/.tmp/mnt 2>/dev/null | head -n 1)
fi

# Opt-in Workaround for sm8250 XBL/ABL bug: reformat BOOT partition each update
if [ -f $UPDATE_ABL -a -f $UPDATE_DIR/KERNEL ]; then

  # Backup ABLs if not already present
  if [ ! -f "/storage/backup/abl_a.img" ]; then
    echo "Backing up ABL A to /storage/backup ..."
    ABL_A="$($SYSTEM_ROOT/usr/sbin/blkid -t PARTLABEL=abl_a -o device)"
    mkdir -p /storage/backup
    dd if="${ABL_A}" of="/storage/backup/abl_a.img" bs=1M
  fi
  if [ ! -f "/storage/backup/abl_b.img" ]; then
    echo "Backing up ABL B to /storage/backup ..."
    ABL_B="$($SYSTEM_ROOT/usr/sbin/blkid -t PARTLABEL=abl_b -o device)"
    mkdir -p /storage/backup
    dd if="${ABL_B}" of="/storage/backup/abl_b.img" bs=1M
  fi

  # Update ABL
  . $SYSTEM_ROOT/usr/bin/updateabl

  # Go ahead and free up SYSTEM to avoid copying it to RAM
  umount /sysroot
  rm -f $BOOT_ROOT/SYSTEM $BOOT_ROOT/SYSTEM.md5

  echo "Copying Boot Files to RAM..."
  cp -a $BOOT_ROOT /run/flash
  umount $BOOT_ROOT
  echo "Updating Boot Files in RAM..."
  cp -a $UPDATE_DIR/. /run/flash/

  # Convert KERNEL to bootimg
  . $SYSTEM_ROOT/etc/os-release
  DISTRO_BOOTLABEL="ROCKNIX"
  DISTRO_DISKLABEL="STORAGE"
  # Get extra cmdline values from grub.cfg
  EXTRA_CMDLINE=$(sed -n '/^\s*linux\s/ { s/^\s*linux\s\+\S\+\s\+//; s/\<\(\(boot\|disk\)=\S*\|grub_portable\)\>\s*//g; p; q; }' "$SYSTEM_ROOT/usr/share/bootloader/boot/grub/grub.cfg")
  # Generate a patch level from the OS_VERSION
  PATCH_LEVEL="2026-05"
  if echo "$OS_VERSION" | grep -qE '^[0-9]{6}'; then
    PATCH_LEVEL="${OS_VERSION:0:4}-${OS_VERSION:4:2}"
  fi

  echo "Building bootimg KERNEL..."
  mkdir -p /run/mkbootimg
  gzip -c /run/flash/KERNEL > /run/mkbootimg/kernel.gz
  for dtb in $SYSTEM_ROOT/usr/share/bootloader/boot/grub/*.dtb; do
    if [ -f ${dtb} ]; then
      cat "$dtb" >> /run/mkbootimg/kernel.gz
    fi
  done

  echo -n "dummy" > /run/mkbootimg/ramdisk
  # Run python mkbootimg from inside the update path
  $SYSTEM_ROOT/lib/ld.so --library-path $SYSTEM_ROOT/usr/lib $SYSTEM_ROOT/usr/bin/python3 $SYSTEM_ROOT/usr/bin/mkbootimg/mkbootimg.py \
    --kernel /run/mkbootimg/kernel.gz --ramdisk /run/mkbootimg/ramdisk \
    --kernel_offset 0x00000000 --ramdisk_offset 0x00000000 --tags_offset 0x00000000 \
    --os_version 12.0.0 --os_patch_level "${PATCH_LEVEL}" --header_version 0 \
    --cmdline "boot=LABEL=${DISTRO_BOOTLABEL} disk=LABEL=${DISTRO_DISKLABEL} ${EXTRA_CMDLINE}" \
    -o /run/flash/KERNEL

  # md5 no longer accurate/needed
  rm -f /run/flash/KERNEL.md5

  echo "Reformatting Boot Partition..."
  UUID_SYSTEM=$(blkid $BOOT_PART -s UUID -o value)
  $SYSTEM_ROOT/usr/sbin/mkfs.vfat -F 32 -S 512 -s 32 -i "${UUID_SYSTEM//-/}" -n "${DISTRO_BOOTLABEL}" $BOOT_PART >/dev/null
  mount $BOOT_PART $BOOT_ROOT

  echo "Restoring KERNEL from RAM..."
  # Explicitly restore KERNEL first
  cp -a /run/flash/KERNEL $BOOT_ROOT/KERNEL
  rm -f /run/flash/KERNEL
  # Remove grub/dtbs from RAM as they aren't needed
  rm -rf /run/flash/EFI/
  rm -rf /run/flash/boot/
  # Copy the rest (use spinner as this will take a while)
  . /functions 2>/dev/null
  StartProgress spinner "Updating SYSTEM and restoring Boot Files from RAM... "
    cp -a /run/flash/. $BOOT_ROOT
    sync
  StopProgress "done"

  # Update was finished above, this skips further updates
  umount $BOOT_ROOT

else # Stick with stock/grub boot, update all necessary files as usual

if [ -d "$SYSTEM_ROOT/usr/share/bootloader/rocknix_abl" ]; then
  mkdir -p $BOOT_ROOT/rocknix_abl
  echo "Updating ROCKNIX ABL on SD..."
  cp $SYSTEM_ROOT/usr/share/bootloader/rocknix_abl/* $BOOT_ROOT/rocknix_abl
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/bootaa64.efi" ]; then
  if [ ! -f "$BOOT_ROOT/EFI/BOOT/bootaa64.efi" ]; then
    mkdir -p $BOOT_ROOT/EFI/BOOT
    echo "Installing GRUB..."
    cp $SYSTEM_ROOT/usr/share/bootloader/EFI/BOOT/bootaa64.efi $BOOT_ROOT/EFI/BOOT
  fi
fi

if [ -d "$SYSTEM_ROOT/usr/share/bootloader/boot/grub" ]; then
  mkdir -p $BOOT_ROOT/boot/grub
  echo "Updating grub dtbs..."
  cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/*.dtb $BOOT_ROOT/boot/grub
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/grub/grub.cfg" ]; then
  mkdir -p $BOOT_ROOT/boot/grub
  echo "Updating grub.cfg..."
  cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/grub.cfg $BOOT_ROOT/boot/grub
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/grub/dejavu-mono.pf2" ]; then
  mkdir -p $BOOT_ROOT/boot/grub
  echo "Updating dejavu-mono.pf2..."
  cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/dejavu-mono.pf2 $BOOT_ROOT/boot/grub
fi

if [ -f "$SYSTEM_ROOT/usr/share/bootloader/boot/grub/grubenv" ]; then
  if [ ! -f "$BOOT_ROOT/boot/grub/grubenv" ]; then
    mkdir -p $BOOT_ROOT/boot/grub
    echo "Installing grubenv..."
    cp $SYSTEM_ROOT/usr/share/bootloader/boot/grub/grubenv $BOOT_ROOT/boot/grub
  fi
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

fi

echo "UPDATE" > /storage/.boot.hint
