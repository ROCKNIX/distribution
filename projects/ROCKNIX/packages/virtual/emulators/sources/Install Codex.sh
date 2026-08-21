#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present UzuCore (https://github.com/UzuCore)

set -e
set -o pipefail

source /etc/profile

command -v bwrap >/dev/null 2>&1 \
  || { echo "[ERROR] bubblewrap is not installed. Codex sandboxing is unavailable." >&2; sleep 10; exit 1; }
command -v rg >/dev/null 2>&1 \
  || { echo "[ERROR] ripgrep is not installed. Rebuild the image with the ripgrep package." >&2; sleep 10; exit 1; }

INSTALL_DIR="/storage/.local/bin"
INSTALL_PATH="${INSTALL_DIR}/codex"
STAGED_PATH="${INSTALL_PATH}.new.$$"
TMP_DIR="/tmp/codex-install.$$"
RELEASE_BASE="https://github.com/openai/codex/releases/latest/download"

log_info() { echo -e "[\033[1;34mINFO\033[0m] $1"; }
die() { echo -e "[\033[1;31mERROR\033[0m] $1" >&2; sleep 10; exit 1; }

cleanup() {
  rm -rf "${TMP_DIR}"
  rm -f "${STAGED_PATH}"
}
trap cleanup EXIT INT TERM

case "$(uname -m)" in
  aarch64|arm64)
    TARGET="aarch64-unknown-linux-musl"
    ;;
  x86_64|amd64)
    TARGET="x86_64-unknown-linux-musl"
    ;;
  *)
    die "Codex is not available for this CPU architecture: $(uname -m)"
    ;;
esac

ARCHIVE="codex-${TARGET}.tar.gz"
DOWNLOAD_URL="${RELEASE_BASE}/${ARCHIVE}"

mkdir -p "${TMP_DIR}" "${INSTALL_DIR}"

log_info "Downloading the latest Codex CLI for ${TARGET}..."
curl -fL --retry 5 --connect-timeout 20 \
  -o "${TMP_DIR}/${ARCHIVE}" "${DOWNLOAD_URL}" \
  || die "Failed to download Codex CLI. Check the network connection and try again."

log_info "Installing Codex CLI to ${INSTALL_PATH}..."
tar -xzf "${TMP_DIR}/${ARCHIVE}" -C "${TMP_DIR}" \
  || die "Failed to extract the Codex CLI archive."

EXTRACTED_BIN="${TMP_DIR}/codex-${TARGET}"
[ -f "${EXTRACTED_BIN}" ] \
  || die "The downloaded archive did not contain the expected Codex binary."

cp "${EXTRACTED_BIN}" "${STAGED_PATH}"
chmod 0755 "${STAGED_PATH}"
mv -f "${STAGED_PATH}" "${INSTALL_PATH}"

VERSION="$(${INSTALL_PATH} --version 2>/dev/null)" \
  || die "Codex was downloaded but could not run on this device."

echo ""
echo -e "[\033[1;32mSUCCESS\033[0m] ${VERSION} installed successfully."
echo "Run Start Codex from Tools, or open QTerminal and run: codex"
echo "On first launch, device authentication will show a URL and one-time code."
sleep 10
