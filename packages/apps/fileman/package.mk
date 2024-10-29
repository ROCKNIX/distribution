# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351elec)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="fileman"
PKG_VERSION="2507b35f126b7169b4f036bb187c387b7efaca63"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ROCKNIX/fileman"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_gfx SDL2_ttf"
PKG_LONGDESC="A Single panel file Manager."
PKG_PATCH_DIRS="${DEVICE}"
[ "${DEVICE}" = "S922X" -a "${USE_MALI}" != "no" ] && PKG_PATCH_DIRS+=" S922X-MALI"

make_target() {
  MAKEDEVICE=$(echo ${DEVICE^^} | sed "s#-#_##g")
  make DEVICE=${MAKEDEVICE^^} RES_PATH=/usr/share/fileman/res START_PATH=/storage/roms SDL2_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config CC=${CXX}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/fileman
  cp fileman ${INSTALL}/usr/bin/
  cp -rf res ${INSTALL}/usr/share/fileman/
  chmod 0755 ${INSTALL}/usr/bin/fileman
}
