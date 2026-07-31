# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-inputd"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ROCKNIX input daemon"

post_install() {
  enable_service rocknix-inputd.service
}
