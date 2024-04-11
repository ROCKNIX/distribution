# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="network"
PKG_VERSION=""
PKG_LICENSE="various"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain connman rfkill hostapd netbase ethtool openssh iw wireless-regdb rsync tailscale avahi miniupnpc nss-mdns bluetool speedtest-cli"
PKG_SECTION="virtual"
PKG_LONGDESC="Metapackage for various packages to install network support"

if [ "${BLUETOOTH_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} pygobject bluez"
fi

if [ "${SAMBA_SERVER}" = "yes" ] || [ "$SAMBA_SUPPORT" = "yes" ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} samba"
fi

if [ "${SIMPLE_HTTP_SERVER}" = "yes" ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} simple-http-server"
fi

if [ "${OPENVPN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} openvpn"
fi

if [ "${WIREGUARD_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} wireguard-tools"
fi

if [ "${ZEROTIER_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} zerotier-one"
fi

# nss needed by inputstream.adaptive, chromium etc.
if [ "${TARGET_ARCH}" = "x86_64" ] || [ "${TARGET_ARCH}" = "arm" ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} nss"
fi
