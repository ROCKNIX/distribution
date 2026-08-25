# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="drm_tool"
PKG_VERSION="1cb5b10b7d529105e33f27388519671ee7ce46f3"
PKG_SHA256="0813a8cf04091b171ffd8c89461f2774d10e13a06694224d205c7cffb0c7f536"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/NickCis/drm_tool"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_LONGDESC="A simple tool for getting drm info and setting properties."

pre_configure_target() {
  export CFLAGS="${TARGET_CFLAGS} -D_FILE_OFFSET_BITS=64 -ldrm"
  export LDFLAGS="${TARGET_LDFLAGS} -ldrm"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a drm_tool ${INSTALL}/usr/bin
}
