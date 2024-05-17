# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="asus-firmware"
PKG_VERSION="25a5ec1248ae56303cffcd5c113fb10538d18cff"
PKG_LICENSE="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/LICENSE.cirrus" # Probably
PKG_SITE="https://gitlab.com/asus-linux/firmware"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASUS ROG Ally audio firmware"
PKG_TOOLCHAIN="manual"

make_target() {
  : 
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/cirrus ||:
  rsync -a cirrus/* ${INSTALL}/$(get_full_firmware_dir)/cirrus/
}

