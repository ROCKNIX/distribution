# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="SDL2_gles"
PKG_VERSION="2.32.64"
PKG_LICENSE="Zlib"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/sdl2-compat-${PKG_VERSION}.tar.gz"
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.tar.gz"

PKG_DEPENDS_TARGET="toolchain SDL3"
PKG_LONGDESC="SDL2-compat built with GLES-only for GLES-only GPU drivers."

PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -ludev"

  # Disable desktop OpenGL, keep only GLES
  sed -i \
    -e 's/^#define SDL_VIDEO_OPENGL 1/\/* #undef SDL_VIDEO_OPENGL *\//' \
    -e 's/^#define SDL_VIDEO_OPENGL_GLX 1/\/* #undef SDL_VIDEO_OPENGL_GLX *\//' \
    "${PKG_BUILD}/include/SDL2/SDL_config_unix.h.cmake"

  sed -i 's/#define SDL_VIDEO_OPENGL_ES 1/#define SDL_VIDEO_OPENGL_ES 1\n#define SDL_VIDEO_OPENGL_ES2 1/' \
    "${PKG_BUILD}/include/SDL2/SDL_config_unix.h.cmake"

  PKG_CMAKE_OPTS_TARGET+=" -DSDL2COMPAT_INSTALL=ON \
                           -DSDL2COMPAT_TESTS=OFF \
                           -DSDL2COMPAT_STATIC=OFF \
                           -DSDL2COMPAT_X11=OFF"
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/glesonly"
  cp -a libSDL2-2.0.so.0.* "${INSTALL}/usr/lib/glesonly/"
}

post_makeinstall_target() {
  :
}
