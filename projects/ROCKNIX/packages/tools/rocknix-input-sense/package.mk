# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-input-sense"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain libevdev"
PKG_LONGDESC="ROCKNIX input sense application"

post_install() {
  enable_service input-sense.service
}
