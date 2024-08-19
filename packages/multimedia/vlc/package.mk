# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="vlc"
PKG_VERSION="3.0.21"
PKG_LICENSE="GPL"
PKG_SITE="http://www.videolan.org"
PKG_URL="https://mirror.netcologne.de/videolan.org/${PKG_NAME}/${PKG_VERSION}/$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libdvbpsi gnutls ffmpeg libmpeg2 zlib flac libvorbis libxml2 pulseaudio SDL2 x264 x265 aom libogg"
PKG_LONGDESC="VideoLAN multimedia player and streamer"

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"
  export CXXLFAGS="${CXXFLAGS} -Wno-error=incompatible-pointer-types"

  ENABLED_FEATURES="--enable-silent-rules \
            --enable-run-as-root \
            --enable-sout \
            --enable-vlm \
            --enable-v4l2 \
            --enable-mpc \
            --enable-avcodec \
            --enable-avformat \
            --enable-swscale \
            --enable-postproc \
            --enable-aa \
            --enable-libmpeg2 \
            --enable-png \
            --enable-jpeg \
            --enable-libxml2 \
            --enable-pulse \
            --enable-udev \
            --enable-vlc \
            --enable-x264"

  DISABLED_FEATURES="--disable-dependency-tracking \
            --without-contrib \
            --disable-alsa \
            --disable-nls \
            --disable-dbus \
            --disable-gprof \
            --disable-cprof \
            --disable-rpath \
            --disable-debug \
            --disable-coverage \
            --disable-lua \
            --disable-notify \
            --disable-taglib \
            --disable-live555 \
            --disable-dc1394 \
            --disable-dvdread \
            --disable-dvdnav \
            --disable-opencv \
            --disable-decklink \
            --disable-sftp \
            --disable-vcd \
            --disable-libcddb \
            --disable-dvbpsi \
            --disable-screen \
            --disable-ogg \
            --disable-shout\
            --disable-mod \
            --disable-gme \
            --disable-wma-fixed \
            --disable-shine \
            --disable-omxil \
            --disable-mad \
            --disable-merge-ffmpeg \
            --disable-faad \
            --disable-flac \
            --disable-twolame \
            --disable-realrtsp \
            --disable-libtar \
            --disable-a52 \
            --disable-dca \
            --disable-vorbis \
            --disable-tremor \
            --disable-speex \
            --disable-theora \
            --disable-schroedinger \
            --disable-fluidsynth \
            --disable-zvbi \
            --disable-telx \
            --disable-libass \
            --disable-kate \
            --disable-tiger \
            --disable-libva \
            --disable-vdpau \
            --without-x \
            --disable-xcb \
            --disable-xvideo \
            --disable-sdl-image \
            --disable-freetype \
            --disable-fribidi \
            --disable-fontconfig \
            --disable-svg \
            --disable-directx \
            --disable-caca \
            --disable-oss \
            --disable-jack \
            --disable-upnp \
            --disable-skins2 \
            --disable-kai \
            --disable-macosx \
            --disable-ncurses \
            --disable-goom \
            --disable-projectm \
            --disable-mtp \
            --disable-lirc \
            --disable-libgcrypt \
            --disable-update-check \
            --disable-kva \
            --disable-bluray \
            --disable-samplerate \
            --disable-sid \
            --disable-crystalhd \
            --disable-dxva2 \
            --disable-dav1d \
            --disable-qt \
            --disable-x26410b \
            --disable-chromecast \
            --disable-static \
            --disable-a52 \
            --disable-addonmanagermodules \
            --disable-aom \
            --disable-aribb25 \
            --disable-aribsub \
            --disable-asdcp \
            --disable-bpg \
            --disable-caca \
            --disable-chromaprint \
            --disable-chromecast \
            --disable-crystalhd \
            --disable-dc1394 \
            --disable-dca \
            --disable-decklink \
            --disable-dsm \
            --disable-dv1394 \
            --disable-fluidlite \
            --disable-gme \
            --disable-goom \
            --disable-jack \
            --disable-kai \
            --disable-kate \
            --disable-kva \
            --disable-libplacebo \
            --disable-linsys \
            --disable-mfx \
            --disable-microdns \
            --disable-mmal \
            --disable-mtp \
            --disable-notify \
            --disable-projectm \
            --disable-shine \
            --disable-shout \
            --disable-sndio \
            --disable-spatialaudio \
            --disable-srt \
            --disable-telx \
            --disable-tiger \
            --disable-twolame \
            --disable-vdpau \
            --disable-vsxu \
            --disable-wasapi \
            --disable-x262 \
            --disable-zvbi"

  case ${ARCH} in
    arm)
      PKG_DEPENDS_TARGET+=" ${OPENGLES}"
      ENABLED_FEATURES+=" --enable-gles2 --enable-neon"
    ;;
    aarch64)
      PKG_DEPENDS_TARGET+=" ${OPENGLES}"
      ENABLED_FEATURES+=" --enable-gles2"
    ;;
    *)
      PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
    ;;
  esac

  PKG_CONFIGURE_OPTS_TARGET="${DISABLED_FEATURES} ${ENABLED_FEATURES}"
  export LDFLAGS="${LDFLAGS} -lresolv -fopenmp -Wl,-rpath,../src/.libs"
}

post_makeinstall_target() {
  rm -fr ${INSTALL}/usr/share/applications
  rm -fr ${INSTALL}/usr/share/icons
  rm -fr ${INSTALL}/usr/share/kde4
  rm -f ${INSTALL}/usr/bin/rvlc
  rm -f ${INSTALL}/usr/bin/vlc-wrapper
}
