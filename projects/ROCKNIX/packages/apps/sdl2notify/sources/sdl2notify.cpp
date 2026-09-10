//# SPDX-License-Identifier: GPL-2.0
//# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

#include <algorithm>
#include <cctype>
#include <iostream>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

static const char* FONT_PATH =
    "/usr/share/fonts/truetype/dejavu/DejaVuSansCondensed.ttf";

// Separates the main message from an optional smaller subtitle line, e.g.
//   "Game Saved||Press START to continue"
// The subtitle is rendered in a smaller font directly under the main text,
// as part of the same centered block. This is a literal token, distinct
// from "\n" (which still just breaks the main text into multiple full-size
// lines).
static const char* SUBTITLE_SEP = "||";

enum Position
{
    TOP,
    CENTER,
    BOTTOM
};

static void usage(const char* p)
{
    std::cout
        << "Usage:\n"
        << "  " << p << " [--top|--center|--bottom] \"Text\\nMore||Smaller subtitle\" R G B [Seconds|Button]\n"
        << "\n"
        << "  Use \\n inside the text to add additional full-size lines.\n"
        << "  Use || once to add a smaller subtitle line under the main text, e.g.\n"
        << "    \"Game Saved||Auto-save complete\"\n"
        << "\n"
        << "  The 5th argument is optional and can be EITHER:\n"
        << "    - a number of seconds, e.g. 5   -> closes after 5s, or on any button\n"
        << "    - a button name, e.g.   start   -> closes ONLY when that button is pressed\n"
        << "\n"
        << "  Valid button names (case-insensitive):\n"
        << "    a, b, x, y, back, select (alias for back), guide,\n"
        << "    start, leftstick, rightstick, leftshoulder, rightshoulder,\n"
        << "    dpup, dpdown, dpleft, dpright, misc1,\n"
        << "    paddle1, paddle2, paddle3, paddle4, touchpad, any\n"
        << "\n"
        << "  If the 5th argument is omitted entirely, the overlay waits for\n"
        << "  ANY controller button, and shows \"Press any button to continue\"\n"
        << "  at the bottom of the screen. Pressing Escape or closing the\n"
        << "  window also dismisses the overlay.\n";
}

// Maps a user-supplied button name to the SDL enum. Returns true and fills
// `out` on success. Accepts SDL_CONTROLLER_BUTTON_INVALID-style names minus
// the prefix, lowercased, plus the common alias "select" for "back".
static bool parse_button_name(std::string name, SDL_GameControllerButton& out)
{
    std::transform(name.begin(), name.end(), name.begin(),
                    [](unsigned char c) { return std::tolower(c); });

    static const std::vector<std::pair<std::string, SDL_GameControllerButton>> table = {
        {"a", SDL_CONTROLLER_BUTTON_A},
        {"b", SDL_CONTROLLER_BUTTON_B},
        {"x", SDL_CONTROLLER_BUTTON_X},
        {"y", SDL_CONTROLLER_BUTTON_Y},
        {"back", SDL_CONTROLLER_BUTTON_BACK},
        {"select", SDL_CONTROLLER_BUTTON_BACK},
        {"guide", SDL_CONTROLLER_BUTTON_GUIDE},
        {"start", SDL_CONTROLLER_BUTTON_START},
        {"leftstick", SDL_CONTROLLER_BUTTON_LEFTSTICK},
        {"rightstick", SDL_CONTROLLER_BUTTON_RIGHTSTICK},
        {"leftshoulder", SDL_CONTROLLER_BUTTON_LEFTSHOULDER},
        {"rightshoulder", SDL_CONTROLLER_BUTTON_RIGHTSHOULDER},
        {"dpup", SDL_CONTROLLER_BUTTON_DPAD_UP},
        {"dpdown", SDL_CONTROLLER_BUTTON_DPAD_DOWN},
        {"dpleft", SDL_CONTROLLER_BUTTON_DPAD_LEFT},
        {"dpright", SDL_CONTROLLER_BUTTON_DPAD_RIGHT},
        {"misc1", SDL_CONTROLLER_BUTTON_MISC1},
        {"paddle1", SDL_CONTROLLER_BUTTON_PADDLE1},
        {"paddle2", SDL_CONTROLLER_BUTTON_PADDLE2},
        {"paddle3", SDL_CONTROLLER_BUTTON_PADDLE3},
        {"paddle4", SDL_CONTROLLER_BUTTON_PADDLE4},
        {"touchpad", SDL_CONTROLLER_BUTTON_TOUCHPAD},
    };

    for (auto& entry : table)
    {
        if (entry.first == name)
        {
            out = entry.second;
            return true;
        }
    }

    return false;
}

// Human-readable display name for a button, used in the "Press X to
// continue" hint. Deliberately separate from the parse table since a couple
// of names are aliases (select/back) and we want one canonical display form.
static std::string button_display_name(SDL_GameControllerButton btn)
{
    switch (btn)
    {
        case SDL_CONTROLLER_BUTTON_A:             return "A";
        case SDL_CONTROLLER_BUTTON_B:             return "B";
        case SDL_CONTROLLER_BUTTON_X:             return "X";
        case SDL_CONTROLLER_BUTTON_Y:             return "Y";
        case SDL_CONTROLLER_BUTTON_BACK:          return "SELECT";
        case SDL_CONTROLLER_BUTTON_GUIDE:         return "GUIDE";
        case SDL_CONTROLLER_BUTTON_START:         return "START";
        case SDL_CONTROLLER_BUTTON_LEFTSTICK:     return "L3";
        case SDL_CONTROLLER_BUTTON_RIGHTSTICK:    return "R3";
        case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:  return "L1";
        case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: return "R1";
        case SDL_CONTROLLER_BUTTON_DPAD_UP:       return "D-PAD UP";
        case SDL_CONTROLLER_BUTTON_DPAD_DOWN:     return "D-PAD DOWN";
        case SDL_CONTROLLER_BUTTON_DPAD_LEFT:     return "D-PAD LEFT";
        case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:    return "D-PAD RIGHT";
        case SDL_CONTROLLER_BUTTON_MISC1:         return "MISC";
        case SDL_CONTROLLER_BUTTON_PADDLE1:       return "PADDLE 1";
        case SDL_CONTROLLER_BUTTON_PADDLE2:       return "PADDLE 2";
        case SDL_CONTROLLER_BUTTON_PADDLE3:       return "PADDLE 3";
        case SDL_CONTROLLER_BUTTON_PADDLE4:       return "PADDLE 4";
        case SDL_CONTROLLER_BUTTON_TOUCHPAD:      return "TOUCHPAD";
        default:                                  return "BUTTON";
    }
}

static std::vector<std::string> split_lines(std::string text)
{
    size_t pos = 0;
    while ((pos = text.find("\\n", pos)) != std::string::npos)
    {
        text.replace(pos, 2, "\n");
        pos++;
    }

    std::vector<std::string> lines;
    std::stringstream ss(text);
    std::string line;

    while (std::getline(ss, line))
        lines.push_back(line);

    return lines;
}

// Opens every currently-connected controller and returns the handles.
static std::vector<SDL_GameController*> open_all_controllers()
{
    std::vector<SDL_GameController*> pads;

    int n = SDL_NumJoysticks();
    for (int i = 0; i < n; i++)
    {
        if (SDL_IsGameController(i))
        {
            SDL_GameController* pad = SDL_GameControllerOpen(i);
            if (pad)
                pads.push_back(pad);
        }
    }

    return pads;
}

int main(int argc, char* argv[])
{
    Position position = CENTER;
    int arg = 1;

    if (argc > 1)
    {
        std::string opt = argv[arg];

        if (opt == "--top")        { position = TOP; arg++; }
        else if (opt == "--bottom"){ position = BOTTOM; arg++; }
        else if (opt == "--center"){ position = CENTER; arg++; }
    }

    // Text + R G B are required; trailing 5th arg is optional and can be
    // EITHER a number of seconds OR a button name (e.g. "start").
    int remaining = argc - arg;
    if (remaining != 4 && remaining != 5)
    {
        usage(argv[0]);
        return 1;
    }

    std::string rawText = argv[arg++];
    int r = atoi(argv[arg++]);
    int g = atoi(argv[arg++]);
    int b = atoi(argv[arg++]);

    bool hasTimeout = false;
    int seconds = 0;
    bool restrictButton = false;
    // Whether to show the "Press X to continue" hint. True by default
    // (covers: 5th arg omitted entirely -> wait for any button), and only
    // set false when a numeric timeout was explicitly given.
    bool showButtonHint = true;
    SDL_GameControllerButton targetButton = SDL_CONTROLLER_BUTTON_INVALID;

    if (remaining == 5)
    {
        std::string fifth = argv[arg++];

        // Decide: is this purely digits (a timeout), or a button name?
        bool isNumber = !fifth.empty() &&
            std::all_of(fifth.begin(), fifth.end(),
                        [](unsigned char c) { return std::isdigit(c); });

        if (isNumber)
        {
            hasTimeout = true;
            seconds = std::max(1, atoi(fifth.c_str()));
            // A pure countdown: any button still works as a bonus escape
            // hatch, but since the person asked for a timer (not a button
            // prompt), don't show the "press X to continue" hint.
            showButtonHint = false;
        }
        else if (fifth == "any")
        {
            // Explicit "any" behaves the same as omitting the arg.
            restrictButton = false;
        }
        else if (parse_button_name(fifth, targetButton))
        {
            restrictButton = true;
        }
        else
        {
            std::cerr << "Unrecognized 5th argument: " << fifth
                       << " (expected a number of seconds or a button name)\n";
            usage(argv[0]);
            return 1;
        }
    }

    // Split off an optional smaller subtitle line using the literal "||"
    // token. Only the first occurrence counts as the separator; if "||"
    // shows up again it's just treated as part of the subtitle text.
    std::string mainText = rawText;
    std::string subtitleText;
    bool hasSubtitle = false;

    {
        size_t sepPos = rawText.find(SUBTITLE_SEP);
        if (sepPos != std::string::npos)
        {
            mainText = rawText.substr(0, sepPos);
            subtitleText = rawText.substr(sepPos + std::string(SUBTITLE_SEP).length());
            hasSubtitle = !subtitleText.empty();
        }
    }

    // Bottom hint text ("Press START to continue" / "Press any button to
    // continue"), shown only when the person actually asked for button-based
    // dismissal (button name given, or 5th arg omitted) — not during a
    // plain timed countdown.
    std::string hintText;
    if (showButtonHint)
    {
        hintText = restrictButton
            ? ("Press " + button_display_name(targetButton) + " to continue")
            : "Press any button to continue";
    }

    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER) != 0)
    {
        std::cerr << "SDL_Init failed: " << SDL_GetError() << "\n";
        return 1;
    }

    if (TTF_Init() != 0)
    {
        std::cerr << "TTF_Init failed: " << TTF_GetError() << "\n";
        SDL_Quit();
        return 1;
    }

    // Open whatever controllers are already plugged in. We also listen for
    // SDL_CONTROLLERDEVICEADDED so a pad plugged in after launch still works.
    std::vector<SDL_GameController*> pads = open_all_controllers();

    SDL_DisplayMode mode;
    if (SDL_GetCurrentDisplayMode(0, &mode) != 0)
    {
        std::cerr << "Display error: " << SDL_GetError() << "\n";
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    int screenW = mode.w;
    int screenH = mode.h;

    SDL_Window* window = SDL_CreateWindow(
        "",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        screenW,
        screenH,
        SDL_WINDOW_FULLSCREEN_DESKTOP |
        SDL_WINDOW_BORDERLESS |
        SDL_WINDOW_ALWAYS_ON_TOP
    );

    SDL_Renderer* renderer = SDL_CreateRenderer(
        window,
        -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
    );

    if (!renderer)
    {
        std::cerr << SDL_GetError() << "\n";
        return 1;
    }

    std::vector<std::string> lines = split_lines(mainText);

    // Append the subtitle as one more line in the same block, flagged so
    // it renders smaller than the main lines above it.
    size_t subtitleIndex = std::string::npos;
    if (hasSubtitle)
    {
        lines.push_back(subtitleText);
        subtitleIndex = lines.size() - 1;
    }

    int fontSize = screenH / 12;

    SDL_Color color = {
        (Uint8)r, (Uint8)g, (Uint8)b, 255
    };

    TTF_Font* font = nullptr;
    TTF_Font* subtitleFont = nullptr;

    std::vector<SDL_Texture*> textures;
    std::vector<SDL_Rect> rects;

    int totalH = 0;
    int maxW = 0;

    // ---------------- FONT AUTO SCALE ----------------
    while (fontSize >= 20)
    {
        if (font) TTF_CloseFont(font);
        if (subtitleFont) { TTF_CloseFont(subtitleFont); subtitleFont = nullptr; }

        for (auto t : textures)
        {
            if (t) SDL_DestroyTexture(t);
        }

        textures.clear();
        rects.clear();

        totalH = 0;
        maxW = 0;

        font = TTF_OpenFont(FONT_PATH, fontSize);
        if (!font)
        {
            std::cerr << "Font load failed\n";
            return 1;
        }

        if (subtitleIndex != std::string::npos)
        {
            // Subtitle renders at ~65% of the main font size, with a floor
            // so it stays legible even when the main text has shrunk a lot.
            int subtitleFontSize = std::max(14, (int)(fontSize * 0.65));
            subtitleFont = TTF_OpenFont(FONT_PATH, subtitleFontSize);
            if (!subtitleFont)
            {
                std::cerr << "Font load failed\n";
                return 1;
            }
        }

        bool ok = true;

        for (size_t i = 0; i < lines.size(); i++)
        {
            const std::string& line = lines[i];
            bool isSubtitleLine = (i == subtitleIndex);

            TTF_Font* useFont = isSubtitleLine ? subtitleFont : font;

            SDL_Surface* surf =
                TTF_RenderUTF8_Blended(useFont, line.c_str(), color);

            if (!surf)
            {
                ok = false;
                break;
            }

            SDL_Texture* tex =
                SDL_CreateTextureFromSurface(renderer, surf);

            SDL_Rect rct;
            rct.w = surf->w;
            rct.h = surf->h;

            textures.push_back(tex);
            rects.push_back(rct);

            totalH += rct.h;
            maxW = std::max(maxW, rct.w);

            SDL_FreeSurface(surf);
        }

        if (ok && maxW <= screenW * 0.90)
            break;

        fontSize -= 4;
    }

    // ---------------- LAYOUT (main text block) ----------------
    int y;

    if (position == TOP)
        y = screenH * 0.05;
    else if (position == BOTTOM)
        y = screenH - totalH - screenH * 0.05;
    else
        y = (screenH - totalH) / 2;

    for (auto& rct : rects)
    {
        rct.x = (screenW - rct.w) / 2;
        rct.y = y;
        y += rct.h;
    }

    // ---------------- HINT TEXT (smaller font, pinned to screen bottom) ---
    // Independent of the main text block and its position; always anchored
    // near the bottom of the screen, same as the original behavior.
    TTF_Font* hintFont = nullptr;
    SDL_Texture* hintTexture = nullptr;
    SDL_Rect hintRect{};

    if (!hintText.empty())
    {
        int hintFontSize = std::max(12, fontSize / 2);
        hintFont = TTF_OpenFont(FONT_PATH, hintFontSize);

        if (hintFont)
        {
            SDL_Surface* surf =
                TTF_RenderUTF8_Blended(hintFont, hintText.c_str(), color);

            if (surf)
            {
                hintTexture = SDL_CreateTextureFromSurface(renderer, surf);

                hintRect.w = surf->w;
                hintRect.h = surf->h;
                hintRect.x = (screenW - hintRect.w) / 2;
                hintRect.y = screenH - hintRect.h - (int)(screenH * 0.04);

                SDL_FreeSurface(surf);
            }
        }
    }

    Uint32 end = hasTimeout ? (SDL_GetTicks() + seconds * 1000) : 0;

    // Small grace period so a button that was already being held down when
    // the overlay appeared (e.g. the same press that triggered it) doesn't
    // instantly close it again. Tune/remove as needed.
    Uint32 inputGraceEnd = SDL_GetTicks() + 150;

    // ---------------- MAIN LOOP ----------------
    bool running = true;

    while (running)
    {
        SDL_Event e;
        while (SDL_PollEvent(&e))
        {
            switch (e.type)
            {
                case SDL_QUIT:
                    running = false;
                    break;

                case SDL_KEYDOWN:
                    if (e.key.keysym.sym == SDLK_ESCAPE)
                        running = false;
                    break;

                case SDL_CONTROLLERBUTTONDOWN:
                    if (SDL_GetTicks() >= inputGraceEnd)
                    {
                        if (!restrictButton ||
                            (SDL_GameControllerButton)e.cbutton.button == targetButton)
                        {
                            running = false;
                        }
                    }
                    break;

                case SDL_JOYBUTTONDOWN:
                    // Fallback for controllers SDL doesn't recognize via the
                    // GameController mapping API but that still show up as
                    // raw joysticks. Specific-button filtering only works
                    // through the GameController API above, so a raw
                    // joystick press here only dismisses in "any" mode.
                    if (!restrictButton && SDL_GetTicks() >= inputGraceEnd)
                        running = false;
                    break;

                case SDL_CONTROLLERDEVICEADDED:
                {
                    SDL_GameController* pad =
                        SDL_GameControllerOpen(e.cdevice.which);
                    if (pad)
                        pads.push_back(pad);
                    break;
                }

                case SDL_CONTROLLERDEVICEREMOVED:
                    // Let SDL clean up; nothing required here.
                    break;

                default:
                    break;
            }

            if (!running)
                break;
        }

        if (hasTimeout && SDL_GetTicks() >= end)
            break;

        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);

        for (size_t i = 0; i < textures.size(); i++)
        {
            if (textures[i])
                SDL_RenderCopy(renderer, textures[i], nullptr, &rects[i]);
        }

        if (hintTexture)
            SDL_RenderCopy(renderer, hintTexture, nullptr, &hintRect);

        SDL_RenderPresent(renderer);

        SDL_Delay(8); // light idle to avoid pegging a CPU core while waiting
    }

    // ---------------- FIX: NO FLASH TEARDOWN ----------------

    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);

    SDL_Delay(50); // allow compositor to flush last frame

    // ---------------- CLEANUP ----------------

    for (auto t : textures)
    {
        if (t)
            SDL_DestroyTexture(t);
    }

    if (hintTexture)
        SDL_DestroyTexture(hintTexture);

    if (hintFont)
        TTF_CloseFont(hintFont);

    if (subtitleFont)
        TTF_CloseFont(subtitleFont);

    if (font)
        TTF_CloseFont(font);

    for (auto pad : pads)
        SDL_GameControllerClose(pad);

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);

    TTF_Quit();
    SDL_Quit();

    return 0;
}
