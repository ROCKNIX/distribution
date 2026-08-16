# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gamepadtester"
PKG_VERSION="6ac49e67aa98fe3dd5c27f73306d65d4b7a82daa"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/timre13/GamepadTester"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_gfx gamecontrollerdb"
PKG_LONGDESC="A simple SDL GUI Gamepad tester"
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS+="${DEVICE}"

case ${DEVICE} in
  SM8650|SM8750|SM8550|SM8250)
    PKG_PATCH_DIRS+=" xbox"
    ;;
  *)
    PKG_PATCH_DIRS+=" legacy"
    ;;
esac

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/gamepad_test ${INSTALL}/usr/bin/gamepad-tester

  mkdir -p ${INSTALL}/usr/config/modules
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
}
