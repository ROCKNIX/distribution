# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="SDL2"
PKG_VERSION="2.30.8"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL2-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus pulseaudio libdrm SDL2:host"
PKG_LONGDESC="Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware."
PKG_DEPENDS_HOST="toolchain:host distutilscross:host"

if [ ! "${OPENGL_SUPPORT}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGL=ON \
                           -DVIDEO_OPENGL=ON \
                           -DVIDEO_KMSDRM=OFF"
  if [ "${PREFER_GLES}" = "yes" ] && [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" SDL2_glesonly "
  fi
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGL=OFF \
                           -DVIDEO_OPENGL=OFF \
                           -DVIDEO_KMSDRM=OFF"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGLES=ON \
                           -DVIDEO_OPENGLES=ON \
                           -DVIDEO_KMSDRM=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGLES=OFF \
                           -DVIDEO_OPENGLES=OFF \
                           -DVIDEO_KMSDRM=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_VULKAN=ON \
                           -DVIDEO_OPENGL=OFF \
                           -DVIDEO_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_VULKAN=OFF \
                           -DVIDEO_VULKAN=OFF"
fi

if [ "${DISPLAYSERVER}" = "wl" ]
then
  PKG_DEPENDS_TARGET+=" wayland "
  case ${ARCH} in
    arm|i686)
      true
      ;;
    *)
      PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
      ;;
  esac
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_WAYLAND=ON \
                           -DVIDEO_WAYLAND=ON \
                           -DVIDEO_WAYLAND_QT_TOUCH=ON \
                           -DWAYLAND_SHARED=ON \
                           -DVIDEO_X11=OFF \
                           -DSDL_X11=OFF"
else
  PKG_CMAKE_OPTS_TARGET+=" -DVIDEO_WAYLAND=OFF \
                           -DVIDEO_WAYLAND_QT_TOUCH=ON \
                           -DWAYLAND_SHARED=OFF \
                           -DVIDEO_X11=OFF \
                           -DSDL_X11=OFF"
fi

case ${PROJECT} in
  Rockchip)
    PKG_DEPENDS_TARGET+=" librga"
    PKG_PATCH_DIRS_TARGET+="${DEVICE}"
  ;;
esac

pre_configure_target(){

  if [ -n "${PKG_PATCH_DIRS_TARGET}" ]
  then
    ###
    ### Patching here is necessary to allow SDL2 to be built for
    ### use by host builds without requiring additional unnecessary
    ### packages to also be built (and break) during the build.
    ###
    ### It may be better served as a hook in scripts/build.
    ###

    if [ -d "${PKG_DIR}/patches/${PKG_PATCH_DIRS_TARGET}" ]
    then
      cd $(get_build_dir SDL2)
      for PATCH in ${PKG_DIR}/patches/${PKG_PATCH_DIRS_TARGET}/*
      do
        patch -p1 <${PATCH}
      done
      cd -
    fi

    ### End
  fi

  export LDFLAGS="${LDFLAGS} -ludev"
  PKG_CMAKE_OPTS_TARGET+="-DSDL_STATIC=OFF \
                         -DLIBC=ON \
                         -DGCC_ATOMICS=ON \
                         -DALTIVEC=OFF \
                         -DOSS=OFF \
                         -DALSA=ON \
                         -DALSA_SHARED=ON \
                         -DJACK=OFF \
                         -DJACK_SHARED=OFF \
                         -DESD=OFF \
                         -DESD_SHARED=OFF \
                         -DARTS=OFF \
                         -DARTS_SHARED=OFF \
                         -DNAS=OFF \
                         -DNAS_SHARED=OFF \
                         -DLIBSAMPLERATE=OFF \
                         -DLIBSAMPLERATE_SHARED=OFF \
                         -DSNDIO=OFF \
                         -DDISKAUDIO=OFF \
                         -DDUMMYAUDIO=OFF \
                         -DVIDEO_X11=OFF \
                         -DVIDEO_MIR=OFF \
                         -DMIR_SHARED=OFF \
                         -DVIDEO_COCOA=OFF \
                         -DVIDEO_DIRECTFB=OFF \
                         -DVIDEO_VIVANTE=OFF \
                         -DDIRECTFB_SHARED=OFF \
                         -DFUSIONSOUND=OFF \
                         -DFUSIONSOUND_SHARED=OFF \
                         -DVIDEO_DUMMY=OFF \
                         -DINPUT_TSLIB=ON \
                         -DSDL_HIDAPI_JOYSTICK=ON \
                         -DPTHREADS=ON \
                         -DPTHREADS_SEM=ON \
                         -DDIRECTX=OFF \
                         -DSDL_DLOPEN=ON \
                         -DCLOCK_GETTIME=OFF \
                         -DSDL_RPATH=OFF \
                         -DRENDER_D3D=OFF \
                         -DPIPEWIRE=ON \
                         -DPULSEAUDIO=ON"
}

post_makeinstall_target() {
  sed -e "s:\(['=LI]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/sdl2-config
  rm -rf ${INSTALL}/usr/bin
}
