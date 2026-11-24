# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/graphics/glew/package.mk

PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_POLICY_VERSION_MINIMUM=3.5"

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER} xwayland xrandr libXi libX11"
  PKG_CMAKE_OPTS_TARGET+=" -DGLEW_X11=ON"
fi

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

unset -f make_target makeinstall_target

pre_configure() {
  PKG_CMAKE_SCRIPT=${PKG_BUILD}/build/cmake/CMakeLists.txt
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DBUILD_UTILS=OFF \
                           -DGLEW_REGAL=OFF \
                           -DGLEW_OSMESA=OFF \
                           -DGLEW_EGL=ON \
                           -DBUILD_SHARED_LIBS=ON"
}
