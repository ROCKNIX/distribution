# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/python/system/dbussy/package.mk

PKG_TOOLCHAIN="manual"

make_target() {
  exec_thread_safe python3 setup.py build
}

makeinstall_target() {
  exec_thread_safe python3 setup.py install --root=${INSTALL} --prefix=/usr
}
