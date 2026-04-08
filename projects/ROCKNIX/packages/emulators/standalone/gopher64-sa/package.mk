# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gopher64-sa"
PKG_LICENSE="GPLv3"
PKG_VERSION="acf5e08b97d8526e7f25578bdaa202557c42c200"
PKG_SITE="https://github.com/gopher64/gopher64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL3 cargo:host cargo rust mesa libXss ${VULKAN}"
PKG_LONGDESC="Gopher64 - Highly compatible N64 emulator"
PKG_TOOLCHAIN="manual"

make_target() {
  unset CMAKE
  export RUSTFLAGS="-A unpredictable_function_pointer_comparisons -C link-arg=-ldrm -C link-arg=-lgbm -C link-arg=-lasound -C link-arg=-lvulkan -C link-arg=-lvolk"
  export PKG_CONFIG_ALLOW_CROSS=1

  export CC=${TARGET_NAME}-gcc
  export CXX=${TARGET_NAME}-g++

  export FREETYPE2_INCLUDE_PATH="${SYSROOT_PREFIX}/usr/include/freetype2"

  export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${SYSROOT_PREFIX} --target=${TARGET_NAME}"

  export SKIA_GN_ARGS="
  target_os=\"linux\"
  target_cpu=\"arm64\"
  cc=\"${TARGET_NAME}-gcc\"
  cxx=\"${TARGET_NAME}-g++\"
  skia_system_freetype2_include_path=\"${SYSROOT_PREFIX}/usr/include/freetype2\"
  extra_cflags=[]
  extra_asmflags=[]
  "
  export SKIA_BINARIES_URL="https://github.com/rust-skia/skia-binaries/releases/download/0.90.0/skia-binaries-da4579b39b75fa2187c5-aarch64-unknown-linux-gnu-gl-pdf-textlayout-vulkan.tar.gz"

  cargo build \
    --target ${TARGET_NAME} \
    --release
}


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/gopher64 ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/gopher64
  cp ${PKG_DIR}/config/* ${INSTALL}/usr/config/gopher64
  chmod +x ${INSTALL}/usr/bin/*
}
