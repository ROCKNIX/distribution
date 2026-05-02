# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="touchhle-sa"
PKG_LICENSE="MPLv2"
PKG_VERSION="d7668926268eded91545fa8ffae6590871ecf5b1"
PKG_SITE="https://github.com/touchHLE/touchHLE"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host cargo rust SDL2 sndio"
PKG_LONGDESC="touchHLE: high-level emulator for iPhone OS apps"
PKG_TOOLCHAIN="manual"

post_unpack() {
  cd ${PKG_BUILD}/vendor/openal-soft
  sed -i 's/false,/AL_FALSE_ENUM,/g' alc/backends/sdl2.c 2>/dev/null || true
  sed -i 's/enum CompatFlags : uint8_t/enum CompatFlags/g' alc/alu.h
  sed -i 's/enum class UhjQualityType : uint8_t/enum UhjQualityType/g' core/uhjfilter.h
}

make_target() {
  unset CMAKE
  export RUSTFLAGS="-C link-arg=-lasound"
  export CMAKE_POLICY_VERSION_MINIMUM="3.5"
  export CFLAGS="${CFLAGS} -std=gnu11"

  cargo build \
    --target ${TARGET_NAME} \
    --release
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/touchHLE ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib/touchHLE/touchHLE_dylibs
  cp -rf ${PKG_BUILD}/touchHLE_dylibs/lib* ${INSTALL}/usr/lib/touchHLE/touchHLE_dylibs/
  mkdir -p ${INSTALL}/usr/lib/touchHLE/touchHLE_fonts
  cp -rf ${PKG_BUILD}/touchHLE_fonts/LiberationSans-* ${INSTALL}/usr/lib/touchHLE/touchHLE_fonts
  cp -rf ${PKG_BUILD}/touchHLE_default_options.txt ${INSTALL}/usr/lib/touchHLE/
  mkdir -p ${INSTALL}/usr/config/touchHLE
  cp -rf ${PKG_BUILD}/touchHLE_options.txt ${INSTALL}/usr/config/touchHLE/
  chmod +x ${INSTALL}/usr/bin/*
}
