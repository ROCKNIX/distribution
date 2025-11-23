# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="retroarch-joypads"
PKG_VERSION="38cf938bba0adbde375972053068f10d955a9d14"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/retroarch-joypad-autoconfig"
PKG_URL="https://github.com/libretro/retroarch-joypad-autoconfig/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="RetroArch joypad autoconfigs."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/libretro/autoconfig
    cp -an ${PKG_BUILD}/{linuxraw,sdl2,udev,x,xinput}/*.cfg ${INSTALL}/usr/share/libretro/autoconfig
    cp -a ${PKG_DIR}/gamepads/* ${INSTALL}/usr/share/libretro/autoconfig
}

post_install() {
  enable_service tmp-joypads.mount
}
