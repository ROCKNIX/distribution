// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

#include <stdio.h>
#include <SDL2/SDL.h>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>

// True if EmulationStation has a mapping for this GUID, with or without SDL's name CRC
static bool es_has_config(const std::string& es_input, std::string guid)
{
  if (es_input.find("deviceGUID=\"" + guid + "\"") != std::string::npos)
    return true;
  guid.replace(4, 4, "0000");
  return es_input.find("deviceGUID=\"" + guid + "\"") != std::string::npos;
}

int main(int argc, char** argv)
{

  SDL_GameControllerAddMappingsFromFile("/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt");
  SDL_Init(SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER);
  atexit(SDL_Quit);

  std::ifstream es_file("/storage/.config/emulationstation/es_input.cfg");
  std::stringstream es_input;
  es_input << es_file.rdbuf();

  int num_joysticks = SDL_NumJoysticks();

  // --unmapped: GUIDs of connected joysticks SDL has no controller mapping for
  if (argc > 1 && strcmp(argv[1], "--unmapped") == 0)
  {
    for (int i = 0; i < num_joysticks; ++i)
    {
      if (SDL_IsGameController(i))
        continue;
      char guid_str[64];
      SDL_JoystickGetGUIDString(SDL_JoystickGetDeviceGUID(i), guid_str, sizeof(guid_str));
      printf("%s\n", guid_str);
    }
    return 0;
  }

  // Player 1 is the first pad SDL knows as a controller, else the first one ES has a mapping for
  for (int pass = 0; pass < 2; ++pass)
  {
    for (int i = 0; i < num_joysticks; ++i)
    {
      SDL_Joystick* js = SDL_JoystickOpen(i);
      if (!js)
        continue;

      char guid_str[1024];
      SDL_JoystickGetGUIDString(SDL_JoystickGetGUID(js), guid_str, sizeof(guid_str));
      bool use = pass == 0 ? SDL_IsGameController(i) : es_has_config(es_input.str(), guid_str);
      if (use)
      {
        const char* name = SDL_JoystickName(js);
        printf("controlfolder=\"/storage/.config/gptokeyb\"\nESUDO=\"sudo\"\nESUDOKILL=\"-sudokill\"\nexport SDL_GAMECONTROLLERCONFIG_FILE=\"$controlfolder/gamecontrollerdb.txt\"\nSDLDBFILE=\"${SDL_GAMECONTROLLERCONFIG_FILE}\"\n[ -z \"${SDLDBFILE}\" ] && SDLDBFILE=\"${controlfolder}/gamecontrollerdb.txt\"\nSDLDBUSERFILE=\"/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt\"\nget_controls() {\nANALOGSTICKS=\"2\"\nDEVICE=\"%s\"\nparam_device=\"%s\"\n}\nGPTOKEYB=\"$controlfolder/gptokeyb $ESUDOKILL\"\n",
               guid_str, name ? name : "Joystick");
        SDL_JoystickClose(js);
        return 0;
      }
      SDL_JoystickClose(js);
    }
  }

  return 0;
}
