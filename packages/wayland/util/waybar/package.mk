# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="waybar"
PKG_VERSION="0.10.3"
PKG_SHA256="50a9ae85d3dcfef04e4bc4e0f3470f187964e4466c156e5558850cea84a3df5c"
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
  cp ${PKG_DIR}/config/config.jsonc ${INSTALL}/etc/xdg/waybar
  cp ${PKG_DIR}/config/style.css ${INSTALL}/etc/xdg/waybar
}

post_install() {
  case "${WINDOWMANAGER}" in
    weston*) 
      enable_service waybar.service
      ;;
  esac
}
