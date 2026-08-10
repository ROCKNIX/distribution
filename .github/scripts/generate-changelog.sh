#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

set -o pipefail

GIT_RANGE="${1}"
MAX_COUNT="${2}"

if [ -z "${GIT_RANGE}" ]; then
  echo "ERROR: no git range provided" >&2
  exit 1
fi

# Category order
categories=(
  "🐧 Kernel & Boot"
  "🎮 Emulators & Frontend"
  "🖥️ Graphics"
  "📦 Multimedia"
  "🔊 Audio"
  "🌐 Network"
  "📱 Device Support"
  "⚙️ CI & Workflows"
  "🔧 System"
  "📚 Documentation"
  "🔩 Other"
  "↩️ Reverts"
)

log_args=(--format="%s%x1f%an%x1f%H")
if [ -n "${MAX_COUNT}" ]; then
  log_args+=(--max-count="${MAX_COUNT}")
fi

tmpdir=$(mktemp -d)

while IFS=$'\x1f' read -r subject author commit_hash; do
  [[ -z "$subject" ]] && continue
  short_hash="${commit_hash:0:7}"
  line="- ${subject} (${author}) ([${short_hash}](https://github.com/ROCKNIX/distribution/commit/${commit_hash}))"
  category="🔩 Other"
  if [[ "$subject" == *:* ]]; then
  prefix=$(echo "$subject" | cut -d: -f1 | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
  case "$prefix" in
    # Reverts
    revert*)
      category="↩️ Reverts" ;;
    # Kernel & Boot
    linux|u-boot*|kernel*|dtc|dt-overlays|rkbin|atf|mkbootimg|grub|syslinux| \
    amlogic-boot-fip|exynos-boot-fip|crust|bootloader|installer|qcom-abl| \
    rocknix-abl|device-tree-overlays|mali-bifrost|rocknix-joypad|dtbocfg| \
    generic-dsi|*-firmware|rtl8812au|rtl8814au|rtl8821au|rtl8821cu| \
    rtl8851bu|rtl88x2bu|rtw88|arm-efi|linux-drivers|abl|asoc| \
    inputtouchscreen|inputjoystick|backlight|drmpanel|regulator|haptics| \
    initramfs|image)
      category="🐧 Kernel & Boot" ;;
    # Emulators & Frontend
    *-sa|*-lr|retroarch|emulationstation|gamecontrollerdb|rocknix-systems| \
    hypseus*|openbor*|pico-8*|heroic*|amiberry*|mednafen*|steam*|box64|box86| \
    fex-emu|wine|portmaster*|moonlight*|lowerdeck*|themes*|es-themes*|oga*| \
    m8c*|supersnes9x|pcsx2|yabasanshiro|yaps2|doom|gzdoom|rpcs3|drastic| \
    retroarch-joypads|emulators|armsx2|azahar|gameguides|game-guides|es|fex| \
    scummvm|hatari|minivmac|aethersx2|bigpemu|duckstation|mupen64plus|touchhle| \
    cemu|flycast|hypseus-singe|nanoboyadvance|vice|ares|daedalusx64|gopher64| \
    skyemu|vita3k|dolphin|melonds|xemu|supermodel|core-info|libretro-database| \
    uae4arm|a5200|arduous|atari800|b2|beetle-gba|beetle-lynx|beetle-ngp| \
    beetle-pce-fast|beetle-pce|beetle-pcfx|beetle-psx|beetle-saturn| \
    beetle-supafaust|beetle-supergrafx|beetle-vb|beetle-wswan|bk|bluemsx| \
    boom3|bsnes-hd|bsnes|bsnes-mercury-accuracy|bsnes-mercury-balanced| \
    bsnes-mercury-performance|bsnes2014-accuracy|bsnes2014-balanced| \
    bsnes2014-performance|cap32|crocods|daphne|desmume| \
    doublecherrygb|dosbox-core|dosbox-pure|easyrpg|ecwolf|emuscv|fake08| \
    fbalpha2012|fbalpha2019|fbneo|fceumm|flycast2021|fmsx|freechaf|freeintv| \
    freej2me|fuse|gambatte|gearboy|gearcoleco|geargrafx|gearlynx|gearsystem| \
    genesis-plus-gx|genesis-plus-gx-wide|geolith|gpsp|gw|handy| \
    idtech|jaxe|kronos|mame|mame2003|mame2003-plus|mame2010|mame2015| \
    melonds-ds|mesen|mesen-s|mgba|mojozork|mu|mupen64plus-nx|neocd_lr| \
    nestopia|np2kai|o2em|opera|panda3ds|parallel-n64|pcsx_rearmed|picodrive| \
    play|pokemini|potator|ppsspp|prboom|prosystem|puae|puae2021|px68k| \
    quasi88|quicknes|race|same_cdi|sameboy|sameduck|smsplus-gx|snes9x| \
    snes9x2002|snes9x2005_plus|snes9x2010| \
    stella|swanstation|tgbdual|theodore|tic80|tyrquake|uzem|vba-next|vbam| \
    vecx|vircon32|virtualjaguar|vitaquake2|vitaquake3|wasm4|xmil)
      category="🎮 Emulators & Frontend" ;;
    # Audio
    pipewire|wireplumber|alsa*|pulseaudio|opus|flac|libvorbis|libsndfile| \
    wavpack|sbc|speex*|openal*|fdk-aac|ldacbt*|libldac|fluidsynth|libopenmpt| \
    soxr|libogg|lame|libfreeaptx|libmodplug|sidplay*|taglib|espeak*| \
    sdl2_mixer|libao|sndio|libxmp)
      category="🔊 Audio" ;;
    # Graphics
    mesa|mesa-demos|gamescope|mangohud|vulkan*|*-shaders|glsl*|slang*| \
    librashader|libdrm|libglvnd|libepoxy|libmali*|librga|gpudriver|spirv*| \
    glew|glfw|glslang|glm|glu|cairo|libpng|libjpeg*|libwebp|pango|harfbuzz| \
    gdk-pixbuf|libheif|libraw|libde265|lcms2|tiff|libprojectm*|sdl2*|sdl3*| \
    waffle|wxwidgets|qt6|imagemagick|fbgrab|grim|gtk2|gtk3|capsimg|xserver| \
    libclc|renderdoc|pixman|libx11*|libxcb*|xcb-proto|xorgproto|libxt| \
    libxft|libxfixes|libxext|libxrender|libxrandr|libxinerama|libxxf86vm| \
    libxmu|libxau|libxkbfile|libxcursor|libxshmfence|libsm|libice| \
    libfontenc|xtrans|xrandr|xorg-launch-helper|x11|lsfg-vk|shaderc| \
    plutosvg|plutovg)
      category="🖥️ Graphics" ;;
    # Multimedia
    ffmpeg|libva|dav1d|aom|libass|libdvd*|libbluray|bento4|libbdplus| \
    libmpeg2|libvdpau|rtmpdump|zvbi|nvidia-vaapi-driver|nv-codec-headers| \
    media-driver|intel-vaapi-driver|libudfread|libaacs|gmmlib|mpv|vlc| \
    gstreamer|gst-plugins*|libvpx|libplacebo|gmu|libdvbpsi|opusfile|rkmpp| \
    mpg123|libmad|libsamplerate)
      category="📦 Multimedia" ;;
    # Network
    connman|iwd|networkmanager|bluez|openssh|samba|nfs*|avahi|syncthing| \
    rclone|tailscale|zerotier*|wireguard*|openvpn|sixaxis|iw|iptables|wsdd2| \
    wireless-regdb|libpcap|enet|libndp|libnl|libtirpc|libssh|nss-mdns| \
    ap6611s|simple-http-server|fping|speedtest-cli|curl|libslirp|wifi)
      category="🌐 Network" ;;
    # Device Support
    h700*|rk3326*|rk3399*|rk3566*|rk3576*|rk3588*|s922x*|sm6115*|sm8250*| \
    sm8550*|sm8650*|sm8750*|amd64*|quirks|thor-lite|odin2|rpnova|thor| \
    allwinner|rockchip|qualcomm|socqcom|batteryplus|dmidecode|pciutils| \
    ayn-platform|rp6)
      category="📱 Device Support" ;;
    # CI & Workflows
    ci|workflows|validate-commit|github)
      category="⚙️ CI & Workflows" ;;
    # Documentation
    documentation|docs)
      category="📚 Documentation" ;;
    # System
    busybox|systemd*|deviceinfo|post-update|updateabl|options|lib32| \
    install*|build|rocknix*|wayland*|libinput|libxkbcommon|weston*|mtdev| \
    dbus|udevil|parted|util-linux|e2fsprogs|dosfstools|kmod|libusb*| \
    usbutils|fuse*|procps*|nano|evrepeat|emmctool|wait-time-sync| \
    inputplumber*|bash|btop|btrfs-progs|drm_tool|gptfdisk|i2c-tools|lsof| \
    nvtop|powerstate|squashfs*|squashfuse|system-utils|umtprd|usb-modeswitch| \
    openssl|libgpg-error|libarchive|libzip|p7zip|gzip|xz|cabextract|expat| \
    icu|jsoncpp|libxml2|libcroco|libiconv|boost|glib|glibc|ncurses|readline| \
    cmake|joyutils|gamepadcalibration|entware|socat|rocknix-splash|coreutils| \
    dialog|freeimage|pyudev|miniupnpc|sound|poppler|grep|file|sleep|avfs| \
    libiio|bin2c|libserialport|swig|llvm|gcc*|go|lua*|nasm|rust*|cargo*| \
    cbindgen|textviewer|dejavu|spleen*|apitrace|strace|at-spi2-atk| \
    at-spi2-core|autostart|config|profiled|sources|sysctld|udevd|bdf2psf| \
    shared-mime-info|ccache|ecm|gnulib|inih|json-glib|libaio|libcom-err| \
    libdatrie|libfmt|libpthread-stubs|libthai|make|patchelf|six|xa|commander| \
    control-gen|device-switch|gamepadtester|jstest-sdl|list-guid|mako-osd| \
    qterminal|sdljoytest|sdltouchtest|compositor|swaywm-env|empty|modules| \
    pyfdt|qemu|synctools|usbgadget|panel|input_sense|python*|distutilscross| \
    sway|wlroots|seatd|foot|bemenu|wlr-randr|fcft|scripts|tools|debug| \
    virtual|network|sdl2notify|sdl2text|batteryplus|libc|compat)
      category="🔧 System" ;;
  esac
  fi
  echo "$line" >> "${tmpdir}/${category}"
done < <(
  git log "${log_args[@]}" "${GIT_RANGE}" 2>/dev/null \
    | grep -v "Merge pull request" \
    | grep -v "Merge branch" \
    | grep -v "Merge remote-tracking branch" \
    | grep -v "^$"
)

for cat in "${categories[@]}"; do
  if [ -f "${tmpdir}/${cat}" ]; then
    printf "\n### %s\n\n" "${cat}"
    cat "${tmpdir}/${cat}"
  fi
done

rm -rf "${tmpdir}"

