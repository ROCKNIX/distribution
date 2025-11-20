# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="amiberry"
PKG_ARCH="aarch64"
PKG_VERSION="5c54536997c0039aaa72bb0552cefdc3c967ad8d"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/midwan/amiberry"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain linux glibc bzip2 zlib SDL2 SDL2_image SDL2_ttf capsimg freetype libxml2 flac libogg mpg123 libpng libmpeg2 libserialport"
PKG_LONGDESC="Amiberry is an optimized Amiga emulator for ARM-based boards."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"
PKG_GIT_CLONE_BRANCH="master"
PKG_PATCH_DIRS+=" ${DEVICE}"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_PATCH_DIRS+=" opengl"
fi

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -logg"

  cd ${PKG_BUILD}
  export SYSROOT_PREFIX=${SYSROOT_PREFIX}
  AMIBERRY_PLATFORM="PLATFORM=${DEVICE}"

  sed -i "s|AS     = as|AS     \?= as|" Makefile
  PKG_MAKE_OPTS_TARGET+="${AMIBERRY_PLATFORM} all SDL_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config"
}

makeinstall_target() {
  # Create directories
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/config/amiberry
  # mkdir -p ${INSTALL}/usr/config/amiberry/controller

  # Copy ressources
  cp -ra ${PKG_DIR}/config/*           ${INSTALL}/usr/config/amiberry/
  cp -a data                          ${INSTALL}/usr/config/amiberry/
  cp -a savestates                    ${INSTALL}/usr/config/amiberry/
  cp -a screenshots                   ${INSTALL}/usr/config/amiberry/
  cp -a whdboot                       ${INSTALL}/usr/config/amiberry/
  ln -s /storage/roms/bios            ${INSTALL}/usr/config/amiberry/kickstarts

  # Create links to Retroarch controller files
  ln -s "/usr/share/libretro/autoconfig" "${INSTALL}/usr/config/amiberry/controller"

  # Copy binary, scripts & link libcapsimg
  cp -a amiberry* ${INSTALL}/usr/bin/amiberry
  cp -a ${PKG_DIR}/scripts/*          ${INSTALL}/usr/bin
  ln -sf /usr/lib/libcapsimage.so.5.1 ${INSTALL}/usr/config/amiberry/capsimg.so
}
