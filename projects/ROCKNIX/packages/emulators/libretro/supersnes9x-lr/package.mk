# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="supersnes9x-lr"
PKG_VERSION="691e47b40fb38fa522a5471462344a2f0206b7a8"
PKG_SHA256="f8646c63337e8d0319afd86e0245b529db174dbec8b5aa7fd5a0e7773130fab5"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/shanytc/snes9x"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="SuperSnes9x is a Snes9x-based core extended to also load and run Game Boy (.gb), Super Game Boy (.sgb), and Game Boy Color (.gbc) content via the bundled SGB subsystem, in addition to SNES/SFC, Satellaview and Sufami Turbo. Game Boy and Super Game Boy are fully supported (BIOS or BIOS-less); .gbc runs in monochrome DMG-compatibility mode. Place a real Super Game Boy BIOS (sgb.sfc / sgb2.sfc) in the system directory for authentic SGB sound and borders."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a libretro/supersnes9x_libretro.so ${INSTALL}/usr/lib/libretro
}
