# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

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
