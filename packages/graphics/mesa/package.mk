# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mesa"
PKG_LICENSE="OSS"
PKG_DEPENDS_TARGET="toolchain expat libdrm zstd Mako:host"
PKG_LONGDESC="Mesa is a 3-D graphics library with an API."
PKG_TOOLCHAIN="meson"
PKG_PATCH_DIRS+=" ${DEVICE}"

case ${DEVICE} in
  RK3588*)
	PKG_VERSION="832c3c7117e4366e415ded92a6f07ec203fd9233"
	PKG_SITE="https://github.com/ROCKNIX/mesa-panfork"
	PKG_URL="${PKG_SITE}.git"
  ;;
  RK3*|S922X)
    if [ "${DEVICE}" = "S922X" -a "${USE_MALI}" != "no" ]; then
      PKG_VERSION="24.0.5"
	    PKG_SITE="http://www.mesa3d.org/"
	    PKG_URL="https://gitlab.freedesktop.org/mesa/mesa/-/archive/mesa-${PKG_VERSION}/mesa-mesa-${PKG_VERSION}.tar.gz"
    else
      #Using upstream dev for panfrost
	    PKG_VERSION="acf1c7dc7377f33ff416f3c52b0be2b73a4867ad"
	    PKG_SITE="https://gitlab.freedesktop.org/mesa/mesa"
	    PKG_URL="${PKG_SITE}.git"
	    PKG_PATCH_DIRS+=" panfrost"
    fi
  ;;
  *)
	PKG_VERSION="24.0.5"
	PKG_SITE="http://www.mesa3d.org/"
	PKG_URL="https://gitlab.freedesktop.org/mesa/mesa/-/archive/mesa-${PKG_VERSION}/mesa-mesa-${PKG_VERSION}.tar.gz"
  ;;
esac

get_graphicdrivers

# For lib32 build Mesa needs some tweaks
#   * scripts/build sets --libdir=/usr/lib
#   * lib32 package moves /usr/lib into /usr/lib32
#   * in running system /usr/lib is 64-bit
#   * mesa loader looks for drivers in ${libdir}/{dri,gbm} etc.
#   * 32-bit mesa fails to load 64-bit drivers
#
# This may be worked around by setting LIBGL_DRIVERS_PATH=/usr/lib32/dri
#   but that needs careful editing of run scripts
#
# Just setting --libdir=/usr/lib32 in scripts/build fails because libtool wants exactly /usr/lib
#
# So, for 32-bit build we set a bunch of options normally derived from libdir
# This hopefully will be not needed if libtool accepts lib32 (libtool-multilib?)
case ${ARCH} in
  arm|i686)
    MESA_LIBS_PATH_OPTS=" -Ddri-drivers-path=/usr/lib32/dri -Dgbm-backends-path=/usr/lib32/gbm -Dd3d-drivers-path=/usr/lib32/d3d "
    ;;
  *)
    MESA_LIBS_PATH_OPTS=""
    ;;
esac

PKG_MESON_OPTS_TARGET=" ${MESA_LIBS_PATH_OPTS} \
                       -Dgallium-drivers=${GALLIUM_DRIVERS// /,} \
                       -Dgallium-extra-hud=false \
                       -Dgallium-omx=disabled \
                       -Dgallium-nine=true \
                       -Dgallium-opencl=disabled \
                       -Dgallium-xa=disabled \
                       -Dshader-cache=enabled \
                       -Dshared-glapi=enabled \
                       -Dopengl=true \
                       -Dgbm=enabled \
                       -Degl=enabled \
                       -Dlibunwind=disabled \
                       -Dlmsensors=disabled \
                       -Dbuild-tests=false \
                       -Dselinux=false \
                       -Dosmesa=false"

if [ "${DISPLAYSERVER}" = "x11" ]; then
  PKG_DEPENDS_TARGET+=" xorgproto libXext libXdamage libXfixes libXxf86vm libxcb libX11 libxshmfence libXrandr libglvnd glfw"
  export X11_INCLUDES=
  PKG_MESON_OPTS_TARGET+="	-Dplatforms=x11 \
				-Ddri3=enabled \
				-Dglx=dri \
				-Dglvnd=true"
elif [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland wayland-protocols libglvnd glfw"
  PKG_MESON_OPTS_TARGET+=" 	-Dplatforms=wayland,x11 \
				-Ddri3=enabled \
				-Dglx=dri \
				-Dglvnd=true"
  PKG_DEPENDS_TARGET+=" xorgproto libXext libXdamage libXfixes libXxf86vm libxcb libX11 libxshmfence libXrandr libglvnd"
  export X11_INCLUDES=
else
  PKG_MESON_OPTS_TARGET+="	-Dplatforms="" \
				-Ddri3=disabled \
				-Dglx=disabled \
				-Dglvnd=false"
fi

if [ "${LLVM_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" elfutils llvm"
  PKG_MESON_OPTS_TARGET+=" -Dllvm=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dllvm=disabled"
fi

if [ "${VDPAU_SUPPORT}" = "yes" -a "${DISPLAYSERVER}" = "x11" ]; then
  PKG_DEPENDS_TARGET+=" libvdpau"
  PKG_MESON_OPTS_TARGET+=" -Dgallium-vdpau=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dgallium-vdpau=disabled"
fi

if [ "${VAAPI_SUPPORT}" = "yes" ] && listcontains "${GRAPHIC_DRIVERS}" "(r600|radeonsi)"; then
  PKG_DEPENDS_TARGET+=" libva"
  PKG_MESON_OPTS_TARGET+=" -Dgallium-va=enabled \
                           -Dvideo-codecs=vc1dec,h264dec,h264enc,h265dec,h265enc"
else
  PKG_MESON_OPTS_TARGET+=" -Dgallium-va=disabled"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_MESON_OPTS_TARGET+=" -Dgles1=enabled -Dgles2=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dgles1=disabled -Dgles2=disabled"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN} vulkan-tools"
  PKG_MESON_OPTS_TARGET+=" -Dvulkan-drivers=${VULKAN_DRIVERS_MESA// /,}"
else
  PKG_MESON_OPTS_TARGET+=" -Dvulkan-drivers="
fi

post_makeinstall_target() {
  if [ -d "${INSTALL}/usr/lib32/dri" ]; then
    mv "${INSTALL}/usr/lib32"/* "${INSTALL}/usr/lib/"
  fi
  if [ "${DEVICE}" = "S922X" -a "${USE_MALI}" != "no" ]; then
    rm -f ${INSTALL}/usr/lib/libvulkan_panfrost.so ${INSTALL}/usr/share/vulkan/icd.d/panfrost_icd.aarch64.json
  fi
}
