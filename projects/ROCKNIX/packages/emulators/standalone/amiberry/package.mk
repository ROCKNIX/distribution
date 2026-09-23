# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="amiberry"
PKG_VERSION="5c54536997c0039aaa72bb0552cefdc3c967ad8d"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/midwan/amiberry"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain linux glibc bzip2 zlib SDL2 SDL2_image SDL2_ttf capsimg freetype libxml2 flac libogg mpg123 libpng libmpeg2 libserialport"
PKG_LONGDESC="Amiberry is an optimized Amiga emulator for ARM-based boards."
PKG_TOOLCHAIN="make"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_PATCH_DIRS+=" opengl"
fi

# 01-platform.patch turns PLATFORM=${DEVICE} into an aarch64/NEON target;
# upstream's own x86-64 target is the right one there.
if [ "${ARCH}" = "x86_64" ]; then
  PKG_MAKE_OPTS_TARGET+=" PLATFORM=x86-64"
else
  PKG_MAKE_OPTS_TARGET+=" PLATFORM=${DEVICE}"
fi
PKG_MAKE_OPTS_TARGET+=" all SDL_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config"

post_unpack() {
  sed -i "s|AS     = as|AS     \?= as|" ${PKG_BUILD}/Makefile
}

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -logg"
  cd ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a amiberry* ${INSTALL}/usr/bin/amiberry
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/amiberry
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/amiberry
    cp -a {data,savestates,screenshots,whdboot} ${INSTALL}/usr/config/amiberry
    ln -s /storage/roms/bios ${INSTALL}/usr/config/amiberry/kickstarts
    ln -s /usr/share/libretro/autoconfig ${INSTALL}/usr/config/amiberry/controller
    ln -sf /usr/lib/libcapsimage.so.5.1 ${INSTALL}/usr/config/amiberry/capsimg.so
}
