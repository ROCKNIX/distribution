# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="retroarch"
PKG_VERSION="0792144fe3a7b59908b0afdb2c01722e79040360" # v1.19.1
PKG_SITE="https://github.com/libretro/RetroArch"
PKG_URL="${PKG_SITE}.git"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain SDL2 alsa-lib libass openssl freetype zlib retroarch-assets core-info ffmpeg libass joyutils nss-mdns openal-soft libogg libvorbisidec libvorbis libvpx libpng libdrm pulseaudio miniupnpc flac"
PKG_LONGDESC="Reference frontend for the libretro API."
GET_HANDLER_SUPPORT="git"

if [ "${PIPEWIRE_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" pipewire"
fi

case ${ARCH} in
  arm|i686)
    true
    ;;
  *)
    PKG_DEPENDS_TARGET+=" empty"
    ;;
esac

PKG_PATCH_DIRS+=" ${DEVICE}"

PKG_CONFIGURE_OPTS_TARGET="   --disable-qt \
                              --enable-alsa \
                              --enable-udev \
                              --disable-opengl1 \
                              --disable-x11 \
                              --enable-zlib \
                              --enable-freetype \
                              --disable-discord \
                              --disable-vg \
                              --disable-sdl \
                              --enable-sdl2 \
                              --enable-kms \
                              --enable-ffmpeg"

case ${ARCH} in
  arm)
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-neon"
  ;;
    aarch64)
    PKG_CONFIGURE_OPTS_TARGET+=" --disable-neon"
  ;;
esac

case ${PROJECT} in
  Rockchip)
    PKG_DEPENDS_TARGET+=" librga"
  ;;
esac

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland"
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-wayland"
  case ${ARCH} in
    arm|i686)
      true
      ;;
    *)
      PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
      ;;
  esac
else
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-wayland"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles --enable-opengles3"
        case ${DEVICE} in
            RK33*|RK35*|H700|SD856)
                PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles3_1"
            ;;
            S922X)
                PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles3_1 --enable-opengles3_2"
            ;;
            AMD64)
                PKG_CONFIGURE_OPTS_TARGET+=" --disable-opengles --disable-opengles3 --disable-opengles3_1 --disable-opengles3_2"
            ;;
        esac
else
    PKG_CONFIGURE_OPTS_TARGET+=" --disable-opengles --disable-opengles3 --disable-opengles3_1 --disable-opengles3_2"
fi

if [[ "${OPENGL_SUPPORT}" = "yes" ]]; then
    PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengl"
else
    PKG_CONFIGURE_OPTS_TARGET+=" --disable-opengl"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
    PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-vulkan --enable-vulkan_display"
else
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-vulkan"
fi

pre_configure_target() {
  CFLAGS+=" -DUDEV_TOUCH_SUPPORT"
  CXXFLAGS+=" -DUDEV_TOUCH_SUPPORT"
  TARGET_CONFIGURE_OPTS=""

  cd ${PKG_BUILD}
}

make_target() {
  make HAVE_UPDATE_ASSETS=0 HAVE_LIBRETRODB=1 HAVE_BLUETOOTH=0 HAVE_NETWORKING=1 HAVE_ZARCH=1 HAVE_QT=0 HAVE_LANGEXTRA=1
  [ $? -eq 0 ] && echo "(retroarch ok)" || { echo "(retroarch failed)" ; exit 1 ; }
  make -C gfx/video_filters compiler=$CC extra_flags="$CFLAGS"
  [ $? -eq 0 ] && echo "(video filters ok)" || { echo "(video filters failed)" ; exit 1 ; }
  make -C libretro-common/audio/dsp_filters compiler=$CC extra_flags="$CFLAGS"
  [ $? -eq 0 ] && echo "(audio filters ok)" || { echo "(audio filters failed)" ; exit 1 ; }
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/retroarch ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/retroarch/filters

  case ${ARCH} in
    aarch64)
      if [ -f ${ROOT}/build.${DISTRO}-${DEVICE}.arm/retroarch-*/.install_pkg/usr/bin/retroarch ]; then
        cp -vP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/retroarch-*/.install_pkg/usr/bin/retroarch ${INSTALL}/usr/bin/retroarch32
        mkdir -p ${INSTALL}/usr/share/retroarch/filters/32bit/
        cp -rvP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/retroarch-*/.install_pkg/usr/share/retroarch/filters/64bit/* ${INSTALL}/usr/share/retroarch/filters/32bit/
      fi
    ;;
  esac

  mkdir -p ${INSTALL}/etc
  cp ${PKG_BUILD}/retroarch.cfg ${INSTALL}/etc

  mkdir -p ${INSTALL}/usr/share/retroarch/filters/64bit/video
  cp ${PKG_BUILD}/gfx/video_filters/*.so ${INSTALL}/usr/share/retroarch/filters/64bit/video
  cp ${PKG_BUILD}/gfx/video_filters/*.filt ${INSTALL}/usr/share/retroarch/filters/64bit/video

  mkdir -p ${INSTALL}/usr/share/retroarch/filters/64bit/audio
  cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.so ${INSTALL}/usr/share/retroarch/filters/64bit/audio
  cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.dsp ${INSTALL}/usr/share/retroarch/filters/64bit/audio

  # General configuration
  mkdir -p ${INSTALL}/usr/config/retroarch/
  if [ -d "${PKG_DIR}/sources/${DEVICE}" ]; then
    cp -rf ${PKG_DIR}/sources/${DEVICE}/* ${INSTALL}/usr/config/retroarch/
  else
    echo "Configure retroarch for ${DEVICE}"
    exit 1
  fi

  # Make sure the shader directories exist for overlayfs.
  for dir in common-shaders glsl-shaders slang-shaders
  do
    mkdir -p ${INSTALL}/usr/share/${dir}
    touch ${INSTALL}/usr/share/${dir}/.overlay
  done
}

post_install() {
  enable_service tmp-cores.mount
  enable_service tmp-database.mount
  enable_service tmp-assets.mount
  enable_service tmp-shaders.mount
  enable_service tmp-overlays.mount
}
