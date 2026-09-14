# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hypseus-singe"
PKG_VERSION="b353e1728bf56d8b6c6fb606df78b7296a203702"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/DirtBagXon/hypseus-singe"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf SDL2_image libmpeg2 libogg libvorbis libzip"
PKG_LONGDESC="Hypseus is a fork of Daphne. A program that lets one play the original versions of many laserdisc arcade games on one's PC."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET=" ./src"

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_hypseus.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/game/configs/hypseus
    cp -a ${PKG_BUILD}/doc/hypinput.ini ${INSTALL}/usr/config/game/configs/hypseus
    ln -fs /storage/roms/daphne/roms ${INSTALL}/usr/config/game/configs/hypseus/roms
    ln -fs /usr/share/daphne/sound ${INSTALL}/usr/config/game/configs/hypseus/sound
    ln -fs /usr/share/daphne/fonts ${INSTALL}/usr/config/game/configs/hypseus/fonts
    ln -fs /usr/share/daphne/pics ${INSTALL}/usr/config/game/configs/hypseus/pics

  mkdir -p ${INSTALL}/usr/share/daphne
    ln -fs /storage/.config/game/configs/hypseus/hypinput.ini ${INSTALL}/usr/share/daphne/hypinput.ini
}
