# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="vita3k-sa"
PKG_VERSION="087285ab6531bf34945512be3ac0b6c81977ed47"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Vita3K/Vita3K"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image zlib libogg libvorbis gtk3 openssl ffmpeg"
PKG_LONGDESC="vita3k"
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS+="${DEVICE}"

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

 pre_configure_target() {
  mkdir -p ${PKG_BUILD}/external
  [ -d "nativefiledialog-cmake" ] && rm -rf nativefiledialog-cmake
  cd ${PKG_BUILD}/external && git clone https://github.com/Vita3K/nativefiledialog-cmake
  [ -d "ffmpeg" ] && rm -rf ffmpeg
  cd ${PKG_BUILD}/external && git clone https://github.com/Vita3K/ffmpeg-core.git ffmpeg

  case ${TARGET_ARCH} in
    aarch64)
      CMAKE_EXTRA_OPTS="-DXXHASH_BUILD_XXHSUM=ON \
                        -DXXH_X86DISPATCH_ALLOW_AVX=OFF"
    ;;
    *)
      CMAKE_EXTRA_OPTS="-DXXH_X86DISPATCH_ALLOW_AVX=ON"
    ;;
  esac

  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                  -DBUILD_SHARED_LIBS=OFF \
                  -DUSE_DISCORD_RICH_PRESENCE=OFF \
                  -DUSE_VITA3K_UPDATE=OFF \
                  ${CMAKE_EXTRA_OPTS}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/vita3k
  cp -rf ${PKG_BUILD}/external/bin/Vita3K ${INSTALL}/usr/bin/
  cp -rf ${PKG_BUILD}/external/bin/* ${INSTALL}/usr/config/vita3k/
  rm -rf ${INSTALL}/usr/config/vita3k/Vita3K
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/vita3k/launcher
  cp ${PKG_DIR}/scripts/start_vita3k.sh ${INSTALL}/usr/config/vita3k/launcher/_Start\ Vita3K.sh
  cp ${PKG_DIR}/scripts/scan_vita3k.sh ${INSTALL}/usr/config/vita3k/launcher/_Scan\ Vita\ Games.sh
  chmod 0755 ${INSTALL}/usr/config/vita3k/launcher/*sh

  cp ${PKG_DIR}/sources/vita-gamelist.txt ${INSTALL}/usr/config/vita3k
}
