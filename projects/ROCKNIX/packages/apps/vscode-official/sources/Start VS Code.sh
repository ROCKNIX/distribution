#!/bin/bash

. /etc/profile
set_kill set "vscode-official"

sway_fullscreen "code" &

exec /usr/bin/vscode-official /storage/roms