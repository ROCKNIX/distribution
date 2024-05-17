# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="git"
PKG_VERSION="2.42.1"
PKG_LICENSE="GPLv2"
PKG_SITE="https://git-scm.com/"
PKG_URL="https://mirrors.edge.kernel.org/pub/software/scm/git/git-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl pcre curl libiconv zlib"
PKG_LONGDESC="Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency. "

PKG_CONFIGURE_OPTS_TARGET="ac_cv_fread_reads_directories=yes \
                           ac_cv_snprintf_returns_bogus=yes \
                           ac_cv_iconv_omits_bom=yes"                          
 
pre_configure_target() {
 cd ..
 rm -rf .${TARGET_NAME}
}

make_target() {
 cd ${PKG_BUILD}
 make git
}

