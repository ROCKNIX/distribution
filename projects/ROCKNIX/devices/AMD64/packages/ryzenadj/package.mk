# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ryzenadj"
PKG_VERSION="ea71739b4a3e1a0a624dfd1c9c268a31cb2a4182"
PKG_SHA256="85e86ddec653b883fe93ce5772969cf4dc825489b32c41289d97dd08d385c41a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/FlyGoat/RyzenAdj"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain pciutils systemd"
PKG_LONGDESC="Adjust power management settings for Ryzen Mobile Processors."
PKG_BUILD_FLAGS="+pic"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    cp -a libryzenadj.so ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/usr/bin
    cp -a ryzenadj ${INSTALL}/usr/bin
}
