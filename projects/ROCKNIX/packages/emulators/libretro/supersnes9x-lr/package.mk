################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="supersnes9x-lr"
PKG_VERSION="d7561a84555a6edcdcb2dc098824b89dab1d8c38"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/shanytc/snes9x"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="SuperSnes9x is a Snes9x-based core extended to also load and run Game Boy (.gb), Super Game Boy (.sgb), and Game Boy Color (.gbc) content via the bundled SGB subsystem, in addition to SNES/SFC, Satellaview and Sufami Turbo. Game Boy and Super Game Boy are fully supported (BIOS or BIOS-less); .gbc runs in monochrome DMG-compatibility mode. Place a real Super Game Boy BIOS (sgb.sfc / sgb2.sfc) in the system directory for authentic SGB sound and borders."

PKG_TOOLCHAIN="make"

make_target() {
  if [ "${ARCH}" == "arm" ]; then
    CXXFLAGS="${CXXFLAGS} -DARM"
  fi

  make -C libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp libretro/supersnes9x_libretro.so ${INSTALL}/usr/lib/libretro/
}
