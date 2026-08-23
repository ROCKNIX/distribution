# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/devel/swig/package.mk

# Held at 4.1.1: swig 4.5 dropped the Python 2 compatibility macros from
# its generated preamble, and u-boot's libfdt.i still calls PyInt_AsLong,
# so binman fails to import _libfdt.so. That file is generated during the
# u-boot build rather than shipped, so there is nothing to patch. swig is
# host codegen only - being current buys us nothing. Drop this once
# u-boot's pylibfdt stops using the Python 2 API.
PKG_VERSION="4.1.1"
PKG_SHA256="2af08aced8fcd65cdb5cc62426768914bedc735b1c250325203716f78e39ac9b"
# core expanded PKG_URL against its own version when this was sourced
PKG_URL="https://downloads.sourceforge.net/project/swig/swig/swig-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
