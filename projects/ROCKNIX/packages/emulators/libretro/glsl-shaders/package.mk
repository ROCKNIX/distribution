# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="glsl-shaders"
PKG_VERSION="4f4eb801b2dbcaed0a9669a9deec1a098f3623d8"
PKG_SHA256="2607e40d468e31ea5bb96e557db8dbbaada683afec189523a7b9d31ef57ed296"
PKG_LICENSE=""
PKG_SITE="https://github.com/libretro/glsl-shaders"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Common GSLS shaders for RetroArch"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/glsl-shaders" -C "${PKG_BUILD}"
}
