# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="slang-shaders"
PKG_VERSION="a02157c6ca60c982229af01ad706302761bf482c"
PKG_SHA256="d026bb7c86f67762cd3d4f33bf6dea8b48c5fa1ac3eb72d0850b2b75516d6abc"
PKG_LICENSE=""
PKG_SITE="https://github.com/libretro/slang-shaders"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="Common SLANG shaders for RetroArch"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/slang-shaders" -C "${PKG_BUILD}"
}
