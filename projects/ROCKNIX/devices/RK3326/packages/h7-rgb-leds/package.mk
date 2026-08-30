# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
PKG_NAME="h7-rgb-leds"
PKG_VERSION="1"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ROCKNIX/distribution"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Gusgu H7: control the WS2812 RGB LEDs over /dev/spidev1.0"
PKG_TOOLCHAIN="manual"

# The H7's RGB LEDs are WS2812s on spi1 MOSI. There is no kernel driver for
# them in 7.1 and the stock firmware drives them from userspace too, so this
# is a small tool rather than a module. The wire format is documented at the top
# of scripts/h7-rgb, along with how it was recovered.

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/h7-rgb ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/h7-rgb

  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cp ${PKG_DIR}/system.d/*.service ${INSTALL}/usr/lib/systemd/system/
  enable_service h7-rgb-leds.service
}
