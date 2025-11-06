# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wlroots"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/wlroots/wlroots/"
PKG_DEPENDS_TARGET="toolchain libinput libxkbcommon pixman libdrm wayland wayland-protocols seatd xwayland hwdata libxcb xcb-util-wm"
PKG_LONGDESC="A modular Wayland compositor library"
PKG_TOOLCHAIN="meson"

case ${DEVICE} in
  SM8250|SM8550|RK3399|H700)
    PKG_VERSION="0.19.2"
    PKG_SHA256="f0530ecaa8739d15f97bd1e1edddb77e281d57e42d4263fccb67157f71730d17"
    PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/wlroots-${PKG_VERSION}.tar.gz"
  ;;
  RK3588|SDM845)
    PKG_VERSION="0.17.4-rk"
    PKG_SHA256="e9e1e14966c6272ca595307fa817fd0fefae96b13fe36c8084b3a7a55fed20d1"
    PKG_URL="https://github.com/stolen/rockchip-wlroots/archive/refs/tags/${PKG_VERSION}.tar.gz"
  ;;
  *)
    PKG_VERSION="0.19.0-rk"
    PKG_SHA256="cf247be7ec6b7be834a2469c6738aa4515e1cb085c6668cdf071bb5a0dc0f524"
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
