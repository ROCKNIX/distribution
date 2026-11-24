# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/lang/gcc/package.mk

# ROCKNIX: ship libatomic on aarch64 too (core enables arm/riscv64 only)
if [ "${TARGET_ARCH}" = "aarch64" ]; then
  OPTS_LIBATOMIC="--enable-libatomic"
  PKG_CONFIGURE_OPTS_HOST="${PKG_CONFIGURE_OPTS_HOST/--disable-libatomic/--enable-libatomic}"
fi

# ROCKNIX: build libgomp (core disables it) and ship it with the target libs
PKG_CONFIGURE_OPTS_HOST="${PKG_CONFIGURE_OPTS_HOST/--disable-libgomp/--enable-libgomp}"

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${TARGET_NAME}/libgomp/.libs/*.so* ${INSTALL}/usr/lib
}
