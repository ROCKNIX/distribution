# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gamescope"
PKG_VERSION="fa0b4d3342078f01eadff0193e09c3b561f40c03"
PKG_GIT_CLONE_BRANCH="master"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/ValveSoftware/gamescope"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain wayland wayland-protocols libdrm libinput libxkbcommon pixman systemd \
                    libcap luajit libdecor libX11 libXext libXfixes libXdamage libXcomposite \
                    libXrender libXxf86vm libXtst libXi libXcursor libXmu libXres libxcb \
                    xcb-util-wm seatd hwdata:host SDL2 pipewire gamescope-glm gamescope-stb"
PKG_LONGDESC="SteamOS session compositing window manager (micro-compositor for games / nested Wayland)."
PKG_TOOLCHAIN="meson"

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

PKG_MESON_OPTS_TARGET="-Ddrm_backend=enabled \
                       -Dpipewire=enabled \
                       -Denable_openvr_support=false \
                       -Davif_screenshots=disabled \
                       -Dbenchmark=disabled \
                       -Dinput_emulation=disabled \
                       -Drt_cap=enabled \
                       -Denable_tests=false \
                       -Dsdl2_backend=enabled"

pre_configure_target() {
  # Subprojects (libliftoff tests, wlroots) use -Werror; distro GCC is stricter than upstream CI.
  # - libdrm_mock.c: unused-but-set-variable
  # - wlroots xwm.c: return-type (control reaches end of non-void function)
  export TARGET_CFLAGS="${TARGET_CFLAGS} -Wno-error=unused-variable -Wno-error=unused-but-set-variable -Wno-error=return-type"
  export TARGET_CXXFLAGS="${TARGET_CXXFLAGS} -Wno-error=unused-variable -Wno-error=unused-but-set-variable -Wno-error=return-type"

  # glm and stb: from the fork's source packages, never from a clone.
  # gamescope's meson.build calls subproject('glm') and subproject('stb')
  # unconditionally, and both wraps are [wrap-git] at a pinned revision that
  # meson would clone at configure; the build refuses that (scripts/build,
  # --wrap-mode=nodownload, fork #226). The two trees come in as sources
  # through gamescope-glm and gamescope-stb, pinned to the wraps' revisions
  # and hash-checked at download, and are put where each wrap's directory
  # says, with the wrap's packagefiles (the meson.build each needs) laid
  # over them, which meson does only for a tree it fetched itself. The wrap
  # and the package must agree, or the build stops here and says which to
  # bump. The other subprojects are git submodules the clone carries.
  local sub dir rev src
  for sub in glm stb; do
    dir=$(sed -n 's/^directory = //p' ${PKG_BUILD}/subprojects/${sub}.wrap)
    rev=$(sed -n 's/^revision = //p' ${PKG_BUILD}/subprojects/${sub}.wrap)
    src=$(get_build_dir gamescope-${sub})
    [ -n "${dir}" ] && [ -n "${rev}" ] || die "gamescope: subprojects/${sub}.wrap names no directory or revision"
    [ "${rev}" = "$(get_pkg_version gamescope-${sub})" ] || die "gamescope: subprojects/${sub}.wrap pins ${rev} and the gamescope-${sub} package carries $(get_pkg_version gamescope-${sub}) -- bump the package to the wrap's revision"
    [ -d "${src}" ] || die "gamescope: the gamescope-${sub} package's tree is not at ${src}"
    rm -rf ${PKG_BUILD}/subprojects/${dir}
    cp -a ${src} ${PKG_BUILD}/subprojects/${dir}
    if [ -d ${PKG_BUILD}/subprojects/packagefiles/${dir} ]; then
      cp -a ${PKG_BUILD}/subprojects/packagefiles/${dir}/. ${PKG_BUILD}/subprojects/${dir}/
    fi
  done
}
