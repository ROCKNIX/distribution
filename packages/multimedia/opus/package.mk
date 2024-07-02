# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="opus"
PKG_VERSION="1.5.2"
PKG_SHA256="65c1d2f78b9f2fb20082c38cbe47c951ad5839345876e46941612ee87f9a7ce1"
PKG_LICENSE="BSD"
PKG_SITE="http://www.opus-codec.org"
PKG_URL="https://downloads.xiph.org/releases/opus/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Codec designed for interactive speech and audio transmission over the Internet."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="+pic"

#if [ "${TARGET_ARCH}" = "arm" ]; then
  PKG_FIXED_POINT="--enable-fixed-point"
#else
#  PKG_FIXED_POINT="--disable-fixed-point"
#fi

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_SHARED_LIBRARY="--enable-shared"
else
  PKG_SHARED_LIBRARY="--disable-shared"
fi

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           $PKG_SHARED_LIBRARY \
                           $PKG_FIXED_POINT"
