# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="raofflineproxy-libchdr"
# The commit RAOfflineProxy pins as its third_party/libchdr submodule at the
# proxy's own pinned commit (248ce5a since 2026-09-28, the same submodule commit as at c1bd3724; unchanged since 4e9bab48, fork #165), read the same way as
# raofflineproxy-rcheevos. The proxy's tarball carries the submodule as an
# empty directory; these sources (libchdr and the miniz, lzma and zstd
# decoders it vendors under deps/) are compiled by raofflineproxy's recipe
# into libraproxy_rchash.so so a CHD disc image hashes the way RetroArch
# hashes it (fork #179). Source only: nothing here is built or installed on
# its own.
# freshness: pinned -- follows the third_party/libchdr submodule commit RAOfflineProxy names (fork #179)
PKG_VERSION="8e7b8bd32bc676b7e5c6b42fe7d2daca986c4a0d"
PKG_SHA256="04d6c61946c95addb78f4554740283b93249b81d8437e3d8a58ca1899c824dcc"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/rtissera/libchdr"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libchdr, at the commit RAOfflineProxy pins: the CHD reader the proxy's ROM scan hashes disc images through."
PKG_TOOLCHAIN="manual"
