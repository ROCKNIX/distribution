# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ares-sa"
PKG_VERSION="f533120df6506390635a99ad58495834a69036e0" #v147
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ares-emulator/ares"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Ares is a multi-system emulator. It is a descendant of higan and bsnes, and focuses on accuracy and preservation."
PKG_DEPENDS_TARGET="toolchain librashader SDL2 ares-sa:host"
PKG_TOOLCHAIN="cmake"

pre_configure_host() {
  PKG_CMAKE_OPTS_HOST+=" -DCMAKE_BUILD_TYPE=Release \
                         -DBUILD_SHARED_LIBS=FALSE \
                         -DWITH_SYSTEM_ZLIB=ON \
                         -DARES_BUILD_LOCAL=OFF \
                         -DARES_ENABLE_MINIMUM_CPU=OFF \
                         -DARES_BUILD_SOURCERY_ONLY=ON \
                         -DCMAKE_CROSSCOMPILING=OFF \
                         -DARES_CROSSCOMPILING=OFF"
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
  cp ${PKG_BUILD}/.${HOST_NAME}/tools/sourcery/sourcery ${TOOLCHAIN}/bin
  chmod +x ${TOOLCHAIN}/bin/sourcery
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DBUILD_SHARED_LIBS=FALSE \
                           -DWITH_SYSTEM_ZLIB=ON \
                           -DARES_BUILD_LOCAL=OFF \
                           -DARES_ENABLE_MINIMUM_CPU=OFF"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/ares
  mkdir -p ${INSTALL}/usr/config/ares

  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/desktop-ui/ares ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/rundir/share/ares/Database ${INSTALL}/usr/share/ares/
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/ares
}
