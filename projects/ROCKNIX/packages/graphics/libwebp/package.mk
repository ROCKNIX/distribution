# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="libwebp"
PKG_VERSION="1.6.0"
PKG_SHA256="93a852c2b3efafee3723efd4636de855b46f9fe1efddd607e1f42f60fc8f2136"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/webmproject/libwebp"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="WebP codec is a library to encode and decode images in WebP format."
PKG_TOOLCHAIN="cmake"
PKG_CMAKE_OPTS_TARGET="-DWEBP_BUILD_ANIM_UTILS=OFF \
                        -DWEBP_BUILD_CWEBP=OFF \
                        -DWEBP_BUILD_DWEBP=OFF \
                        -DWEBP_BUILD_GIF2WEBP=OFF \
                        -DWEBP_BUILD_IMG2WEBP=OFF \
                        -DWEBP_BUILD_VWEBP=OFF \
                        -DWEBP_BUILD_WEBPINFO=OFF \
                        -DWEBP_BUILD_WEBPMUX=OFF \
                        -DWEBP_BUILD_EXTRAS=OFF \
                        -DBUILD_SHARED_LIBS=ON"
