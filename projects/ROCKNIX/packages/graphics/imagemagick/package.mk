# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="imagemagick"
PKG_VERSION="04a04eaaa22f721f204c4bf4c6b24b08b1afe5c5" # 7.1.2-25
PKG_LICENSE="http://www.imagemagick.org/script/license.php"
PKG_SITE="https://github.com/ImageMagick/ImageMagick"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libpng libjpeg-turbo fontconfig libraw lcms2 libtool libxml2 libzip libwebp"
PKG_LONGDESC="Software suite to create, edit, compose, or convert bitmap images"

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" libXext pango"
fi

pre_configure_target() {
  PKG_CONFIGURE_OPTS_TARGET="--disable-openmp \
                             --disable-static \
                             --enable-shared \
                             --with-pango=no \
                             --with-utilities=yes \
                             --with-x=no"

  if [ "${DISPLAYSERVER}" = "wl" ]; then
    PKG_CONFIGURE_OPTS_TARGET+=" --with-x=yes"
  else
    PKG_CONFIGURE_OPTS_TARGET+=" --with-x=no"
  fi
  export LDFLAGS+=" -lsharpyuv -lwebp"
}

makeinstall_target() {
  make install DESTDIR=${INSTALL} ${PKG_MAKEINSTALL_OPTS_TARGET}
  rm ${INSTALL}/usr/bin/*config
}
