# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/readline/package.mk

PKG_CONFIGURE_OPTS_TARGET="bash_cv_wcwidth_broken=no \
                           --enable-shared \
                           --disable-static \
                           --with-curses"
