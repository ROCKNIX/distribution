# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fbalpha2019-lr"
PKG_VERSION="0581797db6fdffd826086b053ced4b6b29bb6678"
PKG_SHA256="96812000a349e413d63bc5ef04ab7a330bb0b4194047c048ed6ec549b8274936"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/fbalpha"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
# Python3:host runs the rotation-table generator in the install step: the
# interpreter the build's PATH finds, not whatever the container carries.
PKG_DEPENDS_TARGET="toolchain Python3:host"
# The rotation-table generator is shared with the other FBA-family cores and
# sits one directory up, outside PKG_DIR, which is all calculate_stamp
# hashes of the package itself; naming it here puts it in this package's
# stamp, so an edit to it rebuilds the core and its table.
PKG_NEED_UNPACK="$(dirname "$(get_pkg_directory ${PKG_NAME})")/rotation-table-fba.py"
PKG_LONGDESC="Port of Final Burn Alpha to Libretro (v0.2.97.44)."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_DIR}/fbalpha2019_libretro.info ${INSTALL}/usr/lib/libretro
    cp -a fbalpha_libretro.so ${INSTALL}/usr/lib/libretro/fbalpha2019_libretro.so

  # The quarter turns this core asks the display for, per game, read from
  # the driver table of the source this build compiles. EmulationStation
  # reads it from /usr/config/emulationstation/rotation/<core>.txt on the
  # system partition, so a device has the table of the core it runs as soon
  # as the build is installed. Every pinned core's table has over 800 rows:
  # under 100 is a wrong source path: --min makes the generator fail on
  # it, and its own || die stops the build wherever the line sits.
  mkdir -p ${INSTALL}/usr/config/emulationstation/rotation
  python3 ${PKG_DIR}/../rotation-table-fba.py --min 100 ${PKG_BUILD} > ${INSTALL}/usr/config/emulationstation/rotation/fbalpha2019.txt \
    || die "rotation table fbalpha2019.txt: the generator failed or found under 100 games -- check the source path handed to it"
}
