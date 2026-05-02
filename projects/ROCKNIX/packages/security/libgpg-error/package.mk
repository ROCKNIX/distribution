# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/security/libgpg-error/package.mk

pre_configure_target() {
  PKG_CONFIGURE_OPTS_TARGET="CC_FOR_BUILD=${HOST_CC} --disable-static --enable-shared --disable-nls --disable-rpath --with-gnu-ld --with-pic"

  # inspired by openembedded
  case ${TARGET_ARCH} in
    aarch64)
      GPGERROR_TUPLE=aarch64-unknown-linux-gnu
      GPGERROR_TARGET=linux-gnu${TARGET_ABI}
      ;;
    arm)
      GPGERROR_TUPLE=arm-unknown-linux-gnueabi
      GPGERROR_TARGET=linux-gnu${TARGET_ABI}
      ;;
    x86_64)
      GPGERROR_TUPLE=x86_64-unknown-linux-gnu
      GPGERROR_TARGET=linux-gnu
      ;;
  esac

  cp ${PKG_BUILD}/src/syscfg/lock-obj-pub.${GPGERROR_TUPLE}.h ${PKG_BUILD}/src/syscfg/lock-obj-pub.${GPGERROR_TARGET}.h
}
