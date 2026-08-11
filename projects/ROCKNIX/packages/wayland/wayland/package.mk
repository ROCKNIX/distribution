# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/wayland/wayland/package.mk

# core builds only the scanner for the host; we need libwayland there too
PKG_MESON_OPTS_HOST="-Dlibraries=true \
                     -Dscanner=true \
                     -Dtests=false \
                     -Ddocumentation=false \
                     -Ddtd_validation=false"
