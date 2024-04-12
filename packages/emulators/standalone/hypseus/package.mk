# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="hypseus"
PKG_VERSION="3f7c4cbad8e36c3babf230321de9e67dee100767"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/btolab/hypseus"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf SDL2_image zlib libogg libvorbis libmpeg2"
PKG_LONGDESC="Hypseus is a fork of Daphne. A program that lets one play the original versions of many laserdisc arcade games on one's PC."
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET=" ./src"

pre_configure_target() {
  mkdir -p ${INSTALL}/usr/config/game/configs/hypseus
  ln -fs /storage/roms/daphne/roms ${INSTALL}/usr/config/game/configs/hypseus/roms
  ln -fs /storage/roms/daphne/sound ${INSTALL}/usr/config/game/configs/hypseus/sound
  ln -fs /usr/share/daphne/fonts ${INSTALL}/usr/config/game/configs/hypseus/fonts
  ln -fs /usr/share/daphne/pics ${INSTALL}/usr/config/game/configs/hypseus/pics
  cp -a ${PKG_DIR}/config/*           ${INSTALL}/usr/config/hypseus
  cp ${PKG_BUILD}/doc/hypinput.ini ${INSTALL}/usr/config/game/configs/hypseus/
}

post_makeinstall_target() {
  ln -fs /storage/.config/game/configs/hypseus/hypinput.ini ${INSTALL}/usr/share/daphne/hypinput.ini
}
