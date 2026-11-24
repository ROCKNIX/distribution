# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dosbox-pure-lr"
PKG_VERSION="cdaea10ce8cac231bc341ca05d4c5e4e5fe0fbd5"
PKG_SHA256="c1c30bedc7254459d446047541570aad907252fdeb151daed2190ba64703ab97"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/schellingb/dosbox-pure"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="A port of DOSBox to libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a dosbox_pure_libretro.so ${INSTALL}/usr/lib/libretro
}
