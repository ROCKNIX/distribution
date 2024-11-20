# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="es-theme-art-book-next"
PKG_VERSION="b4d4f573ddb790c397d0a78bef8c35cb4e927464"
PKG_LICENSE="CUSTOM"
PKG_SITE="https://github.com/anthonycaccese/art-book-next-es"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Art Book Next"
PKG_TOOLCHAIN="manual"

if [ "${ES_WIP}" ]; then
  PKG_VERSION="01f083bd38a34a1b29a514dedac4c35fd285f8bb"
  PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
else
  PKG_VERSION="e1561c28b0a97b5b58303c775d16d357b7b9ede5"
  PKG_URL="https://github.com/anthonycaccese/art-book-next-jelos/archive/${PKG_VERSION}.tar.gz"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/themes/${PKG_NAME}
    cp -rf * ${INSTALL}/usr/share/themes/${PKG_NAME}
}
