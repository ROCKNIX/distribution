# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="dtbocfg"
PKG_VERSION="0.1.0"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/ikwzm/dtbocfg"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Device Tree Blob Overlay Configuration File System"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

make_target() {
  kernel_make KERNEL_SRC=$(kernel_path) -C ${PKG_BUILD} 
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp dtbocfg.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/
}
