# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present BrooksyTech (https://github.com/brooksytech)

PKG_NAME="glfw"
PKG_VERSION="e2c9264"
PKG_LICENSE="zlib"
PKG_DEPENDS_TARGET="toolchain expat libdrm libxkbcommon libXrandr libXinerama libXcursor libXi Mako:host "
PKG_SITE="https://github.com/glfw/glfw"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="GLFW graphics library for wayland & x11"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
        PKG_CMAKE_OPTS_TARGET+="        -DBUILD_SHARED_LIBS=ON \
                                        -DGLFW_BUILD_DOCS=OFF \
                                        -DGLFW_BUILD_EXAMPLES=OFF \
                                        -DGLFW_BUILD_TESTS=OFF"
                                        }

if [ "${DISPLAYSERVER}" = "x11" ]; then
	PKG_DEPENDS_TARGET+=" xorgproto libXext libXdamage libXfixes libXxf86vm libxcb libX11 libxshmfence libXrandr libglvnd"
	PKG_CMAKE_OPTS_TARGET+=" -DGLFW_BUILD_X11=ON"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
	PKG_DEPENDS_TARGET+=" wayland wayland-protocols libglvnd"
	PKG_NEED_UNPACK="$(get_pkg_directory wayland)"
	PKG_CMAKE_OPTS_TARGET+=" -DGLFW_BUILD_WAYLAND=ON"
fi

post_unpack() {
  sed -i "s|\${WAYLAND_CLIENT_PKGDATADIR}|${TOOLCHAIN}/share/wayland|" ${PKG_BUILD}/src/CMakeLists.txt
}

