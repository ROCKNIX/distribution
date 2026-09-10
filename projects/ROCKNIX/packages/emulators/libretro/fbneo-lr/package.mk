# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fbneo-lr"
PKG_VERSION="7e5d732ac1097fdea4439b6af9b8e2bf40ab86df" # DsNo (260817)
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/aleksei74/FBNeo"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of Final Burn Neo to Libretro (v0.2.97.38)."
PKG_TOOLCHAIN="make"

pre_configure_target() {
sed -i "s|LDFLAGS += -static-libgcc -static-libstdc++|LDFLAGS += -static-libgcc|" "${PKG_BUILD}/src/burner/libretro/Makefile"

PKG_MAKE_OPTS_TARGET=" -C ${PKG_BUILD}/src/burner/libretro USE_CYCLONE=0 profile=performance GIT_VERSION=${PKG_VERSION:0:10}"

if [[ "${TARGET_FPU}" =~ "neon" ]]; then
  PKG_MAKE_OPTS_TARGET+=" HAVE_NEON=1"
fi

post_unpack() {
  sed -i "s|LDFLAGS += -static-libgcc -static-libstdc++|LDFLAGS += -static-libgcc|" ${PKG_BUILD}/src/burner/libretro/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/src/burner/libretro/fbneo_libretro.so ${INSTALL}/usr/lib/libretro
}
