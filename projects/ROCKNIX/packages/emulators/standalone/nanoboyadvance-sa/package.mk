# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="nanoboyadvance-sa"
PKG_VERSION="3bb6f478f977dbfd3106508536e5fbce90d1898b"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/nba-emu/NanoBoyAdvance"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 glew"
PKG_LONGDESC="NanoBoyAdvance is a cycle-accurate Game Boy Advance emulator."

PKG_OPEN_SOURCE_BIOS="https://github.com/Nebuleon/ReGBA/raw/master/bios/gba_bios.bin"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

PKG_CMAKE_OPTS_TARGET+=" -DPLATFORM_SDL2=ON \
                         -DPLATFORM_QT=OFF \
                         -DCMAKE_POLICY_VERSION_MINIMUM=3.5"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/bin/sdl/NanoBoyAdvance ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_nanoboyadvance.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/nanoboyadvance
    cp -a ${PKG_DIR}/config/config.toml ${INSTALL}/usr/config/nanoboyadvance
    cp -a ${PKG_DIR}/config/${DEVICE}/keymap.toml ${INSTALL}/usr/config/nanoboyadvance

  mkdir -p ${INSTALL}/usr/config/nanoboyadvance/bios
    curl -Lo ${INSTALL}/usr/config/nanoboyadvance/bios/gba_bios.bin ${PKG_OPEN_SOURCE_BIOS}
}
