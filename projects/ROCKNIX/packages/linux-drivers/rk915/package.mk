# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
PKG_NAME="rk915"
PKG_VERSION="86f0d0e07afe156651ce5eec3e315f66ef79a59f"
PKG_SHA256="27ca0f8ce96e62a0b28d0404a0516a2d188df1d5a7a5a3f9c98ad4944e9581c8"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/sunshineinabox/rk915"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="rk915: Rockchip RK915 SDIO WiFi driver, mainline port"

# Pinned to the head of https://github.com/stolen/rk915/pull/2, which targets
# Linux 7.1 and moves the kernel-side changes onto the standard MMC card-quirks
# framework. The upstream main branch still targets 6.12.

PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

# Needs 035-rk915-mmc-quirks.patch, which registers the card quirks this driver
# relies on, keyed off compatible = "rockchip,rk915" in the DT.

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD} CONFIG_RK915=m
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp *.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  # Loaded via request_firmware as "rockchip/rk915_fw.bin" and
  # "rockchip/rk915_patch.bin" (inc/firmware.h). Byte-identical to the blobs in
  # the vendor EmuELEC image, so this is the right firmware for the revision.
  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/rockchip
    cp -av firmware/rockchip/rk915_fw.bin firmware/rockchip/rk915_patch.bin \
       ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/rockchip
  # The driver detects its own firmware faults and asks mac80211 to restart the
  # hardware, but the firmware re-download that follows always fails, so
  # mac80211 gives up and the link never comes back. Reloading the module does
  # restore it, reliably. Ship a watchdog that watches for that signature and
  # does exactly that; see the header of rk915-recover.sh.
  mkdir -p ${INSTALL}/usr/lib/systemd/system
    cp ${PKG_DIR}/system.d/rk915-recover.service ${INSTALL}/usr/lib/systemd/system
  mkdir -p ${INSTALL}/usr/lib/rk915
    cp ${PKG_DIR}/system.d/rk915-recover.sh ${INSTALL}/usr/lib/rk915
    chmod +x ${INSTALL}/usr/lib/rk915/rk915-recover.sh
}

post_install() {
  enable_service rk915-recover.service
}
