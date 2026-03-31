################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="ppsspp-lr"
PKG_VERSION="afbc66a318b86432642b532c575241f3716642ef" # v1.20.2
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="https://github.com/hrydgard/ppsspp.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libzip zstd"
PKG_LONGDESC="A PSP emulator for Android, Windows, Mac, Linux and Blackberry 10, written in C++."
GET_HANDLER_SUPPORT="git"


pre_configure_target() {
  PKG_LIBNAME="ppsspp_libretro.so"
  PKG_LIBPATH="lib/${PKG_LIBNAME}"


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

  if [ "${VULKAN_SUPPORT}" = "yes" ]
  then
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
    aarch64)
      PKG_CMAKE_OPTS_TARGET+=" -DFORCED_CPU=aarch64"
    ;;
  esac

  PKG_CMAKE_OPTS_TARGET+=" -DUSE_SYSTEM_FFMPEG=OFF \
                           -DCMAKE_BUILD_TYPE=Release \
                           -DCMAKE_SYSTEM_NAME=Linux \
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
}

pre_make_target() {
  # This script should work on any board that has issues with system ffmpeg in ppsspp
  if [ "${TARGET_ARCH}" = "aarch64" ]; then
    sed -i "s|aarch64-linux-gnu-|${TARGET_PREFIX}|g" ${PKG_BUILD}/ffmpeg/linux_arm64.sh
    (cd ${PKG_BUILD}/ffmpeg && ./linux_arm64.sh)
  fi

  # fix cross compiling
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_LIBPATH} ${INSTALL}/usr/lib/libretro/
}
