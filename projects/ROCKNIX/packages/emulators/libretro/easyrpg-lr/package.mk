# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="easyrpg-lr"
PKG_VERSION="212f3466c9f276ff7cade5a5ead78d3a151343ac"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/easyrpg/player"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain zlib libfmt liblcf icu pixman libspeexdsp mpg123 libsndfile libvorbis opusfile wildmidi libxmp-lite fluidsynth harfbuzz libpng retroarch inih"
PKG_LONGDESC="An unofficial libretro port of the EasyRPG/Player."
PKG_BUILD_FLAGS="+pic"

PKG_CMAKE_OPTS_TARGET+=" -DPLAYER_TARGET_PLATFORM=libretro \
                         -DBUILD_SHARED_LIBS=ON"

pre_make_target() {
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/easyrpg_libretro.so ${INSTALL}/usr/lib/libretro

  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}
