# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/graphics/cairo/package.mk

configure_package() {
  if [ "${OPENGL}" != "no" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGL}"
  fi

  if [ "${OPENGLES}" != "no" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  fi

  case ${DISPLAYSERVER} in
    "x11"|"wl")
      PKG_DEPENDS_TARGET+=" libxcb libXrender libX11 mesa"
    ;;
  esac
}

eval "core_$(declare -f pre_configure_target)"
pre_configure_target() {
  core_pre_configure_target
  case ${DISPLAYSERVER} in
    "x11"|"wl")
      PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dxlib=disabled/-Dxlib=enabled}"
      PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dxcb=disabled/-Dxcb=enabled}"
      PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dxlib-xcb=disabled/-Dxlib-xcb=enabled}"
    ;;
  esac
}
