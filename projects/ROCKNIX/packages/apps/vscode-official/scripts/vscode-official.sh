#!/bin/bash

. /etc/profile

export HOME=/storage
export XDG_CONFIG_HOME=/storage/.config
export XDG_DATA_HOME=/storage/.local/share
export XDG_CACHE_HOME=/storage/.cache
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export GTK_USE_PORTAL=1

USER_DATA_DIR="/storage/.local/share/vscode-official"
EXTENSIONS_DIR="${USER_DATA_DIR}/extensions"
DEFAULTS_DIR="/usr/config/vscode-official/User"
SETTINGS_DIR="${USER_DATA_DIR}/User"

mkdir -p "${SETTINGS_DIR}" "${EXTENSIONS_DIR}" /storage/roms /storage/downloads

if [ ! -f "${SETTINGS_DIR}/settings.json" ] && [ -f "${DEFAULTS_DIR}/settings.json" ]; then
  cp -f "${DEFAULTS_DIR}/settings.json" "${SETTINGS_DIR}/settings.json"
fi

cd /storage

exec /usr/lib/vscode-official/bin/code \
  --user-data-dir "${USER_DATA_DIR}" \
  --extensions-dir "${EXTENSIONS_DIR}" \
  --password-store=basic \
  --enable-features=UseOzonePlatform \
  --ozone-platform=wayland \
  --disable-gpu-sandbox \
  "$@"