# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mali-bifrost"
PKG_LICENSE="GPL"
PKG_SITE="https://developer.arm.com/downloads/-/mali-drivers/bifrost-kernel"
PKG_LONGDESC="mali-bifrost: Linux drivers for Mali Bifrost GPUs"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

PKG_VERSION="39da994bb6fc8819e5e8c1873907dd21d17e53c1"
PKG_SHA256="f947b99a1bcb5b86ea270c1ce4cd189f4df26b3c0c8ba92c1ef256bb757afa66"
PKG_URL="http://github.com/rocknix/mali_kbase/archive/${PKG_VERSION}.tar.gz"

make_target() {
  # S922X is an actual Amlogic Meson SoC — it requires the meson platform
  # backend for correct GPU clock and power domain handling.
  # Rockchip devices use the devicetree backend which properly coordinates
  # with kernel power domain drivers during runtime PM suspend/resume cycles.
  case ${DEVICE} in
    S922X)
      MALI_PLATFORM="meson"
      ;;
    *)
      MALI_PLATFORM="devicetree"
      ;;
  esac

  kernel_make KDIR=$(kernel_path) -C ${PKG_BUILD} \
       CONFIG_MALI_MIDGARD=m CONFIG_MALI_PLATFORM_NAME=${MALI_PLATFORM} CONFIG_MALI_REAL_HW=y CONFIG_MALI_DEVFREQ=y CONFIG_MALI_GATOR_SUPPORT=y
}

makeinstall_target() {
  DRIVER_DIR=${PKG_BUILD}/product/kernel/drivers/gpu/arm/midgard

  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${DRIVER_DIR}/mali_kbase.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
