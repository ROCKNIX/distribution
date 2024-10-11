# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 Nicholas Ricciuti (rishooty@gmail.com)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mupen64plus-sa-simplecore"
PKG_VERSION="5340dafcc0f5e8284057ab931dd5c66222d3d49e"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/simple64/mupen64plus-core"
PKG_URL="https://github.com/simple64/mupen64plus-core/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_LONGDESC="simple64"
PKG_LONGDESC="Simple64's core"
PKG_TOOLCHAIN="manual"
PKG_GIT_CLONE_BRANCH="simple64"

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
#  export TARGET_CLFAGS="${TARGET_CFLAGS} -Wno-implicit-function-declaration -Wno-error=incompatible-pointer-types"
#  export TARGET_CXXLFAGS="${TARGET_CXXFLAGS} -Wno-implicit-function-declaration -Wno-error=incompatible-pointer-types"
  case ${ARCH} in
    arm|aarch64)
      export HOST_CPU=aarch64
      ARM="-DARM=1"
    ;;
    x86_64)
      export HOST_CPU=x86_64
      unset ARM
    ;;
  esac

  # Always diable Vulkan
  export VULKAN=0

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export NEW_DYNAREC=1
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"

  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/projects/unix/Makefile

  make -C projects/unix clean
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib
  cp ${PKG_BUILD}/projects/unix/libsimple64.so.2.0.0 ${INSTALL}/usr/local/lib/libsimple64.so.2
  chmod 644 ${INSTALL}/usr/local/lib/libsimple64.so.2
}
