# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="portmaster"
PKG_VERSION="2026.09.13-0343"
PKG_SHA256="2afda49a51b5760c14fda0a12dc543694a6b6a4b4e9ae9d4e11659996382d80a"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/PortsMaster/PortMaster-GUI"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/PortMaster.zip"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey gamecontrollerdb oga_controls control-gen xmlstarlet list-guid gst-plugins-base zip"
PKG_LONGDESC="Portmaster - a simple tool that allows you to download various game ports"
PKG_TOOLCHAIN="manual"

COMPAT_URL="https://github.com/ROCKNIX/packages/raw/main/compat.tar.gz" #f0f5e94

makeinstall_target() {
  export STRIP=true

  mkdir -p ${INSTALL}/usr/config/PortMaster
    cp -a ${PKG_DIR}/sources/* ${INSTALL}/usr/config/PortMaster

  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/PortMaster/release
    curl -Lo ${INSTALL}/usr/config/PortMaster/release/PortMaster.zip ${PKG_URL}

  mkdir -p ${INSTALL}/usr/lib/compat
    curl -Lo ${PKG_BUILD}/compat.tar.gz ${COMPAT_URL}
    tar -xvf ${PKG_BUILD}/compat.tar.gz -C ${INSTALL}/usr/lib
    rm -rf ${INSTALL}/usr/lib/compat/libSDL2-2.0.so.0*
}
