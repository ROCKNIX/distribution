# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mediainfo"
PKG_VERSION="25.07"
PKG_SHA256="508eac1ca097f41cb3fc39625aceb0652fcab00acd0f2ebcbd1dc6800936e97d"
PKG_LICENSE="GPL"
PKG_SITE="https://mediaarea.net/en/MediaInfo/Download/Source"
PKG_URL="https://mediaarea.net/download/source/mediainfo/${PKG_VERSION}/mediainfo_${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libmediainfo"
PKG_DEPENDS_CONFIG="libzen libmediainfo"
PKG_LONGDESC="A convenient unified display of the most relevant technical and tag data for video and audio files."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-sysroot"

configure_target() {
  cd Project/GNU/CLI
  do_autoreconf
  ./configure \
        --host=${TARGET_NAME} \
        --build=${HOST_NAME} \
        --prefix=/usr
}

make_target() {
  make
}

makeinstall_target() {
  make install DESTDIR=${INSTALL}
}
