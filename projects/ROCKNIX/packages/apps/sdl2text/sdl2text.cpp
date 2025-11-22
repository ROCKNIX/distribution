// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <dirent.h>
#include <filesystem>
#include <map>
#include <cstdint>

// -------------------- Config Helpers --------------------
std::filesystem::path get_config_file() {
    std::filesystem::path cfgDir = std::filesystem::path(std::getenv("HOME")) / ".config" / "sdl2text";
    std::filesystem::create_directories(cfgDir);
    return cfgDir / "sdl2text.conf";
}

struct FileConfig { int scroll = 0; int fontSize = 40; }; // default font size 40

std::map<std::string, FileConfig> load_config() {
    std::map<std::string, FileConfig> cfg;
    std::ifstream f(get_config_file());
    if(!f.is_open()) return cfg;
    std::string line;
    while(std::getline(f,line)){
        size_t sep = line.find('=');
        if(sep != std::string::npos){
            std::string key = line.substr(0,sep);
            std::string val = line.substr(sep+1);
            size_t comma = val.find(',');
            int scroll = 0;
            int font = 40;
            if(comma != std::string::npos){
                try {
                    scroll = std::stoi(val.substr(0,comma));
                    font = std::stoi(val.substr(comma+1));
                } catch(...) { /* ignore parse errors, use defaults */ }
            }
            cfg[key] = {scroll,font};
        }
    }
    return cfg;
}

void save_config(const std::map<std::string, FileConfig>& cfg) {
    std::ofstream f(get_config_file());
    if(!f.is_open()) return;
    for(const auto& [k,v]: cfg){
        f << k << "=" << v.scroll << "," << v.fontSize << "\n";
    }
}

// -------------------- File & Font Helpers --------------------
std::vector<std::string> load_file_lines(const std::string& path) {
    std::vector<std::string> lines;
    std::ifstream file(path);
    std::string line;
    while (std::getline(file, line)) lines.push_back(line);
    return lines;
}

std::string find_any_ttf_font() {
    const char* dirs[] = {
        "/usr/share/fonts/truetype/",
        "/usr/share/fonts/truetype/dejavu/",
        "/usr/share/fonts/",
        "/usr/local/share/fonts/",
        "/system/fonts/"
    };
    for (auto dir : dirs) {
        DIR* d = opendir(dir);
        if (!d) continue;
        struct dirent* ent;
        while ((ent = readdir(d)) != nullptr) {
            std::string name = ent->d_name;
            if (name.size() > 4 && name.substr(name.size()-4) == ".ttf") {
                closedir(d);
                return std::string(dir) + name;
            }
        }
        closedir(d);
    }
    return "";
}

// -------------------- UTF-8 safe filtering for unsupported glyphs --------------------
static bool font_can_render_codepoint(TTF_Font* font, uint32_t cp) {
    if (cp <= 0xFFFF) {
        return TTF_GlyphIsProvided(font, static_cast<Uint16>(cp)) != 0;
    }
    return false;
}

std::string filter_invalid_chars(const std::string& s, TTF_Font* font) {
    std::string out;
    size_t i = 0;
    while (i < s.size()) {
        unsigned char c = static_cast<unsigned char>(s[i]);
        if (c < 0x80) {
            if (font_can_render_codepoint(font, c)) out.push_back(static_cast<char>(c));
            ++i;
            continue;
        }

        uint32_t cp = 0;
        size_t seqLen = 0;

        if ((c & 0xE0) == 0xC0) { 
            if (i + 1 >= s.size()) { ++i; continue; }
            unsigned char c1 = static_cast<unsigned char>(s[i+1]);
            if ((c1 & 0xC0) != 0x80) { ++i; continue; }
            cp = ((c & 0x1F) << 6) | (c1 & 0x3F);
            seqLen = 2;
            if (cp < 0x80) { i += 2; continue; }
        } else if ((c & 0xF0) == 0xE0) { 
            if (i + 2 >= s.size()) { ++i; continue; }
            unsigned char c1 = static_cast<unsigned char>(s[i+1]);
            unsigned char c2 = static_cast<unsigned char>(s[i+2]);
            if ((c1 & 0xC0) != 0x80 || (c2 & 0xC0) != 0x80) { ++i; continue; }
            cp = ((c & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
            seqLen = 3;
        } else if ((c & 0xF8) == 0xF0) { 
            if (i + 3 >= s.size()) { ++i; continue; }
            unsigned char c1 = static_cast<unsigned char>(s[i+1]);
            unsigned char c2 = static_cast<unsigned char>(s[i+2]);
            unsigned char c3 = static_cast<unsigned char>(s[i+3]);
            if ((c1 & 0xC0) != 0x80 || (c2 & 0xC0) != 0x80 || (c3 & 0xC0) != 0x80) { ++i; continue; }
            cp = ((c & 0x07) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6) | (c3 & 0x3F);
            seqLen = 4;
        } else { ++i; continue; }

        if (seqLen == 0) { ++i; continue; }

        if (font_can_render_codepoint(font, cp)) {
            out.append(s.substr(i, seqLen));
        }

        i += seqLen;
    }
    return out;
}

// -------------------- Split long line into chunks to fit screen width --------------------
std::vector<std::string> wrap_line(const std::string& line, TTF_Font* font, int maxWidth) {
    std::vector<std::string> result;
    size_t start = 0;
    size_t len = line.length();
    while (start < len) {
        size_t lo = 1, hi = len - start;
        size_t best = 1;
        while (lo <= hi) {
            size_t mid = (lo + hi)/2;
            std::string chunk = line.substr(start, mid);
            int w=0,h=0;
            TTF_SizeUTF8(font, chunk.c_str(), &w, &h);
            if (w > maxWidth) hi = mid-1;
            else { best = mid; lo = mid+1; }
        }
        std::string chunk = line.substr(start, best);
        if(chunk.empty()) chunk = line.substr(start, 1);
        result.push_back(chunk);
        start += chunk.length();
    }
    return result;
}

// -------------------- Pre-render lines to textures --------------------
struct LineTexture { SDL_Texture* tex; int w, h; };

std::vector<LineTexture> create_textures(SDL_Renderer* ren, TTF_Font* font, const std::vector<std::string>& wrapped, SDL_Color color) {
    std::vector<LineTexture> textures;
    for (const auto &line : wrapped) {
        SDL_Surface* surf = TTF_RenderUTF8_Blended(font, line.c_str(), color);
        if (!surf) continue;
        SDL_Texture* tex = SDL_CreateTextureFromSurface(ren, surf);
        textures.push_back({tex, surf->w, surf->h});
        SDL_FreeSurface(surf);
    }
    return textures;
}

// -------------------- Main --------------------
int main(int argc, char* argv[]) {
    if(argc < 2){
        std::cout << "Usage: " << argv[0] << " <textfile>\n";
        return 1;
    }

    std::filesystem::path textFilePath = std::filesystem::absolute(argv[1]);
    std::string textFile = textFilePath.string();
    auto lines = load_file_lines(textFile);
    if(lines.empty()){ std::cout << "Failed to load file\n"; return 1; }

    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER) != 0) {
        std::cerr << "SDL_Init error: " << SDL_GetError() << "\n";
        return 1;
    }
    if (TTF_Init() != 0) {
        std::cerr << "TTF_Init error: " << TTF_GetError() << "\n";
        SDL_Quit();
        return 1;
    }

    std::string fontPath = find_any_ttf_font();
    if(fontPath.empty()){ std::cout << "No TTF font found\n"; TTF_Quit(); SDL_Quit(); return 1; }
    std::cout << "Using font: " << fontPath << "\n";

    auto cfg = load_config();
    FileConfig fcfg = cfg[textFile];
    int fontSize = fcfg.fontSize;

    auto loadFont = [&](int size) -> TTF_Font* {
        TTF_Font* f = TTF_OpenFont(fontPath.c_str(), size);
        if(!f) std::cout << "Failed to load font size " << size << ": " << TTF_GetError() << "\n";
        return f;
    };
    TTF_Font* font = loadFont(fontSize);
    if (!font) { TTF_Quit(); SDL_Quit(); return 1; }

    SDL_Window* win = SDL_CreateWindow("Text Viewer",
                                       SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                       0,0,
                                       SDL_WINDOW_FULLSCREEN_DESKTOP|SDL_WINDOW_BORDERLESS);
    if (!win) { std::cerr << "SDL_CreateWindow error\n"; TTF_CloseFont(font); TTF_Quit(); SDL_Quit(); return 1; }
    SDL_Renderer* ren = SDL_CreateRenderer(win,-1,SDL_RENDERER_ACCELERATED);
    if (!ren) { SDL_DestroyWindow(win); TTF_CloseFont(font); TTF_Quit(); SDL_Quit(); return 1; }

    int WINDOW_W = 0, WINDOW_H = 0;
    SDL_GetWindowSize(win,&WINDOW_W,&WINDOW_H);
    SDL_Color white = {255,255,255,255};

    int scroll_y = fcfg.scroll;
    const int SCROLL_SPEED = 15;
    const int SKIP_LINES = 5;
    int lineHeight = TTF_FontHeight(font);

    SDL_GameController* pad = nullptr;
    for(int i=0;i<SDL_NumJoysticks();i++){
        if(SDL_IsGameController(i)){
            pad = SDL_GameControllerOpen(i);
            if (pad) break;
        }
    }

    // Wrap and pre-render
    std::vector<std::string> wrapped;
    for(auto &line: lines){
        std::string clean = filter_invalid_chars(line, font);
        auto chunks = wrap_line(clean,font,WINDOW_W-20);
        wrapped.insert(wrapped.end(),chunks.begin(),chunks.end());
    }
    auto textures = create_textures(ren, font, wrapped, white);

    bool upPressed=false, downPressed=false, l1Pressed=false, r1Pressed=false;
    bool running=true;
    SDL_Event e;

    // Touch drag-only state
    bool touchActive = false;
    float lastTouchY = 0.0f;
    const float TOUCH_MULTIPLIER = 1.75f;

    // Help overlay
    bool showHelp = false;
    SDL_Color helpColor = {255,255,0,255};
    SDL_Color boxColor = {0,0,0,200};

    while(running){
        while(SDL_PollEvent(&e)){
            if(e.type==SDL_QUIT) { running=false; break; }

            // Controller input
            if(e.type==SDL_CONTROLLERBUTTONDOWN){
                switch(e.cbutton.button){
                    case SDL_CONTROLLER_BUTTON_DPAD_UP: upPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_DPAD_DOWN: downPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_LEFTSHOULDER: l1Pressed=true; break;
                    case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: r1Pressed=true; break;
                    case SDL_CONTROLLER_BUTTON_X:
                        fontSize += 2;
                        TTF_CloseFont(font);
                        font = loadFont(fontSize);
                        if (!font) { fontSize -= 2; font = loadFont(fontSize); }
                        wrapped.clear();
                        for(auto &line: lines){
                            std::string clean = filter_invalid_chars(line, font);
                            auto chunks = wrap_line(clean,font,WINDOW_W-20);
                            wrapped.insert(wrapped.end(),chunks.begin(),chunks.end());
                        }
                        for(auto &lt: textures) if (lt.tex) SDL_DestroyTexture(lt.tex);
                        textures = create_textures(ren, font, wrapped, white);
                        lineHeight = TTF_FontHeight(font);
                        break;
                    case SDL_CONTROLLER_BUTTON_Y:
                        fontSize -= 2;
                        if(fontSize<8) fontSize=8;
                        TTF_CloseFont(font);
                        font = loadFont(fontSize);
                        if (!font) { fontSize += 2; font = loadFont(fontSize); }
                        wrapped.clear();
                        for(auto &line: lines){
                            std::string clean = filter_invalid_chars(line, font);
                            auto chunks = wrap_line(clean,font,WINDOW_W-20);
                            wrapped.insert(wrapped.end(),chunks.begin(),chunks.end());
                        }
                        for(auto &lt: textures) if (lt.tex) SDL_DestroyTexture(lt.tex);
                        textures = create_textures(ren, font, wrapped, white);
                        lineHeight = TTF_FontHeight(font);
                        break;
                    case SDL_CONTROLLER_BUTTON_B:
                        running=false;
                        break;
                    case SDL_CONTROLLER_BUTTON_BACK: // SELECT button
                        showHelp = !showHelp;
                        break;
                }
            }
            if(e.type==SDL_CONTROLLERBUTTONUP){
                switch(e.cbutton.button){
                    case SDL_CONTROLLER_BUTTON_DPAD_UP: upPressed=false; break;
                    case SDL_CONTROLLER_BUTTON_DPAD_DOWN: downPressed=false; break;
                    case SDL_CONTROLLER_BUTTON_LEFTSHOULDER: l1Pressed=false; break;
                    case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: r1Pressed=false; break;
                }
            }

            // Touch events
            if(e.type == SDL_FINGERDOWN) {
                touchActive = true;
                lastTouchY = e.tfinger.y;
            }
            if(e.type == SDL_FINGERMOTION && touchActive) {
                float y = e.tfinger.y;
                float dy_norm = y - lastTouchY;
                lastTouchY = y;
                int deltaPixels = (int)(-dy_norm * WINDOW_H * TOUCH_MULTIPLIER);
                scroll_y += deltaPixels;
            }
            if(e.type == SDL_FINGERUP) touchActive = false;
        }

        // Controller continuous scrolling
        if(upPressed) scroll_y -= SCROLL_SPEED;
        if(downPressed) scroll_y += SCROLL_SPEED;
        if(l1Pressed) scroll_y -= SKIP_LINES*lineHeight;
        if(r1Pressed) scroll_y += SKIP_LINES*lineHeight;

        // Clamp
        int total_height = (int)textures.size()*lineHeight;
        if(total_height < WINDOW_H) total_height = WINDOW_H;
        if(scroll_y < 0) scroll_y=0;
        if(scroll_y > total_height-WINDOW_H) scroll_y = total_height-WINDOW_H;

        // Render
        SDL_SetRenderDrawColor(ren,0,0,0,255);
        SDL_RenderClear(ren);

        int firstLine = scroll_y/lineHeight;
        int offsetY = -(scroll_y%lineHeight);
        for(size_t i=firstLine; i<textures.size() && offsetY<WINDOW_H; i++){
            if (textures[i].tex) {
                SDL_Rect dst = {10, offsetY, textures[i].w, textures[i].h};
                SDL_RenderCopy(ren, textures[i].tex, nullptr, &dst);
            }
            offsetY += textures[i].h;
        }

        // Scroll bar
        int barWidth = 8;
        float scrollPercent = 0.0f;
        if (total_height > WINDOW_H) scrollPercent = (float)scroll_y / (float)(total_height - WINDOW_H);
        if(scrollPercent < 0) scrollPercent = 0;
        if(scrollPercent > 1) scrollPercent = 1;
        int barHeight = (int)((float)WINDOW_H * (float)WINDOW_H / (float)total_height);
        if(barHeight < 10) barHeight = 10;
        int barY = (int)(scrollPercent*(WINDOW_H - barHeight));
        SDL_Rect scrollbar = {WINDOW_W - barWidth - 2, barY, barWidth, barHeight};
        SDL_SetRenderDrawColor(ren, 200,200,200,255);
        SDL_RenderFillRect(ren, &scrollbar);

        // Help overlay
        if(showHelp) {
            int boxW = WINDOW_W / 2;
            int boxH = WINDOW_H / 2;
            int boxX = (WINDOW_W - boxW)/2;
            int boxY = (WINDOW_H - boxH)/2;

            SDL_Rect helpBox = {boxX, boxY, boxW, boxH};
            SDL_SetRenderDrawBlendMode(ren, SDL_BLENDMODE_BLEND);
            SDL_SetRenderDrawColor(ren, boxColor.r, boxColor.g, boxColor.b, boxColor.a);
            SDL_RenderFillRect(ren, &helpBox);

            std::vector<std::string> helpLines = {
                "CONTROLS:",
                "UP/DOWN DPAD   - Scroll",
                "L1/R1          - Skip lines",
                "X/Y            - Increase/Decrease font",
                "B              - Exit",
                "SELECT         - Toggle this help",
                "Touch Drag     - Scroll"
            };

            int ty = boxY + 20;
            for(auto &line : helpLines){
                SDL_Surface* surf = TTF_RenderUTF8_Blended(font, line.c_str(), helpColor);
                if(!surf) continue;
                SDL_Texture* tex = SDL_CreateTextureFromSurface(ren, surf);
                SDL_Rect dst = {boxX + 20, ty, surf->w, surf->h};
                SDL_RenderCopy(ren, tex, nullptr, &dst);
                ty += surf->h + 8;
                SDL_DestroyTexture(tex);
                SDL_FreeSurface(surf);
            }
        }

        SDL_RenderPresent(ren);
        SDL_Delay(16);
    }

    // Save config
    cfg[textFile] = {scroll_y, fontSize};
    save_config(cfg);

    for(auto &lt: textures) if (lt.tex) SDL_DestroyTexture(lt.tex);
    if(pad) SDL_GameControllerClose(pad);
    if(font) TTF_CloseFont(font);
    if(ren) SDL_DestroyRenderer(ren);
    if(win) SDL_DestroyWindow(win);
    TTF_Quit();
    SDL_Quit();
    return 0;
}
