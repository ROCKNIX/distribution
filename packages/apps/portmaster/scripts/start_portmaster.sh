#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release
set_kill set "PortMaster"

#Make sure PortMaster exists in .config/PortMaster
if [ ! -d "/storage/.config/PortMaster" ]; then
    mkdir -p "/storage/.config/PortMaster"
      cp -r "/usr/config/PortMaster" "/storage/.config/"
fi

cd /storage/.config/PortMaster

#Grab the latest control.txt & mapper.txt, then set correct permissions
cp /usr/config/PortMaster/control.txt control.txt
chmod +x /storage/.config/PortMaster/control.txt
cp /usr/config/PortMaster/mapper.txt mapper.txt
chmod +x /storage/.config/PortMaster/mapper.txt


#Use our gamecontrollerdb.txt
rm -r gamecontrollerdb.txt
ln -sf /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt gamecontrollerdb.txt

#Delete old PortMaster fold first (we can probably remove this later)
if [ ! -f "/storage/roms/ports/PortMaster/pugwash" ]; then
    rm -r /storage/roms/ports/PortMaster
fi

#Make sure roms/ports/PortMaster folder exists
if [ ! -d "/storage/roms/ports/PortMaster" ]; then
    unzip /usr/config/PortMaster/release/PortMaster.zip -d /storage/roms/ports/
    chmod +x /storage/roms/ports/PortMaster/PortMaster.sh
fi

#We dont use tasksetter, delete it
if [ -f /storage/roms/ports/PortMaster/tasksetter ]; then
  rm -r /storage/roms/ports/PortMaster/tasksetter
fi

#Use PortMasters gptokeyb
rm gptokeyb
cp /storage/roms/ports/PortMaster/gptokeyb gptokeyb

#Copy over required files for ports
cp /storage/.config/PortMaster/control.txt /storage/roms/ports/PortMaster/control.txt
cp /storage/.config/PortMaster/mapper.txt /storage/roms/ports/PortMaster/mapper.txt
cp /storage/.config/PortMaster/gamecontrollerdb.txt /storage/roms/ports/PortMaster/gamecontrollerdb.txt
cp /usr/bin/oga_controls* /storage/roms/ports/PortMaster/

#Hide PortMaster folder in ports
if [ ! -f /storage/roms/ports/gamelist.xml ]; then
echo "<gameList>
	<folder>
		<path>./PortMaster</path>
		<name>PortMaster</name>
		<hidden>true</hidden>
	</folder>
</gameList>" > /storage/roms/ports/gamelist.xml
else
  xmlstarlet ed --inplace -d  "/gameList/folder[name='PortMaster']" /storage/roms/ports/gamelist.xml
  xmlstarlet ed --inplace -d  "/gameList/game[name='PortMaster']" /storage/roms/ports/gamelist.xml
  xmlstarlet ed --inplace --subnode "/gameList" --type elem -n folder -v "" /storage/roms/ports/gamelist.xml
  xmlstarlet ed --inplace --subnode "/gameList/folder[last()]" --type elem -n path -v "./PortMaster" /storage/roms/ports/gamelist.xml
  xmlstarlet ed --inplace --subnode "/gameList/folder[last()]" --type elem -n name -v "PortMaster" /storage/roms/ports/gamelist.xml
  xmlstarlet ed --inplace --subnode "/gameList/folder[last()]" --type elem -n hidden -v "true" /storage/roms/ports/gamelist.xml
fi

#Start PortMaster
cd /storage/roms/ports/PortMaster
./PortMaster.sh 2>/dev/null
