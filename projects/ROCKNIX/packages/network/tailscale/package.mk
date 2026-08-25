# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present kkoshelev (https://github.com/kkoshelev)
# Copyright (C) 2022-present fewtarius (https://github.com/fewtarius)

PKG_NAME="tailscale"
PKG_VERSION="1.98.8"
PKG_SHA256="53eb3ce89d062fd34e393d24a6c8ec08c769fede8eb77fe9c6e347ad4ae00f84"
PKG_SITE="https://tailscale.com/"
PKG_DEPENDS_TARGET="toolchain wireguard-tools"
PKG_LONGDESC="Zero config VPN. Installs on any device in minutes, manages firewall rules for you, and works from anywhere."
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  aarch64)
    TS_ARCH="_arm64"
    PKG_SHA256="53eb3ce89d062fd34e393d24a6c8ec08c769fede8eb77fe9c6e347ad4ae00f84"
  ;;
  x86_64)
    TS_ARCH="_amd64"
    PKG_SHA256="3a55b5900dd7e11e09b6c74d1e46d223d549dfbefbdc1f044a8ab7bdbafb933c"
  ;;
esac

PKG_URL="https://pkgs.tailscale.com/stable/tailscale_${PKG_VERSION}${TS_ARCH}.tgz"

pre_unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf $SOURCES/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tgz -C ${PKG_BUILD} tailscale_${PKG_VERSION}${TS_ARCH}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin/
    cp ${PKG_BUILD}/tailscale ${INSTALL}/usr/sbin/
    cp ${PKG_BUILD}/tailscaled ${INSTALL}/usr/sbin/

  mkdir -p ${INSTALL}/usr/config
    cp -R ${PKG_DIR}/config/tailscaled.defaults ${INSTALL}/usr/config
}

