# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
PKG_NAME="gamescope-stb"
# The revision gamescope's own subprojects/stb.wrap names ([wrap-git],
# revision below is the wrap's, byte for byte), carried as a source so the
# build never clones it: gamescope's meson.build calls subproject('stb')
# unconditionally, and scripts/build refuses meson's own download
# (--wrap-mode=nodownload). gamescope's recipe copies this tree to
# subprojects/stb before it configures and lays the wrap's packagefiles (the
# meson.build stb lacks) over it. Source only: nothing here is built or
# installed on its own.
# freshness: pinned -- follows subprojects/stb.wrap at gamescope's pinned commit (bump both together)
PKG_VERSION="5736b15f7ea0ffb08dd38af21067c314d6a3aae9"
PKG_SHA256="d00921d49b06af62aa6bfb97c1b136bec661dd11dd4eecbcb0da1f6da7cedb4c"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nothings/stb"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_SOURCE_NAME="stb-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="the stb single-file libraries at the revision gamescope's meson wrap pins, as a source for gamescope's subprojects."
PKG_TOOLCHAIN="manual"
