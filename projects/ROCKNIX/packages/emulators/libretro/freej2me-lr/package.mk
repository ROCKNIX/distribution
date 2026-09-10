# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="freej2me-lr"
PKG_VERSION="1.52"
PKG_SHA256="509c3590827c8556cc0f8ff42c22693dd40e99e01e15f8f5c0e2e00bdbd8c130"
PKG_SITE="https://github.com/TASEmulators/freej2me-plus"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain apache-ant:host libXtst"
PKG_LONGDESC="J2ME emulator with libretro and AWT frontends, it aims to run on basically anything that can run a Java VM."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C src/libretro"

pre_configure_target() {
  ${TOOLCHAIN}/bin/ant
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/src/libretro/freej2me_libretro.so ${INSTALL}/usr/lib/libretro

  mkdir -p ${INSTALL}/usr/config/game/freej2me
    cp -a ${PKG_BUILD}/build/freej2me-lr.jar ${INSTALL}/usr/config/game/freej2me

  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/freej2me.sh ${INSTALL}/usr/bin
}
