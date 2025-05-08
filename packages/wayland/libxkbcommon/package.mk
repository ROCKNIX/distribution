# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libxkbcommon"
PKG_VERSION="1.6.0"
PKG_LICENSE="MIT"
PKG_SITE="https://xkbcommon.org"
PKG_URL="https://xkbcommon.org/download/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain xkeyboard-config libxml2 libXau libxcb wayland"
PKG_DEPENDS_HOST="toolchain:host xkeyboard-config:host libxml2:host libxcb:host libXau:host wayland:host"
PKG_LONGDESC="xkbcommon is a library to handle keyboard descriptions."

PKG_MESON_OPTS_TARGET="-Denable-docs=false"

if [ "${DISPLAYSERVER}" = "x11" ]; then
  PKG_MESON_OPTS_TARGET+=" -Denable-x11=true \
                           -Denable-wayland=false"
elif [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_MESON_OPTS_TARGET+=" -Denable-x11=true \
                           -Denable-wayland=true \
                           -Dxkb-config-root=/usr/share/X11/xkb"
else
  PKG_MESON_OPTS_TARGET+=" -Denable-x11=false \
                           -Denable-wayland=false"
fi
