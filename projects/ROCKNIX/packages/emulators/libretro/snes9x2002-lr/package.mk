# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="snes9x2002-lr"
PKG_VERSION="5bd8bd6d449be8a2ef7909e1aeb2bd8c9c0da8cb"
PKG_SHA256="747d4fdbfcb5a1a846f787d097e77f0c786ba4f166b1480b1c7e3dfb923b7249"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/snes9x2002"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Snes9x 2002."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a snes9x2002_libretro.so ${INSTALL}/usr/lib/libretro
}
