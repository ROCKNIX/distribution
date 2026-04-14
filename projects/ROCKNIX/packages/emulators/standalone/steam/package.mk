# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="steam"
PKG_VERSION="1.0.0.85"
PKG_LICENSE="proprietary"
PKG_SITE="https://steampowered.com"
PKG_URL="https://repo.steampowered.com/steam/archive/stable/steam-launcher_${PKG_VERSION}_amd64.deb"
PKG_DEPENDS_TARGET="mesa:host fex-emu"
PKG_LONGDESC="Steam is the ultimate destination for playing, discussing, and creating games"
PKG_TOOLCHAIN="manual"


unpack() {
 mkdir -p ${PKG_BUILD}
 cd ${PKG_BUILD}
 ar x ${SOURCES}/${PKG_NAME}/steam-${PKG_VERSION}.deb
 tar -xf data.tar.xz
}

makeinstall_target() {
  sed -i '/^# Don'\''t allow running as root$/,/^fi$/d' "${PKG_BUILD}/usr/lib/steam/bin_steam.sh"
  mkdir -p ${INSTALL}/usr/config/modules
  cp -rf ${PKG_BUILD}/usr/bin ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/usr/lib ${INSTALL}/usr/lib
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}