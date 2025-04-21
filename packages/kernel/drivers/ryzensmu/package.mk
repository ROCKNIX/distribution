# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ryzensmu"
PKG_VERSION="0.1.5"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.com/leogx9r/ryzen_smu"
PKG_URL="https://gitlab.com/leogx9r/ryzen_smu/-/archive/v${PKG_VERSION}/ryzensmu-v{PKG_VERSION}.tar.gz"
PKG_LONGDESC="A Linux kernel driver that exposes access to the SMU on certain AMD Ryzen processors."
PKG_TOOLCHAIN="make"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make \
       ARCH=${TARGET_KERNEL_ARCH} \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       TARGET=$(kernel_version) \
       KERNEL_MODULES=$(get_build_dir linux)/.install_pkg/$(get_full_module_dir) \
       KERNEL_BUILD=$(get_build_dir linux)
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp *.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
