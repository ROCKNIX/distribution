# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sndio"
PKG_VERSION="1.10.0"
PKG_LICENSE="GPLv3"
PKG_SITE="https://sndio.org/"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib"
PKG_LONGDESC="Sndio is a small audio and MIDI framework"
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="configure"

configure_target() {
  cd ${PKG_BUILD}
  ./configure \
    --prefix=/usr \
    --enable-static
}

make_target() {
  make
}

makeinstall_target() {
  make DESTDIR=${SYSROOT_PREFIX} install
}
