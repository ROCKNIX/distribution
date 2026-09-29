# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mame2010-lr"
PKG_VERSION="484456818393505dd4367e6e4c116c573c04a1ec"
PKG_SHA256="2c00d52864e1ae4b0eb3335de89f29b1a8ebfe173c9e6910b302e379e92594a8"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/mame2010-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
# Python3:host runs the rotation-table generator in the install step: the
# interpreter the build's PATH finds, not whatever the container carries.
PKG_DEPENDS_TARGET="toolchain Python3:host"
# The rotation-table generator is shared with the other MAME-family cores and
# sits one directory up, outside PKG_DIR, which is all calculate_stamp
# hashes of the package itself; naming it here puts it in this package's
# stamp, so an edit to it rebuilds the core and its table.
PKG_NEED_UNPACK="$(dirname "$(get_pkg_directory ${PKG_NAME})")/rotation-table-mame.py"
PKG_LONGDESC="Late 2010 version of MAME (0.139) for libretro. Compatible with MAME 0.139 romsets."

make_target() {
  if [ "${ARCH}" == "arm" ]; then
    make PLATCFLAGS="${CFLAGS}" PTR64=0 ARM_ENABLED=1 LCPU=arm
  elif [ "${ARCH}" == "i386" ]; then
    make PLATCFLAGS="${CFLAGS}" PTR64=0 ARM_ENABLED=0 LCPU=x86
  elif [ "${ARCH}" == "x86_64" ]; then
    make PLATCFLAGS="${CFLAGS}" PTR64=1 ARM_ENABLED=0 LCPU=x86_64
  elif [ "${ARCH}" == "aarch64" ]; then
    make PLATCFLAGS="${CFLAGS}" PTR64=1 ARM_ENABLED=1 LCPU=arm64
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mame2010_libretro.so ${INSTALL}/usr/lib/libretro

  # The quarter turns this core asks the display for, per game, read from
  # the driver table of the source this build compiles. EmulationStation
  # reads it from /usr/config/emulationstation/rotation/<core>.txt on the
  # system partition, so a device has the table of the core it runs as soon
  # as the build is installed. Every pinned core's table has over 800 rows:
  # under 100 is a wrong source path: --min makes the generator fail on
  # it, and its own || die stops the build wherever the line sits.
  mkdir -p ${INSTALL}/usr/config/emulationstation/rotation
  python3 ${PKG_DIR}/../rotation-table-mame.py --min 100 ${PKG_BUILD} src/mame/drivers > ${INSTALL}/usr/config/emulationstation/rotation/mame2010.txt \
    || die "rotation table mame2010.txt: the generator failed or found under 100 games -- check the source path handed to it"
}
