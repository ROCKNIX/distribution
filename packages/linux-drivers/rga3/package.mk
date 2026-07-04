# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rga3"
# Pristine mirror of drivers/video/rockchip/rga3 (Rockchip BSP kernel); the
# mainline port + RK3576 enablement are applied from patches/.
PKG_VERSION="23e78a0b080603376409d7c8e6af925162b5b617"
PKG_SITE="https://github.com/rockchip-linux/kernel"
PKG_URL="https://github.com/felixjones/linux-rga3-mirror.git"
PKG_LICENSE="GPL-2.0"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_LONGDESC="Rockchip multi-RGA (RGA2/RGA2E/RGA3) 2D accelerator driver. RK3576 uses a mainline kernel with no in-tree multi-RGA driver (only the older V4L2 rockchip-rga), so build the BSP driver out-of-tree to provide the /dev/rga miscdevice that librga consumers use."
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M="${PKG_BUILD}" modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/rga3.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  # No MODULE_DEVICE_TABLE, so udev can't autoload it from a DT modalias.
  mkdir -p ${INSTALL}/usr/lib/modules-load.d
  echo "rga3" > ${INSTALL}/usr/lib/modules-load.d/rga3.conf
}
