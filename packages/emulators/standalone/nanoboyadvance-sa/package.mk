# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="nanoboyadvance-sa"
PKG_VERSION="3bb6f478f977dbfd3106508536e5fbce90d1898b"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/nba-emu/NanoBoyAdvance"
PKG_URL="${PKG_SITE}.git"
PKG_OPEN_SOURCE_BIOS="https://github.com/Nebuleon/ReGBA/raw/master/bios/gba_bios.bin"
PKG_DEPENDS_TARGET="toolchain SDL2 glew"
PKG_LONGDESC="NanoBoyAdvance is a cycle-accurate Game Boy Advance emulator."
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS+="${DEVICE}"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

PKG_CMAKE_OPTS_TARGET+=" -DPLATFORM_SDL2=ON \
                         -DPLATFORM_QT=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/sdl/NanoBoyAdvance ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/nanoboyadvance
  cp -rf ${PKG_DIR}/config/config.toml ${INSTALL}/usr/config/nanoboyadvance/
  cp -rf ${PKG_DIR}/config/${DEVICE}/keymap.toml ${INSTALL}/usr/config/nanoboyadvance/

  mkdir -p ${INSTALL}/usr/config/nanoboyadvance/bios
  curl -Lo ${INSTALL}/usr/config/nanoboyadvance/bios/gba_bios.bin ${PKG_OPEN_SOURCE_BIOS}
}
