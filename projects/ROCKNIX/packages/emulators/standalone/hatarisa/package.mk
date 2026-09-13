# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hatarisa"
PKG_VERSION="6da06056d89bb39777063388d82d065d9e2e31fd"
PKG_SHA256="282eb1536e1bfd9c87ac8cad79b5b5761ca7ade5a5c7ed5498508c768fb352fc"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/hatari/hatari"
PKG_URL="https://github.com/hatari/hatari/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux glibc systemd alsa-lib SDL2 portaudio zlib capsimg libpng"
PKG_DEPENDS_UNPACK="capsimg"
PKG_LONGDESC="Hatari is an Atari ST/STE/TT/Falcon emulator"

post_unpack() {
  sed -i "s|COMMAND cc|COMMAND ${TOOLCHAIN}/bin/host-gcc|g" ${PKG_BUILD}/src/cpu/CMakeLists.txt

  # copy IPF Support Library include files
  mkdir -p ${PKG_BUILD}/src/includes/caps
    cp -a $(get_build_dir capsimg)/LibIPF/* ${PKG_BUILD}/src/includes/caps
    cp -a $(get_build_dir capsimg)/Core/CommonTypes.h ${PKG_BUILD}/src/includes/caps
    cp -a $(get_install_dir capsimg)/usr/lib/libcapsimage.so.5.1 ${PKG_BUILD}
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DCMAKE_SKIP_RPATH=ON \
                         -DDATADIR="/usr/config/hatari" \
                         -DBIN2DATADIR="../../storage/.config/hatari" \
                         -DCAPSIMAGE_INCLUDE_DIR=${PKG_BUILD}/src/include \
                         -DCAPSIMAGE_LIBRARY=${PKG_BUILD}/libcapsimage.so.5.1"

  # add library search path for loading libcapsimage library
  LDFLAGS="${LDFLAGS} -Wl,-rpath='${PKG_BUILD}'"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a src/hatari ${INSTALL}/usr/bin/hatarisa
    cp -a ${PKG_DIR}/scripts/start_hatari.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/hatari
    touch ${INSTALL}/usr/config/hatari/hatari.nvram
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/hatari
}
