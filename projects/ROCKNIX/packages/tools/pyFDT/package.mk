# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pyFDT"
PKG_VERSION="0.3.3"
PKG_SHA256="f70b1008ea78a2a46429d2f3b06a2a71f2bfd59a5e13000c2f3f2a957b57ea9b"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/molejar/${PKG_NAME}"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain Python3 setuptools:host"
PKG_LONGDESC="This python module is usable for manipulation with Device Tree Data and primary was created for imxsb tool"
PKG_TOOLCHAIN="python"

post_makeinstall_target() {
  python_remove_source
}
