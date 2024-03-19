# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="idtech-lr"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://rocknix.org"
PKG_LONGDESC="Package for all iD Software game engines."
PKG_TOOLCHAIN="manual"

if [[ "${OPENGL_SUPPORT}" = "yes" ]] && [[ ! "${DEVICE}" = "S922X" ]]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
  PKG_DEPENDS_TARGET+=" vitaquake3-lr"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_DEPENDS_TARGET+=" ecwolf-lr prboom-lr tyrquake-lr vitaquake2-lr"
fi

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" boom3-lr"
fi
