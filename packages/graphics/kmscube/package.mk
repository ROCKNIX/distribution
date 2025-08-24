# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="kmscube"
PKG_VERSION="e05830984e15ae77bd3dbcf41d4cd0a60010dda2"
PKG_SHA256="aae4a698213866a1381ef6a1a4cc043b22d3e930436c42e1f102e42bc7d841d2"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.freedesktop.org/mesa/kmscube"
PKG_URL="https://gitlab.freedesktop.org/mesa/kmscube/-/archive/master/kmscube-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Example KMS/GBM/EGL application"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
elif [ "${OPENGL_SUPPORT}" = "yes" ]; then
  echo "kmscube only supports OpenGLESv2"
  exit 0
fi
