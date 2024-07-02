# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 351ELEC
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="yabasanshiro-sa"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/devmiyax/yabause"
PKG_ARCH="arm aarch64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 boost openal-soft zlib"
PKG_LONGDESC="Yabause is a Sega Saturn emulator and took over as Yaba Sanshiro"
PKG_TOOLCHAIN="cmake-make"
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="+speed"
PKG_PATCH_DIRS+="${DEVICE}"

case ${TARGET_ARCH} in
  aarch64|arm)
    PKG_VERSION="c7618d2ecbf77b1e8188fa8af4fa1cfb34833a72"
    PKG_GIT_CLONE_BRANCH="pi4-1-9-0"
  ;;
  *)
    PKG_VERSION="82cb29171ebe61cf0129682794af5ceb5acaa0f2"
    PKG_GIT_CLONE_BRANCH="master"
  ;;
esac

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

post_unpack() {
  # use host versions
  sed -i "s|COMMAND m68kmake|COMMAND ${PKG_BUILD}/m68kmake_host|" ${PKG_BUILD}/yabause/src/musashi/CMakeLists.txt
  sed -i "s|COMMAND ./bin2c|COMMAND ${PKG_BUILD}/bin2c_host|" ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/CMakeLists.txt
}

pre_make_target() {
  # runs on host so make them manually if package is not crosscompile friendly
  ${HOST_CC} ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/resources/bin2c.c -o ${PKG_BUILD}/bin2c_host
  ${HOST_CC} ${PKG_BUILD}/yabause/src/musashi/m68kmake.c -o ${PKG_BUILD}/m68kmake_host
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="${PKG_BUILD}/yabause "

  if [ ! "${OPENGL}" = "no" ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DUSE_EGL=ON -DUSE_OPENGL=ON"
  fi

  if [ "${OPENGLES_SUPPORT}" = yes ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DUSE_EGL=ON -DUSE_OPENGL=OFF"
  fi

  #if [ "${VULKAN_SUPPORT}" = "yes" ]
  #then
  #  PKG_CMAKE_OPTS_TARGET+=" -DYAB_WANT_VULKAN=ON"
  #else
  #  PKG_CMAKE_OPTS_TARGET+=" -DYAB_WANT_VULKAN=OFF"
  #fi

  case ${ARCH} in
    aarch64)
      PKG_CMAKE_OPTS_TARGET+=" -DYAB_WANT_ARM7=ON \
                               -DYAB_WANT_DYNAREC_DEVMIYAX=ON \
                               -DCMAKE_TOOLCHAIN_FILE=${PKG_BUILD}/yabause/src/retro_arena/n2.cmake \
                               -DYAB_PORTS=retro_arena"
    ;;
  esac

  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_SYSTEM_PROCESSOR=x86_64"

  PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                           -DOPENGL_opengl_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                           -DOPENGL_glx_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                           -DLIBPNG_LIB_DIR=${SYSROOT_PREFIX}/usr/lib \
                           -Dpng_STATIC_LIBRARIES=${SYSROOT_PREFIX}/usr/lib/libpng16.so \
                           -DCMAKE_BUILD_TYPE=Release \
						   -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -a ${PKG_BUILD}/src/retro_arena/yabasanshiro ${INSTALL}/usr/bin/yabasanshiro
  cp -a ${PKG_DIR}/scripts/start_yabasanshiro.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/start_yabasanshiro.sh
  mkdir -p ${INSTALL}/usr/config/yabasanshiro
  cp ${PKG_DIR}/config/config ${INSTALL}/usr/config/yabasanshiro/.config
  cp -r ${PKG_DIR}/config/devices ${INSTALL}/usr/config/yabasanshiro/
}
