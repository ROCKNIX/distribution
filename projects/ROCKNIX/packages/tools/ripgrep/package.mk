# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present UzuCore (https://github.com/UzuCore)

PKG_NAME="ripgrep"
PKG_VERSION="15.2.0"
PKG_LICENSE="MIT AND Unlicense"
PKG_SITE="https://github.com/BurntSushi/ripgrep"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fast recursive line-oriented search tool."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  aarch64)
    RIPGREP_TARGET="aarch64-unknown-linux-musl"
    PKG_SHA256="800b1e7206afe799dfb5a6901f23147cfaabe0e52210538100f61e86e1740915"
    ;;
  x86_64)
    RIPGREP_TARGET="x86_64-unknown-linux-musl"
    PKG_SHA256="33e15bcf1624b25cdd2a55813a47a2f95dbe126268203e76aa6a585d1e7b149c"
    ;;
esac

PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/ripgrep-${PKG_VERSION}-${RIPGREP_TARGET}.tar.gz"
PKG_SOURCE_NAME="ripgrep-${PKG_VERSION}-${RIPGREP_TARGET}.tar.gz"

makeinstall_target() {
  install -Dm755 ${PKG_BUILD}/rg ${INSTALL}/usr/bin/rg
}
