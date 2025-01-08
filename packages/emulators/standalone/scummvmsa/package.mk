# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="scummvmsa"
PKG_VERSION="2.9.0"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/scummvm/scummvm"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_net freetype fluidsynth soundfont-generaluser pipewire"
PKG_LONGDESC="Script Creation Utility for Maniac Mansion Virtual Machine"

pre_configure_target() { 
  sed -i "s|sdl-config|sdl2-config|g" ${PKG_BUILD}/configure
  TARGET_CONFIGURE_OPTS="--host=${TARGET_NAME} --backend=sdl --disable-alsa --with-sdl-prefix=${SYSROOT_PREFIX}/usr/bin --disable-debug --enable-release --enable-vkeybd --opengl-mode=gles2 --enable-optimizations"
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/scummvm/
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/scummvm/
  chmod 0755 ${INSTALL}/usr/config/scummvm/games/*sh

  mkdir -p ${INSTALL}/usr/config/scummvm/themes
  cp -rf ${PKG_BUILD}/gui/themes ${INSTALL}/usr/config/scummvm/themes

  mv ${INSTALL}/usr/local/bin ${INSTALL}/usr/
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*
	
  for i in appdata applications doc icons man; do
    rm -rf "${INSTALL}/usr/local/share/${i}"
  done
}

