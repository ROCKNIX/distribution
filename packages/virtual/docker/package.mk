# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="docker"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_SECTION="virtual"
PKG_LONGDESC="Container support software metapackage."

PKG_CONTAINERSUPPORT="cli containerd moby runc tini"

PKG_DEPENDS_TARGET="${PKG_CONTAINERSUPPORT}"

