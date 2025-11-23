# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="retroarch-assets"
PKG_VERSION="76cc6cf03507429c5a136cb50d83a14e05430fcd"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/retroarch-assets"
PKG_URL="https://github.com/libretro/retroarch-assets/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="make:host"
PKG_LONGDESC="RetroArch assets. Background and icon themes for the menu drivers."
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  cd ../
  rm -rf .${TARGET_NAME}
}

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/retroarch-assets"
}

post_makeinstall_target() {
  # Remove unnecesary Retroarch Assets and overlays
  rm -rf ${INSTALL}/usr/share/retroarch-assets/{branding,nxrgui,pkg,scripts,switch,wallpapers}
  rm -rf ${INSTALL}/usr/share/retroarch-assets/xmb/{automatic,dot-art,flatui,pixel,retrosystem,systematic}
}
