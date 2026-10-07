# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dsperate-sa"
PKG_VERSION="3.0.1"
PKG_SHA256="6b0027e00e6d5ef1d20f8a15830f618f7ee147ffa8fac1f6371d264e316ede12"
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
