# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="RTL8188FU-firmware"
PKG_VERSION="c8c95708b3756c67139c456a2a6576c1e6491d82"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kelebek333/rtl8188fu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Realtek RTL81xxFU Linux firmware"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware/rtlwifi
    cp firmware/rtl8188fufw.bin ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware/rtlwifi
}
