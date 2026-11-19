# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ppsspp-sa"
PKG_VERSION="afbc66a318b86432642b532c575241f3716642ef" # v1.20.2
CHEAT_DB_VERSION="7c9fe1ae71155626cea767aed53f968de9f4051f" # Update cheat.db (17/01/2026)
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libzip SDL2 zlib"
PKG_LONGDESC="PPSSPPDL"
PKG_PATCH_DIRS+="${DEVICE}"

### Note:
### This package includes the NotoSansJP-Regular.ttf font.  This font is licensed under
### SIL Open Font License, Version 1.1.  The license can be found in the licenses
### directory in the root of this project, OFL.txt.
###

PKG_CMAKE_OPTS_TARGET=" -DUSE_SYSTEM_FFMPEG=OFF \
                        -DCMAKE_BUILD_TYPE=Release \
                        -DCMAKE_SYSTEM_NAME=Linux \
                        -DBUILD_SHARED_LIBS=OFF \
                        -DUSE_SYSTEM_LIBPNG=OFF \
                        -DANDROID=OFF \
                        -DWIN32=OFF \
                        -DAPPLE=OFF \
                        -DCMAKE_CROSSCOMPILING=ON \
                        -DUSING_QT_UI=OFF \
                        -DUNITTEST=OFF \
                        -DSIMULATOR=OFF \
                        -DHEADLESS=OFF \
                        -DUSE_DISCORD=OFF"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd glew"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=OFF \
			   -DUSING_GLES2=OFF"

elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=ON \
                           -DUSING_EGL=OFF \
                           -DUSING_GLES2=ON"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN_DISPLAY_KHR=ON \
                           -DVULKAN=ON \
                           -DUSING_X11_VULKAN=OFF"
  GRENDERER="3 (VULKAN)"
else
  PKG_CMAKE_OPTS_TARGET+=" -DVULKAN=OFF \
                           -DUSE_VULKAN_DISPLAY_KHR=OFF \
                           -DUSING_X11_VULKAN=OFF"
  GRENDERER="0 (OPENGL)"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=OFF"
fi

post_unpack() {
  # fix cross compiling
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

pre_configure_target() {
  sed -i 's/\-O[23]//g' ${PKG_BUILD}/CMakeLists.txt
  sed -i "s|include_directories(/usr/include/drm)|include_directories(${SYSROOT_PREFIX}/usr/include/drm)|" ${PKG_BUILD}/CMakeLists.txt

  export CPPFLAGS="${CPPFLAGS} -Wno-error -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1"
  export CXXFLAGS="${CXXFLAGS} -Wno-error -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1"
  export CFLAGS="${CFLAGS} -Wno-error -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
    cp -a PPSSPPSDL ${INSTALL}/usr/bin/ppsspp
    ln -sf /storage/.config/ppsspp/assets ${INSTALL}/usr/bin/assets

  mkdir -p ${INSTALL}/usr/config/ppsspp
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/ppsspp
    cp -a `find . -name "assets" | xargs echo` ${INSTALL}/usr/config/ppsspp
    rm -f ${INSTALL}/usr/config/ppsspp/assets/gamecontrollerdb.txt
    ln -sf NotoSansJP-Regular.ttf ${INSTALL}/usr/config/ppsspp/assets/Roboto-Condensed.ttf
    curl -Lo ${INSTALL}/usr/config/ppsspp/PSP/Cheats/cheat.db https://raw.githubusercontent.com/Saramagrean/CWCheat-Database-Plus-/${CHEAT_DB_VERSION}/cheat.db

  mkdir -p ${INSTALL}/usr/config/ppsspp/PSP/SYSTEM
    cp -aL ${PKG_DIR}/sources/${DEVICE}/* ${INSTALL}/usr/config/ppsspp/PSP/SYSTEM
}

post_install() {
  sed -e "s/@GRENDERER@/${GRENDERER}/g" -i ${INSTALL}/usr/bin/start_ppsspp.sh
}
