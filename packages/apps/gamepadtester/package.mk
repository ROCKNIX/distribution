# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gamepadtester"
PKG_VERSION="6ac49e67aa98fe3dd5c27f73306d65d4b7a82daa"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/timre13/GamepadTester"
PKG_URL="https://github.com/timre13/GamepadTester/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_gfx gamecontrollerdb"
PKG_LONGDESC="A simple SDL GUI Gamepad tester"
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS+="${DEVICE}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -P ${PKG_BUILD}/.${TARGET_NAME}/gamepad_test ${INSTALL}/usr/bin/gamepad-tester

  mkdir -p ${INSTALL}/usr/config/modules
  cp -P ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
}
