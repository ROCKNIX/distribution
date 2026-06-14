# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

import os
import shutil
import sys
import tarfile
import subprocess
import xbmcaddon
import xbmcgui
from hashlib import sha256
from pathlib import Path
from tempfile import TemporaryDirectory
from time import sleep
from urllib.request import urlretrieve


STEAMLINK_VERSION = "@STEAMLINK_VERSION@"
STEAMLINK_HASH = "@STEAMLINK_HASH@"
STEAMLINK_TARBALL_NAME = f"steamlink-rpi-trixie-arm64-{STEAMLINK_VERSION}.tar.gz"
STEAMLINK_URL = f"http://media.steampowered.com/steamlink/rpi/trixie/arm64/{STEAMLINK_TARBALL_NAME}"
ADDON_DIR = xbmcaddon.Addon().getAddonInfo("path").rstrip("/")
PROGRESS_BAR = xbmcgui.DialogProgress()


def Execute(command, get_result=False):
  """ Run command """
  try:
    cmd_status = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  except subprocess.CalledProcessError as e:
    return '' if get_result else None
  return cmd_status.stdout.decode() if get_result else None

def GetSHA256Hash(file_name):
  """ Get sha256sum of file_name in 8kb chunks """
  with open(file_name,"rb") as file:
    SHA256HASH = sha256()
    while True:
      data_block = file.read(8192)
      if not data_block:
        break
      SHA256HASH.update(data_block)
  return SHA256HASH.hexdigest()

def OutputFileContents(file):
  """ Read everything in file """
  with open(file) as data:
    return data.read()

def ProgressBarReport(chunk_count, chunk_size, total_size):
  """ Use urlretrieve's reporthook to report progress """
  if total_size != -1:
    progress_percentage = int(chunk_count * chunk_size / total_size * 100)
    PROGRESS_BAR.update(progress_percentage)
  else:
    PROGRESS_BAR.update(0, "Filesize Unknown")

def DownloadFile(url, destination, desired_hash):
  """ Download file """
  file_name = url.rsplit("/", 1)[1]
  PROGRESS_BAR.create("File Download", f"Downloading {file_name}...")
  urlretrieve(url, destination, ProgressBarReport)

  download_hash = GetSHA256Hash(destination)
  if download_hash == desired_hash:
    PROGRESS_BAR.update(100, f"File download complete.")
    PROGRESS_BAR.close()
  else:
    PROGRESS_BAR.update(0, "Download Error: bad file hash. Try again later.")
    sleep(5)
    if os.path.isfile(destination):
      os.remove(destination)
    PROGRESS_BAR.close()
    sys.exit(1)

def PrepareSteamlink():
  """ System preparation before launching Steam Link """
  # Add system libraries to bundled
  for file in os.listdir(f"{ADDON_DIR}/system-libs/"):
    os.symlink(f"{ADDON_DIR}/system-libs/{file}", f"{ADDON_DIR}/steamlink/lib/{file}")

  # Disable arch test
  Path(f"{ADDON_DIR}/steamlink/.ignore_arch").touch()

  # Finalize
  Path(f"{ADDON_DIR}/prep.ok").touch()

def StartSteamlink():
  # Check if addon wants to update Steam Link
  if os.path.isfile(f"{ADDON_DIR}/steamlink/version.txt"):
    steamlink_installed_version = OutputFileContents(f"{ADDON_DIR}/steamlink/version.txt").rstrip()

    # Update Steamlink handling
    if STEAMLINK_VERSION != steamlink_installed_version:
      shutil.rmtree(f"{ADDON_DIR}/steamlink/")
      os.remove(f"{ADDON_DIR}/prep.ok")

  # Download needed files
  if not os.path.isfile(f"{ADDON_DIR}/prep.ok"):
    with TemporaryDirectory() as temp_dir:
      steamlink_tarball_path = os.path.join(temp_dir, STEAMLINK_TARBALL_NAME)
      # Steam Link
      DownloadFile(STEAMLINK_URL, steamlink_tarball_path, STEAMLINK_HASH)
      if os.path.isfile(steamlink_tarball_path):
        steamlink_tarball = tarfile.open(steamlink_tarball_path)
        steamlink_tarball.extractall(path=f"{ADDON_DIR}/", filter="data")

    PrepareSteamlink()

  # Start Steamlink
  xbmcgui.Dialog().notification("Steam Link", "Starting Steam Link", xbmcgui.NOTIFICATION_INFO, 3000)
  steamlink_start_result = Execute(f"systemd-run {ADDON_DIR}/bin/steamlink-start.sh")


StartSteamlink()
