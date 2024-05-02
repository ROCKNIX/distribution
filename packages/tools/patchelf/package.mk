# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="patchelf"
PKG_VERSION="0.18.0"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/NixOS/patchelf"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
PKG_LONGDESC="A small utility to modify the dynamic linker and RPATH of ELF executables"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
./bootstrap.sh
}

# "configure" toolchain does not separate host and target build dirs, so
# make a fresh unpack in a dir which later is named PKG_REAL_BUILD
# It is important to generate 'configure' script here because it affects PKG_REAL_BUILD value
pre_build_host() {
  HOST_BUILD_DIR="${PKG_BUILD}/.${HOST_NAME}"
  mkdir -p "${HOST_BUILD_DIR}"
  cd "${HOST_BUILD_DIR}"
  tar -xf ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} --strip-components=1
  echo " PRE_BUILD  in ${PWD}"
  ./bootstrap.sh
  PKG_CONFIGURE_SCRIPT="${HOST_BUILD_DIR}/configure"
}
