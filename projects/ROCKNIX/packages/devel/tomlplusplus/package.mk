# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="tomlplusplus"
PKG_VERSION="3.4.0"
PKG_SHA256="8517f65938a4faae9ccf8ebb36631a38c1cadfb5efa85d9a72e15b9e97d25155"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/marzer/tomlplusplus"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Header-only TOML config file parser and serializer for C++17"
# Meson does not install the tomlplusplus CMake package the consumers look for
PKG_TOOLCHAIN="cmake"
