# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-simplecore"
PKG_VERSION="5340dafcc0f5e8284057ab931dd5c66222d3d49e"
PKG_SHA256="04a3b14a82182b8f54f88b52585e27b91d37335f87393537332ce94c28037f6b"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/simple64/mupen64plus-core"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_LONGDESC="Mupen64Plus Standalone Simple Core"
PKG_TOOLCHAIN="manual"

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
  PKG_MAKE_OPTS_TARGET+=" VULKAN=0"

  export BINUTILS="$(get_build_dir binutils)/.${TARGET_NAME}"
  export NEW_DYNAREC=1
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
}

make_target() {
  make -C projects/unix clean ${PKG_MAKE_OPTS_TARGET}
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/lib
    install -m 0644 ${PKG_BUILD}/projects/unix/libsimple64.so.2.0.0 ${INSTALL}/usr/local/lib/libsimple64.so.2
}
