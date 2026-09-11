# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aic8800-firmware"
PKG_VERSION="516e3b087763d80c44f5e3b6d2dd63e0d925c91d"
PKG_SHA256="f79ff9b8b4dfed97c59fe6877b34406bbac042cc1091ada3bb17224fe62f1b39"
PKG_LICENSE="Proprietary"
PKG_SITE="https://github.com/radxa-pkg/aic8800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="AICSemi AIC8800 firmware"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware
    cp -a ${PKG_BUILD}/src/USB/driver_fw/fw/aic8800* \
       ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/
}
