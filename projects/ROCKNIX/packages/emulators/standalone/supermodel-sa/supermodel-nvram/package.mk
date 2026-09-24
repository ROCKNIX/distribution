# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="supermodel-nvram"
PKG_VERSION="062f01a880283fb983e3f997e78eb9adcc0766fd"
PKG_SHA256="0a90240869a14833a6966ae72f8a44475e96ac6ff673f48ed2bc2ef2cf666315"
PKG_LICENSE="GPL-3.0"
PKG_SITE="https://github.com/batocera-linux/batocera.linux"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Single-cabinet Supermodel NVRAM presets from Batocera, used with permission"
PKG_TOOLCHAIN="manual"

unpack() {
  # The presets are 2 MB of Batocera's tree, so extract only them
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD} \
    --wildcards '*/package/batocera/emulators/supermodel/NVRAM/*.nv'
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/supermodel/NVRAM
    cp -a ${PKG_BUILD}/package/batocera/emulators/supermodel/NVRAM/*.nv ${INSTALL}/usr/config/supermodel/NVRAM
}
