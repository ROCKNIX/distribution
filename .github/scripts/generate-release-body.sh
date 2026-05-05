#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)
# Generate release body with dynamic device tables from config.xml
# Usage: generate-release-body.sh <DATE> <LAST_TAG>

DATE="${1}"
LAST_TAG="${2}"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CONFIG_XML="${REPO_ROOT}/projects/ROCKNIX/config.xml"

if [ ! -f "${CONFIG_XML}" ]; then
  echo "ERROR: config.xml not found at ${CONFIG_XML}" >&2
  exit 1
fi

# Parse config.xml to get devices and their subdevices
# Returns lines like: DEVICE:SUBDEVICE (or DEVICE: if no subdevice)
get_image_variants() {
  local device="$1"
  # Check if device has subdevices with mkimage_options (these produce separate images)
  local subdevices
  subdevices=$(xmlstarlet sel -t -m "//rocknix/${device}/*[@mkimage_options]" -v "name()" -n "${CONFIG_XML}" 2>/dev/null | tr '\n' ' ')

  if [ -n "${subdevices}" ]; then
    for sub in ${subdevices}; do
      echo "${device}:${sub}"
    done
  else
    echo "${device}:"
  fi
}

# Get human-readable device names from file elements
get_device_names() {
  local device="$1"
  local subdevice="$2"

  if [ -n "${subdevice}" ]; then
    # Get full names from files with @full attribute, or derive from dtb filename
    local names
    names=$(xmlstarlet sel -t -m "//rocknix/${device}/${subdevice}/file[@full]" -v "@full" -n "${CONFIG_XML}" 2>/dev/null)
    if [ -z "${names}" ]; then
      names=$(xmlstarlet sel -t -m "//rocknix/${device}/${subdevice}/file" -v "." -n "${CONFIG_XML}" 2>/dev/null)
    fi
  else
    local names
    names=$(xmlstarlet sel -t -m "//rocknix/${device}/file[@full]" -v "@full" -n "${CONFIG_XML}" 2>/dev/null)
    if [ -z "${names}" ]; then
      names=$(xmlstarlet sel -t -m "//rocknix/${device}/file" -v "." -n "${CONFIG_XML}" 2>/dev/null)
    fi
  fi
  echo "${names}"
}

# Format dtb name to human-readable
format_dtb_name() {
  local dtb="$1"
  # Remove known SoC prefixes: sun50i-h700-, rk3326-, rk3566-, rk3399-, rk3576-, rk3588s-, rk3568-, meson-g12b-, sm8250-, sm8650-, qcs8550-, cq8725s-, sm6115-
  local name
  name=$(echo "${dtb}" | sed -E 's/^(sun50i-h700|rk33[0-9]{2}|rk35[0-9]{2}s?|meson-g12b|sm[0-9]+|qcs[0-9]+|cq[0-9]+s?)-//')
  echo "${name}" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g'
}

# Generate image filename
get_image_filename() {
  local device="$1"
  local subdevice="$2"
  local suffix=""

  if [ -n "${subdevice}" ]; then
    suffix="-${subdevice}"
  fi

  echo "ROCKNIX-${device}.aarch64-${DATE}${suffix}.img.gz"
}

get_update_filename() {
  local device="$1"
  echo "ROCKNIX-${device}.aarch64-${DATE}.tar"
}

# Build device description string
get_device_description() {
  local device="$1"
  local subdevice="$2"
  local names

  # Try to get full attribute names first
  if [ -n "${subdevice}" ]; then
    names=$(xmlstarlet sel -t -m "//rocknix/${device}/${subdevice}/file[@full]" -v "@full" -n "${CONFIG_XML}" 2>/dev/null)
    if [ -z "${names}" ]; then
      names=$(xmlstarlet sel -t -m "//rocknix/${device}/${subdevice}/file" -v "." -n "${CONFIG_XML}" 2>/dev/null | grep -v -E "rev[0-9]|v2-panel")
      names=$(echo "${names}" | while read -r line; do [ -n "$line" ] && format_dtb_name "$line"; done)
    fi
  else
    names=$(xmlstarlet sel -t -m "//rocknix/${device}/file[@full]" -v "@full" -n "${CONFIG_XML}" 2>/dev/null)
    if [ -z "${names}" ]; then
      names=$(xmlstarlet sel -t -m "//rocknix/${device}/file" -v "." -n "${CONFIG_XML}" 2>/dev/null | grep -v -E "rev[0-9]|v2-panel")
      names=$(echo "${names}" | while read -r line; do [ -n "$line" ] && format_dtb_name "$line"; done)
    fi
  fi

  echo "${names}" | paste -sd "," - | sed 's/,/, /g'
}

# Determine documentation path
get_doc_path() {
  local device="$1"
  local subdevice="$2"
  local doc_dir="${REPO_ROOT}/documentation/PER_DEVICE_DOCUMENTATION"

  if [ -n "${subdevice}" ] && [ -d "${doc_dir}/${device}-${subdevice}" ]; then
    echo "/documentation/PER_DEVICE_DOCUMENTATION/${device}-${subdevice}/"
  elif [ -d "${doc_dir}/${device}" ]; then
    echo "/documentation/PER_DEVICE_DOCUMENTATION/${device}/"
  else
    echo ""
  fi
}

# --- Generate the release body ---

cat << 'HEADER'
&nbsp;&nbsp;<img src="https://raw.githubusercontent.com/ROCKNIX/distribution/next/distributions/ROCKNIX/logos/rocknix-logo.png" width=192>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![Latest Version](https://img.shields.io/github/release/ROCKNIX/distribution.svg?color=5998FF&label=latest%20version&style=flat-square)](https://github.com/ROCKNIX/distribution/releases/latest) [![Activity](https://img.shields.io/github/commit-activity/m/ROCKNIX/distribution?color=5998FF&style=flat-square)](https://github.com/ROCKNIX/distribution/commits) [![Pull Requests](https://img.shields.io/github/issues-pr-closed/ROCKNIX/distribution?color=5998FF&style=flat-square)](https://github.com/ROCKNIX/distribution/pulls) [![Discord Server](https://img.shields.io/discord/948029830325235753?color=5998FF&label=chat&style=flat-square)](https://discord.gg/seTxckZjJy)
#
ROCKNIX is a community developed Linux distribution for handheld gaming devices.  Our goal is to produce an operating system that has the features and capabilities that we need, and to have fun as we develop it.

## Licenses
ROCKNIX is a Linux distribution that is made up of many open-source components.  Components are provided under their respective licenses.  This distribution includes components licensed for non-commercial use only.

### ROCKNIX Branding
ROCKNIX branding and images are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

#### You are free to
* Share — copy and redistribute the material in any medium or format
* Adapt — remix, transform, and build upon the material

#### Under the following terms
* Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
* NonCommercial — You may not use the material for commercial purposes.
* ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

### ROCKNIX Software
HEADER

echo "Copyright (C) $(date +%Y) ROCKNIX (https://github.com/ROCKNIX)"

cat << 'HEADER2'

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Installation
* Download the latest version of ROCKNIX.
* Decompress the image.
* Write the image to an SDCARD using an imaging tool.  Common imaging tools include [Balena Etcher](https://www.balena.io/etcher/), [Raspberry Pi Imager](https://www.raspberrypi.com/software/), and [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/).  If you're skilled with the command line, dd works fine too.

### Installation Package Downloads
HEADER2

# Generate installation table
echo "| **Device/Platform** | **Download Package** | **Documentation** |"
echo "|---------------------|----------------------|-------------------|"

# Get all top-level devices
devices=$(xmlstarlet sel -t -m "//rocknix/*" -v "name()" -n "${CONFIG_XML}" 2>/dev/null | sort -u)

for device in ${devices}; do
  variants=$(get_image_variants "${device}")
  for variant in ${variants}; do
    dev="${variant%%:*}"
    sub="${variant#*:}"

    description=$(get_device_description "${dev}" "${sub}")
    img_file=$(get_image_filename "${dev}" "${sub}")
    doc_path=$(get_doc_path "${dev}" "${sub}")

    doc_link=""
    if [ -n "${doc_path}" ]; then
      doc_link="[documentation](${doc_path})"
    fi

    echo "| **${description}** | [${img_file}](https://github.com/ROCKNIX/distribution/releases/download/${DATE}/${img_file}) | ${doc_link} |"
  done
done

cat << 'MIDDLE'

## Upgrading
* Download and install the update online via the System Settings menu.
* If you are unable to update online
  * Download the latest version of ROCKNIX from Github
  * Copy the update to your device over the network to your device's update share.
  * Reboot the device, and the update will begin automatically.

### Update Package Downloads
| **Device/Platform** | **Download Package** |
|---------------------|----------------------|
MIDDLE

for device in ${devices}; do
  # For update table, collect all device names across all subdevices
  variants=$(get_image_variants "${device}")
  all_descriptions=""
  for variant in ${variants}; do
    dev="${variant%%:*}"
    sub="${variant#*:}"
    desc=$(get_device_description "${dev}" "${sub}")
    if [ -n "${all_descriptions}" ] && [ -n "${desc}" ]; then
      all_descriptions="${all_descriptions}, ${desc}"
    elif [ -n "${desc}" ]; then
      all_descriptions="${desc}"
    fi
  done
  update_file=$(get_update_filename "${device}")
  echo "| **${all_descriptions}** | [${update_file}](https://github.com/ROCKNIX/distribution/releases/download/${DATE}/${update_file}) |"
done

cat << FOOTER

## Documentation

### Contribute

* [Building ROCKNIX](https://rocknix.org/contribute/build/)
* [Code of Conduct](https://rocknix.org/contribute/code-of-conduct/)
* [Contributing to ROCKNIX](https://rocknix.org/contribute/)
* [Modifying ROCKNIX](https://rocknix.org/contribute/modify/)
* [Adding Hardware Quirks](https://rocknix.org/contribute/quirks/)
* [Creating Packages](https://rocknix.org/contribute/packages/)
* [Pull Request Template](/PULL_REQUEST_TEMPLATE.md)

### Play

* [Installing ROCKNIX](https://rocknix.org/play/install/)
* [Updating ROCKNIX](https://rocknix.org/play/update/)
* [Controls](https://rocknix.org/play/controls/)
* [Netplay](https://rocknix.org/play/netplay/)
* [Configuring Moonlight](https://rocknix.org/systems/moonlight/)
* [Device Specific Documentation](/documentation/PER_DEVICE_DOCUMENTATION)

### Configure

* [Optimizations](https://rocknix.org/configure/optimizations/)
* [Shaders](https://rocknix.org/configure/shaders/)
* [Cloud Sync](https://rocknix.org/configure/cloud-sync/)
* [VPN](https://rocknix.org/configure/vpn/)

### Other

* [Frequently Asked Questions](https://rocknix.org/faqs/)
* [Donating to ROCKNIX](https://rocknix.org/donations/)


**Full Changelog**: https://github.com/ROCKNIX/distribution/compare/${LAST_TAG}...${DATE}
FOOTER




