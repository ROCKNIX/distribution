#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

STEAM="${STEAM:-/storage/.local/share/Steam}"
STEAM_GAMES_ROOT="${STEAM_GAMES_ROOT:-/storage/games-internal/roms/steam}"
STEAM_DOT="${STEAM_DOT:-/storage/.steam}"
APPLICATIONS="${APPLICATIONS:-/storage/.local/share/applications}"

STEAM_DATA_ROOT=""
if [ -L "${STEAM}" ]; then
  STEAM_DATA_ROOT="$(readlink -f "${STEAM}")"
elif [ -d "${STEAM}" ]; then
  STEAM_DATA_ROOT="${STEAM}"
fi

if [ -n "${STEAM_DATA_ROOT}" ] && [ -d "${STEAM_DATA_ROOT}" ]; then
  while IFS= read -r -d '' entry; do
    base="$(basename "${entry}")"
    case "${base}" in
      steamapps|userdata|depotcache)
        ;;
      *)
        rm -rf "${entry}"
        ;;
    esac
  done < <(find "${STEAM_DATA_ROOT}" -mindepth 1 -maxdepth 1 -print0 2>/dev/null)
fi

if [ -L "${STEAM}" ]; then
  rm -f "${STEAM}"
fi

if [ -d "${STEAM_DOT}" ]; then
  rm -f "${STEAM_DOT}/steam" "${STEAM_DOT}/sdkarm64" "${STEAM_DOT}/registry.vdf"
  rmdir "${STEAM_DOT}" 2>/dev/null || true
elif [ -e "${STEAM_DOT}" ]; then
  rm -f "${STEAM_DOT}"
fi

rm -f "${APPLICATIONS}/Steam.desktop"

echo ""
if [ -n "${STEAM_DATA_ROOT}" ]; then
  echo "Steam client removed. Games (steamapps), saves (userdata), and depot cache were kept under ${STEAM_DATA_ROOT}."
else
  echo "Steam client removed. No Steam library path was found (nothing to preserve)."
fi
sleep 5
