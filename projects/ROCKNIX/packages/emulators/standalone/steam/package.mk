# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="steam"
PKG_VERSION="1.0.0.85"
PKG_LICENSE="proprietary"
PKG_SITE="https://steampowered.com"
PKG_URL="https://repo.steampowered.com/steam/archive/stable/steam-launcher_${PKG_VERSION}_amd64.deb"
PKG_DEPENDS_TARGET="fex-emu gamescope lsfg-vk nss networkmanager"
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
  mkdir -p ${INSTALL}/usr/share/steam
  cp -rf ${PKG_BUILD}/usr/bin ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/usr/lib ${INSTALL}/usr/lib
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/bin/steamos-polkit-helpers
  install -m 0755 ${PKG_DIR}/scripts/steamos-polkit-helpers/steamos-set-timezone \
    ${INSTALL}/usr/bin/steamos-polkit-helpers/steamos-set-timezone
  cp -rf ${PKG_DIR}/resources/registry.vdf ${INSTALL}/usr/share/steam
  mkdir -p ${INSTALL}/usr/lib/sysctl.d
  install -m 0644 ${PKG_DIR}/config/50-max-map-count.conf ${INSTALL}/usr/lib/sysctl.d/
}
