#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

HEROIC_BASE="/storage/.local/share/heroic-arm64"
HEROIC_TAR_URL="https://codeberg.org/trescenzi/rocknix-ports/raw/branch/main/heroic/Heroic-2.21.0-linux-arm64.tar.xz"
HEROIC_BIN=""

resolve_heroic_bin() {
  HEROIC_BIN=""
  for candidate in "${HEROIC_BASE}"/Heroic*/heroic "${HEROIC_BASE}"/heroic; do
    [ -x "${candidate}" ] || continue
    HEROIC_BIN="${candidate}"
    return 0
  done
  return 1
}

heroic_write_es_stub() {
  local dest="$1"
  local launcher_name="$2"
  cat >"${dest}" <<EOF
#!/bin/bash
source /etc/profile
HEROIC_LAUNCHER_NAME="${launcher_name}"
for HEROIC_LAUNCHER_DIR in /storage/.config/heroic-launchers /storage/.config/modules /usr/config/modules; do
  H="\${HEROIC_LAUNCHER_DIR}/\${HEROIC_LAUNCHER_NAME}"
  [ -x "\$H" ] || continue
  exec "\$H" "\$@"
done
H="/usr/bin/\${HEROIC_LAUNCHER_NAME}"
[ -x "\$H" ] && exec "\$H" "\$@"
echo "Heroic: \${HEROIC_LAUNCHER_NAME} not found under /storage/.config/heroic-launchers, /storage/.config/modules, /usr/config/modules, or /usr/bin." >&2
exit 127
EOF
  chmod 0755 "${dest}"
}

heroic_seed_rom_launchers() {
  local roms="/storage/roms/heroic"
  mkdir -p "${roms}"
  heroic_write_es_stub "${roms}/Heroic Games Launcher (Authenticate).sh" "start_heroic_authenticate.sh"
  heroic_write_es_stub "${roms}/Heroic Games Launcher.sh" "start_heroic_play.sh"
  heroic_write_es_stub "${roms}/Heroic Games Launcher (Gamescope).sh" "start_heroic_play_gamescope.sh"
}

if ! resolve_heroic_bin; then
  LOCK_DIR="/tmp/heroic-arm64.lock"
  if ! mkdir "${LOCK_DIR}" 2>/dev/null; then
    echo "Heroic install in progress, please retry in a few seconds."
    exit 1
  fi
  trap 'rmdir "${LOCK_DIR}" 2>/dev/null || true' EXIT
  mkdir -p "${HEROIC_BASE}"
  TMP_ARCHIVE="/tmp/heroic-arm64.tar.xz"
  wget -c -t 5 -O "${TMP_ARCHIVE}" "${HEROIC_TAR_URL}" || exit 1
  rm -rf "${HEROIC_BASE}/Heroic-Games-Launcher"
  tar -xJf "${TMP_ARCHIVE}" -C "${HEROIC_BASE}" || exit 1
  rm -f "${TMP_ARCHIVE}"
  resolve_heroic_bin || exit 1
  chmod +x "${HEROIC_BIN}" || true
fi

heroic_seed_rom_launchers
echo ""
echo "Heroic installed successfully. You can now launch it from EmulationStation in the Heroic section."
sleep 10
