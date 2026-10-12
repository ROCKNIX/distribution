# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cmp"
PKG_VERSION="0.5.0"
PKG_SHA256="db01ab0a3d15252a1cb27ccb8315ae608a2aa4da4819e9fcc0564049689c84a6"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/cobanov/cmp"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain mpv Python3"
PKG_LONGDESC="Console Music Player: a music player built on mpv, with touch controls on the second screen of dual-screen handhelds."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/cmp
    cp -a ${PKG_BUILD}/hub/media-hub.py ${PKG_BUILD}/mpv/input.conf ${PKG_BUILD}/mpv/scripts ${INSTALL}/usr/share/cmp
    cp -a ${PKG_BUILD}/es/Music.sh ${INSTALL}/usr/share/cmp/start_cmp.sh

  mkdir -p ${INSTALL}/usr/bin
    ln -sf /usr/share/cmp/start_cmp.sh ${INSTALL}/usr/bin/start_cmp.sh

  mkdir -p ${INSTALL}/usr/config/gmu/playlists
    ln -sf /usr/bin/start_cmp.sh "${INSTALL}/usr/config/gmu/playlists/Start CMP.sh"
}
