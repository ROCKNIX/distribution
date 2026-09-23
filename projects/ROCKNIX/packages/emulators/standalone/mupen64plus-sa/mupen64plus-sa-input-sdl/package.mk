# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-input-sdl"
PKG_VERSION="3698a2b12b1dc536801649de2705b4a79ffb8a08"
PKG_SHA256="9a2f2b2a0dbb7bdd32f26495d9614d19a0fc215ffaefeb11bef167d7e7b006c9"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-input-sdl"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_DEPENDS_UNPACK="mupen64plus-sa-core"
PKG_LONGDESC="Mupen64Plus Standalone Input SDL"
PKG_TOOLCHAIN="manual"

case ${DEVICE} in
  RK3588|S922X|RK3399|RK3566*|SM4450|SM8250|SM8550|SM8650|SM8750|AMD64)
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
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
  export APIDIR=$(get_build_dir mupen64plus-sa-core)/src/api
}

make_target() {
  make -C projects/unix clean
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
  cp -a ${PKG_BUILD}/projects/unix/mupen64plus-input-sdl.so ${PKG_BUILD}/projects/unix/mupen64plus-input-sdl-base.so

  case ${DEVICE} in
    RK3588|S922X|RK3399|RK3566*|SM4450|SM8250|SM8550|SM8650|SM8750|AMD64)
      export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
      make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
      cp -a ${PKG_BUILD}/projects/unix/mupen64plus-input-sdl.so ${PKG_BUILD}/projects/unix/mupen64plus-input-sdl-simple.so
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib/mupen64plus
    install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-input-sdl-base.so ${INSTALL}/usr/local/lib/mupen64plus/mupen64plus-input-sdl.so
    if [ -e "${PKG_BUILD}/projects/unix/mupen64plus-input-sdl-simple.so" ]; then
      install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-input-sdl-simple.so ${INSTALL}/usr/local/lib/mupen64plus
    fi

  mkdir -p ${INSTALL}/usr/local/share/mupen64plus
    cp -a ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/local/share/mupen64plus
}
