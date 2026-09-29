# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libpsl"
PKG_VERSION="0.23.3"
PKG_SHA256="93941f85a1e7bd593fa94f299233cb5dfc91cd144fd9a78a6ceb75001c5b03be"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/rockdaboot/libpsl"
PKG_URL="https://github.com/rockdaboot/libpsl/releases/download/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain icu"
PKG_LONGDESC="Public Suffix List library, used by libsoup to scope cookies to registrable domains."

pre_configure_target() {
  # ICU rather than libidn2: it is already in the tree and in the image,
  # and libidn2 would drag in libunistring, which is not.
  PKG_MESON_OPTS_TARGET="-Druntime=libicu \
                         -Dbuiltin=true \
                         -Ddocs=false \
                         -Dtests=false"
}
