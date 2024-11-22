# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="qt6"
PKG_VERSION="d302ec578f03866cece4a4f4dd014df1b48398d5"
PKG_LICENSE="GPL"
PKG_SITE="http://qt-project.org"
PKG_URL="https://github.com/qt/qt5.git"
PKG_DEPENDS_TARGET="toolchain qt6:host"
PKG_DEPENDS_HOST="toolchain:host"
PKG_LONGDESC="A cross-platform application and UI framework"
GET_HANDLER_SUPPORT="git"
PKG_GIT_CLONE_BRANCH="6.8.1"
PKG_GIT_CLONE_SINGLE="yes"

configure_package() {
  # Apply project-specific patches
  PKG_PATCH_DIRS="${PROJECT}"

  # Set OpenGL or OpenGLES support for CMake
  if [ "${OPENGL_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGL}"
    PKG_CMAKE_OPTS_TARGET+=" -DQT_FEATURE_opengl=ON -DQT_FEATURE_opengles2=OFF"
  elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
    PKG_CMAKE_OPTS_TARGET+=" -DQT_FEATURE_opengles2=ON -DQT_FEATURE_opengl=OFF"
  else
    PKG_CMAKE_OPTS_TARGET+=" -DQT_FEATURE_opengl=OFF -DQT_FEATURE_opengles2=OFF"
  fi

  # XCB support for X11
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    PKG_DEPENDS_TARGET+=" xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm"
    PKG_CMAKE_OPTS_TARGET+=" -DQT_QPA_PLATFORM=xcb"
  fi

  # Wayland support
  if [ "${DISPLAYSERVER}" = "wl" ]; then
    PKG_DEPENDS_TARGET+=" wayland xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm"
    PKG_CMAKE_OPTS_TARGET+=" -DQT_QPA_PLATFORM=wayland \
                             -DBUILD_qtwayland=ON"
  else
    PKG_CMAKE_OPTS_TARGET+=" -DBUILD_qtwayland=OFF"
  fi

  # Vulkan support
  if [ "${VULKAN_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
    PKG_CMAKE_OPTS_TARGET+=" -DQT_FEATURE_vulkan=ON"
  else
    PKG_CMAKE_OPTS_TARGET+=" -DQT_FEATURE_vulkan=OFF"
  fi
}


pre_configure_host() {
  unset HOST_CMAKE_OPTS
  # Disable unneeded modules
  MODULES_TO_DISABLE=("qt3d" "qt5compat" "qtactiveqt" "qtcharts" "qtcoap" "qtconnectivity" "qtdatavis3d"
                      "qtdoc" "qtgraphs" "qtgrpc" "qthttpserver" "qtlocation" "qtlottie" "qtmqtt"
                      "qtmultimedia" "qtnetworkauth" "qtopcua" "qtpositioning" "qtqa" "qtquick3d" "qtquick3dphysics"
                      "qtquickeffectmaker" "qtquicktimeline" "qtremoteobjects" "qtscxml" "qtsensors" "qtserialbus"
                      "qtserialport" "qtspeech" "qttranslations" "qtvirtualkeyboard" "qtwebchannel"
                      "qtwebengine" "qtwebsockets" "qtwebview")
  for module in "${MODULES_TO_DISABLE[@]}"; do
    PKG_CMAKE_OPTS_HOST+=" -DBUILD_${module}=OFF"
  done

  # Enable required modules
  # > qtbase qtshadertools qtdeclarative qtsvg qtlanguageserver qttools qtwayland
  MODULES_TO_ENABLE=("qtbase" "qtshadertools" "qtdeclarative" "qtsvg" "qtlanguageserver" "qtimageformats" "qttools" "qtwayland")
  for module in "${MODULES_TO_ENABLE[@]}"; do
    PKG_CMAKE_OPTS_HOST+=" -DBUILD_${module}=ON"
  done

  # Set Host Install path
  PKG_CMAKE_OPTS_HOST+=" -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN}/usr/local/qt6 \
                         -DCMAKE_BUILD_TYPE=Release \
                         -DQT_BUILD_EXAMPLES=OFF \
                         -DQT_BUILD_TESTS=OFF \
                         -DQT_USE_CCACHE=ON \
                         -DQT_GENERATE_SBOM=OFF \
                         -DQT_FEATURE_wayland=ON"
}

pre_configure_target(){
  unset TARGET_CMAKE_OPTS
  # Disable unneeded modules
  MODULES_TO_DISABLE=("qt3d" "qtactiveqt" "qtcharts" "qtcoap" "qtconnectivity" "qtdatavis3d"
                      "qtdoc" "qtgraphs" "qtgrpc" "qthttpserver" "qtimageformats"
                      "qtlocation" "qtlottie" "qtmqtt" "qtnetworkauth" "qtopcua" "qtpositioning"
                      "qtqa" "qtquick3d" "qtquick3dphysics" "qtquickeffectmaker" "qtquicktimeline" "qtremoteobjects"
                      "qtscxml" "qtsensors" "qtspeech" "qttranslations" "qtvirtualkeyboard"
                      "qtwebchannel" "qtwebengine" "qtwebview")
  for module in "${MODULES_TO_DISABLE[@]}"; do
    PKG_CMAKE_OPTS_TARGET+=" -DBUILD_${module}=OFF"
  done

  # Enable required modules: qtbase qtmultimedia qtshadertools qtdeclarative qt5compat qtserialbus qtserialport qtsvg qttools qtwebsockets qtlanguageserver
  # Conditionals: qtwayland
  MODULES_TO_ENABLE=("qtbase" "qtmultimedia" "qtshadertools" "qtdeclarative" "qt5compat"
                     "qtserialbus" "qtserialport" "qtsvg" "qttools" "qtwebsockets"
                     "qtlanguageserver")
  for module in "${MODULES_TO_ENABLE[@]}"; do
    PKG_CMAKE_OPTS_TARGET+=" -DBUILD_${module}=ON"
  done

  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
                           -DCMAKE_SYSROOT=${SYSROOT_PREFIX} \
                           -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CONF} \
                           -DCMAKE_BUILD_TYPE=Release \
                           -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                           -DQT_DEBUG_FIND_PACKAGE=ON \
                           -DBUILD_SHARED_LIBS=ON \
                           -DQT_BUILD_EXAMPLES=OFF \
                           -DQT_BUILD_TESTS=OFF \
                           -DQT_FEATURE_printer=OFF \
                           -DQT_USE_CCACHE=ON \
                           -DQT_GENERATE_SBOM=OFF"
}

makeinstall_target() {
  QT6_INSTALL_PREFIX=usr/local/qt6
  QT6_LIB=${INSTALL}/${QT6_INSTALL_PREFIX}/lib
  QT6_PLUGINS=${INSTALL}/${QT6_INSTALL_PREFIX}/plugins
  QT6_QML=${INSTALL}/${QT6_INSTALL_PREFIX}/qml
  # Create necessary directories for installation
  mkdir -p ${QT6_LIB}
  mkdir -p ${QT6_PLUGINS}
  mkdir -p ${QT6_QML}

  # Define the sysroot path for Qt6 files
  PKG_QT6_SYSROOT_PATH=${PKG_ORIG_SYSROOT_PREFIX:-${SYSROOT_PREFIX}}/${QT6_INSTALL_PREFIX}

  # Copy Libs
  cp -PR ${PKG_QT6_SYSROOT_PATH}/lib/*.so* ${QT6_LIB}
  # Copy Plugins
  cp -PR ${PKG_QT6_SYSROOT_PATH}/plugins/* ${QT6_PLUGINS}
  # Copy QML
  cp -PR ${PKG_QT6_SYSROOT_PATH}/qml/* ${QT6_QML}
}
