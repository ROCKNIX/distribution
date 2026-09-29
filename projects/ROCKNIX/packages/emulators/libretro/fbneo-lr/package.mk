# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fbneo-lr"
PKG_VERSION="f3b774987e009d07f1322ebc4910532ed5b8c808"
PKG_SHA256="48e35bf75aa76200fb2bc64fa12d25606e0b7ebe3dcc41c37a641c33f93601d5"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/FBNeo"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
# Python3:host runs the rotation-table generator in the install step: the
# interpreter the build's PATH finds, not whatever the container carries.
PKG_DEPENDS_TARGET="toolchain Python3:host"
# The rotation-table generator is shared with the other FBA-family cores and
# sits one directory up, outside PKG_DIR, which is all calculate_stamp
# hashes of the package itself; naming it here puts it in this package's
# stamp, so an edit to it rebuilds the core and its table.
PKG_NEED_UNPACK="$(dirname "$(get_pkg_directory ${PKG_NAME})")/rotation-table-fba.py"
PKG_LONGDESC="Port of Final Burn Neo to Libretro (v0.2.97.38)."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET=" -C ../src/burner/libretro USE_CYCLONE=0 profile=performance"

if [[ "${TARGET_FPU}" =~ "neon" ]]; then
  PKG_MAKE_OPTS_TARGET+=" HAVE_NEON=1"
fi

post_unpack() {
  sed -i "s|LDFLAGS += -static-libgcc -static-libstdc++|LDFLAGS += -static-libgcc|" ${PKG_BUILD}/src/burner/libretro/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/src/burner/libretro/fbneo_libretro.so ${INSTALL}/usr/lib/libretro

  # The quarter turns this core asks the display for, per game, read from
  # the driver table of the source this build compiles. EmulationStation
  # reads it from /usr/config/emulationstation/rotation/<core>.txt on the
  # system partition, so a device has the table of the core it runs as soon
  # as the build is installed. Every pinned core's table has over 800 rows:
  # under 100 is a wrong source path: --min makes the generator fail on
  # it, and its own || die stops the build wherever the line sits.
  mkdir -p ${INSTALL}/usr/config/emulationstation/rotation
  python3 ${PKG_DIR}/../rotation-table-fba.py --min 100 ${PKG_BUILD} > ${INSTALL}/usr/config/emulationstation/rotation/fbneo.txt \
    || die "rotation table fbneo.txt: the generator failed or found under 100 games -- check the source path handed to it"
}
