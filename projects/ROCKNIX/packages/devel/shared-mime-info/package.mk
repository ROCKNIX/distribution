# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/shared-mime-info/package.mk

post_makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp shared-mime-info.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig

  if [ "${WINDOWMANAGER}" = "sway" ]; then
    ${TOOLCHAIN}/bin/update-mime-database ${INSTALL}/usr/share/mime
  fi
}
