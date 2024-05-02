# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mali-bifrost"
PKG_VERSION="r48p0-01eac0"
PKG_LICENSE="GPL"
PKG_SITE="https://developer.arm.com/downloads/-/mali-drivers/bifrost-kernel"
PKG_URL="https://developer.arm.com/-/media/Files/downloads/mali-drivers/kernel/mali-bifrost-gpu/BX304L01B-SW-99002-${PKG_VERSION}.tar"
PKG_LONGDESC="mali-bifrost: Linux drivers for Mali Bifrost GPUs"
PKG_ARCH="aarch64"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

make_target() {
  kernel_make KDIR=$(kernel_path) -C ${PKG_BUILD} \
       CONFIG_MALI_MIDGARD=m CONFIG_MALI_PLATFORM_NAME=meson CONFIG_MALI_REAL_HW=y CONFIG_MALI_DEVFREQ=y CONFIG_MALI_GATOR_SUPPORT=y
}

makeinstall_target() {
  DRIVER_DIR=${PKG_BUILD}/product/kernel/drivers/gpu/arm/midgard

  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${DRIVER_DIR}/mali_kbase.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
