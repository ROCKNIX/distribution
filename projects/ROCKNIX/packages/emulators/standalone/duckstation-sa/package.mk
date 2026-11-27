# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="duckstation-sa"
PKG_VERSION="0.1-12870"
PKG_LICENSE="CC-BY-NC-ND-4.0"
PKG_SITE="https://github.com/stenzek/duckstation"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Fast PlayStation 1 emulator for x86-64/AArch32/AArch64 "
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  x86_64)
    PKG_URL="${PKG_SITE}/releases/download/latest/DuckStation-x64.AppImage"
    PKG_SHA256="c1366ee5933d80a9df7ec337bf023da6ebaf92518b65df8a76c0dcc177b17a82"
    ;;
  aarch64)
    PKG_URL="${PKG_SITE}/releases/download/latest/DuckStation-arm64.AppImage"
    PKG_SHA256="3cd9e8465a6979e98eea69f5c512d4764b9f1f9d8cc58422665eede4b0a3e045"
    ;;
esac

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true

  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/duckstation-sa
    chmod 0755 ${INSTALL}/usr/bin/duckstation-sa
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/duckstation
    cp -a ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/duckstation

  mkdir -p ${INSTALL}/usr/config/modules
    cp -a ${PKG_DIR}/sources/"Start Duckstation.sh" ${INSTALL}/usr/config/modules
}
