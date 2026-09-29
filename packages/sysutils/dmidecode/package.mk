# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dmidecode"
PKG_VERSION="3.7"
PKG_SHA256="2c3aed12c85a1e6a9410d406d5e417c455466dc1bc7c89278bb32cf7cad91e8a"
PKG_ARCH="x86_64"
PKG_LICENSE="GPL-2.0"
PKG_SITE="http://www.nongnu.org/dmidecode/"
PKG_URL="http://download.savannah.gnu.org/releases/dmidecode/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="sysutils"
PKG_SHORTDESC="dmidecode: DMI table decoder"
PKG_LONGDESC="dmidecode: Reports information about your system's hardware as described in your system BIOS according to the SMBIOS/DMI standard."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS="PREFIX=/usr"

makeinstall_target() {
  make PREFIX=/usr DESTDIR=${INSTALL} install
}
