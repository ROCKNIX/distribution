# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

import xbmc
import xbmcaddon
import xbmcvfs
import xbmcgui
import os
import xml.etree.ElementTree as ET

ADDON_NAME = xbmcaddon.Addon().getAddonInfo('name')

FFMPEG_PARMS = ( '-y [ANALYZE_DURATION] [SEEK] -i [SOURCE] -map_metadata -1 -threads [THREADS] -ignore_unknown -map 0:v:0? [PREFERRED_LANGUAGE] -map 0:a:[AUDIO_STREAM] -map -0:s '
                '-vcodec @PRESET@ -acodec aac -ac 2 -c:s copy -hls_time [SEGMENT_DURATION] -start_number 0 -hls_list_size [SEGMENT_COUNT] -y [TARGET]')

LS = xbmcaddon.Addon().getLocalizedString

preset = None
crf = None

class Monitor(xbmc.Monitor):

   def __init__(self, *args, **kwargs):
      global preset
      xbmc.Monitor.__init__(self)
      preset = xbmcaddon.Addon().getSetting('preset')
      crf = xbmcaddon.Addon().getSetting('crf')

   def onSettingsChanged(self):
      newpreset = xbmcaddon.Addon().getSetting('preset')
      newcrf = xbmcaddon.Addon().getSetting('preset')
      if crf != newcrf or preset != newpreset:
         self.transcodeHLS()

   def transcodeHLS(self):
      base = os.path.join(xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('profile')), 'config/config.xml')
      tree = ET.parse(base)
      parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
      tree = ET.parse(base, parser=parser)
      root = tree.getroot()
      parent = root.find("WebServer")
      child = parent.find('TranscodeHLS')
      preset = xbmcaddon.Addon().getSetting('preset')
      if preset  == 'default':
         parms = 'default'
      else:
         if preset != "copy":
               crf = xbmcaddon.Addon().getSetting('crf')
               preset = "libx264 -preset " + preset + ' -crf ' + crf
         parms = FFMPEG_PARMS.replace('@PRESET@', preset)

      if child.text != parms:
         child.text = parms
         tree.write(base, encoding='utf-8')
         if child.text == 'default':
               self.showMessage(LS(30018))
         else:
               self.showMessage(LS(30019))
      else:
         self.showMessage(LS(30020))

   def showMessage(self, message):
      xbmc.log(message, xbmc.LOGDEBUG)
      xbmcgui.Dialog().notification(ADDON_NAME, message, xbmcgui.NOTIFICATION_INFO)


if __name__ == "__main__":
   Monitor().waitForAbort()
