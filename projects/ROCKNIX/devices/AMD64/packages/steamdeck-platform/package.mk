# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

# sources/steamdeck.c and sources/steamdeck-hwmon.c are Valve's drivers from the SteamOS
# kernel (drivers/mfd, drivers/hwmon), unmodified, at linux-integration 6.15.8-valve1.
PKG_NAME="steamdeck-platform"
PKG_VERSION="49248f4e2ad186679349461f2c518b94734bd1f1"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://gitlab.com/evlaV/linux-integration"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_LONGDESC="Valve's Steam Deck EC drivers: fan speed and target, battery charge limits."
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${PKG_BUILD}/*.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
