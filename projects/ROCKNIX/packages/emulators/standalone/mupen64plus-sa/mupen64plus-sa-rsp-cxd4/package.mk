# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-rsp-cxd4"
PKG_VERSION="f6ff3719cb68d3e1c1497fc87a661921671db719"
PKG_SHA256="01ecf1e584a132cfc69e367583db3a9de9b44fdf7fe10cd3e1d10c0cd88e171e"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-rsp-cxd4"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_DEPENDS_UNPACK="mupen64plus-sa-core"
PKG_LONGDESC="Mupen64Plus Standalone RSP CXD4"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-fpic"

case ${DEVICE} in
  RK3588|S922X|RK3399|RK3566*|SM4450|SM8250|SM8550|SM8650|SM8750|AMD64)
    PKG_DEPENDS_TARGET+=" mupen64plus-sa-simplecore"
    PKG_DEPENDS_UNPACK+=" mupen64plus-sa-simplecore"
    ;;
esac

case ${DEVICE} in
  SM4450|SM8250|SM8550|SM8650|SM8750|AMD64)
    PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
    export USE_GLES=0
    ;;
  *)
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
    export USE_GLES=1
    ;;
esac

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/projects/unix/Makefile
}

configure_target() {
  export HOST_CPU=${TARGET_ARCH} \
         NEW_DYNAREC=1 \
         VFP_HARD=1 \
         HLEVIDEO=1 \
         V=1 \
         VC=0 \
         OSD=0

  case ${TARGET_ARCH} in
    x86_64) export SUFFIX="-sse2" ;;
  esac

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export APIDIR=$(get_build_dir mupen64plus-sa-core)/src/api
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
}

make_target() {
  make -C projects/unix clean
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
  cp -a ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4${SUFFIX}.so ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-base.so

  case ${DEVICE} in
    RK3588|S922X|RK3399|RK3566*|SM4450|SM8250|SM8550|SM8650|SM8750)
      PKG_MAKE_OPTS_TARGET+=" cxd4VIDEO=1"
      export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
      make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
      cp -a ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4${SUFFIX}.so ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-simple.so
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib/mupen64plus
    install -m 0644  ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-base.so ${INSTALL}/usr/local/lib/mupen64plus/mupen64plus-rsp-cxd4.so
    if [ -e "${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-simple.so" ]; then
      install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-simple.so ${INSTALL}/usr/local/lib/mupen64plus
    fi
}

