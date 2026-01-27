#!/bin/bash

. /etc/profile

INI="$HOME/.config/melonDS/melonDS.ini"
BACKUP="$(mktemp)"

# Backup original config to restore on exit
cp "$INI" "$BACKUP"

set_ini() {
  local key="$1"
  local value="$2"
  if grep -Eq "^[[:space:]]*$key[[:space:]]*=" "$INI"; then
    sed -i "s|^[[:space:]]*$key[[:space:]]*=.*|$key=$value|" "$INI"
  else
    printf '\n%s=%s\n' "$key" "$value" >> "$INI"
  fi
}

cleanup() {
  cp "$BACKUP" "$INI"
  rm -f "$BACKUP"
}

# Ensure settings are restored when the game closes
trap cleanup EXIT INT TERM

# ROM discovery
ROM=$(find "$HOME/roms/nds/" -maxdepth 1 -name "*.nds" -print -quit)

if [ -z "$ROM" ]; then
    echo "No ROM found."
    exit 1
fi

# DSi mode
set_ini ConsoleType 1
set_ini DirectBoot 0

sway_fullscreen "net.kuribo64.melonDS" &
/usr/bin/start_melonds.sh "$ROM" "nds"

wait
