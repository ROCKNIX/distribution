# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/multimedia/gstreamer/gstreamer/package.mk

# The plugin registry, which upstream disables.
#
# Without it GStreamer does no dynamic plugin discovery at all: elements can
# only be found if something linked them in directly. So WebKit asks for
# "appsink", the registry that would have found it does not exist, it gets
# NULL back and segfaults dereferencing it -- killing the web process a
# second after every page load. Shipping the plugin made no difference, and
# neither did GST_PLUGIN_PATH, because nothing was scanning.
#
# Restated in full rather than patched: the generic recipe builds this string
# inside pre_configure_target, so a substitution at global scope is
# overwritten before configure sees it. Only -Dregistry differs from
# upstream; keep the rest in step when rebasing.
pre_configure_target() {
  PKG_MESON_OPTS_TARGET="-Dgst_debug=false \
                         -Dgst_parse=true \
                         -Dregistry=true \
                         -Dtracer_hooks=false \
                         -Doption-parsing=true \
                         -Dpoisoning=false \
                         -Dcheck=disabled \
                         -Dlibunwind=disabled \
                         -Dlibdw=disabled \
                         -Ddbghelp=disabled \
                         -Dbash-completion=disabled \
                         -Dcoretracers=disabled \
                         -Dexamples=disabled \
                         -Dtests=disabled \
                         -Dbenchmarks=disabled \
                         -Dtools=disabled \
                         -Ddoc=disabled \
                         -Dintrospection=disabled \
                         -Dnls=disabled \
                         -Dglib_debug=disabled \
                         -Dglib_assert=false \
                         -Dglib_checks=false \
                         -Dextra-checks=disabled \
                         -Dpackage-name="gstreamer"
                         -Dpackage-origin="LibreELEC.tv"
                         -Ddoc=disabled"
}
