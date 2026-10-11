# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/boost/package.mk

PKG_DEPENDS_TARGET+=" icu"

makeinstall_target() {
  local b2_arch=""
  if [ "${TARGET_ARCH}" = "aarch64" ]; then
    b2_arch="abi=aapcs address-model=64 architecture=arm"
  fi

  ${TOOLCHAIN}/bin/b2 -d2 --ignore-site-config \
                      --layout=system \
                      --prefix=${SYSROOT_PREFIX}/usr \
                      --toolset=gcc link=static \
                      binary-format=elf threading=multi ${b2_arch} \
                      --with-chrono \
                      --with-context \
                      --with-date_time \
                      --with-filesystem \
                      --with-iostreams \
                      --with-locale \
                      --with-nowide \
                      --with-program_options \
                      --with-python \
                      --with-random \
                      --with-regex -sICU_PATH="${SYSROOT_PREFIX}/usr" \
                      --with-serialization \
                      --with-thread \
                      install
}
