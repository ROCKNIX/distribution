# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libgudev"
PKG_VERSION="bd531e8622e2c98a1da3d28a0a6df59c844f25c0"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://gitlab.gnome.org/GNOME/libgudev"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/libgudev-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd ninja:host"
PKG_LONGDESC="Library providing GObject bindings for libudev"
PKG_TOOLCHAIN="meson"
