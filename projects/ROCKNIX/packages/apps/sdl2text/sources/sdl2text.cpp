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
#include <cstdlib>
#include <cstring>
#include <csignal>
#include <cerrno>
#include <cstddef>
#include <ctime>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

// -------------------- Config Helpers --------------------
static std::filesystem::path get_home_dir() {
    const char* h = std::getenv("HOME");
    return std::filesystem::path(h ? h : "/storage");
}

static std::filesystem::path get_config_dir() {
    std::filesystem::path cfgDir = get_home_dir() / ".config" / "sdl2text";
    std::error_code ec;
    std::filesystem::create_directories(cfgDir, ec);
    return cfgDir;
}

std::filesystem::path get_config_file() {
    return get_config_dir() / "sdl2text.conf";
}

// -------------------- Single instance --------------------
// An abstract-namespace UNIX socket. The name lives in a kernel namespace, not
// on any filesystem: nothing to orphan, no pid to recycle, no $HOME to
// disagree about, no permissions to get wrong. The kernel frees the name the
// moment this process dies -- normal exit, SIGKILL, battery pull, all of it --
// so it can never go stale. bind() is atomic, so two launches racing in the
// same millisecond cannot both win.
static const char* LOCK_NAME = "sdl2text-single-instance";
static int g_lockSock = -1;   // held open for the life of the process

// How long to keep holding the name after the window is gone. A hotkey press
// delivered in the instant the guide closes would otherwise relaunch it; this
// makes that press lose the race and get dropped.
static const long EXIT_GRACE_NS = 1200L * 1000000L;   // 1.2s

enum LockResult { LOCK_ACQUIRED, LOCK_BUSY, LOCK_UNAVAILABLE };

static LockResult acquire_single_instance() {
    int fd = socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    if(fd < 0) return LOCK_UNAVAILABLE;

    struct sockaddr_un addr;
    std::memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    addr.sun_path[0] = '\0';                      // leading NUL = abstract namespace
    std::strncpy(addr.sun_path + 1, LOCK_NAME, sizeof(addr.sun_path) - 2);
    socklen_t len = offsetof(struct sockaddr_un, sun_path) + 1 + std::strlen(LOCK_NAME);

    if(bind(fd, (struct sockaddr*)&addr, len) < 0) {
        int err = errno;
        close(fd);
        return (err == EADDRINUSE) ? LOCK_BUSY : LOCK_UNAVAILABLE;
    }
    g_lockSock = fd;
    return LOCK_ACQUIRED;
}

// -------------------- Graceful shutdown --------------------
// Set by SIGTERM/SIGINT so the main loop can exit cleanly and still save the
// scroll position, instead of being torn down mid-frame.
static volatile sig_atomic_t g_quitSignal = 0;
static void handle_signal(int) { g_quitSignal = 1; }

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
            if(font < 8) font = 8;
            if(font > 200) font = 200;
            if(scroll < 0) scroll = 0;
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
    while (std::getline(file, line)) {
        // Strip trailing CR so CRLF files don't turn every blank line into junk
        if(!line.empty() && line.back() == '\r') line.pop_back();
        lines.push_back(line);
    }
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
        if (c < 0x80) {
            // Expand tabs so indented guides don't collapse
            if (c == '\t') { out.append("    "); ++i; continue; }
            if (font_can_render_codepoint(font, c)) out.push_back(static_cast<char>(c));
            ++i; continue;
        }
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
// Binary-search the widest chunk that fits, then back off to a UTF-8 boundary
// and, where possible, to a word boundary.
std::vector<std::string> wrap_line(const std::string& line, TTF_Font* font, int maxWidth) {
    std::vector<std::string> result;
    size_t start=0,len=line.length();
    if(len==0) { result.push_back(""); return result; }
    while(start<len) {
        size_t lo=1,hi=len-start,best=1;
        while(lo<=hi) {
            size_t mid=(lo+hi)/2;
            std::string chunk=line.substr(start,mid);
            int w=0,h=0; TTF_SizeUTF8(font, chunk.c_str(), &w,&h);
            if(w>maxWidth) hi=mid-1;
            else { best=mid; lo=mid+1; }
        }

        // Never cut in the middle of a multi-byte UTF-8 sequence
        while(best>1 && start+best<len &&
              (static_cast<unsigned char>(line[start+best]) & 0xC0) == 0x80)
            --best;

        // Prefer breaking at whitespace if we're mid-word
        if(start+best<len && line[start+best]!=' ') {
            size_t sp = line.rfind(' ', start+best-1);
            if(sp != std::string::npos && sp > start) best = sp - start + 1;
        }

        if(best==0) best=1;
        result.push_back(line.substr(start,best));
        start+=best;
    }
    return result;
}

// -------------------- Main --------------------
int main(int argc,char* argv[]) {
    std::string fileArg;

    for(int i=1;i<argc;i++) {
        std::string a=argv[i];
        if(a=="--help" || a=="-h") {
            std::cout << "Usage: " << argv[0] << " <textfile>\n";
            return 0;
        }
        else if(fileArg.empty()) fileArg=a;
    }

    if(fileArg.empty()) { std::cout << "Usage: " << argv[0] << " <textfile>\n"; return 1; }

    // -------- Refuse to be a second instance --------
    LockResult lock = acquire_single_instance();
    if(lock == LOCK_BUSY) return 0;   // the guide is already on screen, nothing to do
    if(lock == LOCK_UNAVAILABLE)
        std::cerr << "sdl2text: single-instance check unavailable, continuing\n";

    // Exit cleanly on SIGTERM/SIGINT so the scroll position still gets saved.
    struct sigaction sa;
    std::memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_signal;
    sigaction(SIGTERM, &sa, nullptr);
    sigaction(SIGINT,  &sa, nullptr);
    sigaction(SIGHUP,  &sa, nullptr);

    std::filesystem::path textFilePath=std::filesystem::absolute(fileArg);
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
    if(!ren) {
        std::cerr<<"Accelerated renderer failed ("<<SDL_GetError()<<"), trying software\n";
        ren=SDL_CreateRenderer(win,-1,SDL_RENDERER_SOFTWARE);
    }
    if(!ren) { std::cerr<<"SDL_CreateRenderer error: "<<SDL_GetError()<<"\n"; SDL_DestroyWindow(win); TTF_CloseFont(font); TTF_Quit(); SDL_Quit(); return 1; }

    int WINDOW_W=0,WINDOW_H=0; SDL_GetWindowSize(win,&WINDOW_W,&WINDOW_H);
    // A zero/garbage window size would make the wrap width negative, which wraps
    // every single character onto its own line and explodes the line count.
    if(WINDOW_W<200) WINDOW_W=640;
    if(WINDOW_H<200) WINDOW_H=480;
    const int WRAP_W = (WINDOW_W-20 < 50) ? 50 : WINDOW_W-20;
    SDL_Color white={255,255,255,255};
    int scroll_y=fcfg.scroll;
    const int SCROLL_SPEED=15,SKIP_LINES=5;
    int lineHeight=TTF_FontHeight(font);
    if(lineHeight<1) lineHeight=1;

    SDL_GameController* pad=nullptr;
    for(int i=0;i<SDL_NumJoysticks();i++) { if(SDL_IsGameController(i)) { pad=SDL_GameControllerOpen(i); if(pad) break; } }

    // -------------------- Wrapped text (strings only, no textures) --------------------
    std::vector<std::string> wrapped;

    auto rewrap=[&]() {
        wrapped.clear();
        wrapped.reserve(lines.size()*2);
        for(auto &line:lines) {
            if(line.empty()) { wrapped.push_back(""); continue; }
            std::string clean=filter_invalid_chars(line,font);
            if(clean.empty()) { wrapped.push_back(""); continue; }
            auto chunks=wrap_line(clean,font,WRAP_W);
            if(chunks.empty()) wrapped.push_back("");
            else wrapped.insert(wrapped.end(),chunks.begin(),chunks.end());
        }
        if(wrapped.empty()) wrapped.push_back("");
    };
    rewrap();

    // -------------------- Lazy texture cache --------------------
    // Only lines currently on screen (plus a small margin) ever become textures.
    // This is the difference between ~25 live textures and ~50,000 of them.
    struct LineTexture { SDL_Texture* tex=nullptr; int w=0,h=0; };
    std::map<int, LineTexture> texCache;

    auto clearCache=[&]() {
        for(auto &kv:texCache) if(kv.second.tex) SDL_DestroyTexture(kv.second.tex);
        texCache.clear();
    };

    auto getLine=[&](int idx)->const LineTexture& {
        auto it=texCache.find(idx);
        if(it!=texCache.end()) return it->second;

        LineTexture lt;
        lt.h=lineHeight;
        const std::string& s=wrapped[idx];
        if(!s.empty()) {
            SDL_Surface* surf=TTF_RenderUTF8_Blended(font,s.c_str(),white);
            if(surf) {
                lt.tex=SDL_CreateTextureFromSurface(ren,surf);
                lt.w=surf->w;
                lt.h=surf->h;
                SDL_FreeSurface(surf);
            }
        }
        return texCache.emplace(idx,lt).first->second;
    };

    auto changeFontSize=[&](int delta) {
        int newSize=fontSize+delta;
        if(newSize<8) newSize=8;
        if(newSize>200) newSize=200;
        TTF_Font* nf=loadFont(newSize);
        if(!nf) return;

        // Keep the reader roughly where they were
        double frac = 0.0;
        int oldTotal = (int)wrapped.size()*lineHeight;
        if(oldTotal>0) frac = (double)scroll_y/(double)oldTotal;

        clearCache();
        TTF_CloseFont(font);
        font=nf;
        fontSize=newSize;
        lineHeight=TTF_FontHeight(font);
        if(lineHeight<1) lineHeight=1;
        rewrap();
        scroll_y=(int)(frac*(double)wrapped.size()*lineHeight);
        if(scroll_y<0) scroll_y=0;
    };

    bool upPressed=false,downPressed=false,l1Pressed=false,r1Pressed=false,startPressed=false;
    int16_t axisLeftY=0, axisRightY=0;
    const int16_t AXIS_DEADZONE=8000;
    const float AXIS_SCROLL_SCALE=0.002f;

    bool running=true,showHelp=false;
    SDL_Event e;
    bool touchActive=false;
    float lastTouchY=0.0f;
    const float TOUCH_MULTIPLIER=1.75f;
    SDL_Color helpColor={255,255,255,255}, boxColor={0,0,0,200};

    while(running) {
        if(g_quitSignal) { running=false; break; }

        while(SDL_PollEvent(&e)) {
            if(e.type==SDL_QUIT) { running=false; break; }

            if(e.type==SDL_CONTROLLERDEVICEADDED && !pad) {
                if(SDL_IsGameController(e.cdevice.which)) pad=SDL_GameControllerOpen(e.cdevice.which);
            }
            if(e.type==SDL_CONTROLLERDEVICEREMOVED && pad) {
                SDL_GameControllerClose(pad); pad=nullptr;
                upPressed=downPressed=l1Pressed=r1Pressed=startPressed=false;
                axisLeftY=axisRightY=0;
            }

            if(e.type==SDL_CONTROLLERAXISMOTION) {
                if(e.caxis.axis==SDL_CONTROLLER_AXIS_LEFTY)  axisLeftY  = e.caxis.value;
                if(e.caxis.axis==SDL_CONTROLLER_AXIS_RIGHTY) axisRightY = e.caxis.value;
            }

            if(e.type==SDL_CONTROLLERBUTTONDOWN) {
                switch(e.cbutton.button) {
                    case SDL_CONTROLLER_BUTTON_DPAD_UP: upPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_DPAD_DOWN: downPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_LEFTSHOULDER: l1Pressed=true; break;
                    case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: r1Pressed=true; break;
                    case SDL_CONTROLLER_BUTTON_START: startPressed=true; break;
                    case SDL_CONTROLLER_BUTTON_DPAD_RIGHT: changeFontSize(+2); break;
                    case SDL_CONTROLLER_BUTTON_DPAD_LEFT:  changeFontSize(-2); break;
                    case SDL_CONTROLLER_BUTTON_A: running=false; break;
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

        // D-pad continuous scrolling
        if(upPressed) scroll_y-=SCROLL_SPEED;
        if(downPressed) scroll_y+=SCROLL_SPEED;
        if(l1Pressed) scroll_y-=SKIP_LINES*lineHeight;
        if(r1Pressed) scroll_y+=SKIP_LINES*lineHeight;

        auto applyAxis = [&](int16_t raw) {
            if(raw > AXIS_DEADZONE)
                scroll_y += (int)((raw - AXIS_DEADZONE) * AXIS_SCROLL_SCALE);
            else if(raw < -AXIS_DEADZONE)
                scroll_y += (int)((raw + AXIS_DEADZONE) * AXIS_SCROLL_SCALE);
        };
        applyAxis(axisLeftY);
        applyAxis(axisRightY);

        // Secret kill combo: L1 + START + SELECT  (pad may be null)
        if(pad && l1Pressed && startPressed && SDL_GameControllerGetButton(pad, SDL_CONTROLLER_BUTTON_BACK)) running=false;

        // Clamp -- O(1) now that every line is the same height
        int totalLines=(int)wrapped.size();
        int total_height=totalLines*lineHeight;
        int maxScroll=total_height-WINDOW_H;
        if(maxScroll<0) maxScroll=0;
        if(scroll_y<0) scroll_y=0;
        if(scroll_y>maxScroll) scroll_y=maxScroll;

        // Render
        SDL_SetRenderDrawColor(ren,0,0,0,255); SDL_RenderClear(ren);

        int firstLine=scroll_y/lineHeight;
        int offsetY=-(scroll_y%lineHeight);
        int lastLine=firstLine;

        for(int i=firstLine;i<totalLines && offsetY<WINDOW_H;++i) {
            const LineTexture& lt=getLine(i);
            if(lt.tex) {
                SDL_Rect dst={10,offsetY,lt.w,lt.h};
                SDL_RenderCopy(ren,lt.tex,nullptr,&dst);
            }
            lastLine=i;
            offsetY+=lineHeight;
        }

        // Evict anything well off-screen so the cache stays tiny
        if(texCache.size()>256) {
            for(auto it=texCache.begin();it!=texCache.end();) {
                if(it->first < firstLine-64 || it->first > lastLine+64) {
                    if(it->second.tex) SDL_DestroyTexture(it->second.tex);
                    it=texCache.erase(it);
                } else ++it;
            }
        }

        // Help overlay
        if(showHelp) {
            std::vector<std::string> helpLines={
                "CONTROLS:",
                "SELECT          - Toggle Help Screen",
                "STICK UP/DOWN   - Scroll Up / Down",
                "DPAD UP/DOWN    - Scroll Up / Down",
                "L1/R1           - Skip Up / Down",
                "DPAD LEFT/RIGHT - + / - Text Size",
                "TOUCHSCREEN     - Scroll Up / Down",
                "A / B           - Exit"
            };

            int helpLineHeight=TTF_FontLineSkip(font);
            int boxH=40+((int)helpLines.size()*(helpLineHeight+8));
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
                        if(tex1) SDL_RenderCopy(ren,tex1,nullptr,&dst1);
                        int h1=surf1->h;
                        if(tex1) SDL_DestroyTexture(tex1);
                        SDL_FreeSurface(surf1);

                        SDL_Surface* surf2=TTF_RenderUTF8_Blended(font,rightPart.c_str(),helpColor);
                        if(surf2) {
                            SDL_Texture* tex2=SDL_CreateTextureFromSurface(ren,surf2);
                            SDL_Rect dst2={boxX+20+columnSplit,ty,surf2->w,surf2->h};
                            if(tex2) SDL_RenderCopy(ren,tex2,nullptr,&dst2);
                            if(tex2) SDL_DestroyTexture(tex2);
                            SDL_FreeSurface(surf2);
                        }
                        ty+=h1+8;
                    }
                } else {
                    SDL_Surface* surf=TTF_RenderUTF8_Blended(font,line.c_str(),helpColor);
                    if(surf) {
                        SDL_Texture* tex=SDL_CreateTextureFromSurface(ren,surf);
                        SDL_Rect dst={boxX+20,ty,surf->w,surf->h};
                        if(tex) SDL_RenderCopy(ren,tex,nullptr,&dst);
                        ty+=surf->h+8;
                        if(tex) SDL_DestroyTexture(tex);
                        SDL_FreeSurface(surf);
                    }
                }
            }
        }

        // ---- Line Counter (bottom-right) ----
        {
            int currentLine=firstLine+1;
            if(currentLine<1) currentLine=1;
            if(currentLine>totalLines) currentLine=totalLines;

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

    clearCache();
    if(pad) SDL_GameControllerClose(pad);
    if(font) TTF_CloseFont(font);
    if(ren) SDL_DestroyRenderer(ren);
    if(win) SDL_DestroyWindow(win);
    TTF_Quit();
    SDL_Quit();

    // Screen is clear; keep the name a moment longer to swallow a press that
    // landed as the guide was closing.
    struct timespec grace = {0, EXIT_GRACE_NS};
    nanosleep(&grace, nullptr);
    return 0;
}
