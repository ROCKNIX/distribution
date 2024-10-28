# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)


PKG_NAME="gamescope"
PKG_VERSION="426fc5865a5a00339ab17bf006fddcca8a68675f"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ChimeraOS/gamescope/"
PKG_URL="https://github.com/ChimeraOS/gamescope.git"
PKG_DEPENDS_TARGET="toolchain wayland wayland-protocols libdrm libxkbcommon libinput json-c wlroots gdk-pixbuf xcb-util-wm xwayland xkbcomp vulkan-headers glslang libXdamage pixman pipewire libdecor lcms2 glm openvr libXRes"
PKG_LONGDESC="gamescope is a micro wayland compositor useful for games. It creates a virtual environment for a game application to run in that helps solves various headaches such as resolution, alt-tabbing, mouse focusing issues etc. Gamescope also tries to remove as many unneccessary copies as it can and should provide better latency."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="meson"

#PKG_MESON_OPTS_TARGET=""

pre_configure_target() {
:
}

post_makeinstall_target() {
:
}

post_install() {
:
}

