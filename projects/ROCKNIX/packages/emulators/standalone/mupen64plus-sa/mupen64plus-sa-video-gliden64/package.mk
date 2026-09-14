# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-video-gliden64"
PKG_VERSION="85bdd452d7090f78a0f76d02121fa59ad079b7f6"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/gonetz/GLideN64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_DEPENDS_UNPACK="mupen64plus-sa-core"
PKG_LONGDESC="Mupen64Plus Standalone GLide64 Video Driver"
PKG_TOOLCHAIN="manual"

case ${DEVICE} in
  RK3588|S922X|RK3399|RK3566*|SM4450|SM8250|SM8550|SM8650|SM8750|AMD64)
    PKG_DEPENDS_TARGET+=" mupen64plus-sa-simplecore"
    PKG_DEPENDS_UNPACK+=" mupen64plus-sa-simplecore"
    ;;
esac

case ${DEVICE} in
  SM4450|SM8250|SM8550|SM8650|SM8750)
    PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
    export USE_GLES=0
    ;;
  *)
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
    export USE_GLES=1
    ;;
esac

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/src/CMakeLists.txt
  sed -i '/#ifndef TXHIRESLOADER_H/a #include <cstdint>' ${PKG_BUILD}/src/GLideNHQ/TxHiResLoader.h
}

configure_target() {
  export HOST_CPU=${TARGET_ARCH} \
         NEW_DYNAREC=1 \
         VFP_HARD=1 \
         V=1 \
         VC=0 \
         OSD=0

  case ${TARGET_ARCH} in
    arm|aarch64) PKG_MAKE_OPTS_TARGET+="-DNOHQ=On -DCRC_ARMV8=On -DEGL=On -DNEON_OPT=On" ;;
  esac

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export APIDIR=$(get_build_dir mupen64plus-sa-core)/src/api
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
}

make_target() {
  ./src/getRevision.sh
  cmake ${PKG_MAKE_OPTS_TARGET} -DAPIDIR=${APIDIR} -DMUPENPLUSAPI=On -DGLIDEN64_BUILD_TYPE=Release -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS} -pthread" -S src -B projects/cmake
  make clean -C projects/cmake
  make -Wno-unused-variable -C projects/cmake
  cp -a ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-base.so

  export APIDIR=$(get_build_dir mupen64plus-sa-simplecore)/src/api
  cmake ${PKG_MAKE_OPTS_TARGET} -DAPIDIR=${APIDIR} -DMUPENPLUSAPI=On -DGLIDEN64_BUILD_TYPE=Release -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS} -pthread" -S src -B projects/cmake
  make -Wno-unused-variable -C projects/cmake
  cp -a ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-simple.so
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib/mupen64plus
    install -m 0644 ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-base.so ${INSTALL}/usr/local/lib/mupen64plus/mupen64plus-video-GLideN64.so
    install -m 0644 ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64-simple.so ${INSTALL}/usr/local/lib/mupen64plus

  mkdir -p ${INSTALL}/usr/local/share/mupen64plus
    cp -a ${PKG_BUILD}/ini/GLideN64.ini ${INSTALL}/usr/local/share/mupen64plus
}
