# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="tqftpserv"
PKG_VERSION="1.1.1"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/linux-msm/tqftpserv"
PKG_URL="https://github.com/linux-msm/tqftpserv/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd qrtr zstd"
PKG_LONGDESC="tqftpserv"

post_install() {
  enable_service tqftpserv.service
}
