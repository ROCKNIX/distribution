# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 Nicholas Ricciuti (rishooty@gmail.com)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mupen64plus-sa-video-gliden64"
PKG_VERSION="85bdd452d7090f78a0f76d02121fa59ad079b7f6"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/gonetz/GLideN64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_LONGDESC="mupen64plus-video-gliden64"
PKG_LONGDESC="Mupen64Plus Standalone GLide64 Video Driver"
PKG_TOOLCHAIN="manual"

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
         V=1 \
         VC=0 \
         OSD=0

  case ${TARGET_ARCH} in
    arm|aarch64)
      PKG_MAKE_OPTS_TARGET+="-DNOHQ=On -DCRC_ARMV8=On -DEGL=On -DNEON_OPT=On"
    ;;
  esac

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export APIDIR=$(get_build_dir mupen64plus-sa-core)/src/api
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"

  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/src/CMakeLists.txt

  ./src/getRevision.sh
  cmake ${PKG_MAKE_OPTS_TARGET} -DAPIDIR=${APIDIR} -DMUPENPLUSAPI=On -DGLIDEN64_BUILD_TYPE=Release -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS} -pthread" -S src -B projects/cmake
  make clean -C projects/cmake
  make -Wno-unused-variable -C projects/cmake
  cp ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-base.so

  export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
  cmake ${PKG_MAKE_OPTS_TARGET} -DAPIDIR=${APIDIR} -DMUPENPLUSAPI=On -DGLIDEN64_BUILD_TYPE=Release -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS} -pthread" -S src -B projects/cmake
  make -Wno-unused-variable -C projects/cmake
  cp ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-simple.so
}

makeinstall_target() {
  UPREFIX=${INSTALL}/usr/local
  ULIBDIR=${UPREFIX}/lib
  USHAREDIR=${UPREFIX}/share/mupen64plus
  UPLUGINDIR=${ULIBDIR}/mupen64plus
  mkdir -p ${UPLUGINDIR}
  cp ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-base.so ${UPLUGINDIR}/mupen64plus-video-GLideN64.so
  chmod 0644 ${UPLUGINDIR}/mupen64plus-video-GLideN64.so

  cp ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-simple.so ${UPLUGINDIR} 
  chmod 0644 ${UPLUGINDIR}/mupen64plus-video-GLideN64-simple.so

  mkdir -p ${USHAREDIR}
  cp ${PKG_BUILD}/ini/GLideN64.ini ${USHAREDIR}
  chmod 0644 ${USHAREDIR}/GLideN64.ini
}
