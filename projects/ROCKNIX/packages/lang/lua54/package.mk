# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/lang/lua54/package.mk

post_makeinstall_target() {
  cp src/lua.hpp ${SYSROOT_PREFIX}/usr/include/lua$(get_pkg_version_maj_min)
}
