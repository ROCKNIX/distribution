# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/audio/alsa-lib/package.mk

PKG_DEPENDS_TARGET+=" alsa-ucm-conf alsa-topology-conf"
PKG_PATCH_DIRS+=" ${DEVICE}"

PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--disable-largefile/}"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
