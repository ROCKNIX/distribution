# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mame2003-plus-lr"
PKG_VERSION="a045126dad33d70ce555e7e7fe22a69d3a1efcc7"
PKG_SHA256="0b1661fb1c7d19746bd0e5d76fa10beccc5338328928e79ec620a4253a3216c4"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/mame2003-plus-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
# Python3:host runs the rotation-table generator in the install step: the
# interpreter the build's PATH finds, not whatever the container carries.
PKG_DEPENDS_TARGET="toolchain Python3:host"
# The rotation-table generator is shared with the other MAME-family cores and
# sits one directory up, outside PKG_DIR, which is all calculate_stamp
# hashes of the package itself; naming it here puts it in this package's
# stamp, so an edit to it rebuilds the core and its table.
PKG_NEED_UNPACK="$(dirname "$(get_pkg_directory ${PKG_NAME})")/rotation-table-mame.py"
PKG_LONGDESC="MAME - Multiple Arcade Machine Emulator"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mame2003_plus_libretro.so ${INSTALL}/usr/lib/libretro

  # The quarter turns this core asks the display for, per game, read from
  # the driver table of the source this build compiles. EmulationStation
  # reads it from /usr/config/emulationstation/rotation/<core>.txt on the
  # system partition, so a device has the table of the core it runs as soon
  # as the build is installed. Every pinned core's table has over 800 rows:
  # under 100 is a wrong source path: --min makes the generator fail on
  # it, and its own || die stops the build wherever the line sits.
  mkdir -p ${INSTALL}/usr/config/emulationstation/rotation
  python3 ${PKG_DIR}/../rotation-table-mame.py --min 100 ${PKG_BUILD} src/drivers > ${INSTALL}/usr/config/emulationstation/rotation/mame2003_plus.txt \
    || die "rotation table mame2003_plus.txt: the generator failed or found under 100 games -- check the source path handed to it"
}
