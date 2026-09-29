# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ruby"
# freshness: series 3.3 -- a host-only interpreter for WebKit's generators (e7300897c1); each minor series is a separate download path at cache.ruby-lang.org (PKG_URL uses the series), so the tool follows the newest 3.3.x rather than a new series that would need the URL and libyaml re-checked
PKG_VERSION="3.3.12"
PKG_SHA256="873e3297990b8cff7a5436f6e510a3a7a18c74e5f2c794e4162e605fe0a743b3"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://www.ruby-lang.org/"
PKG_URL="https://cache.ruby-lang.org/pub/ruby/${PKG_VERSION:0:3}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain zlib:host libyaml:host"
PKG_LONGDESC="Ruby interpreter. Host-only: JavaScriptCore's bytecode generator is written in Ruby, so WebKit cannot be built without it."
PKG_TOOLCHAIN="autotools"

# Only the interpreter is wanted -- no docs, no extensions we will never load,
# and nothing installed onto the device: this never leaves the build host.
PKG_CONFIGURE_OPTS_HOST="--disable-install-doc \
                         --disable-install-rdoc \
                         --disable-install-capi \
                         --without-gmp \
                         --with-out-ext=openssl,readline,curses,dbm,gdbm,fiddle,pty,syslog \
                         --disable-jit-support"
