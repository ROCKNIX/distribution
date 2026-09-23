# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-video-rice"
PKG_VERSION="470865c6c64bdb44645faa88eae59cd87ce561b6"
PKG_SHA256="baa1fc034cc27d6c178d014794f8171817b9c96db5317feaede0d0d22e898676"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-video-rice"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_DEPENDS_UNPACK="mupen64plus-sa-core"
PKG_LONGDESC="Mupen64Plus Standalone Rice Video Driver"
PKG_TOOLCHAIN="manual"

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
  cp -a ${PKG_BUILD}/projects/unix/mupen64plus-video-rice.so ${PKG_BUILD}/projects/unix/mupen64plus-video-rice-base.so

  case ${DEVICE} in
    RK3588|S922X|RK3399|RK3566*|SM4450|SM8250|SM8550|SM8650|SM8750|AMD64)
      export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
      make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
      cp -a ${PKG_BUILD}/projects/unix/mupen64plus-video-rice.so ${PKG_BUILD}/projects/unix/mupen64plus-video-rice-simple.so
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib/mupen64plus
    install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-video-rice-base.so ${INSTALL}/usr/local/lib/mupen64plus/mupen64plus-video-rice.so
    if [ -e "${PKG_BUILD}/projects/unix/mupen64plus-video-rice-simple.so" ]; then
      install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-video-rice-simple.so ${INSTALL}/usr/local/lib/mupen64plus
    fi

  mkdir -p ${INSTALL}/usr/local/share/mupen64plus
    cp -a ${PKG_BUILD}/data/RiceVideoLinux.ini ${INSTALL}/usr/local/share/mupen64plus
}
