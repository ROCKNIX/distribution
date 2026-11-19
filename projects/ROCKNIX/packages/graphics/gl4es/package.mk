# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gl4es"
PKG_VERSION="81547d986798e876de8b434193920b606a72363f"
PKG_SHA256="475c30409fd64a649352487d0df0dc3f8ef200ea5c54b7de5f61d099948877ed"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ptitSeb/gl4es"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="GL4ES - OpenGL for GLES Hardware"
PKG_TOOLCHAIN="cmake"

configure_package() {
  PKG_CMAKE_OPTS_TARGET="-DODROID=1 -DNOX11=1 -DNOEGL=1"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/gl4es
  cp -rf ${PKG_BUILD}/lib/* ${INSTALL}/usr/lib/gl4es
}
