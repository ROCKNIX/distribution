# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gamepadtester"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ROCKNIX/GamepadTester"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_gfx gamecontrollerdb"
PKG_LONGDESC="A simple SDL GUI Gamepad tester"
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS+="${DEVICE}"

case ${DEVICE} in
  SM8650|SM8750|SM8550|SM8250|RK3576|RK3566|SDM845)
    PKG_VERSION="48d35475e1a0a5825373a56af3ab6121b12be187"
    PKG_SHA256="bcd33141e433b01a126b7b0e6fef83f1e49557a28d63ad9b45e266b1fb870156"
  ;;
  *)
    PKG_VERSION="6ac49e67aa98fe3dd5c27f73306d65d4b7a82daa"
    PKG_SHA256="dcba71ac2e673b7714a6cac12661d56e61a2eb861136bf7d74a42165d6a69be6"
    PKG_SITE="https://github.com/timre13/GamepadTester"
    PKG_PATCH_DIRS+=" legacy"
    ;;
esac

PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/gamepad_test ${INSTALL}/usr/bin/gamepad-tester

  mkdir -p ${INSTALL}/usr/config/modules
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
}
