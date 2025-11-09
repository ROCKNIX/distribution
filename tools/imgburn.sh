#!/bin/bash

usage() {
  echo "Usage: $0  [-n] [-l] <DEVICE> [usb-device-name]"
  echo "   -l                 list available images and USB drives"
  echo "   -n                 dry run"
  echo "   -h                 this help"
  echo "   -N                 instead of a local build, fetch nightly image"
  echo "   DEVICE             selects an image to burn, e.g. RK3566 or SM8550"
  echo "   usb-device-name    is a name of your SD flash (see -l flag)"
}

DRY_RUN=0
LIST_OPTS=0
NIGHTLY=0

script_args=()
while [ $OPTIND -le "$#" ]
do
    if getopts nlhN option
    then
        case $option
        in
            N) NIGHTLY=1;;
            n) DRY_RUN=1;;
            l) LIST_OPTS=1;;
            h) usage; exit 0;;
        esac
    else
        script_args+=("${!OPTIND}")
        ((OPTIND++))
    fi
done

removables(){
  for r in /sys/class/block/*/removable; do
    grep -q 1 "${r}" || continue
    udevadm info $(dirname "${r}") -q property --property=DEVNAME | cut -d= -f2
  done
}

if [[ "${NIGHTLY}" == "1" ]]; then
  NIGHTLY_URLS="$(curl -s --max-time 10 'https://nightly.rocknix.org/' |\
    sed -n 's|^.*<a href="\([^"]*\)"|\1|;s|^\(http[^ >]*nightly-[0-9]*/ROCKNIX[^ >]*\)[ >].*$|\1|p')"
fi

nightly_urls(){
  for u in ${NIGHTLY_URLS}; do echo $u; done
}

image_locations(){
  case "${NIGHTLY}" in
    0) ls target/ROCKNIX-*.*.img.gz ;;
    1) nightly_urls ;;
    *) exit 3 ;;
  esac
}

images(){
  image_locations | sed -nE 's|^.*ROCKNIX-([^.]*)\..*-[0-9]+(-.*)?.img.gz|\1\2|p'
}

find_img(){
  DEVICE="${1%-*}"
  SUBDEVICE="${1#${DEVICE}}"
  image_locations | grep -m 1 "/ROCKNIX-${DEVICE}.aarch64-.*${SUBDEVICE}.img.gz" || exit 1
}


if [[ ${LIST_OPTS} -eq 1 ]]; then
  echo "Available images:"
  for img in $(images); do
    echo " - ${img} $(find_img ${img})"
  done
  echo "Available removable devices:"
  for dev in $(removables); do
    size=$(($(blockdev --getsize64 ${dev})/1000/1000/1000))
    echo " - [${size} GB] ${dev} $(udevadm info ${dev} -q symlink | xargs -n1 echo | sed -n 's|\(.*/by-id/\)|/dev/\1|p' | head -1)"
  done
  exit 0
fi

SRC="${script_args[0]}"
# Find image to burn
if [ -z "${SRC}" ]; then
  echo "No DEVICE given." >&2
  usage >&2
  exit 1
fi
case "${NIGHTLY}-${SRC}" in
  *-"https://"*)
    STREAMER="curl -sL"
    IMGGZ="${SRC}"
    ;;
  1-*)
    STREAMER="curl -sL"
    IMGGZ=$(find_img ${SRC})
    ;;
  0-*)
    STREAMER=cat
    IMGGZ=$(find_img ${SRC})
    ;;
esac

# Find device to write
DEV="${script_args[1]}"
if [ -z "$DEV" ]; then
  for dev in $(removables); do
    if [ -n "$DEV" ]; then
      echo "Several removable devices found. Please specify the one you want to write." >&2
      exit 2
    fi
    DEV="${dev}"
  done
  if [ -z "$DEV" ]; then
    echo "No removable device found. Please insert one or specify it in args." >&2
    exit 2
  fi
fi

if [[ ${DRY_RUN} -eq 1 ]]; then
  echo "Would burn ${IMGGZ} to ${DEV}"
  exit 0
fi

echo "Burning ${IMGGZ} to ${DEV}"
${STREAMER} "${IMGGZ}" | gunzip | dd iflag=fullblock bs=4M of="${DEV}" conv=fdatasync oflag=sync,nocache status=progress
sync
