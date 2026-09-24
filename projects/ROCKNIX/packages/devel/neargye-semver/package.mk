# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="neargye-semver"
PKG_VERSION="1.0.0-rc"
PKG_SHA256="343a667ecf619ead05ba75ccd6bc500e7a809a450b2a79fe3ee92238f2ecf814"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/Neargye/semver"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Semantic Versioning for modern C++"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DSEMVER_OPT_BUILD_EXAMPLES=OFF \
                       -DSEMVER_OPT_BUILD_TESTS=OFF \
                       -DSEMVER_OPT_INSTALL=ON"
