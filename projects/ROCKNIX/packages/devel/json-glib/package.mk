# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/devel/json-glib/package.mk

# json-glib's introspection needs the host glib tooling
PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} glib:host"
