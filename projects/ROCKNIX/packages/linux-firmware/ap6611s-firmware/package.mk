# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 Rocknix (https://github.com/ROCKNIX)

PKG_NAME="ap6611s-firmware"
PKG_VERSION="9912b9a116e0073327fdc76d08660dcbab22442b"
PKG_SHA256="e7735fa394bc2f4ca13f31202ba903ffce2f762bf42f9c1db9542a24810f2927"
PKG_LICENSE="Apache"
PKG_SITE="https://github.com/armbian/firmware"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ap6611s Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/brcm
    mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/brcm/ap6275p
      cp -av brcm/SYN43711A0.hcd ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/brcm/
      cp -av ap6275p/clm_syn43711a0.blob ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/brcm/ap6275p/
      cp -av ap6275p/fw_syn43711a0_sdio.bin ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/brcm/ap6275p/
      cp -av ap6275p/nvram_ap6611s.txt ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/brcm/ap6275p/
}
