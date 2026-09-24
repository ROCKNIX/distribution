# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kddockwidgets"
PKG_VERSION="2.4.1"
PKG_SHA256="5cd9495d9316cf6cc937bb328a7fd491c3248ef2469cfa42511f1039f6148aca"
PKG_LICENSE="GPL-2.0-only OR GPL-3.0-only"
PKG_SITE="https://github.com/KDAB/KDDockWidgets"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_LONGDESC="KDAB's Qt dock widget library"
PKG_DEPENDS_TARGET="toolchain qt6"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                       -DKDDockWidgets_QT6=ON \
                       -DKDDockWidgets_EXAMPLES=OFF \
                       -DKDDockWidgets_FRONTENDS=qtwidgets"
