#!/bin/bash

case "${QUIRK_DEVICE}" in
HARDKERNEL ODROID-GO-Ultra)
    file_path="/usr/share/waybar/hardkernel_odroid-go-ultra.txt"
    ;;
HARDKRENEL ODROID-N2*)
    file_path="/usr/share/waybar/hardkernel_odroid-n2.txt"
    ;;
Powkiddy RGB10 MAX 3 PRO)
    file_path="/usr/share/waybar/powkiddy_rgb10-max-3-pro.txt"
    ;;
GameForce ACE)
    file_path="/usr/share/waybar/gameforce_gameforce-ace.txt"
    ;;
Indiedroid Nova)
    file_path="/usr/share/waybar/indiedroid_nova.txt"
    ;;
Orange Pi 5)
    file_path="/usr/share/waybar/orange-pi_orange-pi-5.txt"
    ;;
Anbernic RG552)
    file_path="/usr/share/waybar/anbernic_rg552.txt"
    ;;
Powkiddy X55)
    file_path="/usr/share/waybar/powkiddy_x55.txt"
    ;;
Anbernic RG353*)
    file_path="/usr/share/waybar/anbernic_rg353pmvvs.txt"
    ;;
Anbernic RG503)
    file_path="/usr/share/waybar/anbernic_rg503.txt"
    ;;
Anbernic RG ARC-*)
    file_path="/usr/share/waybar/anbernic_rgarc.txt"
    ;;
Powkiddy RGB10 Max 3)
    file_path="/usr/share/waybar/powkiddy_rgb10-max-3.txt"
    ;;
Powkiddy RGB RK2023)
    file_path="/usr/share/waybar/powkiddy_rk2023.txt"
    ;;
Powkiddy RGB20S*)
    file_path="/usr/share/waybar/powkiddy_rgb20sx.txt"
    ;;
Powkiddy RGB30)
    file_path="/usr/share/waybar/powkiddy_rgb30.txt"
    ;;
Anbernic RG351*)
    file_path="/usr/share/waybar/anbernic_rg351pmv.txt"
    ;;
ODROID-GO Advance*)
    file_path="/usr/share/waybar/hardkernel_odroid-go-advance.txt"
    ;;
ODROID-GO Super)
    file_path="/usr/share/waybar/hardkernel_odroid-go-super.txt"
    ;;
Powkiddy RGB10)
    file_path="/usr/share/waybar/powkiddy_rgb10.txt"
    ;;
MagicX XU10)
    file_path="/usr/share/waybar/powkiddy_xu10.txt"
    ;;
Game Console R33S)
    file_path="/usr/share/waybar/unbranded_game-console-r33s.txt"
    ;;
Game Console R36S)
    file_path="/usr/share/waybar/unbranded_game-console-r35s-r36s.txt"
    ;;
*)
    file_path=""
    ;;
esac

if [ -n "$file_path" ] && [ -f "$file_path" ]; then
    cat "$file_path"
else
    echo "No hotkey information available for the current device."
fi
