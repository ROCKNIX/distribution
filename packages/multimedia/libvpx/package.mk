# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="libvpx"
PKG_VERSION="df655cf4fb6c2a23b964544acd015cc715752830" # 1.13.1
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/webmproject/libvpx"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_HOST="toolchain nasm:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="WebM VP8/VP9 Codec"

configure_host() {
  HOST_ARCH=$(uname -m)
  case ${HOST_ARCH} in
    aarch64)
      PKG_HOST_NAME_LIBVPX="arm64-linux-gcc"
      ;;
    arm)
      PKG_HOST_NAME_LIBVPX="armv7-linux-gcc"
      ;;
    x86_64)
      PKG_HOST_NAME_LIBVPX="x86_64-linux-gcc"
      ;;
  esac
  ${PKG_CONFIGURE_SCRIPT} --prefix=${TOOLCHAIN} \
                        --extra-cflags="${CFLAGS}" \
                        --as=nasm \
                        --target=${PKG_HOST_NAME_LIBVPX} \
                        --disable-docs \
                        --disable-examples \
                        --disable-shared \
                        --disable-tools \
                        --disable-unit-tests \
                        --disable-vp8-decoder \
                        --disable-vp9-decoder \
                        --enable-ccache \
                        --enable-pic \
                        --enable-static \
                        --enable-vp8 \
                        --enable-vp9
}

configure_target() {

  case ${ARCH} in
    aarch64)
      PKG_TARGET_NAME_LIBVPX="arm64-linux-gcc"
      ;;
    arm)
      PKG_TARGET_NAME_LIBVPX="armv7-linux-gcc"
      ;;
    x86_64)
      PKG_TARGET_NAME_LIBVPX="x86_64-linux-gcc"
      ;;
  esac

  ${PKG_CONFIGURE_SCRIPT} --prefix=/usr \
                        --extra-cflags="${CFLAGS}" \
                        --as=nasm \
                        --target=${PKG_TARGET_NAME_LIBVPX} \
                        --disable-docs \
                        --disable-examples \
                        --disable-shared \
                        --disable-tools \
                        --disable-unit-tests \
                        --disable-vp8-decoder \
                        --disable-vp9-decoder \
                        --enable-ccache \
                        --enable-pic \
                        --enable-static \
                        --enable-vp8 \
                        --enable-vp9
}
