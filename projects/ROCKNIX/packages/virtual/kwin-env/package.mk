# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kwin-env"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_SECTION="virtual"
PKG_LONGDESC="kwin-env: KWin window manager environment"

if [ ! "${BASE_ONLY}" = "true" ]
then
  PKG_DEPENDS_TARGET+=" foot xkbcomp rocknix-screenshot"
fi
