# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="gzip"
PKG_VERSION="1.13"
PKG_SHA256="7454eb6935db17c6655576c2e1b0fabefd38b4d0936e0f87f48cd062ce91a057"
PKG_LICENSE="GPL"
PKG_SITE="https://ftp.gnu.org/gnu/gzip"
PKG_URL="https://ftp.gnu.org/gnu/gzip/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host"
PKG_DEPENDS_TARGET="gcc:host"
PKG_LONGDESC="GNU Gzip is a popular data compression program originally written by Jean-loup Gailly for the GNU project."

# For some weird reason gzip wrappers default to /bin/dash which we don't have
CONFIG_SHELL=/bin/bash
PKG_CONFIGURE_OPTS_TARGET=" CONFIG_SHELL=/bin/bash"
