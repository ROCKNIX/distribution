# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sof-bin"
PKG_VERSION="2026.09"
PKG_SHA256="fa36605af8f0e78c8cf39ede079306815fa6f29d47c2b7026753dcb2b14649d5"
PKG_LICENSE="LicenseRef-nonfree"
PKG_SITE="https://github.com/thesofproject/sof-bin"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_ARCH="x86_64"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Sound Open Firmware binaries and topologies for Intel audio DSPs."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/intel
    cp -a sof* ${INSTALL}/$(get_full_firmware_dir)/intel
}
