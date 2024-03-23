// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

#include <stdio.h>
#include <SDL.h>
#include <cstdlib>

int main()
{

  SDL_GameControllerAddMappingsFromFile("/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt");
  SDL_Init(SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER);
  atexit(SDL_Quit);

  int num_joysticks = SDL_NumJoysticks();
  int i;
  for(i = 0; i < num_joysticks; ++i)
  {
    SDL_Joystick* js = SDL_JoystickOpen(i);
    if (js)
    {
      SDL_JoystickGUID guid = SDL_JoystickGetGUID(js);
      bool is_controller = SDL_IsGameController(i);

      char guid_str[1024];
      SDL_JoystickGetGUIDString(guid, guid_str, sizeof(guid_str));
      if (is_controller)
      {
        const char* name = SDL_JoystickName(js);

        printf("controlfolder=\"/storage/.config/gptokeyb\"\nESUDO=\"sudo\"\nESUDOKILL=\"-sudokill\"\nexport SDL_GAMECONTROLLERCONFIG_FILE=\"$controlfolder/gamecontrollerdb.txt\"\nSDLDBFILE=\"${SDL_GAMECONTROLLERCONFIG_FILE}\"\n[ -z \"${SDLDBFILE}\" ] && SDLDBFILE=\"${controlfolder}/gamecontrollerdb.txt\"\nSDLDBUSERFILE=\"/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt\"\nget_controls() {\nANALOGSTICKS=\"2\"\nDEVICE=\"%s\"\nparam_device=\"%s\"\n}\nGPTOKEYB=\"$controlfolder/gptokeyb $ESUDOKILL\"",
               guid_str, name);
      }
      SDL_JoystickClose(js);
    }
  }

  return 0;
}
