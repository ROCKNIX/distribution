# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="cairomm"
PKG_VERSION="1.14.5"
PKG_SHA256="70136203540c884e89ce1c9edfb6369b9953937f6cd596d97c78c9758a5d48db"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.cairographics.org/cairomm/"
PKG_URL="https://www.cairographics.org/releases/cairomm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain sigcpp"
PKG_LONGDESC="cairomm is the official C++ interface for Cairo."

PKG_MESON_OPTS_TARGET="-Dbuild-tests=false -Dbuild-examples=false -Dbuild-documentation=false -Dmaintainer-mode=false -Dmsvc14x-parallel-installable=false"