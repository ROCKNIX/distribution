# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 Nicholas Ricciuti (rishooty@gmail.com)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mupen64plus-sa-rsp-cxd4"
PKG_VERSION="f6ff3719cb68d3e1c1497fc87a661921671db719"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-rsp-cxd4"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_LONGDESC="mupen64plus-rsp-cxd4"
PKG_LONGDESC="Mupen64Plus Standalone RSP CXD4"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-fpic"

case ${DEVICE} in
  AMD64|RK3588|S922X|RK3399|RK3566*|SD865)
    PKG_DEPENDS_TARGET+=" mupen64plus-sa-simplecore"
  ;;
esac

case ${DEVICE} in
  AMD64|SD865)
    PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
    export USE_GLES=0
  ;;
  *)
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
    export USE_GLES=1
  ;;
esac

make_target() {

  export HOST_CPU=${TARGET_ARCH} \
         NEW_DYNAREC=1 \
         VFP_HARD=1 \
         HLEVIDEO=1 \
         V=1 \
         VC=0 \
         OSD=0

  case ${TARGET_ARCH} in
    x86_64)
      export SUFFIX="-sse2"
    ;;
  esac

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export APIDIR=$(get_build_dir mupen64plus-sa-core)/src/api
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"

  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/projects/unix/Makefile

  make -C projects/unix clean
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
  cp ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4${SUFFIX}.so ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-base.so

  case ${DEVICE} in
    AMD64|RK3588|S922X|RK3399|RK3566*|SD865)
      PKG_MAKE_OPTS_TARGET+=" cxd4VIDEO=1"
      export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
      make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
      cp ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4${SUFFIX}.so ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-simple.so
    ;;
  esac
}

makeinstall_target() {
  UPREFIX=${INSTALL}/usr/local
  ULIBDIR=${UPREFIX}/lib
  UPLUGINDIR=${ULIBDIR}/mupen64plus
  mkdir -p ${UPLUGINDIR}
  cp ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-base.so ${UPLUGINDIR}/mupen64plus-rsp-cxd4.so
  chmod 0644 ${UPLUGINDIR}/mupen64plus-rsp-cxd4.so

  if [ -e "${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-simple.so" ]
  then
    cp ${PKG_BUILD}/projects/unix/mupen64plus-rsp-cxd4-simple.so ${UPLUGINDIR}
    chmod 0644 ${UPLUGINDIR}/mupen64plus-rsp-cxd4-simple.so
  fi
}

