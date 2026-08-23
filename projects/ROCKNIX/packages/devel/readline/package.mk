# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/readline/package.mk

# --with-curses only picks the termcap interface; nothing links a termcap
# library into libreadline.so, which is left with tgetent/tputs/tgoto
# undefined. bfd and gold tolerate that, mold does not. Name the library
# explicitly: "=yes" resolves to -ltinfo, which exists here only as a static
# archive, and the symbols live in libtinfow regardless.
PKG_CONFIGURE_OPTS_TARGET="bash_cv_wcwidth_broken=no \
                           --enable-shared \
                           --disable-static \
                           --with-curses \
                           --with-shared-termcap-library=-ltinfow"
