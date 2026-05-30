# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="qcom-fastrpc"
PKG_VERSION="1.0.5"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/qualcomm/fastrpc"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libyaml libmd libbsd meson"
PKG_LONGDESC="Qualcomm's userspace library that facilitates efficient remote procedure calls between the CPU and DSP"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET=" --with-config-base-dir=/usr/share/qcom \
                            --with-systemdsystemunitdir=/usr/lib/systemd/system"

post_makeinstall_target() {
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
}

post_install() {
  enable_service adsprpcd-sensorspd.service
}