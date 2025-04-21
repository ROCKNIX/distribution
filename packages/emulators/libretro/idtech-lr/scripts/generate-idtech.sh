#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)


# This scripts scans the /storage/roms/idtech folder for idtech game files
# and creates the necessary idtech launcher scripts

# Source predefined variables
. /etc/os-release

RA_BIN="/usr/bin/retroarch"
RA_DIR="/usr/lib/libretro"
SCRIPT_DIR="/storage/.config/idtech"
GAME_DIR="/storage/roms/idtech"

### create .config/idtech if does not exist
if [ ! -d ${SCRIPT_DIR} ]; then
  mkdir -p ${SCRIPT_DIR}
fi

### Create game directories
while read IDTECH_DIR; do
  if [ ! -d "${GAME_DIR}/${IDTECH_DIR}" ]; then
    mkdir -p ${GAME_DIR}/${IDTECH_DIR}
  fi
done </usr/share/idtech/idtech_dirs


### Create scripts ###

### Doom / Doom shareware
if [[ ! -f "${GAME_DIR}/doom/doom/doom.wad" ]]; then
  tar -xf /usr/share/idtech/doom.tar.gz -C ${GAME_DIR}/doom/doom/
fi

if [[ -f "${GAME_DIR}/doom/doom/doom.wad" ]] && [[ ! -f ${SCRIPT_DIR}/Doom.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Doom.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/prboom_libretro.so ${GAME_DIR}/doom/doom/doom.wad
EOF
fi

### The Ultimate Doom
if [[ -f "${GAME_DIR}/doom/doomu/doomu.wad" ]] && [[ ! -f ${SCRIPT_DIR}/The\ Ultimate\ Doom.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/The\ Ultimate\ Doom.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/prboom_libretro.so ${GAME_DIR}/doom/doomu/doomu.wad
EOF
fi

### Doom 2
if [[ -f "${GAME_DIR}/doom/doom2/doom2.wad" ]] && [[ ! -f ${SCRIPT_DIR}/Doom\ II.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Doom\ II.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/prboom_libretro.so ${GAME_DIR}/doom/doom2/doom2.wad
EOF
fi

### The Plutonia Experiment
if [[ -f "${GAME_DIR}/doom/plutonia/plutonia.wad" ]] && [[ ! -f ${SCRIPT_DIR}/The\ Plutonia\ Experiment.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/The\ Plutonia\ Experiment.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/prboom_libretro.so ${GAME_DIR}/doom/plutonia/plutonia.wad
EOF
fi

### TNT Evilution
if [[ -f "${GAME_DIR}/doom/tnt/tnt.wad" ]] && [[ ! -f ${SCRIPT_DIR}/TNT\ Evilution.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/TNT\ Evilution.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/prboom_libretro.so ${GAME_DIR}/doom/tnt/tnt.wad
EOF
fi

### SIGIL
if [[ -f "${GAME_DIR}/doom/sigil/sigil.wad" ]] && [[ ! -f ${SCRIPT_DIR}/Sigil.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Sigil.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/prboom_libretro.so ${GAME_DIR}/doom/sigil/sigil.wad
EOF
fi

### SIGIL II
if [[ -f "${GAME_DIR}/doom/sigil2/sigil2.wad" ]] && [[ ! -f ${SCRIPT_DIR}/Sigil\ II.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Sigil\ II.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/prboom_libretro.so ${GAME_DIR}/doom/sigil2/sigil2.wad
EOF
fi

### Doom 3
if [[ ${HW_ARCH} = "x86_64" ]] && [[ -f "${GAME_DIR}/doom3/base/pak000.pk4" ]] && [[ ! -f ${SCRIPT_DIR}/Doom\ 3.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Doom\ 3.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/boom3_libretro.so ${GAME_DIR}/doom3/base/*
EOF
fi

### Doom 3 - Resurrection of Evil
if [[ ${HW_ARCH} = "x86_64" ]] && [[ -f "${GAME_DIR}/doom3/d3xp/pak000.pk4" ]] && [[ ! -f ${SCRIPT_DIR}/Doom\ 3\ -\ Resurrection\ of\ Evil.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Doom\ 3\ -\ Resurrection\ of\ Evil.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/boom3_xp_libretro.so ${GAME_DIR}/doom3/d3xp/*
EOF
fi

### Quake
if [[ -f "${GAME_DIR}/quake/id1/pak0.pak" ]] && [[ ! -f ${SCRIPT_DIR}/Quake.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/tyrquake_libretro.so ${GAME_DIR}/quake/id1/pak0.pak
EOF
fi

### Quake - Scourge of Armagon
if [[ -f "${GAME_DIR}/quake/hipnotic/pak0.pak" ]] && [[ ! -f ${SCRIPT_DIR}/Quake\ -\ Scourge\ of\ Armagon.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake\ -\ Scourge\ of\ Armagon.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/tyrquake_libretro.so ${GAME_DIR}/quake/hipnotic/pak0.pak
EOF
fi

### Quake - Dissolution of Eternity
if [[ -f "${GAME_DIR}/quake/rogue/pak0.pak" ]] && [[ ! -f ${SCRIPT_DIR}/Quake\ -\ Dissolution\ of\ Eternity.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake\ -\ Dissolution\ of\ Eternity.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/tyrquake_libretro.so ${GAME_DIR}/quake/rogue/pak0.pak
EOF
fi

### Quake 2
if [[ -f "${GAME_DIR}/quake2/baseq2/pak0.pak" ]] && [[ ! -f ${SCRIPT_DIR}/Quake\ II.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake\ II.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/vitaquake2_libretro.so ${GAME_DIR}/quake2/baseq2/*
EOF
fi

### Quake 2 - The Reckoning
if [[ -f "${GAME_DIR}/quake2/xatrix/pak0.pak" ]] && [[ ! -f ${SCRIPT_DIR}/Quake\ II\ -\ The\ Reckoning.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake\ II\ -\ The\ Reckoning.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/vitaquake2-xatrix_libretro.so ${GAME_DIR}/quake2/xatrix/*
EOF
fi

### Quake 2 - Ground Zero
if [[ -f "${GAME_DIR}/quake2/rogue/pak0.pak" ]] && [[ ! -f ${SCRIPT_DIR}/Quake\ II\ -\ Ground\ Zero.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake\ II\ -\ Ground\ Zero.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/vitaquake2-rogue_libretro.so ${GAME_DIR}/quake2/rogue/*
EOF
fi

### Quake 2 - Zaero
if [[ -f "${GAME_DIR}/quake2/zaero/pak0.pak" ]] && [[ ! -f ${SCRIPT_DIR}/Quake\ II\ -\ Zaero.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake\ II\ -\ Zaero.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/vitaquake2-zaero_libretro.so ${GAME_DIR}/quake2/zaero/*
EOF
fi

### Quake 3
if [[ ${HW_ARCH} = "x86_64" ]] && [[ -f "${GAME_DIR}/quake3/baseq3/pak0.pk3" ]] && [[ ! -f ${SCRIPT_DIR}/Quake\ III.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Quake\ III.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/vitaquake3_libretro.so ${GAME_DIR}/quake3/baseq3/*
EOF
fi

### Wolfenstein 3D
if [[ -f "${GAME_DIR}/wolf3d/wolf3d/VSWAP.WL6" ]] && [[ ! -f ${SCRIPT_DIR}/Wolfenstein\ 3D.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Wolfenstein\ 3D.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/ecwolf_libretro.so ${GAME_DIR}/wolf3d/wolf3d/*
EOF
fi

### Wolfenstein 3D - Spear of Destiny
if [[ -f "${GAME_DIR}/wolf3d/sod/VSWAP.SOD" ]] && [[ ! -f ${SCRIPT_DIR}/Wolfenstein\ 3D\ -\ Spear\ of\ Destiny.sh ]]; then
cat <<EOF >${SCRIPT_DIR}/Wolfenstein\ 3D\ -\ Spear\ of\ Destiny.sh
#!/bin/bash

${RA_BIN} -L ${RA_DIR}/ecwolf_libretro.so ${GAME_DIR}/wolf3d/sod/*
EOF
fi


### Set all launcher scripts to be executable ###
chmod +x ${SCRIPT_DIR}/*
