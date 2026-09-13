# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-sa-core"
PKG_VERSION="5340dafcc0f5e8284057ab931dd5c66222d3d49e"
PKG_SHA256="04a3b14a82182b8f54f88b52585e27b91d37335f87393537332ce94c28037f6b"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-core"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host"
PKG_LONGDESC="Mupen64Plus Standalone Core"
PKG_TOOLCHAIN="manual"

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_MAKE_OPTS_TARGET+=" VULKAN=1"
else
  PKG_MAKE_OPTS_TARGET+=" VULKAN=0"
fi

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
    install -m 0644 ${PKG_BUILD}/projects/unix/libmupen64plus.so.2.0.0 ${INSTALL}/usr/local/lib
    cp -a ${PKG_BUILD}/projects/unix/libmupen64plus.so.2 ${INSTALL}/usr/local/lib

  mkdir -p ${INSTALL}/usr/local/share/mupen64plus
    cp -a ${PKG_BUILD}/data/* ${INSTALL}/usr/local/share/mupen64plus
    if [ -e "${PKG_DIR}/config/${DEVICE}/mupen64plus.cfg" ]; then
      cp -a ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/local/share/mupen64plus
    fi

  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_mupen64plus.sh ${INSTALL}/usr/bin
}
