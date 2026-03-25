# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wlroots"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/wlroots/wlroots/"
PKG_DEPENDS_TARGET="toolchain libinput libxkbcommon pixman libdrm wayland wayland-protocols seatd xwayland hwdata libxcb xcb-util-wm"
PKG_LONGDESC="A modular Wayland compositor library"
PKG_TOOLCHAIN="meson"

case ${DEVICE} in
  RK3326|RK3566|S922X)
    # despite the '-rk' indication this is a wlroots version with libmali hacks
    PKG_VERSION="0.19.3-rk"
    PKG_SHA256="5385dc105f2c4c5fe3157e0b0299d6508765086d605fe4efe3ae437d4f18a5d9"
    PKG_PATCH_DIRS+=" libmali"
    PKG_URL="https://github.com/rocknix/rockchip-wlroots/archive/refs/tags/${PKG_VERSION}.tar.gz"
  ;;
  RK3588|SDM845)
    PKG_VERSION="0.17.4-rk"
    PKG_SHA256="e9e1e14966c6272ca595307fa817fd0fefae96b13fe36c8084b3a7a55fed20d1"
    PKG_URL="https://github.com/rocknix/rockchip-wlroots/archive/refs/tags/${PKG_VERSION}.tar.gz"
  ;;
  *)
    PKG_VERSION="0.19.3"
    PKG_SHA256="a6ff89b64ea15e424d1b0db4a22145fccf5ec2ff2e7b8af0fa35e2ac8975986f"
    PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/wlroots-${PKG_VERSION}.tar.gz"
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
