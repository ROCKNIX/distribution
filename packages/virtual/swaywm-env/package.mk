# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="swaywm-env"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_SECTION="virtual"
PKG_LONGDESC="swaywm-env: Sway window manager environment"

if [ ! "${BASE_ONLY}" = "true" ]
then
  PKG_DEPENDS_TARGET+=" sway wlr-randr swayimg"
fi
