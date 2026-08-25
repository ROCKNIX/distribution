# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ppsspp-lr"
PKG_VERSION="fa50bb1976065c4f8b1b47af227d367fe9771555" # v1.20.4
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libzip zstd"
PKG_LONGDESC="A PSP emulator for Android, Windows, Mac, Linux and Blackberry 10, written in C++."

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd glew glslang"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=OFF \
                           -DUSING_GLES2=OFF"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=ON \
                           -DUSING_EGL=OFF \
                           -DUSING_GLES2=ON \
                           -DVULKAN=OFF \
                           -DUSE_VULKAN_DISPLAY_KHR=OFF\
                           -DUSING_X11_VULKAN=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN_DISPLAY_KHR=ON \
                           -DVULKAN=ON \
                           -DEGL_NO_X11=1 \
                           -DMESA_EGL_NO_X11_HEADERS=1"
else
  PKG_CMAKE_OPTS_TARGET+=" -DVULKAN=OFF"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=OFF"
fi

case ${TARGET_ARCH} in
  aarch64) PKG_CMAKE_OPTS_TARGET+=" -DFORCED_CPU=aarch64" ;;
esac

PKG_CMAKE_OPTS_TARGET+=" -DUSE_SYSTEM_FFMPEG=ON \
                         -DBUILD_SHARED_LIBS=OFF \
                         -DANDROID=OFF \
                         -DWIN32=OFF \
                         -DAPPLE=OFF \
                         -DLIBRETRO=ON \
                         -DCMAKE_CROSSCOMPILING=ON \
                         -DUSING_QT_UI=OFF \
                         -DUNITTEST=OFF \
                         -DSIMULATOR=OFF \
                         -DHEADLESS=OFF \
                         -DUSE_DISCORD=OFF"

post_unpack() {
  # fix cross compiling
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a lib/ppsspp_libretro.so ${INSTALL}/usr/lib/libretro
}
