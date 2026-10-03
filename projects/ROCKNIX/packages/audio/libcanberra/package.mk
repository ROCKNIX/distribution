# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libcanberra"
PKG_VERSION="0.30"
PKG_SHA256="c2b671e67e0c288a69fc33dc1b6f1b534d07882c2aceed37004bf48c601afa72"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://0pointer.de/lennart/projects/libcanberra/"
PKG_URL="https://0pointer.de/lennart/projects/libcanberra/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libtool libvorbis alsa-lib pulseaudio"
PKG_LONGDESC="Portable XDG sound event library"
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--enable-alsa \
                           --enable-pulse \
                           --disable-oss \
                           --disable-gstreamer \
                           --disable-null \
                           --disable-gtk \
                           --disable-gtk3 \
                           --disable-tdb \
                           --disable-udev \
                           --disable-lynx"

PKG_MAKEINSTALL_OPTS_TARGET="-j1"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/share/vala
}
