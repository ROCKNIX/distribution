#define _GNU_SOURCE
#include <dlfcn.h>
#include <SDL2/SDL.h>
#include <stdio.h>

static const int ds_screen_width = 256;
static const int ds_screen_height = 192;
static int last_x = -1;
static int last_y = -1;
static int xy_idx = 0;
static int phys_width = -1;
static int phys_height = -1;
static int logical_width = -1;
static int logical_height = -1;

static SDL_Texture* screens[2];
static SDL_Rect touch_rect_storage = {0};
static SDL_Rect* touch_rect = NULL;
static SDL_Renderer* renderer = NULL;
static SDL_Window* (*real_SDL_CreateWindow)(const char*, int, int, int, int, Uint32) = NULL;
static SDL_Renderer* (*real_SDL_CreateRenderer)(SDL_Window*, int, Uint32) = NULL;
static int (*real_SDL_RenderSetLogicalSize)(SDL_Renderer*, int, int) = NULL;
static SDL_Texture* (*real_SDL_CreateTexture)(SDL_Renderer*, Uint32, int, int, int) = NULL;
static int (*real_SDL_RenderCopy)(SDL_Renderer*, SDL_Texture*, const SDL_Rect*, const SDL_Rect*) = NULL;
static int (*real_SDL_PollEvent)(SDL_Event*) = NULL;

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

    // Record screen size for rect tracking/conversion
    phys_width = total_width;
    phys_height = total_height;

    // DraStic starts in the center of the virtual screen
    last_x = ds_screen_width / 2;
    last_y = ds_screen_height / 2;

    // Check which screen side is longer for dual screens
    if (num_displays > 1)
        xy_idx = (last_width > last_height) ? 1 : 2;

    return window;
}

SDL_Renderer* SDL_CreateRenderer(SDL_Window* window, int index, Uint32 flags) {
    renderer = real_SDL_CreateRenderer(window, index, flags);
    // Just in case it's already set
    SDL_RenderGetLogicalSize(renderer, &logical_width, &logical_height);
    return renderer;
}

int SDL_RenderSetLogicalSize(SDL_Renderer* renderer, int w, int h) {
    int result = real_SDL_RenderSetLogicalSize(renderer, w, h);
    // Otherwise store it here
    logical_width = w;
    logical_height = h;
    return result;
}

SDL_Texture* SDL_CreateTexture(SDL_Renderer *renderer, Uint32 format, int type, int w, int h) {
	SDL_Texture* texture = real_SDL_CreateTexture(renderer, format, type, w, h);
	// Identify DS screen textures (2x native by default)
	if (type == SDL_TEXTUREACCESS_STREAMING) {
		if (w == 512 && h == 384) {
			if (!screens[0]) screens[0] = texture;
			else if (!screens[1]) screens[1] = texture;
		}
	}
	return texture;
}

int SDL_RenderCopy(SDL_Renderer *renderer, SDL_Texture *texture, const SDL_Rect *srcrect, const SDL_Rect *dstrect) {
    if (screens[0] && texture == screens[0]) {
        // Convert renderer coordinates to physical screen coordinates
        if (logical_width > 0 && logical_height > 0) {
            int output_w, output_h;
            SDL_GetRendererOutputSize(renderer, &output_w, &output_h);
            float scale_x = (float)output_w / logical_width;
            float scale_y = (float)output_h / logical_height;

            touch_rect_storage.x = (int)(dstrect->x * scale_x);
            touch_rect_storage.y = (int)(dstrect->y * scale_y);
            touch_rect_storage.w = (int)(dstrect->w * scale_x);
            touch_rect_storage.h = (int)(dstrect->h * scale_y);
        } else {
            // Fallback and hope they're right
            touch_rect_storage.x = dstrect->x;
            touch_rect_storage.y = dstrect->y;
            touch_rect_storage.w = dstrect->w;
            touch_rect_storage.h = dstrect->h;
        }
        touch_rect = &touch_rect_storage;
    }
    return real_SDL_RenderCopy(renderer, texture, srcrect, dstrect);
}

int SDL_PollEvent(SDL_Event* event) {
    // Loop required to filter events we don't want to pass along
    while (1) {
        int result = real_SDL_PollEvent(event);
        if (!result) return 0;

        switch (event->type) {
            case SDL_FINGERDOWN: {
                int x = (int)(event->tfinger.x * phys_width);
                int y = (int)(event->tfinger.y * phys_height);
                if (x < touch_rect->x || x > touch_rect->x + touch_rect->w ||
                    y < touch_rect->y || y > touch_rect->y + touch_rect->h)
                    return 0; // Outside valid coords, don't convert

                // Scale to virtual touchscreen
                x = ((x - touch_rect->x) * ds_screen_width) / touch_rect->w;
                y = ((y - touch_rect->y) * ds_screen_height) / touch_rect->h;

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
                int x = (int)(event->tfinger.x * phys_width);
                int y = (int)(event->tfinger.y * phys_height);
                if (x < touch_rect->x || x > touch_rect->x + touch_rect->w ||
                    y < touch_rect->y || y > touch_rect->y + touch_rect->h)
                    return 0;

                x = ((x - touch_rect->x) * ds_screen_width) / touch_rect->w;
                y = ((y - touch_rect->y) * ds_screen_height) / touch_rect->h;
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
    real_SDL_CreateRenderer = dlsym(RTLD_NEXT, "SDL_CreateRenderer");
    real_SDL_RenderSetLogicalSize = dlsym(RTLD_NEXT, "SDL_RenderSetLogicalSize");
    real_SDL_CreateTexture = dlsym(RTLD_NEXT, "SDL_CreateTexture");
    real_SDL_RenderCopy = dlsym(RTLD_NEXT, "SDL_RenderCopy");
    real_SDL_PollEvent = dlsym(RTLD_NEXT, "SDL_PollEvent");
}

// Major thanks/credit to Shaun Inman for providing the basis of this hook library!