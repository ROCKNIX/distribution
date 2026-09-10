# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="play-lr"
PKG_VERSION="04bde0df87ee7c0e2f0151b51bb2cc22c88541da"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/jpd002/Play-"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libevdev zstd"
PKG_LONGDESC="Play! is an attempt to create a PlayStation 2 emulator for Windows, macOS, UNIX, Android & iOS platforms."

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

case ${TARGET_ARCH} in
  aarch64)
    PKG_CMAKE_OPTS_TARGET+=" -DUSE_GLEW=off \
                             -DUSE_GLES=on
                             -DTARGET_PLATFORM_UNIX_AARCH64=yes"
    ;;
esac

PKG_CMAKE_OPTS_TARGET+=" -DBUILD_LIBRETRO_CORE=yes \
                         -DBUILD_PLAY=off \
                         -DBUILD_TESTS=no \
                         -DENABLE_AMAZON_S3=no \
                         -DCMAKE_BUILD_TYPE=Release"

post_unpack() {
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a Source/ui_libretro/play_libretro.so ${INSTALL}/usr/lib/libretro
}
