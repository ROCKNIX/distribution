# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fileman"
PKG_VERSION="555628136c024cead9deaf4e5e2574a38285c2d3"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ROCKNIX/fileman"
PKG_URL="https://github.com/ROCKNIX/fileman/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_gfx SDL2_ttf"
PKG_LONGDESC="A Single panel file Manager."

make_target() {
  MAKEDEVICE=$(echo ${DEVICE^^} | sed "s#-#_##g")
  make DEVICE=${MAKEDEVICE^^} RES_PATH=/usr/share/fileman/res START_PATH=/storage/roms SDL2_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config CC=${CXX}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -P fileman ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/fileman
  cp -rf res ${INSTALL}/usr/share/fileman
}
