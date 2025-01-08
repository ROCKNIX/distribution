# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="portmaster"
PKG_VERSION="2024.10.25-0040"
PKG_SITE="https://github.com/PortsMaster/PortMaster-GUI"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/PortMaster.zip"
COMPAT_URL="https://github.com/ROCKNIX/packages/raw/main/compat.zip"
PKG_LICENSE="MIT"
PKG_ARCH="arm aarch64"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey gamecontrollerdb wget oga_controls control-gen xmlstarlet list-guid"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Portmaster - a simple tool that allows you to download various game ports"

makeinstall_target() {
  export STRIP=true
  mkdir -p ${INSTALL}/usr/config/PortMaster
  cp ${PKG_DIR}/sources/* ${INSTALL}/usr/config/PortMaster/
  chmod +x ${INSTALL}/usr/config/PortMaster/*

  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/PortMaster/release
  curl -Lo ${INSTALL}/usr/config/PortMaster/release/PortMaster.zip ${PKG_URL}

  mkdir -p ${INSTALL}/usr/lib/compat
  curl -Lo ${PKG_BUILD}/compat.zip ${COMPAT_URL}
  unzip -qq ${PKG_BUILD}/compat.zip -d ${INSTALL}/usr/lib/compat/

  case ${DEVICE} in
    SD865|H700)
      GUIDEBUTTON='"hotkeyenable")     TR_NAME="guide";;'
      sed -e "s/@GUIDEBUTTON@/${GUIDEBUTTON}/g" -i ${INSTALL}/usr/config/PortMaster/mapper.txt
    ;;
    *)
      sed -i "/@GUIDEBUTTON@/d" ${INSTALL}/usr/config/PortMaster/mapper.txt 
    ;;
  esac
}
