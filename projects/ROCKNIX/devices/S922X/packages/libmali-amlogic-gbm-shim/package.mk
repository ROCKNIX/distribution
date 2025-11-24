# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali-amlogic-gbm-shim"
PKG_VERSION="5bf814354982c7e3ad0cbef73edbf88b389ffe68"
PKG_LICENSE="mali_driver"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/viraniac/mali-debs"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_TOOLCHAIN="make"
PKG_LONGDESC="GBM shim for Vulkan Mali drivers for S922X SOC"


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  cp ${PKG_BUILD}/mali_gbm_shim.so ${INSTALL}/usr/lib/
}
