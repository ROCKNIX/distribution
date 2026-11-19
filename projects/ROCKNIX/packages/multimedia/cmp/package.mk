# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cmp"
PKG_VERSION="0.6.2"
PKG_SHA256="3debddc7e5a06ecf57e15fd251f64953b43b5221819ba621c801cd881099ad8e"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/cobanov/cmp"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain mpv Python3"
PKG_LONGDESC="Console Media Player: a music and a video player built on mpv, with touch controls on the second screen of dual-screen handhelds."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/cmp
    cp -a ${PKG_BUILD}/hub/media-hub.py ${PKG_BUILD}/mpv/input.conf ${PKG_BUILD}/mpv/scripts ${INSTALL}/usr/share/cmp
    cp -a ${PKG_BUILD}/es/Music.sh ${INSTALL}/usr/share/cmp/start_cmp.sh
    cp -a ${PKG_BUILD}/es/Video.sh ${INSTALL}/usr/share/cmp/start_cmp_video.sh

  mkdir -p ${INSTALL}/usr/bin
    ln -sf /usr/share/cmp/start_cmp.sh ${INSTALL}/usr/bin/start_cmp.sh
    ln -sf /usr/share/cmp/start_cmp_video.sh ${INSTALL}/usr/bin/start_cmp_video.sh

  mkdir -p ${INSTALL}/usr/config/gmu/playlists
    ln -sf /usr/bin/start_cmp.sh "${INSTALL}/usr/config/gmu/playlists/Start CMP.sh"
}
