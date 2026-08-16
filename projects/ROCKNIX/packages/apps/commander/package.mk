# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="commander"
PKG_VERSION="b3c008cac3bff9de54a3542cecc53cc271058744"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ROCKNIX/commander"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_gfx SDL2_ttf dejavu"
PKG_LONGDESC="A minimal SDL2 file manager for embedded Linux devices."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/commander ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/commander
    cp -a ${PKG_BUILD}/res ${INSTALL}/usr/share/commander
}
