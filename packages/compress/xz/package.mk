# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="xz"
PKG_VERSION="5.4.4"
PKG_LICENSE="GPL"
PKG_SHA512="2b233a924b82190ff15e970c5a4a59f1c53a0b39a96bde228c9dfc9b103b4a3e5888f5024da4834e180f6010620ff23caf9f7135a38724eb2c8d01bff7a9a9e1"
PKG_SITE="https://src.fedoraproject.org/repo/pkgs/xz/"
PKG_URL="https://src.fedoraproject.org/repo/pkgs/xz/${PKG_NAME}-${PKG_VERSION}.tar.xz/sha512/${PKG_SHA512}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A free general-purpose data compression software with high compression ratio."
PKG_BUILD_FLAGS="+pic +pic:host"
PKG_TOOLCHAIN="configure"

# never build shared or k0p happens when building
# on fedora due to host selinux/liblzma
PKG_CONFIGURE_OPTS_HOST="--disable-shared --enable-static \
                         --disable-lzmadec \
                         --disable-lzmainfo \
                         --enable-lzma-links \
                         --disable-nls \
                         --disable-scripts \
                         --enable-symbol-versions=no"

PKG_CONFIGURE_OPTS_TARGET="--enable-shared \
                          --disable-static \
                          --enable-symbol-versions=yes"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
