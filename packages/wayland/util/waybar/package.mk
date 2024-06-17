# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="waybar"
PKG_VERSION="0.9.9"
PKG_SHA256="3b6f72d0c09a4a05a36b3e9b8a29f5a5d6c1d7ba50d80b9c654a0b71515e4c8f"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/Alexays/Waybar"
PKG_URL="https://github.com/Alexays/Waybar/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain jsoncpp gtk3 libsigcpp libinput libxkbcommon pixman pango cairo glib"
PKG_LONGDESC="Waybar is a highly customizable Wayland bar for Sway and other Wlroots-based compositors."

PKG_MESON_OPTS_TARGET="-Dexamples=disabled \
                       -Dman-pages=disabled \
                       -Dtests=disabled"

pre_configure_target() {
  export TARGET_CFLAGS=$(echo "${TARGET_CFLAGS} -Wno-error=switch")
  ./getHotkeys.sh
}

post_makeinstall_target() {
  # clean up
  safe_remove ${INSTALL}/usr/share/*

  # install config
  mkdir -p ${INSTALL}/usr/share/waybar
  cp ${PKG_DIR}/config/config.jsonc /storage/.config/waybar
  cp ${PKG_DIR}/config/style.css /storage/.config/waybar
  cp ${PKG_DIR}/config/*.txt ${INSTALL}/usr/share/waybar
  cp ${PKG_DIR}/scripts/loadHotkeys.sh ${INSTALL}/usr/share/waybar
}

post_install() {
  enable_service waybar.service
}