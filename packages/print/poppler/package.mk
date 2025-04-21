# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="poppler"
PKG_VERSION="23.05.0"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.freedesktop.org/poppler/poppler"
PKG_URL="https://gitlab.freedesktop.org/poppler/poppler/-/archive/${PKG_NAME}-${PKG_VERSION}/${PKG_NAME}-${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib libpng libjpeg-turbo fontconfig boost"
PKG_LONGDESC="This is Poppler, a library for rendering PDF files, and examining or modifying their structure."
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=release \
                         -DENABLE_LIBOPENJPEG=none \
                         -DENABLE_GLIB=ON \
                         -DENABLE_QT5=off \
                         -DENABLE_CPP=off"

  # Disable "gobject-introspection"
  sed -i "s|set(HAVE_INTROSPECTION \${INTROSPECTION_FOUND})|set(HAVE_INTROSPECTION "NO")|g" ${PKG_BUILD}/CMakeLists.txt
}

