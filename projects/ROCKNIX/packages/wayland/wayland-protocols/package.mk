# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/wayland/wayland-protocols/package.mk

# we build this for the host as well
PKG_DEPENDS_HOST="toolchain:host wayland:host"
