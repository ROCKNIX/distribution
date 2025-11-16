# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali-amlogic-gbm-shim"
PKG_VERSION="5bf814354982c7e3ad0cbef73edbf88b389ffe68"
PKG_LICENSE="mali_driver"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/viraniac/mali-debs"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="GBM shim for Vulkan Mali drivers for S922X SOC"

make_target() {
  cd ./jammy/arm64/VIM4/wayland/src
  "${TOOLCHAIN}"/bin/aarch64-rocknix-linux-gnueabi-gcc -I"${TOOLCHAIN}"/include -Wall -O2 -fpic -shared gbm_bo_create_with_modifiers2.c -o mali_gbm_shim.so
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  cp ${PKG_BUILD}/jammy/arm64/VIM4/wayland/src/mali_gbm_shim.so ${INSTALL}/usr/lib/
}
