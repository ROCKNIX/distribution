# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="raofflineproxy-rcheevos"
# The commit RAOfflineProxy pins as its third_party/rcheevos submodule at the
# proxy's own pinned commit (248ce5a since 2026-09-28, the same submodule commit as at c1bd3724 and 0711f0b9, fork #259; upstream moved it from
# 2ad0b86 in 095867d): read from the repository's
# tree with `gh api repos/misantronic/RAOfflineProxy/contents/third_party`.
# GitHub's tarball of the proxy carries the submodule as an empty directory,
# so the sources that rc_hash is built from come in through this package and
# are compiled by raofflineproxy's own recipe into libraproxy_rchash.so, the
# library the client's ROM hashing loads (fork #179). Source only: nothing
# here is built or installed on its own.
# freshness: pinned -- follows the third_party/rcheevos submodule commit RAOfflineProxy names (fork #179)
PKG_VERSION="1433173220a7eaede6a9ed7a18e94117be1821e0"
PKG_SHA256="da635153d2dab228f3a3ef672bae56a7a6e5f57f1aacd420133521c5d3768cec"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/RetroAchievements/rcheevos"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="rcheevos, at the commit RAOfflineProxy pins: the RetroAchievements hashing (rc_hash) that the proxy's ROM scan is built from."
PKG_TOOLCHAIN="manual"
