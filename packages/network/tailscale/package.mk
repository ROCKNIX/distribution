# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present kkoshelev (https://github.com/kkoshelev)
# Copyright (C) 2022-present fewtarius (https://github.com/fewtarius)

PKG_NAME="tailscale"
PKG_VERSION="1.56.1"
PKG_SITE="https://tailscale.com/"
PKG_DEPENDS_TARGET="toolchain wireguard-tools"
PKG_LONGDESC="Zero config VPN. Installs on any device in minutes, manages firewall rules for you, and works from anywhere."
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  aarch64)
    TS_ARCH="_arm64"
    PKG_SHA256="6fca51f7b7fb5187e3401902f5e888cb86e9d006c5e60ef145031b0ddc299e39"
  ;;
  x86_64)
    TS_ARCH="_amd64"
    PKG_SHA256="2434ec69d8a7a0372b37a1c9f0ac2f499c0614e483ff096eb4481cfb873445f9"
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

