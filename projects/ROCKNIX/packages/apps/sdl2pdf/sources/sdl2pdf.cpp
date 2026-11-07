// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <dirent.h>
#include <map>
#include <string>
#include <vector>


// ------------------------------------------------------------
// PDF helpers
// ------------------------------------------------------------

int getPageCount(const std::string& pdf)
{
    std::string command =
        "pdfinfo \"" + pdf + "\" | grep '^Pages:'";

    FILE* pipe = popen(command.c_str(), "r");

    if (!pipe)
        return 0;

    char buffer[256];

    if (!fgets(buffer, sizeof(buffer), pipe))
    {
        pclose(pipe);
        return 0;
    }

    pclose(pipe);

    int pages = 0;

    if (sscanf(buffer, "Pages: %d", &pages) != 1)
        return 0;

    return pages;
}


bool renderPage(const std::string& pdf, int page)
{
    std::string command =
        "pdftoppm "
        "-f " + std::to_string(page) +
        " -l " + std::to_string(page) +
        " -singlefile "
        "-png "
        "-r 150 "
        "\"" + pdf + "\" "
        "/tmp/sdl2pdf-page";

    int result = std::system(command.c_str());

    return result == 0;
}


// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------

struct FileConfig
{
    int page = 1;
    uintmax_t fileSize = 0;
    int pageCount = 0;
};


static std::filesystem::path get_home_dir()
{
    const char* h = std::getenv("HOME");

    return std::filesystem::path(
        h ? h : "/storage"
    );
}


static std::filesystem::path get_config_dir()
{
    std::filesystem::path cfgDir =
        get_home_dir() / ".config" / "sdl2pdf";

    std::error_code ec;

    std::filesystem::create_directories(
        cfgDir,
        ec
    );

    return cfgDir;
}


static std::filesystem::path get_config_file()
{
    return get_config_dir() / "sdl2pdf.conf";
}


std::map<std::string, FileConfig> load_config()
{
    std::map<std::string, FileConfig> cfg;

    std::ifstream f(get_config_file());

    if (!f.is_open())
        return cfg;

    std::string line;

    while (std::getline(f, line))
    {
        size_t sep = line.find('=');

        if (sep == std::string::npos)
            continue;

        std::string key =
            line.substr(0, sep);

        std::string value =
            line.substr(sep + 1);

        size_t sep1 =
            value.find('|');

        size_t sep2 =
            value.find('|', sep1 + 1);

        if (sep1 == std::string::npos ||
            sep2 == std::string::npos)
        {
            continue;
        }

        try
        {
            FileConfig file;

            file.page =
                std::stoi(
                    value.substr(
                        0,
                        sep1
                    )
                );

            file.fileSize =
                std::stoull(
                    value.substr(
                        sep1 + 1,
                        sep2 - sep1 - 1
                    )
                );

            file.pageCount =
                std::stoi(
                    value.substr(
                        sep2 + 1
                    )
                );

            if (file.page < 1)
                file.page = 1;

            cfg[key] = file;
        }
        catch (...)
        {
            // Ignore malformed entries.
        }
    }

    return cfg;
}


void save_config(
    const std::map<std::string, FileConfig>& cfg
)
{
    std::ofstream f(get_config_file());

    if (!f.is_open())
        return;

    for (const auto& [path, file] : cfg)
    {
        f << path
          << "="
          << file.page
          << "|"
          << file.fileSize
          << "|"
          << file.pageCount
          << "\n";
    }
}


// ------------------------------------------------------------
// Font discovery
// ------------------------------------------------------------

std::string find_any_ttf_font()
{
    const char* dirs[] = {
        "/usr/share/fonts/truetype/",
        "/usr/share/fonts/truetype/dejavu/",
        "/usr/share/fonts/",
        "/usr/local/share/fonts/",
        "/system/fonts/"
    };

    for (auto dir : dirs)
    {
        DIR* d = opendir(dir);

        if (!d)
            continue;

        struct dirent* ent;

        while ((ent = readdir(d)) != nullptr)
        {
            std::string name = ent->d_name;

            if (name.size() > 4 &&
                name.substr(name.size() - 4) == ".ttf")
            {
                closedir(d);
                return std::string(dir) + name;
            }
        }

        closedir(d);
    }

    return "";
}


// ------------------------------------------------------------
// Page overlay
// ------------------------------------------------------------

bool drawPageOverlay(
    SDL_Renderer* renderer,
    TTF_Font* font,
    int page,
    int pageCount
)
{
    if (!font)
        return false;

    std::string label =
        "Page " + std::to_string(page) +
        " / " + std::to_string(pageCount);

    SDL_Color textColor = {
        255,
        255,
        255,
        255
    };

    SDL_Surface* textSurface =
        TTF_RenderUTF8_Blended(
            font,
            label.c_str(),
            textColor
        );

    if (!textSurface)
        return false;

    SDL_Texture* textTexture =
        SDL_CreateTextureFromSurface(
            renderer,
            textSurface
        );

    int textWidth = textSurface->w;
    int textHeight = textSurface->h;

    SDL_FreeSurface(textSurface);

    if (!textTexture)
        return false;

    const int paddingX = 16;
    const int paddingY = 10;
    const int margin = 20;

    SDL_Rect backgroundRect = {
        margin,
        margin,
        textWidth + paddingX * 2,
        textHeight + paddingY * 2
    };

    SDL_Rect textRect = {
        margin + paddingX,
        margin + paddingY,
        textWidth,
        textHeight
    };

    SDL_SetRenderDrawBlendMode(
        renderer,
        SDL_BLENDMODE_BLEND
    );

    SDL_SetRenderDrawColor(
        renderer,
        0,
        0,
        0,
        190
    );

    SDL_RenderFillRect(
        renderer,
        &backgroundRect
    );

    SDL_RenderCopy(
        renderer,
        textTexture,
        nullptr,
        &textRect
    );

    SDL_DestroyTexture(textTexture);

    return true;
}


bool drawHelpScreen(
    SDL_Renderer* renderer,
    TTF_Font* font,
    int windowW,
    int windowH
)
{
    if (!font)
        return false;

    struct HelpLine
    {
        const char* button;
        const char* description;
    };

    const HelpLine lines[] =
    {
        { "SELECT",            "Toggle Help Screen" },
        { "D-PAD",             "Pan when zoomed" },
        { "L1 / R1",           "Previous / Next Page" },
        { "L1 / R1 HOLD     ", "Skip 5 Pages" },
        { "X",                 "Zoom Out" },
        { "Y",                 "Zoom In" },
        { "START",             "Reset Zoom" },
        { "A / B",             "Exit" }
    };

    const int lineCount =
        sizeof(lines) / sizeof(lines[0]);

    const int lineSpacing = 10;
    const int paddingX = 40;
    const int paddingY = 30;
    const int margin = 30;
    const int columnSpacing = 20;

    SDL_Color textColor = { 255, 255, 255, 255 };

    SDL_Surface* titleSurface =
        TTF_RenderUTF8_Blended(font, "CONTROLS", textColor);

    if (!titleSurface)
        return false;

    SDL_Texture* titleTexture =
        SDL_CreateTextureFromSurface(renderer, titleSurface);

    int titleWidth = titleSurface->w;
    int titleHeight = titleSurface->h;

    SDL_FreeSurface(titleSurface);

    if (!titleTexture)
        return false;

    std::vector<SDL_Texture*> buttonTextures;
    std::vector<SDL_Texture*> descriptionTextures;
    std::vector<SDL_Rect> buttonRects;
    std::vector<SDL_Rect> descriptionRects;

    int maxButtonWidth = 0;
    int maxDescriptionWidth = 0;
    int totalHeight = paddingY * 2 + titleHeight + lineSpacing;

    for (int i = 0; i < lineCount; ++i)
    {
        SDL_Surface* buttonSurface =
            TTF_RenderUTF8_Blended(font, lines[i].button, textColor);

        SDL_Surface* descriptionSurface =
            TTF_RenderUTF8_Blended(font, lines[i].description, textColor);

        if (!buttonSurface || !descriptionSurface)
        {
            if (buttonSurface)
                SDL_FreeSurface(buttonSurface);
            if (descriptionSurface)
                SDL_FreeSurface(descriptionSurface);
            SDL_DestroyTexture(titleTexture);
            for (SDL_Texture* texture : buttonTextures)
                SDL_DestroyTexture(texture);
            for (SDL_Texture* texture : descriptionTextures)
                SDL_DestroyTexture(texture);
            return false;
        }

        SDL_Texture* buttonTexture =
            SDL_CreateTextureFromSurface(renderer, buttonSurface);

        SDL_Texture* descriptionTexture =
            SDL_CreateTextureFromSurface(renderer, descriptionSurface);

        if (!buttonTexture || !descriptionTexture)
        {
            if (buttonTexture)
                SDL_DestroyTexture(buttonTexture);
            if (descriptionTexture)
                SDL_DestroyTexture(descriptionTexture);
            SDL_FreeSurface(buttonSurface);
            SDL_FreeSurface(descriptionSurface);
            SDL_DestroyTexture(titleTexture);
            for (SDL_Texture* texture : buttonTextures)
                SDL_DestroyTexture(texture);
            for (SDL_Texture* texture : descriptionTextures)
                SDL_DestroyTexture(texture);
            return false;
        }

        buttonRects.push_back({ 0, 0, buttonSurface->w, buttonSurface->h });
        descriptionRects.push_back({ 0, 0, descriptionSurface->w, descriptionSurface->h });

        maxButtonWidth = std::max(maxButtonWidth, buttonSurface->w);
        maxDescriptionWidth = std::max(maxDescriptionWidth, descriptionSurface->w);

        totalHeight += buttonSurface->h;
        if (i < lineCount - 1)
            totalHeight += lineSpacing;

        buttonTextures.push_back(buttonTexture);
        descriptionTextures.push_back(descriptionTexture);

        SDL_FreeSurface(buttonSurface);
        SDL_FreeSurface(descriptionSurface);
    }

    int boxWidth =
        paddingX * 2 +
        maxButtonWidth +
        columnSpacing +
        maxDescriptionWidth;

    int boxHeight = totalHeight;

    boxWidth = std::min(boxWidth, windowW - margin * 2);
    boxHeight = std::min(boxHeight, windowH - margin * 2);

    SDL_Rect backgroundRect = {
        (windowW - boxWidth) / 2,
        (windowH - boxHeight) / 2,
        boxWidth,
        boxHeight
    };

    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);

    // Darken the entire screen slightly.
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 150);

    SDL_Rect screenRect = { 0, 0, windowW, windowH };
    SDL_RenderFillRect(renderer, &screenRect);

    // Help box.
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 230);
    SDL_RenderFillRect(renderer, &backgroundRect);

    int y = backgroundRect.y + paddingY;

    SDL_Rect titleRect = {
        backgroundRect.x + paddingX,
        y,
        titleWidth,
        titleHeight
    };

    SDL_RenderCopy(renderer, titleTexture, nullptr, &titleRect);

    y += titleHeight + lineSpacing;

    const int descriptionX =
        backgroundRect.x + paddingX + maxButtonWidth + columnSpacing;

    for (int i = 0; i < lineCount; ++i)
    {
        SDL_Rect buttonRect = buttonRects[i];
        buttonRect.x = backgroundRect.x + paddingX;
        buttonRect.y = y;

        SDL_RenderCopy(renderer, buttonTextures[i], nullptr, &buttonRect);

        SDL_Rect descriptionRect = descriptionRects[i];
        descriptionRect.x = descriptionX;
        descriptionRect.y = y;

        SDL_RenderCopy(renderer, descriptionTextures[i], nullptr, &descriptionRect);

        y += std::max(buttonRect.h, descriptionRect.h) + lineSpacing;
    }

    SDL_DestroyTexture(titleTexture);

    for (SDL_Texture* texture : buttonTextures)
        SDL_DestroyTexture(texture);

    for (SDL_Texture* texture : descriptionTextures)
        SDL_DestroyTexture(texture);

    return true;
}
const Uint32 PAGE_SKIP_INTERVAL = 350;
const int PAGE_OVERLAY_FONT_SIZE = 25;
const Uint32 PAGE_OVERLAY_HIDE_DELAY = 300;


// ------------------------------------------------------------
// Main
// ------------------------------------------------------------

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        std::cerr
            << "Usage: sdl2pdf <file.pdf>\n";

        return 1;
    }

    std::string pdf = argv[1];


    // --------------------------------------------------------
    // Get PDF information
    // --------------------------------------------------------

    int pageCount = getPageCount(pdf);

    if (pageCount <= 0)
    {
        std::cerr
            << "Could not determine PDF page count.\n";

        return 1;
    }


    uintmax_t fileSize = 0;

    try
    {
        fileSize =
            std::filesystem::file_size(pdf);
    }
    catch (...)
    {
        std::cerr
            << "Could not determine PDF file size.\n";

        return 1;
    }


    // --------------------------------------------------------
    // Load saved page
    // --------------------------------------------------------

    auto config = load_config();

    int currentPage = 1;
    int targetPage = 1;

    Uint32 pageOverlayUntil = 0;

    bool helpVisible = false;

    auto saved = config.find(pdf);

    if (saved != config.end() &&
        saved->second.fileSize == fileSize &&
        saved->second.pageCount == pageCount)
    {
        currentPage =
            saved->second.page;

        if (currentPage < 1)
            currentPage = 1;

        if (currentPage > pageCount)
            currentPage = pageCount;
    }


    // --------------------------------------------------------
    // SDL initialization
    // --------------------------------------------------------

    if (SDL_Init(
            SDL_INIT_VIDEO |
            SDL_INIT_GAMECONTROLLER
        ) != 0)
    {
        std::cerr
            << "SDL_Init failed: "
            << SDL_GetError()
            << "\n";

        return 1;
    }


    if (TTF_Init() != 0)
    {
        std::cerr
            << "TTF_Init failed: "
            << TTF_GetError()
            << "\n";

        SDL_Quit();

        return 1;
    }


    if (!(IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG))
    {
        std::cerr
            << "IMG_Init failed: "
            << IMG_GetError()
            << "\n";

        TTF_Quit();
        SDL_Quit();

        return 1;
    }


    // --------------------------------------------------------
    // Create fullscreen window
    // --------------------------------------------------------

    SDL_Window* win =
        SDL_CreateWindow(
            "PDF Viewer",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            0,
            0,
            SDL_WINDOW_FULLSCREEN_DESKTOP |
            SDL_WINDOW_BORDERLESS
        );

    if (!win)
    {
        std::cerr
            << "SDL_CreateWindow failed: "
            << SDL_GetError()
            << "\n";

        IMG_Quit();
        TTF_Quit();
        SDL_Quit();

        return 1;
    }


    // --------------------------------------------------------
    // Get actual display dimensions
    // --------------------------------------------------------

    int WINDOW_W = 0;
    int WINDOW_H = 0;

    SDL_GetWindowSize(
        win,
        &WINDOW_W,
        &WINDOW_H
    );

    if (WINDOW_W < 200)
        WINDOW_W = 640;

    if (WINDOW_H < 200)
        WINDOW_H = 480;


    // --------------------------------------------------------
    // Create renderer
    // --------------------------------------------------------

    SDL_Renderer* renderer =
        SDL_CreateRenderer(
            win,
            -1,
            SDL_RENDERER_ACCELERATED |
            SDL_RENDERER_PRESENTVSYNC
        );

    if (!renderer)
    {
        renderer =
            SDL_CreateRenderer(
                win,
                -1,
                SDL_RENDERER_SOFTWARE
            );
    }

    if (!renderer)
    {
        std::cerr
            << "SDL_CreateRenderer failed: "
            << SDL_GetError()
            << "\n";

        SDL_DestroyWindow(win);

        IMG_Quit();
        TTF_Quit();
        SDL_Quit();

        return 1;
    }


    // --------------------------------------------------------
    // Find page overlay font
    // --------------------------------------------------------

    TTF_Font* pageOverlayFont = nullptr;

    std::string fontPath =
        find_any_ttf_font();

    if (fontPath.empty())
    {
        std::cerr
            << "Warning: no TTF font found\n";
    }
    else
    {
        pageOverlayFont =
            TTF_OpenFont(
                fontPath.c_str(),
                PAGE_OVERLAY_FONT_SIZE
            );

        if (!pageOverlayFont)
        {
            std::cerr
                << "Warning: could not load "
                   "page overlay font: "
                << TTF_GetError()
                << "\n";
        }
    }


    // --------------------------------------------------------
    // Open first controller
    // --------------------------------------------------------

    SDL_GameController* controller = nullptr;

    for (int i = 0;
         i < SDL_NumJoysticks();
         ++i)
    {
        if (SDL_IsGameController(i))
        {
            controller =
                SDL_GameControllerOpen(i);

            if (controller)
                break;
        }
    }


    // --------------------------------------------------------
    // Zoom and pan state
    // --------------------------------------------------------

    const float zoomLevels[] =
    {
        1.00f,
        1.25f,
        1.50f,
        1.75f,
        2.00f,
        2.50f,
        3.00f
    };

    const int zoomLevelCount =
        sizeof(zoomLevels) /
        sizeof(zoomLevels[0]);

    int zoomIndex = 0;

    float zoom =
        zoomLevels[zoomIndex];

    int panX = 0;
    int panY = 0;

    const int PAN_STEP = 60;

    // Continuous panning settings.
    const Uint32 PAN_REPEAT_DELAY = 400;
    const Uint32 PAN_REPEAT_INTERVAL = 40;

    bool dpadLeftHeld = false;
    bool dpadRightHeld = false;
    bool dpadUpHeld = false;
    bool dpadDownHeld = false;

    bool l1Held = false;
    bool r1Held = false;

    Uint32 l1Start = 0;
    Uint32 r1Start = 0;

    Uint32 l1Repeat = 0;
    Uint32 r1Repeat = 0;

    Uint32 dpadLeftStart = 0;
    Uint32 dpadRightStart = 0;
    Uint32 dpadUpStart = 0;
    Uint32 dpadDownStart = 0;

    Uint32 dpadLeftRepeat = 0;
    Uint32 dpadRightRepeat = 0;
    Uint32 dpadUpRepeat = 0;
    Uint32 dpadDownRepeat = 0;


    auto resetView = [&]()
    {
        zoomIndex = 0;

        zoom =
            zoomLevels[zoomIndex];

        panX = 0;
        panY = 0;
    };


    // --------------------------------------------------------
    // Page texture
    // --------------------------------------------------------

    SDL_Texture* pageTexture = nullptr;


    auto loadPage =
        [&](int page) -> bool
    {
        if (pageTexture)
        {
            SDL_DestroyTexture(pageTexture);
            pageTexture = nullptr;
        }

        resetView();

        // Stop D-pad repeat when changing page.
        dpadLeftHeld = false;
        dpadRightHeld = false;
        dpadUpHeld = false;
        dpadDownHeld = false;

        l1Held = false;
        r1Held = false;

        l1Start = 0;
        r1Start = 0;

        l1Repeat = 0;
        r1Repeat = 0;

        if (!renderPage(pdf, page))
        {
            std::cerr
                << "Failed to render page "
                << page
                << "\n";

            return false;
        }

        SDL_Surface* surface =
            IMG_Load(
                "/tmp/sdl2pdf-page.png"
            );

        if (!surface)
        {
            std::cerr
                << "IMG_Load failed: "
                << IMG_GetError()
                << "\n";

            return false;
        }

        SDL_Texture* newTexture =
            SDL_CreateTextureFromSurface(
                renderer,
                surface
            );

        SDL_FreeSurface(surface);

        if (!newTexture)
        {
            std::cerr
                << "SDL_CreateTextureFromSurface "
                   "failed: "
                << SDL_GetError()
                << "\n";

            return false;
        }

        pageTexture = newTexture;

        return true;
    };


    // --------------------------------------------------------
    // Load initial page
    // --------------------------------------------------------

    if (!loadPage(currentPage))
    {
        if (pageOverlayFont)
            TTF_CloseFont(pageOverlayFont);

        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(win);

        IMG_Quit();
        TTF_Quit();
        SDL_Quit();

        return 1;
    }


    // --------------------------------------------------------
    // Event loop
    // --------------------------------------------------------

    bool running = true;

    while (running)
    {
        SDL_Event event;

        while (SDL_PollEvent(&event))
        {
            switch (event.type)
            {
                // --------------------------------------------
                // Quit
                // --------------------------------------------

                case SDL_QUIT:

                    running = false;

                    break;


                // --------------------------------------------
                // Keyboard
                // --------------------------------------------

                case SDL_KEYDOWN:
                {
                    SDL_Keycode key =
                        event.key.keysym.sym;


                    // Exit

                    if (key == SDLK_ESCAPE ||
                        key == SDLK_q)
                    {
                        running = false;
                    }


                    // Previous page

                    else if (key == SDLK_LEFT)
                    {
                        if (currentPage > 1)
                        {
                            --currentPage;
                            loadPage(currentPage);
                        }
                    }


                    // Next page

                    else if (key == SDLK_RIGHT)
                    {
                        if (currentPage < pageCount)
                        {
                            ++currentPage;
                            loadPage(currentPage);
                        }
                    }


                    // Zoom out

                    else if (key == SDLK_x)
                    {
                        if (zoomIndex > 0)
                        {
                            --zoomIndex;

                            zoom =
                                zoomLevels[zoomIndex];

                            if (zoomIndex == 0)
                            {
                                panX = 0;
                                panY = 0;
                            }
                        }
                    }


                    // Zoom in

                    else if (key == SDLK_y)
                    {
                        if (zoomIndex <
                            zoomLevelCount - 1)
                        {
                            ++zoomIndex;

                            zoom =
                                zoomLevels[zoomIndex];
                        }
                    }


                    // Pan left

                    else if (key == SDLK_a)
                    {
                        if (zoom > 1.0f)
                            panX += PAN_STEP;
                    }


                    // Pan right

                    else if (key == SDLK_d)
                    {
                        if (zoom > 1.0f)
                            panX -= PAN_STEP;
                    }


                    // Pan up

                    else if (key == SDLK_w)
                    {
                        if (zoom > 1.0f)
                            panY += PAN_STEP;
                    }


                    // Pan down

                    else if (key == SDLK_s)
                    {
                        if (zoom > 1.0f)
                            panY -= PAN_STEP;
                    }


                    // Reset zoom and center

                    else if (key == SDLK_RETURN)
                    {
                        resetView();
                    }

                    break;
                }


                // --------------------------------------------
                // Gamepad button pressed
                // --------------------------------------------

                case SDL_CONTROLLERBUTTONDOWN:

                    // Select always works so the Help screen can be opened
                    // and closed. All other controller buttons are disabled
                    // while Help is visible.
                    if (event.cbutton.button == SDL_CONTROLLER_BUTTON_BACK)
                    {
                        helpVisible = !helpVisible;

                        // Clear any held-button state when entering or leaving
                        // the Help screen.
                        l1Held = false;
                        r1Held = false;
                        dpadLeftHeld = false;
                        dpadRightHeld = false;
                        dpadUpHeld = false;
                        dpadDownHeld = false;

                        break;
                    }

                    if (helpVisible)
                        break;

                    switch (event.cbutton.button)
                    {
                        // Previous page.
                        // Change target immediately,
                        // but don't render until release.

                        case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:

                            if (!l1Held)
                            {
                                l1Held = true;

                                l1Start =
                                    SDL_GetTicks();

                                l1Repeat =
                                    l1Start;

                                targetPage =
                                    std::max(
                                        1,
                                        currentPage - 1
                                    );

                                pageOverlayUntil =
                                    SDL_GetTicks() +
                                    PAGE_OVERLAY_HIDE_DELAY;
                            }

                            break;


                        // Next page.
                        // Change target immediately,
                        // but don't render until release.

                        case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER:

                            if (!r1Held)
                            {
                                r1Held = true;

                                r1Start =
                                    SDL_GetTicks();

                                r1Repeat =
                                    r1Start;

                                targetPage =
                                    std::min(
                                        pageCount,
                                        currentPage + 1
                                    );

                                pageOverlayUntil =
                                    SDL_GetTicks() +
                                    PAGE_OVERLAY_HIDE_DELAY;
                            }

                            break;


                        // Exit

                        case SDL_CONTROLLER_BUTTON_A:
                        case SDL_CONTROLLER_BUTTON_B:

                            running = false;

                            break;


                        // Zoom out

                        case SDL_CONTROLLER_BUTTON_X:

                            if (zoomIndex > 0)
                            {
                                --zoomIndex;

                                zoom =
                                    zoomLevels[zoomIndex];

                                if (zoomIndex == 0)
                                {
                                    panX = 0;
                                    panY = 0;
                                }
                            }

                            break;


                        // Zoom in

                        case SDL_CONTROLLER_BUTTON_Y:

                            if (zoomIndex <
                                zoomLevelCount - 1)
                            {
                                ++zoomIndex;

                                zoom =
                                    zoomLevels[zoomIndex];
                            }

                            break;


                        // Reset zoom and center

                        case SDL_CONTROLLER_BUTTON_START:

                            resetView();

                            break;


                        // D-pad left

                        case SDL_CONTROLLER_BUTTON_DPAD_LEFT:

                            if (zoom > 1.0f)
                            {
                                panX += PAN_STEP;

                                dpadLeftHeld = true;

                                dpadLeftStart =
                                    SDL_GetTicks();

                                dpadLeftRepeat =
                                    dpadLeftStart;
                            }

                            break;


                        // D-pad right

                        case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:

                            if (zoom > 1.0f)
                            {
                                panX -= PAN_STEP;

                                dpadRightHeld = true;

                                dpadRightStart =
                                    SDL_GetTicks();

                                dpadRightRepeat =
                                    dpadRightStart;
                            }

                            break;


                        // D-pad up

                        case SDL_CONTROLLER_BUTTON_DPAD_UP:

                            if (zoom > 1.0f)
                            {
                                panY += PAN_STEP;

                                dpadUpHeld = true;

                                dpadUpStart =
                                    SDL_GetTicks();

                                dpadUpRepeat =
                                    dpadUpStart;
                            }

                            break;


                        // D-pad down

                        case SDL_CONTROLLER_BUTTON_DPAD_DOWN:

                            if (zoom > 1.0f)
                            {
                                panY -= PAN_STEP;

                                dpadDownHeld = true;

                                dpadDownStart =
                                    SDL_GetTicks();

                                dpadDownRepeat =
                                    dpadDownStart;
                            }

                            break;


                        default:

                            break;
                    }

                    break;


                // --------------------------------------------
                // Gamepad button released
                // --------------------------------------------

                case SDL_CONTROLLERBUTTONUP:

                    // Ignore button releases while the Help screen is visible.
                    if (helpVisible)
                        break;

                    switch (event.cbutton.button)
                    {
                        case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:

                            if (l1Held)
                            {
                                if (targetPage != currentPage)
                                {
                                    currentPage =
                                        targetPage;

                                    loadPage(
                                        currentPage
                                    );
                                }

                                l1Held = false;
                            }

                            break;


                        case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER:

                            if (r1Held)
                            {
                                if (targetPage != currentPage)
                                {
                                    currentPage =
                                        targetPage;

                                    loadPage(
                                        currentPage
                                    );
                                }

                                r1Held = false;
                            }

                            break;


                        case SDL_CONTROLLER_BUTTON_DPAD_LEFT:

                            dpadLeftHeld = false;

                            break;


                        case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:

                            dpadRightHeld = false;

                            break;


                        case SDL_CONTROLLER_BUTTON_DPAD_UP:

                            dpadUpHeld = false;

                            break;


                        case SDL_CONTROLLER_BUTTON_DPAD_DOWN:

                            dpadDownHeld = false;

                            break;


                        default:

                            break;
                    }

                    break;


                // --------------------------------------------
                // Controller hotplug
                // --------------------------------------------

                case SDL_CONTROLLERDEVICEADDED:

                    if (!controller)
                    {
                        controller =
                            SDL_GameControllerOpen(
                                event.cdevice.which
                            );
                    }

                    break;


                case SDL_CONTROLLERDEVICEREMOVED:

                    if (controller)
                    {
                        SDL_Joystick* joystick =
                            SDL_GameControllerGetJoystick(
                                controller
                            );

                        SDL_JoystickID id =
                            SDL_JoystickInstanceID(
                                joystick
                            );

                        if (id ==
                            event.cdevice.which)
                        {
                            SDL_GameControllerClose(
                                controller
                            );

                            controller = nullptr;

                            dpadLeftHeld = false;
                            dpadRightHeld = false;
                            dpadUpHeld = false;
                            dpadDownHeld = false;

                            l1Held = false;
                            r1Held = false;
                        }
                    }

                    break;
            }
        }


        // ----------------------------------------------------
        // L1/R1 hold to skip 5 pages
        // ----------------------------------------------------

        Uint32 now = SDL_GetTicks();

        // Only change the target page while held.
        // The actual PDF is rendered once on release.

        if (!helpVisible &&
            l1Held &&
            now - l1Start >= PAN_REPEAT_DELAY &&
            now - l1Repeat >= PAGE_SKIP_INTERVAL)
        {
            targetPage =
                std::max(
                    1,
                    targetPage - 5
                );

            pageOverlayUntil =
                now + PAGE_OVERLAY_HIDE_DELAY;

            l1Repeat = now;
        }


        if (!helpVisible &&
            r1Held &&
            now - r1Start >= PAN_REPEAT_DELAY &&
            now - r1Repeat >= PAGE_SKIP_INTERVAL)
        {
            targetPage =
                std::min(
                    pageCount,
                    targetPage + 5
                );

            pageOverlayUntil =
                now + PAGE_OVERLAY_HIDE_DELAY;

            r1Repeat = now;
        }


        // ----------------------------------------------------
        // Continuous D-pad panning
        // ----------------------------------------------------

        now = SDL_GetTicks();


        if (!helpVisible &&
            dpadLeftHeld &&
            now - dpadLeftStart >= PAN_REPEAT_DELAY &&
            now - dpadLeftRepeat >= PAN_REPEAT_INTERVAL)
        {
            panX += PAN_STEP;

            dpadLeftRepeat = now;
        }


        if (!helpVisible &&
            dpadRightHeld &&
            now - dpadRightStart >= PAN_REPEAT_DELAY &&
            now - dpadRightRepeat >= PAN_REPEAT_INTERVAL)
        {
            panX -= PAN_STEP;

            dpadRightRepeat = now;
        }


        if (!helpVisible &&
            dpadUpHeld &&
            now - dpadUpStart >= PAN_REPEAT_DELAY &&
            now - dpadUpRepeat >= PAN_REPEAT_INTERVAL)
        {
            panY += PAN_STEP;

            dpadUpRepeat = now;
        }


        if (!helpVisible &&
            dpadDownHeld &&
            now - dpadDownStart >= PAN_REPEAT_DELAY &&
            now - dpadDownRepeat >= PAN_REPEAT_INTERVAL)
        {
            panY -= PAN_STEP;

            dpadDownRepeat = now;
        }


        // ----------------------------------------------------
        // Draw
        // ----------------------------------------------------

        SDL_SetRenderDrawColor(
            renderer,
            0,
            0,
            0,
            255
        );

        SDL_RenderClear(renderer);


        if (pageTexture)
        {
            int texW = 0;
            int texH = 0;

            SDL_QueryTexture(
                pageTexture,
                nullptr,
                nullptr,
                &texW,
                &texH
            );


            // -----------------------------------------------
            // Calculate fit-to-screen size
            // -----------------------------------------------

            float imageRatio =
                static_cast<float>(texW) /
                static_cast<float>(texH);

            float screenRatio =
                static_cast<float>(WINDOW_W) /
                static_cast<float>(WINDOW_H);

            int baseW;
            int baseH;

            if (imageRatio > screenRatio)
            {
                baseW = WINDOW_W;

                baseH =
                    static_cast<int>(
                        WINDOW_W / imageRatio
                    );
            }
            else
            {
                baseH = WINDOW_H;

                baseW =
                    static_cast<int>(
                        WINDOW_H * imageRatio
                    );
            }


            // -----------------------------------------------
            // Apply zoom
            // -----------------------------------------------

            int drawW =
                static_cast<int>(
                    baseW * zoom
                );

            int drawH =
                static_cast<int>(
                    baseH * zoom
                );


            // -----------------------------------------------
            // Calculate maximum panning range
            // -----------------------------------------------

            int maxPanX =
                std::max(
                    0,
                    (drawW - WINDOW_W) / 2
                );

            int maxPanY =
                std::max(
                    0,
                    (drawH - WINDOW_H) / 2
                );


            // Clamp panning.

            panX =
                std::clamp(
                    panX,
                    -maxPanX,
                    maxPanX
                );

            panY =
                std::clamp(
                    panY,
                    -maxPanY,
                    maxPanY
                );


            // -----------------------------------------------
            // Center page and apply pan
            // -----------------------------------------------

            SDL_Rect destination;

            destination.w = drawW;
            destination.h = drawH;

            destination.x =
                (WINDOW_W - drawW) / 2 +
                panX;

            destination.y =
                (WINDOW_H - drawH) / 2 +
                panY;


            SDL_RenderCopy(
                renderer,
                pageTexture,
                nullptr,
                &destination
            );
        }


        // ----------------------------------------------------
        // Page overlay
        // ----------------------------------------------------

        if (!helpVisible &&
            (l1Held || r1Held) &&
            SDL_GetTicks() < pageOverlayUntil)
        {
            drawPageOverlay(
                renderer,
                pageOverlayFont,
                targetPage,
                pageCount
            );
        }


        // ----------------------------------------------------
        // Help screen
        // ----------------------------------------------------

        if (helpVisible)
        {
            drawHelpScreen(
                renderer,
                pageOverlayFont,
                WINDOW_W,
                WINDOW_H
            );
        }


        SDL_RenderPresent(renderer);
    }


    // --------------------------------------------------------
    // Save current page
    // --------------------------------------------------------

    config[pdf] =
    {
        currentPage,
        fileSize,
        pageCount
    };

    save_config(config);


    // --------------------------------------------------------
    // Cleanup
    // --------------------------------------------------------

    if (controller)
        SDL_GameControllerClose(controller);

    if (pageTexture)
        SDL_DestroyTexture(pageTexture);

    if (pageOverlayFont)
        TTF_CloseFont(pageOverlayFont);

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(win);

    IMG_Quit();
    TTF_Quit();
    SDL_Quit();

    return 0;
}