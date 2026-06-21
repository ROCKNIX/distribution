# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="cargo-c-lock"
PKG_VERSION="$(get_pkg_version cargo-c)"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/lu-zero/cargo-c"
PKG_LONGDESC="cargo-c lock"
PKG_TOOLCHAIN="manual"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/Cargo.lock"
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.Cargo.lock"

unpack() {
  :
}
