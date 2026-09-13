# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mednafen"
PKG_VERSION="1.32.1"
PKG_SHA256="00cdcf02e83072d1d0e861b61e86d1d12eac18accc03cfa161e84bd3744b0137"
PKG_LICENSE="GPL-2.0-or-later"
PKG_URL="https://github.com/sydarn/mednafen/archive/refs/tags/1.32.1-chd.tar.gz"
PKG_SITE="https://mednafen.github.io/"
PKG_DEPENDS_TARGET="toolchain SDL2 flac zstd zlib"
PKG_LONGDESC="Mednafen standalone emulator"

case ${DEVICE} in
  H700|SM8*) PKG_PATCH_DIRS+=" sdl-input" ;;
esac

pre_configure_target() {
  export CFLAGS="${CFLAGS} -flto -fipa-pta"
  export CXXFLAGS="${CXXFLAGS} -flto -fipa-pta"
  export LDFLAGS="${LDFLAGS} -flto -fipa-pta"

  # unsupported modules
  DISABLED_MODULES+=" --disable-apple2 \
                      --disable-sasplay \
                      --disable-ssfplay"

  case ${DEVICE} in
    RK3326|RK3566*|H700)
      DISABLED_MODULES+=" --disable-snes \
                          --disable-ss \
                          --disable-psx"
      ;;
    RK3399)
      DISABLED_MODULES+=" --disable-snes \
                          --disable-ss"
      ;;
    RK3588)
      DISABLED_MODULES+=" --disable-snes"
      ;;
  esac

  PKG_CONFIGURE_OPTS_TARGET="${DISABLED_MODULES}"
  # Need to update automake files
  (
    cd ..
    sh autogen.sh
  )
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/src/mednafen ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/mednafen
    cp -a ${PKG_DIR}/config/common/* ${INSTALL}/usr/config/mednafen
}
