# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="portmaster"
PKG_VERSION="2024.04.07-0359"
PKG_SITE="https://github.com/PortsMaster/PortMaster-GUI"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/PortMaster.zip"
COMPAT_URL="https://github.com/brooksytech/JelosAddOns/raw/main/compat.zip"
PKG_LICENSE="MIT"
PKG_ARCH="arm aarch64"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey gamecontrollerdb wget oga_controls control-gen"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Portmaster - a simple tool that allows you to download various game ports"

if [ "${DEVICE}" = "S922X" -a "${USE_MALI}" != "no" ]; then
  PKG_DEPENDS_TARGET+=" libegl"
fi

makeinstall_target() {
  export STRIP=true
  mkdir -p ${INSTALL}/usr/config/PortMaster
  cp ${PKG_DIR}/sources/* ${INSTALL}/usr/config/PortMaster/

  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/PortMaster/release
  curl -Lo ${INSTALL}/usr/config/PortMaster/release/PortMaster.zip ${PKG_URL}

  mkdir -p ${INSTALL}/usr/lib/compat
  curl -Lo ${PKG_BUILD}/compat.zip ${COMPAT_URL}
  unzip -qq ${PKG_BUILD}/compat.zip -d ${INSTALL}/usr/lib/compat/
}

post_install() {
  if [ "${DEVICE}" = "S922X" -a "${USE_MALI}" != "no" ]; then
    LIBEGL="export SDL_VIDEO_GL_DRIVER=\/usr\/lib\/egl\/libGL.so.1 SDL_VIDEO_EGL_DRIVER=\/usr\/lib\/egl\/libEGL.so.1"
  else
    LIBEGL=""
  fi

  sed -e "s/@LIBEGL@/${LIBEGL}/g" \
      -i ${INSTALL}/usr/bin/start_portmaster.sh
}
