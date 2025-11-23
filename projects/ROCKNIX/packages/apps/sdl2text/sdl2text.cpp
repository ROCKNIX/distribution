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
    while(std::getline(f,line)) {
        size_t sep = line.find('=');
        if(sep != std::string::npos) {
            std::string key = line.substr(0,sep);
            std::string val = line.substr(sep+1);
            size_t comma = val.find(',');
            int scroll = 0;
            int font = 40;
            if(comma != std::string::npos) {
                try {
                    scroll = std::stoi(val.substr(0,comma));
                    font = std::stoi(val.substr(comma+1));
                } catch(...) { }
            }
            cfg[key] = {scroll,font};
        }
    }
    return cfg;
}

void save_config(const std::map<std::string, FileConfig>& cfg) {
    std::ofstream f(get_config_file());
    if(!f.is_open()) return;
    for(const auto& [k,v]: cfg) {
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

// -------------------- UTF-8 safe filtering --------------------
static bool font_can_render_codepoint(TTF_Font* font, uint32_t cp) {
    if (cp <= 0xFFFF) return TTF_GlyphIsProvided(font, static_cast<Uint16>(cp)) != 0;
    return false;
}

std::string filter_invalid_chars(const std::string& s, TTF_Font* font) {
    std::string out;
    size_t i = 0;
    while (i < s.size()) {
        unsigned char c = static_cast<unsigned char>(s[i]);
        if (c < 0x80) { if (font_can_render_codepoint(font, c)) out.push_back(static_cast<char>(c)); ++i; continue; }
        uint32_t cp = 0; size_t seqLen = 0;

        if ((c & 0xE0) == 0xC0) { if (i+1 >= s.size()) { ++i; continue; } unsigned char c1 = s[i+1]; if ((c1 & 0xC0) != 0x80) { ++i; continue; } cp = ((c & 0x1F)<<6)|(c1&0x3F); seqLen=2; if(cp<0x80){i+=2;continue;} }
        else if ((c & 0xF0) == 0xE0) { if(i+2>=s.size()){++i;continue;} unsigned char c1=s[i+1],c2=s[i+2]; if((c1&0xC0)!=0x80||(c2&0xC0)!=0x80){++i;continue;} cp=((c&0x0F)<<12)|((c1&0x3F)<<6)|(c2&0x3F); seqLen=3; }
        else if ((c & 0xF8) == 0xF0) { if(i+3>=s.size()){++i;continue;} unsigned char c1=s[i+1],c2=s[i+2],c3=s[i+3]; if((c1&0xC0)!=0x80||(c2&0xC0)!=0x80||(c3&0xC0)!=0x80){++i;continue;} cp=((c&0x07)<<18)|((c1&0x3F)<<12)|((c2&0x3F)<<6)|(c3&0x3F); seqLen=4; }
        else { ++i; continue; }

        if(seqLen==0){++i;continue;}
        if(font_can_render_codepoint(font,cp)) out.append(s.substr(i,seqLen));
        i+=seqLen;
    }
    return out;
}

// -------------------- Line wrapping --------------------
std::vector<std::string> wrap_line(const std::string& line, TTF_Font* font, int maxWidth) {
    std::vector<std::string> result;
    size_t start=0,len=line.length();
    while(start<len) {
        size_t lo=1,hi=len-start,best=1;
        while(lo<=hi) {
            size_t mid=(lo+hi)/2;
            std::string chunk=line.substr(start,mid);
            int w=0,h=0; TTF_SizeUTF8(font, chunk.c_str(), &w,&h);
            if(w>maxWidth) hi=mid-1;
            else { best=mid; lo=mid+1; }
        }
        std::string chunk=line.substr(start,best);
        if(chunk.empty()) chunk=line.substr(start,1);
        result.push_back(chunk);
        start+=chunk.length();
    }
    return result;
}

// -------------------- Pre-render textures --------------------
struct LineTexture { SDL_Texture* tex; int w,h; };

std::vector<LineTexture> create_textures(SDL_Renderer* ren, TTF_Font* font, const std::vector<std::string>& wrapped, SDL_Color color) {
    std::vector<LineTexture> textures;
    for(auto &line:wrapped) {
        SDL_Surface* surf=TTF_RenderUTF8_Blended(font,line.c_str(),color);
        if(!surf) continue;
        SDL_Texture* tex=SDL_CreateTextureFromSurface(ren,surf);
        textures.push_back({tex,surf->w,surf->h});
        SDL_FreeSurface(surf);
    }
    return textures;
}

// -------------------- Main --------------------
int main(int argc,char* argv[]) {
    if(argc<2) { std::cout << "Usage: " << argv[0] << " <textfile>\n"; return 1; }
    {
        std::filesystem::path cfgDir =
            std::filesystem::path(std::getenv("HOME")) / ".config" / "sdl2text";
        std::filesystem::create_directories(cfgDir);
    }

    std::filesystem::path textFilePath=std::filesystem::absolute(argv[1]);
    std::string textFile=textFilePath.string();
    auto lines=load_file_lines(textFile);
    if(lines.empty()) { std::cout << "Failed to load file\n"; return 1; }

    if(SDL_Init(SDL_INIT_VIDEO|SDL_INIT_GAMECONTROLLER)!=0) { std::cerr << "SDL_Init error\n"; return 1; }
    if(TTF_Init()!=0) { std::cerr << "TTF_Init error\n"; SDL_Quit(); return 1; }

    std::string fontPath=find_any_ttf_font();
    if(fontPath.empty()) { std::cout<<"No TTF font found\n"; TTF_Quit(); SDL_Quit(); return 1; }

    auto cfg=load_config();
    FileConfig fcfg=cfg[textFile];
    int fontSize=fcfg.fontSize;
    auto loadFont=[&](int size)->TTF_Font* { TTF_Font* f=TTF_OpenFont(fontPath.c_str(),size); if(!f) std::cout<<"Failed to load font size "<<size<<"\n"; return f; };
    TTF_Font* font=loadFont(fontSize);
    if(!font) { TTF_Quit(); SDL_Quit(); return 1; }

    SDL_Window* win=SDL_CreateWindow("Text Viewer",SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,0,0,SDL_WINDOW_FULLSCREEN_DESKTOP|SDL_WINDOW_BORDERLESS);
    if(!win) { std::cerr<<"SDL_CreateWindow error\n"; TTF_CloseFont(font); TTF_Quit(); SDL_Quit(); return 1; }
    SDL_Renderer* ren=SDL_CreateRenderer(win,-1,SDL_RENDERER_ACCELERATED);
    if(!ren) { SDL_DestroyWindow(win); TTF_CloseFont(font); TTF_Quit(); SDL_Quit(); return 1; }

    int WINDOW_W=0,WINDOW_H=0; SDL_GetWindowSize(win,&WINDOW_W,&WINDOW_H);
    SDL_Color white={255,255,255,255};
    int scroll_y=fcfg.scroll;
    const int SCROLL_SPEED=15,SKIP_LINES=5;
    int lineHeight=TTF_FontHeight(font);

    SDL_GameController* pad=nullptr;
    for(int i=0;i<SDL_NumJoysticks();i++) { if(SDL_IsGameController(i)) { pad=SDL_GameControllerOpen(i); if(pad) break; } }

    std::vector<std::string> wrapped;
    for(auto &line:lines) {
        std::string clean=filter_invalid_chars(line,font);
        auto chunks=wrap_line(clean,font,WINDOW_W-20);
        wrapped.insert(wrapped.end(),chunks.begin(),chunks.end());
    }
    auto textures=create_textures(ren,font,wrapped,white);

    bool upPressed=false,downPressed=false,l1Pressed=false,r1Pressed=false,startPressed=false;
    bool running=true,showHelp=false;
    SDL_Event e;
    bool touchActive=false;
    float lastTouchY=0.0f;
    const float TOUCH_MULTIPLIER=1.75f;
    SDL_Color helpColor={255,255,255,255}, boxColor={0,0,0,200};

    while(running) {
        while(SDL_PollEvent(&e)) {
            if(e.type==SDL_QUIT) { running=false; break; }

            if(e.type==SDL_CONTROLLERBUTTONDOWN) {
                switch(e.cbutton.button) {
                    case SDL_CONTROLLER_BUTTON_DPAD_UP: upPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_DPAD_DOWN: downPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_LEFTSHOULDER: l1Pressed=true; break;
                    case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: r1Pressed=true; break;
                    case SDL_CONTROLLER_BUTTON_START: startPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
                        fontSize+=2; TTF_CloseFont(font); font=loadFont(fontSize); if(!font){fontSize-=2; font=loadFont(fontSize);}
                        wrapped.clear();
                        for(auto &line:lines) { std::string clean=filter_invalid_chars(line,font); auto chunks=wrap_line(clean,font,WINDOW_W-20); wrapped.insert(wrapped.end(),chunks.begin(),chunks.end()); }
                        for(auto &lt:textures) if(lt.tex) SDL_DestroyTexture(lt.tex);
                        textures=create_textures(ren,font,wrapped,white); lineHeight=TTF_FontHeight(font); break;
                    case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
                        fontSize-=2; if(fontSize<8) fontSize=8; TTF_CloseFont(font); font=loadFont(fontSize); if(!font){fontSize+=2; font=loadFont(fontSize);}
                        wrapped.clear();
                        for(auto &line:lines) { std::string clean=filter_invalid_chars(line,font); auto chunks=wrap_line(clean,font,WINDOW_W-20); wrapped.insert(wrapped.end(),chunks.begin(),chunks.end()); }
                        for(auto &lt:textures) if(lt.tex) SDL_DestroyTexture(lt.tex);
                        textures=create_textures(ren,font,wrapped,white); lineHeight=TTF_FontHeight(font); break;
                    case SDL_CONTROLLER_BUTTON_B: running=false; break;
                    case SDL_CONTROLLER_BUTTON_BACK: showHelp=!showHelp; break;
                }
            }

            if(e.type==SDL_CONTROLLERBUTTONUP) {
                switch(e.cbutton.button) {
                    case SDL_CONTROLLER_BUTTON_DPAD_UP: upPressed=false; break;
                    case SDL_CONTROLLER_BUTTON_DPAD_DOWN: downPressed=false; break;
                    case SDL_CONTROLLER_BUTTON_LEFTSHOULDER: l1Pressed=false; break;
                    case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: r1Pressed=false; break;
                    case SDL_CONTROLLER_BUTTON_START: startPressed=false; break;
                }
            }

            if(e.type==SDL_FINGERDOWN) { touchActive=true; lastTouchY=e.tfinger.y; }
            if(e.type==SDL_FINGERMOTION && touchActive) { float y=e.tfinger.y; float dy_norm=y-lastTouchY; lastTouchY=y; scroll_y+=(int)(-dy_norm*WINDOW_H*TOUCH_MULTIPLIER); }
            if(e.type==SDL_FINGERUP) touchActive=false;
        }

        // Controller continuous scrolling
        if(upPressed) scroll_y-=SCROLL_SPEED;
        if(downPressed) scroll_y+=SCROLL_SPEED;
        if(l1Pressed) scroll_y-=SKIP_LINES*lineHeight;
        if(r1Pressed) scroll_y+=SKIP_LINES*lineHeight;

        // Secret kill combo: L1 + START + SELECT
        if(l1Pressed && startPressed && SDL_GameControllerGetButton(pad, SDL_CONTROLLER_BUTTON_BACK)) running=false;

        // Clamp
        int total_height=(int)textures.size()*lineHeight;
        if(total_height<WINDOW_H) total_height=WINDOW_H;
        if(scroll_y<0) scroll_y=0;
        if(scroll_y>total_height-WINDOW_H) scroll_y=total_height-WINDOW_H;

        // Render
        SDL_SetRenderDrawColor(ren,0,0,0,255); SDL_RenderClear(ren);
        int firstLine=scroll_y/lineHeight, offsetY=-(scroll_y%lineHeight);
        for(size_t i=firstLine;i<textures.size() && offsetY<WINDOW_H;i++) {
            if(textures[i].tex) { SDL_Rect dst={10,offsetY,textures[i].w,textures[i].h}; SDL_RenderCopy(ren,textures[i].tex,nullptr,&dst); }
            offsetY+=textures[i].h;
        }

        // Help overlay
        if(showHelp) {
            std::vector<std::string> helpLines={
                "CONTROLS:",
                "SELECT          - Toggle This Help",
                "DPAD UP/DOWN    - Scroll Up / Down",
                "L1/R1           - Skip Up / Down",
                "DPAD LEFT/RIGHT - Dec / Inc Font Size",
                "Touch Drag      - Scroll Up / Down",
                "B               - Exit"
            };

            // Calculate box height based on content
            int lineHeight=TTF_FontLineSkip(font); // Get typical line height
            int boxH=40+(helpLines.size()*(lineHeight+8)); // Top margin + all lines with spacing
            int boxW=WINDOW_W/2;
            int boxX=(WINDOW_W-boxW)/2, boxY=(WINDOW_H-boxH)/2;

            SDL_Rect helpBox={boxX,boxY,boxW,boxH};
            SDL_SetRenderDrawBlendMode(ren, SDL_BLENDMODE_BLEND);
            SDL_SetRenderDrawColor(ren, boxColor.r, boxColor.g, boxColor.b, boxColor.a);
            SDL_RenderFillRect(ren,&helpBox);

            int ty=boxY+20;
            int columnSplit=375;

            for(auto &line:helpLines) {
                size_t dashPos=line.find(" - ");
                if(dashPos!=std::string::npos) {
                    std::string leftPart=line.substr(0,dashPos);
                    std::string rightPart=line.substr(dashPos);

                    SDL_Surface* surf1=TTF_RenderUTF8_Blended(font,leftPart.c_str(),helpColor);
                    if(surf1) {
                        SDL_Texture* tex1=SDL_CreateTextureFromSurface(ren,surf1);
                        SDL_Rect dst1={boxX+20,ty,surf1->w,surf1->h};
                        SDL_RenderCopy(ren,tex1,nullptr,&dst1);
                        int lineHeight=surf1->h;
                        SDL_DestroyTexture(tex1);
                        SDL_FreeSurface(surf1);

                        SDL_Surface* surf2=TTF_RenderUTF8_Blended(font,rightPart.c_str(),helpColor);
                        if(surf2) {
                            SDL_Texture* tex2=SDL_CreateTextureFromSurface(ren,surf2);
                            SDL_Rect dst2={boxX+20+columnSplit,ty,surf2->w,surf2->h};
                            SDL_RenderCopy(ren,tex2,nullptr,&dst2);
                            SDL_DestroyTexture(tex2);
                            SDL_FreeSurface(surf2);
                        }
                        ty+=lineHeight+8;
                    }
                } else {
                    SDL_Surface* surf=TTF_RenderUTF8_Blended(font,line.c_str(),helpColor);
                    if(surf) {
                        SDL_Texture* tex=SDL_CreateTextureFromSurface(ren,surf);
                        SDL_Rect dst={boxX+20,ty,surf->w,surf->h};
                        SDL_RenderCopy(ren,tex,nullptr,&dst);
                        ty+=surf->h+8;
                        SDL_DestroyTexture(tex);
                        SDL_FreeSurface(surf);
                    }
                }
            }
        }

        // ---- Line Counter (bottom-right) ----
        {
            int currentLine = scroll_y / lineHeight + 1;
            int totalLines  = (int)textures.size();

            if (currentLine < 1) currentLine = 1;
            if (currentLine > totalLines) currentLine = totalLines;

            std::string lcText = std::to_string(currentLine) + "/" + std::to_string(totalLines);

            SDL_Color lcColor = {255,255,255,255};

            SDL_Surface* lcSurf = TTF_RenderUTF8_Blended(font, lcText.c_str(), lcColor);
            if (lcSurf) {
                SDL_Texture* lcTex = SDL_CreateTextureFromSurface(ren, lcSurf);
                if (lcTex) {
                    SDL_Rect textRect;
                    textRect.w = lcSurf->w;
                    textRect.h = lcSurf->h;
                    textRect.x = WINDOW_W - textRect.w - 15;
                    textRect.y = WINDOW_H - textRect.h - 10;

                    // transparent background box
                    SDL_Rect bgRect;
                    bgRect.x = textRect.x - 8;
                    bgRect.y = textRect.y - 4;
                    bgRect.w = textRect.w + 16;
                    bgRect.h = textRect.h + 8;

                    SDL_SetRenderDrawBlendMode(ren, SDL_BLENDMODE_BLEND);
                    SDL_SetRenderDrawColor(ren, 0, 0, 0, 200);
                    SDL_RenderFillRect(ren, &bgRect);

                    SDL_RenderCopy(ren, lcTex, nullptr, &textRect);

                    SDL_DestroyTexture(lcTex);
                }
                SDL_FreeSurface(lcSurf);
            }
        }

        SDL_RenderPresent(ren);
        SDL_Delay(16);
    }

    // Save config
    cfg[textFile]={scroll_y,fontSize};
    save_config(cfg);

    for(auto &lt:textures) if(lt.tex) SDL_DestroyTexture(lt.tex);
    if(pad) SDL_GameControllerClose(pad);
    if(font) TTF_CloseFont(font);
    if(ren) SDL_DestroyRenderer(ren);
    if(win) SDL_DestroyWindow(win);
    TTF_Quit();
    SDL_Quit();
    return 0;
}
