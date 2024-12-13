# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wlroots"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/wlroots/wlroots/"
PKG_DEPENDS_TARGET="toolchain libinput libxkbcommon pixman libdrm wayland wayland-protocols seatd xwayland hwdata libxcb xcb-util-wm"
PKG_LONGDESC="A modular Wayland compositor library"
PKG_TOOLCHAIN="meson"

case ${DEVICE} in
  SD865|AMD64|RK3399|H700)
  PKG_VERSION="0.18.2"
  PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/wlroots-${PKG_VERSION}.tar.gz"
  ;;
  RK3588)
    PKG_VERSION="0.17.4-rk"
    PKG_SHA256="e9e1e14966c6272ca595307fa817fd0fefae96b13fe36c8084b3a7a55fed20d1"
    PKG_URL="https://github.com/stolen/rockchip-wlroots/archive/refs/tags/${PKG_VERSION}.tar.gz"
  ;;
  *)
    PKG_VERSION="0.18.1-rk"
    PKG_SHA256="93572a16ba48749e1a8cea4e78a1992008e2713dcb72019abfc6f7efd0947ccf"
    PKG_URL="https://github.com/stolen/rockchip-wlroots/archive/refs/tags/${PKG_VERSION}.tar.gz"
  ;;
esac


configure_package() {
  # OpenGLES Support
  if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  fi
}
# to enable xwayland package: https://gitlab.freedesktop.org/xorg/lib/libxcb-wm/-/tree/master/icccm?ref_type=heads
PKG_MESON_OPTS_TARGET="-Dxcb-errors=disabled \
                       -Dxwayland=enabled \
                       -Dexamples=false \
                       -Drenderers=gles2 \
                       -Dbackends=drm,libinput"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

pre_configure_target() {
  # wlroots does not build without -Wno flags as all warnings being treated as errors
  export TARGET_CFLAGS=$(echo "${TARGET_CFLAGS} -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-function -Wno-return-type")
}
