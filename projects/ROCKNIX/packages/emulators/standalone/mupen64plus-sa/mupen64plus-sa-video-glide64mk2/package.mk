# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-video-glide64mk2"
PKG_VERSION="992b5942078fe77987e8c40bcd396f44be19be2b"
PKG_SHA256="192ae40ac12c1dc38c336748e68679c4393ebc02caa1f0530ba21f1a7024ccdf"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-video-glide64mk2"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_DEPENDS_UNPACK="mupen64plus-sa-core"
PKG_LONGDESC="Mupen64Plus Standalone Glide64 Video Driver"
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
  cp -a ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2.so ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-base.so

  case ${DEVICE} in
    RK3588|S922X|RK3399|RK3566*|SM4450|SM8250|SM8550|SM8650|SM8750|AMD64)
      export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
      make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
      cp ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2.so ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-simple.so
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib/mupen64plus
    install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-base.so ${INSTALL}/usr/local/lib/mupen64plus/mupen64plus-video-glide64mk2.so
    if [ -e "${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-simple.so" ]; then
      install -m 0644 ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-simple.so ${INSTALL}/usr/local/lib/mupen64plus
    fi

  mkdir -p ${INSTALL}/usr/local/share/mupen64plus
    cp -a ${PKG_BUILD}/data/Glide64mk2.ini ${INSTALL}/usr/local/share/mupen64plus
}
