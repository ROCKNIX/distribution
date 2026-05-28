# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/lang/Python3/package.mk

PKG_CONFIGURE_OPTS_HOST="ac_cv_prog_HAS_HG=/bin/false
                         ac_cv_prog_SVNVERSION=/bin/false
                         py_cv_module_unicodedata=yes
                         py_cv_module__codecs_cn=n/a
                         py_cv_module__codecs_hk=n/a
                         py_cv_module__codecs_iso2022=n/a
                         py_cv_module__codecs_jp=n/a
                         py_cv_module__codecs_kr=n/a
                         py_cv_module__codecs_tw=n/a
                         py_cv_module__decimal=n/a
                         py_cv_module__lzma=n/a
                         py_cv_module_nis=n/a
                         py_cv_module_ossaudiodev=n/a
                         py_cv_module__dbm=n/a
                         py_cv_module__gdbm=n/a
                         --without-readline
                         --disable-tk
                         --disable-curses
                         --disable-pydoc
                         --disable-idle3
                         --with-expat=builtin
                         --with-doc-strings
                         --without-pymalloc
                         --with-ensurepip=yes
                         --enable-shared
"

post_makeinstall_target() {
  ln -sf ${PKG_PYTHON_VERSION} ${INSTALL}/usr/bin/python

  rm -fr ${PKG_BUILD}/.${TARGET_NAME}/build/temp.*

  PKG_INSTALL_PATH_LIB=${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}

  for dir in config compiler sysconfigdata lib-dynload/sysconfigdata test; do
    rm -rf ${PKG_INSTALL_PATH_LIB}/${dir}
  done

  safe_remove ${INSTALL}/usr/bin/python*-config

  find ${INSTALL} -name '*.o' -delete
  find ${INSTALL}/usr/lib/ | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf
  
  # strip
  chmod u+w ${INSTALL}/usr/lib/libpython*.so.*
  debug_strip ${INSTALL}/usr
}