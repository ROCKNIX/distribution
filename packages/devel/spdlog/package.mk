# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="spdlog"
PKG_VERSION="1.11.0"
PKG_SHA256="ca5cae8d6cac15dae0ec63b21d6ad3530070650f68076f3a4a862ca293a858bb"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/gabime/spdlog"
PKG_URL="https://github.com/gabime/spdlog/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="spdlog is a very fast, header-only/compiled, C++ logging library."

PKG_MESON_OPTS_TARGET="-Dbuild-tests=false \
                       -Dbuild-examples=false"
