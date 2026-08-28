# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gamepadcalibration"
PKG_VERSION="2077e7af7e9a8c1df54af6f1959cb92daea03207"
PKG_SHA256="f14730170a41ec183a203bdad98e5acd089ab59cd580cd0235a5eda39759b677"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/cdeletre/GPcal"
PKG_URL="https://github.com/cdeletre/GPcal/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="Python3 SDL2 gamecontrollerdb pyxel"
PKG_LONGDESC="A gamepad calibration tool for the Retroid Pocket 5 and Mini"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/share
    tar -xzf ${PKG_BUILD}/rocknix/gpcal-python-3.13.tgz -C ${INSTALL}/usr/local/share
    rm -rf ${INSTALL}/usr/local/share/gpcal/pyxel

  case ${DEVICE} in
    SM8250)
      sed -i 's|^PARAMETERS_DIR_PATH=.*|import os\nPARAMETERS_DIR_PATH = "/sys/module/mangmi_pocket_max/parameters" if os.path.exists("/sys/module/mangmi_pocket_max/parameters") else "/sys/module/retroid/parameters"|' \
        ${INSTALL}/usr/local/share/gpcal/Klib/RPocket.py
      sed -i 's|^GAMEPAD_NAME=.*|from Klib.RPocket import PARAMETERS_DIR_PATH\nGAMEPAD_NAME = "MANGMI Pocket Max Joypad" if "mangmi" in PARAMETERS_DIR_PATH else "Retroid Pocket Gamepad"|' \
        ${INSTALL}/usr/local/share/gpcal/Klib/PyxUI.py
      ;;
    SM8550|SM8750)
      sed -i 's|/sys/module/retroid/parameters|/sys/module/rsinput/parameters|g' ${INSTALL}/usr/local/share/gpcal/Klib/RPocket.py
      ;;
    SM6115)
      sed -i 's|/sys/module/retroid/parameters|/sys/module/mangmi/parameters|g' ${INSTALL}/usr/local/share/gpcal/Klib/RPocket.py
      ;;
  esac

  # restart inputplumber after the driver re-reads the calibration
  sed -i '/echo 1 > .*update_params/a\
            savefile.write("sleep 0.5\\n")\
            savefile.write("# Restart InputPlumber\\n")\
            savefile.write("systemctl restart inputplumber\\n")
' ${INSTALL}/usr/local/share/gpcal/Klib/RPocket.py

  mkdir -p ${INSTALL}/usr/config/modules
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
}
