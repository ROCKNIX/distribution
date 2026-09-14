#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

FONTS_INSTALL_DIR="/storage/.local/share/fonts"
FONTS_CONFIG_DIR="/storage/.config/fontconfig/conf.d"
RA_FONTS_INSTALL_DIR="/storage/assets/fonts"

mkdir -p "${FONTS_INSTALL_DIR}"
cd "${FONTS_INSTALL_DIR}"

wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/9b0f1436e455d902de067a2501422e5dc71ad16b/Serif/Variable/OTC/NotoSerifCJK-VF.otf.ttc" || die "Failed to download Noto Serif CJK variable fonts."
wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/OTC/NotoSansCJK-VF.otf.ttc" || die "Failed to download Noto Sans CJK variable fonts."
wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/OTC/NotoSansMonoCJK-VF.otf.ttc" || die "Failed to download Noto Sans Mono CJK variable fonts."

mkdir -p "${RA_FONTS_INSTALL_DIR}"
cd "${RA_FONTS_INSTALL_DIR}"

# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/9b0f1436e455d902de067a2501422e5dc71ad16b/Serif/Variable/TTF/NotoSerifCJKhk-VF.ttf" || die "Failed to download Noto Serif CJK HK variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/9b0f1436e455d902de067a2501422e5dc71ad16b/Serif/Variable/TTF/NotoSerifCJKjp-VF.ttf" || die "Failed to download Noto Serif CJK JP variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/9b0f1436e455d902de067a2501422e5dc71ad16b/Serif/Variable/TTF/NotoSerifCJKkr-VF.ttf" || die "Failed to download Noto Serif CJK KR variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/9b0f1436e455d902de067a2501422e5dc71ad16b/Serif/Variable/TTF/NotoSerifCJKsc-VF.ttf" || die "Failed to download Noto Serif CJK SC variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/9b0f1436e455d902de067a2501422e5dc71ad16b/Serif/Variable/TTF/NotoSerifCJKtc-VF.ttf" || die "Failed to download Noto Serif CJK TC variable fonts."

wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/NotoSansCJKhk-VF.ttf" || die "Failed to download Noto Sans CJK HK variable fonts."
wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/NotoSansCJKjp-VF.ttf" || die "Failed to download Noto Sans CJK JP variable fonts."
wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/NotoSansCJKkr-VF.ttf" || die "Failed to download Noto Sans CJK KR variable fonts."
wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/NotoSansCJKsc-VF.ttf" || die "Failed to download Noto Sans CJK SC variable fonts."
wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/NotoSansCJKtc-VF.ttf" || die "Failed to download Noto Sans CJK TC variable fonts."

# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/Mono/NotoSansMonoCJKhk-VF.ttf" || die "Failed to download Noto Sans Mono CJK HK variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/Mono/NotoSansMonoCJKjp-VF.ttf" || die "Failed to download Noto Sans Mono CJK JP variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/Mono/NotoSansMonoCJKkr-VF.ttf" || die "Failed to download Noto Sans Mono CJK KR variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/Mono/NotoSansMonoCJKsc-VF.ttf" || die "Failed to download Noto Sans Mono CJK SC variable fonts."
# wget -c -t 5 "https://github.com/notofonts/noto-cjk/raw/165c01b46ea533872e002e0785ff17e44f6d97d8/Sans/Variable/TTF/Mono/NotoSansMonoCJKtc-VF.ttf" || die "Failed to download Noto Sans Mono CJK TC variable fonts."

mkdir -p "${FONTS_CONFIG_DIR}"
cd "${FONTS_CONFIG_DIR}"
cat >"${FONTS_CONFIG_DIR}/46-noto.conf" <<END
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>Noto Sans Mono</family>
    <default>
      <family>monospace</family>
    </default>
  </alias>
  <alias>
    <family>Noto Sans</family>
    <default>
      <family>sans-serif</family>
    </default>
  </alias>
  <alias>
    <family>Noto Serif</family>
    <default>
      <family>serif</family>
    </default>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Noto Sans Mono</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
    </prefer>
  </alias>
</fontconfig>

END

fc-cache -f -v || die "Failed to update fontconfig cache."

echo ""
echo "Noto CJK fonts installed successfully."
sleep 10
