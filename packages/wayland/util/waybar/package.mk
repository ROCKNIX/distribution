# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="waybar"
PKG_VERSION="0.10.3"
PKG_SHA256="50a9ae85d3dcfef04e4bc4e0f3470f187964e4466c156e5558850cea84a3df5c"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/Alexays/Waybar"
PKG_URL="https://github.com/Alexays/Waybar/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain jsoncpp gtk3 libsigcpp libinput libxkbcommon pixman pango cairo glib libfmt spdlog gtkmm"
PKG_LONGDESC="Waybar is a highly customizable Wayland bar for Sway and other Wlroots-based compositors."

PKG_MESON_OPTS_TARGET="-Dman-pages=disabled \
                       -Dtests=disabled"

pre_configure_target() {
  export TARGET_CFLAGS=$(echo "${TARGET_CFLAGS} -Wno-error=switch")
  ${PKG_DIR}/scripts/getHotkeys.sh
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