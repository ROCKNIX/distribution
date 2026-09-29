# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="webkitgtk"
PKG_VERSION="2.54.0"
PKG_SHA256="846fd19ccedbae1dbfe904f26dbf2d68a800a33a50caf2ad5222c8dcb3f25682"
PKG_LICENSE="LGPL-2.1-or-later AND BSD-2-Clause"
PKG_SITE="https://webkitgtk.org/"
PKG_URL="https://webkitgtk.org/releases/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain ruby:host unifdef:host \
                    glib gtk3 cairo harfbuzz harfbuzz-icu icu libsoup libxml2 libxslt sqlite \
                    libjpeg-turbo libpng libwebp openjpeg woff2 brotli \
                    libgcrypt libtasn1 zlib freetype fontconfig \
                    libepoxy wayland wayland-protocols libdrm mesa \
                    at-spi2-atk gstreamer gst-plugins-base gst-plugins-bad"
PKG_LONGDESC="WebKit rendering engine, GTK port. Present for one job: showing a cloud provider's sign-in page on the device, so the OAuth redirect to localhost lands where rclone is listening instead of on somebody's phone."
PKG_TOOLCHAIN="cmake"

# ROCKNIX fork: cap this package's parallelism, and only this package's.
#
# CONCURRENCY_MAKE_LEVEL is nproc (24 on the build box), and WebCore's
# translation units are the heaviest in the tree -- 24 cc1plus at once asks
# for more memory than the machine has. The cold GENERIC_X64 build of
# 2026-09-19 died here twice with
#
#   x86_64-rocknix-linux-gnu-g++-15.2.0: fatal error: Killed signal
#   terminated program cc1plus
#
# at ninja edge ~5437 of 6230, taking the box low enough on memory that
# unrelated processes were reaped too. ninja takes the last -j it is given
# and scripts/build appends PKG_MAKE_OPTS_TARGET after NINJA_OPTS, so this
# overrides the global level for webkitgtk alone; every other package still
# builds at full width.
#
# 4 is deliberately conservative -- the maintainer's call, 2026-09-19, is to
# optimise for a build that finishes rather than one that is fast. Raise it
# only with a build that survives on a machine doing something else at the
# same time.
PKG_MAKE_OPTS_TARGET="-j4"

pre_configure_target() {
  # A sign-in window, not a web browser. Everything switched off below is
  # either a dependency we do not ship (spellcheck/enchant, the bubblewrap
  # sandbox and its dbus proxy) or surface we have no use for on a handheld
  # that opens exactly one page. Introspection and docs are build-host
  # artifacts that never reach the image.
  #
  # USE_GSTREAMER_GL is ON, because USE_GBM is on (the GTK port's Wayland
  # buffers) and 2.54.0's VideoFrameGStreamer declares the DMABuf memory
  # type only under GSTREAMER_GL while compiling getDMABuf() under GBM alone:
  # with GL off and GBM on, `'DMABuf' is not a member of MemoryType` at
  # object 7916 of 8585 (fork #228, the 2026-09-24 spike, fix two of three).
  # The GL upload path it enables is never exercised by a sign-in page.
  # And the third fix, a patch: WebKit's own processes could not find
  # GraphicsTypesGL.h through GStreamerCommon.h in that option set
  # (patches/webkitgtk-0002); three fixes is the bound (D-WORKFLOW-038).
  # ENABLE_WEBDRIVER is OFF: a sign-in window is not driven by Selenium,
  # and 2.54.0's WebDriver does not compile in this option set anyway --
  # WebDriverService.cpp:383 asks for a WebDriverClassic log channel that
  # nothing declares (fork #228, the 2026-09-20 run 8 and the 2026-09-24
  # spike both stopped there, the second at object 7364 of 8609 with the
  # GStreamer pieces in place).
  # ENABLE_VIDEO stays ON. The GTK port does not build with it off: WebCore
  # compiles JSHTMLMediaElementCustom.cpp regardless and needs the binding
  # only video generates. Learned 2026-08-30 (cb05cbe80d turned it off,
  # 64907d0ab8 turned it back on the same day) and again 2026-09-20, when
  # four builds of 2.54.0 hit the same wall from every side (#228). What can
  # go is the *pipeline around* video: media stream, recorder, WebRTC, the
  # transcoder, GL upload -- all off below. 2.54 additionally makes
  # gstreamer-mpegts and gstreamer-gl hard requirements of video: the
  # fork's gst-plugins-base builds GL and its gst-plugins-bad keeps the
  # mpegts library for exactly this (fork #228, D-WORKFLOW-038).
  # ENABLE_MINIBROWSER is OFF: it built WebKit's MiniBrowser -- an address
  # bar, tabs, anywhere on the web -- into /usr/libexec/webkit2gtk-4.1 on
  # every image, beside a sign-in window whose whole design is that the
  # device has no browser (audit #308, claude F-RS-04). Nothing runs it. In
  # 2.54.0 the option's only use is Tools/PlatformGTK.cmake's
  # add_subdirectory(MiniBrowser/gtk), so OFF drops one leaf target and
  # changes nothing the library is built from.
  PKG_CMAKE_OPTS_TARGET="-DPORT=GTK \
                         -DUSE_GTK4=OFF \
                         -DUSE_SOUP2=OFF \
                         -DENABLE_WAYLAND_TARGET=ON \
                         -DENABLE_X11_TARGET=OFF \
                         -DENABLE_MINIBROWSER=OFF \
                         -DENABLE_INTROSPECTION=OFF \
                         -DENABLE_WEBDRIVER=OFF \
                         -DENABLE_DOCUMENTATION=OFF \
                         -DENABLE_SPELLCHECK=OFF \
                         -DENABLE_SPEECH_SYNTHESIS=OFF \
                         -DUSE_FLITE=OFF \
                         -DENABLE_ENCRYPTED_MEDIA=OFF \
                         -DENABLE_THUNDER=OFF \
                         -DENABLE_BUBBLEWRAP_SANDBOX=OFF \
                         -DENABLE_JOURNALD_LOG=OFF \
                         -DENABLE_GAMEPAD=OFF \
                         -DENABLE_MEDIA_STREAM=OFF \
                         -DENABLE_MEDIA_RECORDER=OFF \
                         -DUSE_GSTREAMER_GL=ON \
                         -DUSE_GSTREAMER_WEBRTC=OFF \
                         -DUSE_GSTREAMER_TRANSCODER=OFF \
                         -DENABLE_WEB_RTC=OFF \
                         -DENABLE_WEBGL=OFF \
                         -DUSE_LIBSECRET=OFF \
                         -DUSE_LIBBACKTRACE=OFF \
                         -DUSE_AVIF=OFF \
                         -DUSE_JPEGXL=OFF \
                         -DUSE_LCMS=OFF \
                         -DUSE_LIBHYPHEN=OFF \
                         -DENABLE_SAMPLING_PROFILER=OFF \
                         -DUSE_SYSPROF_CAPTURE=OFF \
                         -DUSE_SYSTEM_SYSPROF_CAPTURE=OFF \
                         -DCMAKE_BUILD_TYPE=Release"
}
