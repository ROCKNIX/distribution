# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="u-boot"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader"

for PKG_SUBDEVICE in $SUBDEVICES; do
  PKG_DEPENDS_TARGET+=" u-boot-${PKG_SUBDEVICE}"
  PKG_NEED_UNPACK+=" $(get_pkg_directory u-boot-${PKG_SUBDEVICE}) ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"
done

make_target() {
  : # nothing
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

  # Always install the update script
  find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader

  if find_file_path bootloader/boot.ini; then
    cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    sed -e "s/@DISTRO_BOOTLABEL@/${DISTRO_BOOTLABEL}/" \
        -e "s/@DISTRO_DISKLABEL@/${DISTRO_DISKLABEL}/" \
        -e "s/@EXTRA_CMDLINE@/${EXTRA_CMDLINE}/" \
        -i "${INSTALL}/usr/share/bootloader/boot.ini"
  fi

  if find_dir_path bootloader/extlinux; then
    cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    sed -e "s/@DISTRO_BOOTLABEL@/${DISTRO_BOOTLABEL}/" \
        -e "s/@DISTRO_DISKLABEL@/${DISTRO_DISKLABEL}/" \
        -e "s/@EXTRA_CMDLINE@/${EXTRA_CMDLINE}/" \
        -i "${INSTALL}/usr/share/bootloader/extlinux/extlinux.conf"
  fi

  for PKG_SUBDEVICE in $SUBDEVICES; do
    unset PKG_UBOOTBIN
    if [ "${PKG_SUBDEVICE}" = "Odroid_GOU" ]; then
      PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/sd_fuse/u-boot.bin
      cp -av $(get_build_dir u-boot-${PKG_SUBDEVICE})/tools/odroid_resource/* ${INSTALL}/usr/share/bootloader
    else
      PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/u-boot.bin
    fi
    if [ ${PKG_UBOOTBIN} ]; then
      cp -av ${PKG_UBOOTBIN} $INSTALL/usr/share/bootloader/${PKG_SUBDEVICE}_u-boot
    fi
  done
}
