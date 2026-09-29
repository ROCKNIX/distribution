# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ryzenadj"
PKG_VERSION="0.19.0"
PKG_SHA256="d1998b6c2d1b564f5d43c786cbf764ca9a1d8bb213e2001f98f611ead3087c7e"
PKG_ARCH="x86_64"
PKG_LICENSE="LGPL-3.0"
PKG_SITE="https://github.com/FlyGoat/RyzenAdj"
PKG_URL="https://github.com/FlyGoat/RyzenAdj/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain pciutils systemd"
PKG_SECTION="sysutils"
PKG_SHORTDESC="ryzenadj: Adjust power management settings for Ryzen APUs"
PKG_LONGDESC="ryzenadj: Tool for adjusting power management settings for Ryzen Mobile Processors, including TDP, temperature limits, and performance profiles."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                       -DBUILD_SHARED_LIBS=OFF \
                       -DCMAKE_EXE_LINKER_FLAGS=-ludev"
