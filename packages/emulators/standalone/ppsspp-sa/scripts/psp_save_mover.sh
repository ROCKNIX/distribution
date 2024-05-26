#!/bin/bash

#This will copy saves to the correct directory after making changes to PPSSPP
if [ ! -d "/storage/roms/psp/PSP" ]; then
  mkdir -p "/storage/roms/psp/PSP"
  cp -r /storage/.config/ppsspp/PSP/SAVEDATA /storage/roms/psp/PSP/
fi

if [ ! -d "/storage/roms/savestates/psp/ppsspp-sa" ]; then
  mkdir -p /storage/roms/savestates/psp/ppsspp-sa
  cp -r /storage/.config/ppsspp/PSP/PPSSPP_STATE/* /storage/roms/savestates/psp/ppsspp-sa/
fi
