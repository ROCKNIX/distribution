#define _GNU_SOURCE
#include <dlfcn.h>
#include <SDL2/SDL.h>
#include <stdio.h>

static const int ds_screen_width = 256;
static const int ds_screen_height = 192;
static int last_x = -1;
static int last_y = -1;
static int xy_idx = 0;

static int (*real_SDL_PollEvent)(SDL_Event*) = NULL;
static SDL_Window* (*real_SDL_CreateWindow)(const char*, int, int, int, int, Uint32) = NULL;

SDL_Window* SDL_CreateWindow(const char* title, int x, int y, int w, int h, Uint32 flags) {
    int num_displays = SDL_GetNumVideoDisplays();
    int total_width = 0;
    int total_height = 0;
    int last_width = 0;
    int last_height = 0;

    // Change window to total screen size
    // Prevents empty spacing on dual displays
    for (int i = 0; i < num_displays; ++i) {
        SDL_Rect bounds;
        if (SDL_GetDisplayBounds(i, &bounds) == 0) {
            last_width = bounds.w;
            last_height = bounds.h;
            if (bounds.w + bounds.x > total_width)
                total_width += bounds.w;
            if (bounds.h + bounds.y > total_height)
                total_height += bounds.h;
        }
    }
    SDL_Window* window = real_SDL_CreateWindow(title, 0, 0, total_width, total_height, flags);

    // DraStic starts in the center of the virtual screen
    last_x = ds_screen_width / 2;
    last_y = ds_screen_height / 2;

    // Check which screen side is longer for dual screens
    if (num_displays > 1)
        xy_idx = (last_width > last_height) ? 1 : 2;

    return window;
}

int SDL_PollEvent(SDL_Event* event) {
    // Loop required to filter events we don't want to pass along
    while (1) {
        int result = real_SDL_PollEvent(event);
        if (!result) return 0;

        switch (event->type) {
            case SDL_FINGERDOWN: {
                int x, y;
                if (xy_idx == 1) {
                    x = (int)(((event->tfinger.x * 2) - 1) * ds_screen_width);
                    y = (int)(event->tfinger.y * ds_screen_height);
                } else if (xy_idx == 2) {
                    x = (int)(event->tfinger.x * ds_screen_width);
                    y = (int)(((event->tfinger.y * 2) - 1) * ds_screen_height);
                } else {
                    x = (int)(event->tfinger.x * ds_screen_width);
                    y = (int)(event->tfinger.y * ds_screen_height);
                }

                // Queue click for after jump
                event->type = SDL_MOUSEBUTTONDOWN;
                event->button.button = SDL_BUTTON_LEFT;
                event->button.state = SDL_PRESSED;
                event->button.x = x;
                event->button.y = y;
                SDL_PushEvent(event);

                // Jump to new position
                event->type = SDL_MOUSEMOTION;
                event->motion.x = x;
                event->motion.y = y;
                event->motion.xrel = x - last_x;
                event->motion.yrel = y - last_y;

                // Update to keep position accurate
                last_x = x;
                last_y = y;
                break;
            }
            case SDL_FINGERMOTION: {
                int x, y;
                if (xy_idx == 1) {
                    x = (int)(((event->tfinger.x * 2) - 1) * ds_screen_width);
                    y = (int)(event->tfinger.y * ds_screen_height);
                } else if (xy_idx == 2) {
                    x = (int)(event->tfinger.x * ds_screen_width);
                    y = (int)(((event->tfinger.y * 2) - 1) * ds_screen_height);
                } else {
                    x = (int)(event->tfinger.x * ds_screen_width);
                    y = (int)(event->tfinger.y * ds_screen_height);
                }
                int xrel = x - last_x;
                int yrel = y - last_y;

                // Only update when needed
                if (xrel != 0 || yrel != 0) {
                    event->type = SDL_MOUSEMOTION;
                    event->motion.x = x;
                    event->motion.y = y;
                    event->motion.xrel = xrel;
                    event->motion.yrel = yrel;

                    last_x = x;
                    last_y = y;
                }
                break;
            }
            case SDL_FINGERUP: {
                // Queue jump to bottom right for after release to "hide" the stylus icon
                event->type = SDL_MOUSEMOTION;
                event->motion.x = ds_screen_width;
                event->motion.y = ds_screen_height;
                event->motion.xrel = ds_screen_width - last_x;
                event->motion.yrel = ds_screen_height - last_y;
                SDL_PushEvent(event);
                
                event->type = SDL_MOUSEBUTTONUP;
                event->button.button = SDL_BUTTON_LEFT;
                event->button.state = SDL_RELEASED;
                event->button.x = last_x;
                event->button.y = last_y;

                last_x = ds_screen_width;
                last_y = ds_screen_height;
                break;
            }
        }
        return result;
    }
}

__attribute__((constructor))
static void init(void) {
    real_SDL_CreateWindow = dlsym(RTLD_NEXT, "SDL_CreateWindow");
    real_SDL_PollEvent = dlsym(RTLD_NEXT, "SDL_PollEvent");
}

// Major thanks/credit to Shaun Inman for providing the basis of this hook library!