# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dosbox-core-lr"
PKG_VERSION="7bcf083e8309660e2c598d6f7d5982d3851f2178"
PKG_SHA256="adf88f729b3240d9dc979cc41f0f111559663a86e5e3be200e8b0d36d166eb79"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/realnc/dosbox-core"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Upstream port of DOSBox to libretro"
PKG_BUILD_FLAGS="-lto"
PKG_TOOLCHAIN="make"

case ${TARGET_ARCH} in
  x86_64) BUILD_ARCH=amd64 ;;
  aarch64) BUILD_ARCH=arm64 ;;
esac

PKG_MAKE_OPTS_TARGET="-C libretro target=${BUILD_ARCH} platform=unix WITH_FAKE_SDL=1 STATIC_LIBCXX=0 \
                      WITH_DYNAREC=${BUILD_ARCH} WITH_FLUIDSYNTH=0 BUNDLED_AUDIO_CODECS=0 BUNDLED_GLIB=0 \
                      BUNDLED_LIBSNDFILE=0 WITH_PINHACK=0 WITH_VOODOO=0 WITH_BASSMIDI=0"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/libretro/dosbox_core_libretro.so ${INSTALL}/usr/lib/libretro
}
