# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="duckstation-sa"
PKG_VERSION="0.1-10998"
PKG_LICENSE="CC-BY-NC-ND-4.0"
PKG_SITE="https://github.com/stenzek/duckstation"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Fast PlayStation 1 emulator for x86-64/AArch32/AArch64 "
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  x86_64)
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/DuckStation-x64.AppImage"
    PKG_SHA256="b204886bb498ede1a290215fc2efb521c0c2f26b964788df697b4fc2cb3f7f7b"
    ;;
  aarch64)
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/DuckStation-arm64.AppImage"
    PKG_SHA256="f92319a0484e67bb62bfab7b0e56dac46165b50e45b51293038d9344a6288440"
    ;;
esac

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true

  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/duckstation-sa
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/duckstation
    cp -a ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/duckstation

  mkdir -p ${INSTALL}/usr/config/modules
    cp -a ${PKG_DIR}/sources/"Start Duckstation.sh" ${INSTALL}/usr/config/modules
}
