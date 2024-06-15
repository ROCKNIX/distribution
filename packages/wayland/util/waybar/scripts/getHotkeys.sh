#!/bin/bash

base_url="https://rocknix.org/devices/"

case "${DEVICE}" in
S922X)
    urls=("hardkernel/odroid-go-ultra" "hardkernel/odroid-n2" "powkiddy/rgb10-max-3-pro")
    ;;
RK3588)
    urls=("gameforce/gameforce-ace" "indiedroid/nova" "orange-pi/orange-pi-5")
    ;;
RK3399)
    urls=("anbernic/rg552")
    ;;
RK3566-X55)
    urls=("powkiddy/x55")
    ;;
RK3566)
    urls=("anbernic/rg353pmvvs" "anbernic/rg503" "anbernic/rgarc" "powkiddy/rgb10-max-3" "powkiddy/rk2023" "powkiddy/rgb20sx" "powkiddy/rgb30")
    ;;
RK3326)
    urls=("anbernic/rg351pmv" "hardkernel/odroid-go-advance" "hardkernel/odroid-go-super" "powkiddy/rgb10" "powkiddy/xu10" "unbranded/game-console-r33s" "unbranded/game-console-r35s-r36s")
    ;;
*)
    urls=()
    ;;
esac

for url in "${urls[@]}"; do
    # Download the HTML content
    html=$(curl -sL "$base_url$url")

    # Extract the <tr> elements and process them
    content=$(echo "$html" | xmlstarlet fo --html --recover --nocdata 2>/dev/null | xmlstarlet sel -t -m '//tr' -v 'normalize-space(td[1])' -o ' ' -v 'normalize-space(td[2])' -n)

    # Create a txt file with the extracted content
    echo "$content" >"${url//\//_}.txt"
done
