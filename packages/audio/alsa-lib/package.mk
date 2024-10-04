# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="alsa-lib"
PKG_VERSION="1.2.12"
PKG_LICENSE="GPL"
PKG_SITE="http://www.alsa-project.org/"
PKG_URL="https://www.alsa-project.org/files/pub/lib/alsa-lib-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain alsa-ucm-conf alsa-topology-conf"
PKG_LONGDESC="ALSA (Advanced Linux Sound Architecture) is the next generation Linux Sound API."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic"
PKG_PATCH_DIRS+=" ${DEVICE}"

if build_with_debug; then
  PKG_ALSA_DEBUG=--with-debug
else
  PKG_ALSA_DEBUG=--without-debug
fi

PKG_CONFIGURE_OPTS_TARGET+="${PKG_ALSA_DEBUG} \
                           --disable-dependency-tracking \
                           --with-plugindir=/usr/lib/alsa \
                           --disable-python"

post_configure_target() {
  sed -i 's/.*PKGLIBDIR.*/#define PKGLIBDIR ""/' include/config.h
}

