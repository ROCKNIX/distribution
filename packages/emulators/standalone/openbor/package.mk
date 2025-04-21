# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="openbor"
PKG_VERSION="b8303cce992a0db93c3a465df3c943942fe322f8"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/DCurrent/openbor"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libogg libvorbisidec libvpx libpng"
PKG_LONGDESC="OpenBOR is the ultimate 2D side scrolling engine for beat em' ups, shooters, and more!"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="BUILD_LINUX_${ARCH}=1 -C ${PKG_BUILD}/engine SDKPATH=${SYSROOT_PREFIX} PREFIX=${TARGET_NAME}"
  cd ${PKG_BUILD}
  #sed -i "s|device->mappings\[SDID_START\]      = SDL_CONTROLLER_BUTTON_START;|device->mappings\[SDID_START\]      = SDL_CONTROLLER_BUTTON_BACK;|g" engine/sdl/control.c
  #sed -i "s|device->mappings\[SDID_SCREENSHOT\] = SDL_CONTROLLER_BUTTON_BACK;|device->mappings\[SDID_SCREENSHOT\] = SDL_CONTROLLER_BUTTON_START;|g" engine/sdl/control.c
  sed -i "s|-Werror||g" engine/Makefile
}

pre_make_target() {
  cd ${PKG_BUILD}/engine
  ./version.sh
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -P OpenBOR ${INSTALL}/usr/bin/OpenBOR
  cp -P ${PKG_DIR}/sources/start_OpenBOR.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/openbor
  cp ${PKG_DIR}/config/master.cfg ${INSTALL}/usr/config/openbor/master.cfg
}
