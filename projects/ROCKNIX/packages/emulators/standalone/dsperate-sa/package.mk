# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dsperate-sa"
PKG_VERSION="2.0.1"
PKG_SHA256="0a6b86e474ecf8a51a5c60c0a400ab0ce67ab1d5d8f26b9a5946e3bfa4ac1f9c"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/beebono/DSperate"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/dsperate-v${PKG_VERSION}-linux-${TARGET_ARCH}.tar.gz"
PKG_SOURCE_DIR="dsperate-v${PKG_VERSION}-linux-${TARGET_ARCH}"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="A Nintendo DS emulator reimplementing DraStic's JIT and NEON rendering with melonDS accuracy."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/dsperate ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  case ${DEVICE} in
    RK3576|SM4450|SM6115|SM8250|SM8550|SM8650|SM8750) CONFIG="InputPlumber" ;;
    *) CONFIG="${DEVICE}" ;;
  esac

  mkdir -p ${INSTALL}/usr/config/dsperate
    cp -a ${PKG_DIR}/config/${CONFIG}/* ${INSTALL}/usr/config/dsperate
}
