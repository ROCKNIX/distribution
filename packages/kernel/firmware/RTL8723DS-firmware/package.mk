# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="RTL8723DS-firmware"
PKG_VERSION=""
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://rocknix.org"
PKG_LONGDESC="Realtek RTL8723DS Linux firmware"
PKG_DEPENDS_TARGET="linux rtk_hciattach"
PKG_TOOLCHAIN="manual"

make_target() {
  : 
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir) ||:
  cp -v ${PKG_DIR}/firmware/rtl8723ds_fw ${INSTALL}/$(get_full_firmware_dir)/rtl8723d_fw
  cp -v ${PKG_DIR}/firmware/rtl8723ds_config ${INSTALL}/$(get_full_firmware_dir)/rtl8723d_config
}

