# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/rust/rust/package.mk

# ROCKNIX: our cargo packages read the linker setup from the toolchain cargo home
post_configure_host() {
  mkdir -p ${TOOLCHAIN}/cargo_home
    cp -a ${PKG_BUILD}/cargo_home/config.toml ${TOOLCHAIN}/cargo_home
}
