# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-rsp-hle"
PKG_VERSION="9d13986f764b14bb4fb8eaa5846ff8be5a9fa4f6"
PKG_SHA256="c52973bf4118031372e541257921001441af0b4016ce687fe6d94f4ac02f4678"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-rsp-hle"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_DEPENDS_UNPACK="mupen64plus-sa-core"
PKG_LONGDESC="Mupen64Plus Standalone RSP HLE"
PKG_TOOLCHAIN="manual"

case ${DEVICE} in
  RK3588|S922X|RK3399|RK3566*)
    PKG_DEPENDS_TARGET+=" mupen64plus-sa-simplecore"
    PKG_DEPENDS_UNPACK+=" mupen64plus-sa-simplecore"
    ;;
esac

case ${DEVICE} in
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
         V=1 \
         VC=0 \
         OSD=0

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export APIDIR=$(get_build_dir mupen64plus-sa-core)/src/api
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
}

make_target() {
  make -C projects/unix clean
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
  cp -a ${PKG_BUILD}/projects/unix/mupen64plus-rsp-hle.so ${PKG_BUILD}/projects/unix/mupen64plus-rsp-hle-base.so

  case ${DEVICE} in
    RK3588|S922X|RK3399|RK3566*)
      export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
      make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
      cp -a ${PKG_BUILD}/projects/unix/mupen64plus-rsp-hle.so ${PKG_BUILD}/projects/unix/mupen64plus-rsp-hle-simple.so
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib/mupen64plus
    install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-rsp-hle-base.so ${INSTALL}/usr/local/lib/mupen64plus/mupen64plus-rsp-hle.so
    if [ -e "${PKG_BUILD}/projects/unix/mupen64plus-rsp-hle-simple.so" ]; then
      install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-rsp-hle-simple.so ${INSTALL}/usr/local/lib/mupen64plus
    fi
}
