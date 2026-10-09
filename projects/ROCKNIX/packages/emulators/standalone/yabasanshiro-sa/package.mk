# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="yabasanshiro-sa"
PKG_VERSION="a40dace1ae0af3ebd45848549fdf396f40e3930f"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/sydarn/yabause"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 boost openal-soft zlib"
PKG_LONGDESC="Yabause is a Sega Saturn emulator and took over as Yaba Sanshiro"
PKG_TOOLCHAIN="cmake-make"
PKG_BUILD_FLAGS="+speed"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_EGL=ON -DUSE_OPENGL=ON"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_EGL=ON -DUSE_OPENGL=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_SYSTEM_PROCESSOR=x86_64
                         -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                         -DOPENGL_opengl_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                         -DOPENGL_glx_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                         -DLIBPNG_LIB_DIR=${SYSROOT_PREFIX}/usr/lib \
                         -Dpng_STATIC_LIBRARIES=${SYSROOT_PREFIX}/usr/lib/libpng16.so \
                         -DCMAKE_BUILD_TYPE=Release \
                         -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"

post_unpack() {
  # use host versions
  sed -i "s|COMMAND m68kmake|COMMAND ${PKG_BUILD}/m68kmake_host|" ${PKG_BUILD}/yabause/src/musashi/CMakeLists.txt
  sed -i "s|COMMAND ./bin2c|COMMAND ${PKG_BUILD}/bin2c_host|" ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/CMakeLists.txt
  find ${PKG_BUILD} -type f -name "CMakeLists.txt" -exec sed -i 's/^\s*cmake_minimum_required.*$/cmake_minimum_required(VERSION 3.5)/' {} +
}

configure_package() {
  PKG_CMAKE_SCRIPT="${PKG_BUILD}/yabause/CMakeLists.txt"
}

pre_configure_target() {
  case ${ARCH} in
    aarch64)
      PKG_CMAKE_OPTS_TARGET+=" -DYAB_WANT_ARM7=ON \
                               -DYAB_WANT_DYNAREC_DEVMIYAX=ON \
                               -DYAB_PORTS=retro_arena \
                               -DCMAKE_PROJECT_INCLUDE=${PKG_BUILD}/yabause/src/retro_arena/n2.cmake"
      ;;
    x86_64)
      PKG_CMAKE_OPTS_TARGET+=" -DYAB_PORTS=retro_arena \
                               -DCMAKE_PROJECT_INCLUDE=${PKG_BUILD}/yabause/src/retro_arena/pc.cmake"
      ;;
  esac
}

pre_make_target() {
  # runs on host so make them manually if package is not crosscompile friendly
  ${HOST_CC} ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/resources/bin2c.c -o ${PKG_BUILD}/bin2c_host
  ${HOST_CC} ${PKG_BUILD}/yabause/src/musashi/m68kmake.c -o ${PKG_BUILD}/m68kmake_host
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/src/retro_arena/yabasanshiro ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_yabasanshiro.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/yabasanshiro
    cp -a ${PKG_DIR}/config/config ${INSTALL}/usr/config/yabasanshiro/.config
    cp -a ${PKG_DIR}/config/devices ${INSTALL}/usr/config/yabasanshiro
}
