# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026

PKG_NAME="ayaneo-haptics"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain linux"
PKG_SECTION="driver"
PKG_SHORTDESC="AYANEO Controller haptics bridge"
PKG_LONGDESC="Bridges FF_RUMBLE events from AYANEO Controller (USB HID) to qcom-hv-haptics driver"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
  cp ${PKG_DIR}/source/ayaneo-haptics.c ${PKG_BUILD}/
  cp ${PKG_DIR}/source/Makefile ${PKG_BUILD}/
}

make_target() {
  kernel_make V=1 KDIR=$(kernel_path) module
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/ayaneo-haptics.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/
  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cp ${PKG_DIR}/source/system.d/ayaneo-haptics.service ${INSTALL}/usr/lib/systemd/system/
}

post_install() {
  enable_service ayaneo-haptics.service
}
