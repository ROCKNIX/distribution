# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="openbor"
PKG_VERSION="b8303cce992a0db93c3a465df3c943942fe322f8"
PKG_SHA256="8a21e40b31bf04fd5212d1bb86452f1843fcd0e8a54d073e474e51f4fc130973"
PKG_SITE="https://github.com/DCurrent/openbor"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libogg libvorbisidec libvpx libpng"
PKG_LONGDESC="OpenBOR is the ultimate 2D side scrolling engine for beat em' ups, shooters, and more!"
PKG_TOOLCHAIN="make"

post_unpack() {
  sed -i "s|-Werror||g" ${PKG_BUILD}/engine/Makefile
}

pre_make_target() {
  PKG_MAKE_OPTS_TARGET="BUILD_LINUX_${ARCH}=1 -C ${PKG_BUILD}/engine SDKPATH=${SYSROOT_PREFIX} PREFIX=${TARGET_NAME}"

  cd ${PKG_BUILD}/engine
    ./version.sh
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a OpenBOR ${INSTALL}/usr/bin/OpenBOR
    cp -a ${PKG_DIR}/scripts/start_OpenBOR.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/openbor
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/openbor
}
