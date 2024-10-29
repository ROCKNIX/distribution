# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mednafen"
PKG_VERSION="1.32.1"
PKG_LICENSE="mixed"
PKG_SITE="https://mednafen.github.io/"
PKG_URL="${PKG_SITE}/releases/files/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain SDL2 flac"
PKG_TOOLCHAIN="configure"

if [ "${DEVICE}" = "S922X" ]; then
  PKG_DEPENDS_TARGET+=" libegl"
fi

pre_configure_target() {

export CFLAGS="${CFLAGS} -flto -fipa-pta"
export CXXFLAGS="${CXXFLAGS} -flto -fipa-pta"
export LDFLAGS="${LDFLAGS} -flto -fipa-pta"

# unsupported modules
DISABLED_MODULES+=" --disable-apple2 \
                   --disable-sasplay \
                    --disable-ssfplay"

case ${DEVICE} in
  RK3326|RK3566*|RK3399|H700)
    DISABLED_MODULES+="   --disable-snes \
			 --disable-ss \
			 --disable-psx"
  ;;
  S922X)
    DISABLED_MODULES+="  --disable-ss \
			 --disable-snes"
  ;;
  RK3588*)
    DISABLED_MODULES+=" --disable-snes"
  ;;
esac

PKG_CONFIGURE_OPTS_TARGET="${DISABLED_MODULES}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/src/mednafen ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  chmod +x ${INSTALL}/usr/bin/start_mednafen.sh
  chmod +x ${INSTALL}/usr/bin/mednafen_gen_config.sh

  mkdir -p ${INSTALL}/usr/config/${PKG_NAME}
  cp ${PKG_DIR}/config/common/* ${INSTALL}/usr/config/${PKG_NAME}
}

post_install() {
    case ${DEVICE} in
      S922X)
        LIBEGL="export SDL_VIDEO_GL_DRIVER=\/usr\/lib\/egl\/libGL.so.1 SDL_VIDEO_EGL_DRIVER=\/usr\/lib\/egl\/libEGL.so.1"
      ;;
      *)
        LIBEGL=""
      ;;
    esac
    sed -e "s/@LIBEGL@/${LIBEGL}/g" \
        -i ${INSTALL}/usr/bin/start_mednafen.sh
}
