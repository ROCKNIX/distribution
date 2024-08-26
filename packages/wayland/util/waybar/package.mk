# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="waybar"
PKG_VERSION="0.10.4"
PKG_SHA256="ad1ead64aec35bc589207ea1edce90e848620d578985967d44a850a66b5ef829"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/Alexays/Waybar"
PKG_URL="https://github.com/Alexays/Waybar/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain jsoncpp gtk3 libsigcpp libinput libxkbcommon pixman pango cairo glib libfmt spdlog gtkmm libnl pipewire pulseaudio wireplumber gtk-layer-shell font-awesome"
PKG_LONGDESC="Waybar is a highly customizable Wayland bar for Sway and other Wlroots-based compositors."

PKG_MESON_OPTS_TARGET="-Dman-pages=disabled \
                       -Dtests=disabled \
                       -Dcava=disabled \
                       -Drfkill=enabled"

pre_configure_target() {
  export TARGET_CFLAGS=$(echo "${TARGET_CFLAGS} -Wno-error=switch")
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/etc/xdg/waybar
  mkdir -p ${INSTALL}/etc/xdg/waybar/hotkeys
  cp ${PKG_DIR}/config/config.jsonc ${INSTALL}/etc/xdg/waybar
  cp ${PKG_DIR}/config/style.css ${INSTALL}/etc/xdg/waybar
  cp -rf ${PKG_DIR}/hotkeys/* ${INSTALL}/etc/xdg/waybar/hotkeys
  cp ${PKG_DIR}/scripts/key_guide.sh ${INSTALL}/etc/xdg/waybar
  chmod +x ${INSTALL}/etc/xdg/waybar/key_guide.sh
}