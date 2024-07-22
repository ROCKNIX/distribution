# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="textviewer"
PKG_VERSION="fcbda2d1708e9e2c650abc589ea8e7f1fe1d04d8"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ROCKNIX/TvTextViewer"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Full-screen text viewer tool with gamepad controls"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_configure_target() {
  sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" Makefile
}

makeinstall_target(){
  mkdir -p ${INSTALL}/usr/bin
  cp text_viewer ${INSTALL}/usr/bin
}
