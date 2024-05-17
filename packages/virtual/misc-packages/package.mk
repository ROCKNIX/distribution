# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="misc-packages"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_SECTION="virtual"
PKG_LONGDESC="misc-packages: Metapackage for miscellaneous packages"

if [ ! "${BASE_ONLY}" = "true" ]
then
  PKG_DEPENDS_TARGET+=" ${ADDITIONAL_PACKAGES}"
fi
