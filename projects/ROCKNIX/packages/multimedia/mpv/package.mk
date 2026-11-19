# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mpv"
PKG_VERSION="41f6a645068483470267271e1d09966ca3b9f413" # 0.41.0
PKG_SHA256="068960e89211f2adc80af03f637fa393fb5e407d3dd23592c8fe8c5490bb7ae4"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/mpv-player/mpv"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ffmpeg SDL2 luajit libass libplacebo libdrm"
PKG_LONGDESC="Video player based on MPlayer/mplayer2 https://mpv.io"

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MESON_OPTS_TARGET+=" -Dgl=enabled -Degl=enabled"
elif [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MESON_OPTS_TARGET+=" -Dgl=enabled -Degl=disabled"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_MESON_OPTS_TARGET+=" -Dwayland=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dwayland=disabled"
fi

PKG_MESON_OPTS_TARGET+=" -Dsdl2-audio=enabled -Dsdl2-video=enabled -Dsdl2-gamepad=enabled"

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" libva"
  PKG_MESON_OPTS_TARGET+=" -Dvaapi=enabled"
fi

PKG_MESON_OPTS_TARGET+=" -Ddrm=enabled"

post_makeinstall_target() {
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/* 2>/dev/null ||:
  mkdir -p ${INSTALL}/usr/config/mpv
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/mpv/

  mkdir -p ${INSTALL}/etc/mpv
    cp ${PKG_DIR}/config/mpv.conf ${INSTALL}/etc/mpv/

  case ${DEVICE} in
    RK3326|RK3399|RK3566)
      sed -i 's/^hwdec=.*/&\nhwdec-codecs=all/' ${INSTALL}/etc/mpv/mpv.conf ${INSTALL}/usr/config/mpv/mpv.conf
    ;;
    RK3588*)
      sed -i 's/^hwdec=.*/hwdec=rkmpp,rkmpp-copy,auto/' ${INSTALL}/etc/mpv/mpv.conf ${INSTALL}/usr/config/mpv/mpv.conf
    ;;
    S922X|SM*)
      sed -i 's/^hwdec=.*/hwdec=v4l2m2m-copy,auto/' ${INSTALL}/etc/mpv/mpv.conf ${INSTALL}/usr/config/mpv/mpv.conf
    ;;
  esac
}
