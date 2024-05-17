# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 Nicholas Ricciuti (rishooty@gmail.com)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mupen64plus-sa-simplecore"
PKG_VERSION="6867e510d03ce91e67baf54116c1447033d12066"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/simple64/mupen64plus-core"
PKG_URL="https://github.com/simple64/mupen64plus-core/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_LONGDESC="simple64"
PKG_LONGDESC="Simple64's core"
PKG_TOOLCHAIN="manual"
PKG_GIT_CLONE_BRANCH="simple64"

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  export GLES="USE_GLES=0"
fi

make_target() {
  case ${ARCH} in
    arm|aarch64)
      export HOST_CPU=aarch64
      sed -i 's/x86-64-v3/armv8-a/g' ${PKG_BUILD}/CMakeLists.txt
      ARM="-DARM=1"
    ;;
    x86_64)
      export HOST_CPU=x86_64
      unset ARM
    ;;
  esac

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export NEW_DYNAREC=1
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
  cd ${PKG_BUILD}
  sed -i 's~<SDL_net.h>~<SDL2/SDL_net.h>~g' src/main/netplay.c
  rm -rf build
  mkdir build
  cd build
  cmake -G Ninja ${ARM} -DCMAKE_FIND_ROOT_PATH="${SYSROOT_PREFIX}" -DCMAKE_BUILD_TYPE="Release" ..
  VERBOSE=1 cmake --build .
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib
  cp ${PKG_BUILD}/build/libmupen64plus.so ${INSTALL}/usr/local/lib/libsimple64.so.2
  chmod 644 ${INSTALL}/usr/local/lib/libsimple64.so.2
}
