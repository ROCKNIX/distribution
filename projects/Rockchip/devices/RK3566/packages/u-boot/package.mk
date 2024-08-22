# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

for PKG_SUBDEVICE in ${SUBDEVICES}; do
  PKG_DEPENDS_TARGET+=" u-boot-${PKG_SUBDEVICE}"
  PKG_NEED_UNPACK+=" $(get_pkg_directory u-boot-${PKG_SUBDEVICE})"
done

make_target() {
  : # nothing
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

  # Always install the update script
  find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader

  for PKG_SUBDEVICE in $SUBDEVICES; do
    unset PKG_IDBLOADER PKG_UBOOTIDB
    PKG_IDBLOADER=$(get_build_dir u-boot-${PKG_SUBDEVICE})/idbloader.img
    PKG_UBOOTITB=$(get_build_dir u-boot-${PKG_SUBDEVICE})/u-boot.itb
    if [ ${PKG_IDBLOADER} ]; then
      cp -av ${PKG_IDBLOADER} $INSTALL/usr/share/bootloader/${PKG_SUBDEVICE}_idbloader.img
    fi
    if [ ${PKG_UBOOTITB} ]; then
      cp -av ${PKG_UBOOTITB} $INSTALL/usr/share/bootloader/${PKG_SUBDEVICE}_u-boot.itb
    fi
  done
}
