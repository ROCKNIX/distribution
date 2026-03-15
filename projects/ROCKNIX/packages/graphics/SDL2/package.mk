# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="SDL2" #This is a compatibility package for SDL2, implemented on top of SDL3. TODO : rename to SDL2-compat later
PKG_VERSION="2.32.64"
PKG_LICENSE="Zlib"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/sdl2-compat-${PKG_VERSION}.tar.gz"

PKG_DEPENDS_TARGET="toolchain SDL3"
PKG_DEPENDS_HOST="toolchain:host distutilscross:host SDL3:host"
PKG_PROVIDES_TARGET="SDL2"

PKG_LONGDESC="SDL2 ABI compatibility layer implemented on top of SDL3."

PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -ludev"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  #TODO: sdl2-compat's SDL_config_unix.h.cmake defines SDL_VIDEO_OPENGL_ES without SDL_VIDEO_OPENGL_ES2. Should be fixed upstream.
  sed -i 's/#define SDL_VIDEO_OPENGL_ES 1/#define SDL_VIDEO_OPENGL_ES 1\n#define SDL_VIDEO_OPENGL_ES2 1/' \
  "${PKG_BUILD}/include/SDL2/SDL_config_unix.h.cmake"
fi

 PKG_CMAKE_OPTS_TARGET+=" -DSDL2COMPAT_INSTALL=ON \
                          -DSDL2COMPAT_TESTS=OFF \
                          -DSDL2COMPAT_STATIC=OFF \
                          -DSDL2COMPAT_X11=OFF"
}

post_makeinstall_target() {
  # rename pkg-config file so dependents find it as 'sdl2'
  if [ -f "${SYSROOT_PREFIX}/usr/lib/pkgconfig/sdl2-compat.pc" ]; then
    mv "${SYSROOT_PREFIX}/usr/lib/pkgconfig/sdl2-compat.pc" \
       "${SYSROOT_PREFIX}/usr/lib/pkgconfig/sdl2.pc"
  fi
  if [ -f "${INSTALL}/usr/lib/pkgconfig/sdl2-compat.pc" ]; then
    mv "${INSTALL}/usr/lib/pkgconfig/sdl2-compat.pc" \
       "${INSTALL}/usr/lib/pkgconfig/sdl2.pc"
  fi

  if [ -f "${SYSROOT_PREFIX}/usr/bin/sdl2-config" ]; then
    sed -e "s:\(['=LI]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" \
        -i "${SYSROOT_PREFIX}/usr/bin/sdl2-config"
  fi

  rm -rf "${INSTALL}/usr/bin"
}
