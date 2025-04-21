# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="RTL8188FU-firmware"
PKG_VERSION="68ced40d862d13663294496bac2e9a91ffa0e5c7"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kelebek333/rtl8188fu"
PKG_URL="https://github.com/kelebek333/rtl8188fu/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Realtek RTL81xxFU Linux firmware"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware/rtlwifi
  cp firmware/rtl8188fufw.bin ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware/rtlwifi
}
