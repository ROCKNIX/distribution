# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="glsl-shaders"
PKG_VERSION="cba01a48b0974a1232bea68d999a7c21bc4c233e"
PKG_SHA256="e50f298219f442efa07ca2a3ca27639884b7b14bf0098c7aa7cc5a9bc7307338"
PKG_LICENSE=""
PKG_SITE="https://github.com/libretro/glsl-shaders"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Common GSLS shaders for RetroArch"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/glsl-shaders" -C "${PKG_BUILD}"
}
