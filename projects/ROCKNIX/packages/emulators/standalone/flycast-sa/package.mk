# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="flycast-sa"
PKG_VERSION="5f4eefab5852d1c832ad8ffdf514fef8c217f1ac" #v2.5
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/flyinghead/flycast"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain alsa SDL2 libzip zip curl miniupnpc lua54 libao"
PKG_LONGDESC="Flycast is a multiplatform Sega Dreamcast, Naomi and Atomiswave emulator"
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS+="${DEVICE}"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CMAKE_OPTS_TARGET+="  -USE_OPENGL=ON -DUSE_GLES=OFF"

elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_GLES=ON"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=ON"
  GRENDERER="4"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=OFF"
  GRENDERER="0"
fi

pre_configure_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-error=array-bounds"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_OPENMP=ON"
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/CMakeLists.txt
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/flycast
  cp ${PKG_BUILD}/.${TARGET_NAME}/flycast ${INSTALL}/usr/bin/flycast
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  cp -r ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/flycast

  chmod +x ${INSTALL}/usr/bin/*
}

post_install() {
  sed -e "s/@GRENDERER@/${GRENDERER}/g" -i ${INSTALL}/usr/bin/start_flycast.sh
}
