# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="gamesupport"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_SECTION="virtual"
PKG_LONGDESC="Game support software metapackage."

PKG_GAMESUPPORT="sixaxis rocknix-hotkey jstest-sdl gamecontrollerdb sdljoytest sdltouchtest control-gen"

PKG_DEPENDS_TARGET="${PKG_GAMESUPPORT}"

