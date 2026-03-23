# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pd-mapper"
PKG_VERSION="1.1"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/linux-msm/pd-mapper"
PKG_URL="https://github.com/linux-msm/pd-mapper/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd qrtr"
PKG_LONGDESC="pd-mapper"

PKG_MAKEINSTALL_OPTS_TARGET="prefix=/usr"

post_install() {
  enable_service pd-mapper.service
}
