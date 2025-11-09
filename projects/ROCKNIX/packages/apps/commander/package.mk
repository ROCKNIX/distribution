# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="commander"
PKG_VERSION="a6ef30eb3bd6ef80a031744aae0f5b9cd974c182"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/od-contrib/commander"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_gfx SDL2_ttf dejavu"
PKG_LONGDESC="A minimal SDL2 file manager for embedded Linux devices."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                         -DWITH_SYSTEM_SDL_TTF=ON \
                         -DWITH_SYSTEM_SDL_GFX=ON \
                         -DAUTOSCALE=0 \
                         -DAUTOSCALE_DPI=0 \
                         -DPPU_X=2 \
                         -DPPU_Y=2 \
                         -DCMDR_GAMEPAD_OPEN=ControllerButton::A \
                         -DCMDR_GAMEPAD_PARENT=ControllerButton::B"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/commander

  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/commander ${INSTALL}/usr/bin/
  cp -rf ${PKG_BUILD}/res ${INSTALL}/usr/share/commander/res

  chmod 0755 ${INSTALL}/usr/bin/commander
}
