# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/multimedia/gstreamer/gst-plugins-base/package.mk

# GL needs the EGL/GLES headers and wayland-client in the sysroot before
# meson looks for them (fork #228).
PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} mesa wayland"

# Upstream throws the whole install away -- this package exists there only to
# populate the sysroot so other things can link. That works right up until
# something links it and then has to *run*: WebKit pulls in libgstapp, audio,
# video, tag, pbutils, allocators and fft, and without them
# cloud-signin-window dies at load with "cannot open shared object file".
#
# So keep the shared libraries and nothing else. The plugins, headers,
# pkg-config files and tools stay build-time only, as before.
# WebKit builds its media pipeline out of appsrc/appsink, and upstream
# disables that plugin because nothing else in the image wanted it. Without
# it WebKit asks the registry for "appsink", gets NULL, and segfaults
# dereferencing it -- taking the whole web process down a second after every
# page load, which presents as keystrokes not reaching the page rather than
# as anything to do with media.
#
# Restated in full rather than patched: the generic recipe builds this string
# from scratch inside pre_configure_target, so a substitution at global scope
# is overwritten before configure sees it, and there is no configure hook to
# chain onto. Only -Dapp differs from upstream; keep the rest in step when
# rebasing.
pre_configure_target() {
  PKG_MESON_OPTS_TARGET="-Dgl=enabled \
                         -Dgl_platform=egl \
                         -Dgl_winsys=wayland \
                         -Dadder=disabled \
                         -Dapp=enabled \
                         -Daudioconvert=disabled \
                         -Daudiomixer=disabled \
                         -Daudiorate=disabled \
                         -Daudioresample=disabled \
                         -Daudiotestsrc=disabled \
                         -Dcompositor=disabled \
                         -Dencoding=disabled \
                         -Dgio=disabled \
                         -Dgio-typefinder=disabled \
                         -Doverlaycomposition=disabled \
                         -Dpbtypes=disabled \
                         -Dplayback=disabled \
                         -Drawparse=enabled \
                         -Dsubparse=enabled \
                         -Dtcp=disabled \
                         -Dtypefind=disabled \
                         -Dvideoconvertscale=disabled \
                         -Dvideorate=disabled \
                         -Dvideotestsrc=disabled \
                         -Dvolume=disabled \
                         -Dalsa=disabled \
                         -Dcdparanoia=disabled \
                         -Dlibvisual=disabled \
                         -Dogg=disabled \
                         -Dopus=disabled \
                         -Dpango=disabled \
                         -Dtheora=disabled \
                         -Dtremor=disabled \
                         -Dvorbis=disabled \
                         -Dx11=disabled \
                         -Dxshm=disabled \
                         -Dxi=disabled \
                         -Dxvideo=disabled \
                         -Dexamples=disabled \
                         -Dtests=disabled \
                         -Dtools=disabled \
                         -Dintrospection=disabled \
                         -Dnls=disabled \
                         -Dorc=disabled \
                         -Dglib_debug=disabled \
                         -Dglib_assert=false \
                         -Dglib_checks=false \
                         -Dpackage-name=gst-plugins-base \
                         -Dpackage-origin=LibreELEC.tv \
                         -Ddoc=disabled"
}

post_makeinstall_target() {
  # The libraries and plugins, not the libraries alone: see the appsink
  # paragraph above. What WebKit loads and cannot start without -- the
  # libraries it links and the plugin that provides appsink -- has to be
  # there, so its absence fails the package here rather than the sign-in
  # window at load or a second after it. Each is checked by the name the
  # loader asks for -- a library's soname, lib<name>-1.0.so.0, and the
  # plugin's own file -- resolving to a file, before the keep and again in
  # what was kept: a link whose file is missing matches a glob and loads
  # nothing, and neither does a file whose name only starts the same way.
  local keep="${PKG_BUILD}/.rocknix-keep" f
  local needs="libgstapp-1.0.so.0 libgstaudio-1.0.so.0 libgstvideo-1.0.so.0 libgsttag-1.0.so.0
               libgstpbutils-1.0.so.0 libgstallocators-1.0.so.0 libgstfft-1.0.so.0 gstreamer-1.0/libgstapp.so"
  for f in ${needs}; do
    [ -f "${INSTALL}/usr/lib/${f}" ] || die "gst-plugins-base: ${f##*/} was not built -- WebKit needs it"
  done
  rm -rf "${keep}" && mkdir -p "${keep}/lib" "${keep}/plugins"
  cp -a ${INSTALL}/usr/lib/libgst*.so* "${keep}/lib"/
  cp -a ${INSTALL}/usr/lib/gstreamer-1.0/*.so "${keep}/plugins"/
  safe_remove ${INSTALL}
  mkdir -p ${INSTALL}/usr/lib/gstreamer-1.0
  cp -a "${keep}/lib"/. ${INSTALL}/usr/lib/
  cp -a "${keep}/plugins"/. ${INSTALL}/usr/lib/gstreamer-1.0/
  rm -rf "${keep}"
  for f in ${needs}; do
    [ -f "${INSTALL}/usr/lib/${f}" ] || die "gst-plugins-base: ${f##*/} was not kept -- WebKit needs it"
  done
}
