# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/multimedia/gstreamer/gst-plugins-bad/package.mk

# Upstream builds this for nothing in our images and throws every library
# away. webkitgtk 2.54 links gstreamer-mpegts -- the library, not the
# demuxer plugin -- as a hard requirement of the video it cannot build
# without (fork #228, D-WORKFLOW-038), so this override turns the mpegts
# pieces on and keeps their library, and nothing else changes.
#
# The option string is upstream's own: the generic recipe builds it inside
# pre_configure_target, so that function is kept under another name and
# called first, and only the two mpegts options are flipped in what it
# produced. Reading the string out of the recipe's text instead (as this
# override once did) broke on a quoted value ending a line. If either flip
# finds nothing to flip, the generic string has changed shape and the
# package stops rather than configuring without the library WebKit needs.
eval "gst_plugins_bad_generic_$(declare -f pre_configure_target)"

pre_configure_target() {
  gst_plugins_bad_generic_pre_configure_target
  PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dmpegtsdemux=disabled/-Dmpegtsdemux=enabled}"
  PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dmpegtsmux=disabled/-Dmpegtsmux=enabled}"
  case "${PKG_MESON_OPTS_TARGET}" in
    *-Dmpegtsdemux=enabled*) ;;
    *) die "gst-plugins-bad: the generic option string has no -Dmpegtsdemux to enable" ;;
  esac
  case "${PKG_MESON_OPTS_TARGET}" in
    *-Dmpegtsmux=enabled*) ;;
    *) die "gst-plugins-bad: the generic option string has no -Dmpegtsmux to enable" ;;
  esac
}

post_makeinstall_target() {
  # Only libgstmpegts-1.0 is kept, and it has to be there: WebKit cannot
  # start without it, so its absence fails the package here rather than
  # the sign-in window at load. The name checked is the one the loader
  # asks for, the soname libgstmpegts-1.0.so.0, and it has to resolve to a
  # file -- a link whose file is missing matches a glob and loads nothing --
  # before the keep and again in what was kept.
  local keep="${PKG_BUILD}/.rocknix-keep"
  [ -f "${INSTALL}/usr/lib/libgstmpegts-1.0.so.0" ] \
    || die "gst-plugins-bad: libgstmpegts-1.0 was not built -- WebKit needs it"
  rm -rf "${keep}" && mkdir -p "${keep}/lib"
  cp -a ${INSTALL}/usr/lib/libgstmpegts-1.0.so* "${keep}/lib"/
  safe_remove ${INSTALL}
  mkdir -p ${INSTALL}/usr/lib
  cp -a "${keep}/lib"/. ${INSTALL}/usr/lib/
  rm -rf "${keep}"
  [ -f "${INSTALL}/usr/lib/libgstmpegts-1.0.so.0" ] \
    || die "gst-plugins-bad: libgstmpegts-1.0 was not kept -- WebKit needs it"
}
