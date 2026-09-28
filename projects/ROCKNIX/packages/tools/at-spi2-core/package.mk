# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/chrome-depends/at-spi2-core/package.mk

PKG_DEPENDS_TARGET+=" libXext libXi"

pre_configure_target() {
  PKG_MESON_OPTS_TARGET="-Ddocs=false \
                         -Dintrospection=disabled \
                         -Ddbus_daemon=/usr/bin/dbus-daemon"

  TARGET_LDFLAGS="${TARGET_LDFLAGS} -lXi -lXext"
}
