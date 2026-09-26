# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sing-box"
PKG_VERSION="1.13.15"
PKG_SITE="https://sing-box.sagernet.org/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Universal proxy platform (VLESS/Reality, WireGuard, AmneziaWG, Shadowsocks, Hysteria2) with a tun transparent-routing mode."
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  aarch64)
    SB_ARCH="linux-arm64"
    PKG_SHA256="f0810bbb5722ae36635687c421019defcc8b328d31a0b3c287901f331747ca93"
  ;;
  x86_64)
    SB_ARCH="linux-amd64"
    PKG_SHA256="a3a3ff223b23c3f4731d0a17cb0ef94c97ce257c70721a5b07dc7ca079203c9f"
  ;;
esac

PKG_URL="https://github.com/SagerNet/sing-box/releases/download/v${PKG_VERSION}/sing-box-${PKG_VERSION}-${SB_ARCH}.tar.gz"

pre_unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz \
      -C ${PKG_BUILD} sing-box-${PKG_VERSION}-${SB_ARCH}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
    cp ${PKG_BUILD}/sing-box ${INSTALL}/usr/sbin/

  mkdir -p ${INSTALL}/usr/config/sing-box
    cp ${PKG_DIR}/config/config.json.sample ${INSTALL}/usr/config/sing-box/
}
