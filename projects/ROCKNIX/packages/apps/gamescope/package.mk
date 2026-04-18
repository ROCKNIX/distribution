# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gamescope"
PKG_VERSION="f8b33d38c5acc35825c7966b208222770c4a623e"
PKG_GIT_CLONE_BRANCH="master"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/ValveSoftware/gamescope"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain wayland wayland-protocols libdrm libinput libxkbcommon pixman systemd \
                    libcap luajit libdecor libX11 libXext libXfixes libXdamage libXcomposite \
                    libXrender libXxf86vm libXtst libXi libXcursor libXmu libXres libxcb \
                    xcb-util-wm seatd hwdata SDL2"
PKG_LONGDESC="SteamOS session compositing window manager (micro-compositor for games / nested Wayland)."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="meson"
PKG_DEPENDS_HOST="toolchain:host wayland:host wayland-protocols:host glslang:host"

configure_package() {
  if [ "${VULKAN_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${VULKAN}"
  fi
}

pre_configure_target() {
  PKG_MESON_OPTS_TARGET+=" -Ddrm_backend=enabled \
                           -Dpipewire=disabled \
                           -Denable_openvr_support=false \
                           -Davif_screenshots=disabled \
                           -Dbenchmark=disabled \
                           -Dinput_emulation=disabled \
                           -Drt_cap=enabled \
                           -Dsdl2_backend=enabled"

  # Subprojects (libliftoff tests, wlroots) use -Werror; distro GCC is stricter than upstream CI.
  # - libdrm_mock.c: unused-but-set-variable
  # - wlroots xwm.c: return-type (control reaches end of non-void function)
  export TARGET_CFLAGS="${TARGET_CFLAGS} -Wno-error=unused-variable -Wno-error=unused-but-set-variable -Wno-error=return-type"
  export TARGET_CXXFLAGS="${TARGET_CXXFLAGS} -Wno-error=unused-variable -Wno-error=unused-but-set-variable -Wno-error=return-type"
}
