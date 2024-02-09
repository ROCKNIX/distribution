# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wlroots"
PKG_VERSION="0.17.1"
PKG_SHA256="b4b1b08daf0728cd2648fb57660493e5b3eafe4fcc081c138de864895181cdfe"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/wlroots/wlroots/"
PKG_URL="${PKG_SITE}-/archive/${PKG_VERSION}/wlroots-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libinput libxkbcommon pixman libdrm wayland wayland-protocols seatd xwayland hwdata libxcb xcb-util-wm"
PKG_LONGDESC="A modular Wayland compositor library"
PKG_TOOLCHAIN="meson"

configure_package() {
  # OpenGLES Support
  if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  fi
}
# to enable xwayland package: https://gitlab.freedesktop.org/xorg/lib/libxcb-wm/-/tree/master/icccm?ref_type=heads
PKG_MESON_OPTS_TARGET="-Dxcb-errors=disabled \
					   -Dxwayland=disabled \
                       -Dexamples=false \
                       -Drenderers=gles2 \
					   -Dbackends=drm,libinput"

pre_configure_target() {
  # wlroots does not build without -Wno flags as all warnings being treated as errors
  export TARGET_CFLAGS=$(echo "${TARGET_CFLAGS} -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-function")
}
