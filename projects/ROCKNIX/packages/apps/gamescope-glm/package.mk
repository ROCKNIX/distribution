# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
PKG_NAME="gamescope-glm"
# The revision gamescope's own subprojects/glm.wrap names ([wrap-git],
# revision below is the wrap's, byte for byte), carried as a source so the
# build never clones it: gamescope's meson.build calls subproject('glm')
# unconditionally, and scripts/build refuses meson's own download
# (--wrap-mode=nodownload, the rule a build fetches no dependency of its own).
# gamescope's recipe copies this tree to subprojects/glm before it configures
# and lays the wrap's packagefiles (the meson.build glm lacks) over it. Source
# only: nothing here is built or installed on its own.
# freshness: pinned -- follows subprojects/glm.wrap at gamescope's pinned commit (bump both together)
PKG_VERSION="0af55ccecd98d4e5a8d1fad7de25ba429d60e863"
PKG_SHA256="e7f187d83523f505eb38dd25d297ea6c0d4ed856d733e808f18253f5a8fa88a0"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/g-truc/glm"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_SOURCE_NAME="glm-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="OpenGL Mathematics at the revision gamescope's meson wrap pins, as a source for gamescope's subprojects."
PKG_TOOLCHAIN="manual"
