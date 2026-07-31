// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <errno.h>
#include <getopt.h>
#include <linux/input.h>
#include <sys/epoll.h>
#include <sys/inotify.h>
#include <sys/timerfd.h>

#define MAX_CMD_LEN 256
#define MAX_EVENTS 64
#define INOTIFY_BUF_LEN (1024 * (sizeof(struct inotify_event) + 16))

bool debug_mode = false;
#define DEBUG_PRINT(...) do { if (debug_mode) { printf("[DEBUG] " __VA_ARGS__); fflush(stdout); } } while (0)

int epoll_fd;
int vol_timer_fd = -1;

struct {
    int key_vol_up, key_vol_down;
    int fn_a, fn_b, hk_a, hk_b, hk_c;
    char fn_a_up[MAX_CMD_LEN], fn_a_down[MAX_CMD_LEN];
    char fn_b_up[MAX_CMD_LEN], fn_b_down[MAX_CMD_LEN];
    char fn_ab_up[MAX_CMD_LEN], fn_ab_down[MAX_CMD_LEN];
    bool touch_events, dpad_events;
} cfg;

struct {
    bool fn_a, fn_b, hk_a, hk_b, hk_c, vol_up, vol_down;
} state = {0};

void run_cmd(const char *cmd) {
    if (cmd && cmd[0]) {
        DEBUG_PRINT("Executing: %s\n", cmd);
        system(cmd);
    }
}

bool find_in_conf(const char *search_key, char *out) {
    FILE *fp = fopen("/storage/.config/system/configs/system.cfg", "r");
    if (!fp) return false;

    char line[512];
    size_t len = strlen(search_key);
    bool found = false;

    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, search_key, len) == 0 && line[len] == '=') {
            char *val = line + len + 1;
            val[strcspn(val, "\r\n")] = '\0';
            strncpy(out, val, MAX_CMD_LEN - 1);
            found = true;
            break;
        }
    }
    fclose(fp);
    return found;
}

bool get_setting(const char *key, const char *fallback, char *out) {
    char search[512];
    out[0] = '\0';

    snprintf(search, sizeof(search), "system.%s", key);
    if (find_in_conf(search, out)) goto found;

    snprintf(search, sizeof(search), "%s", key);
    if (find_in_conf(search, out)) goto found;

    snprintf(search, sizeof(search), "global.%s", key);
    if (find_in_conf(search, out)) goto found;

    if (fallback) {
        strncpy(out, fallback, MAX_CMD_LEN - 1);
    }

    DEBUG_PRINT("Warning: Setting '%s' not found, using fallback '%s'\n", key, fallback ? fallback : "(null)");
    return false;

found:
    DEBUG_PRINT("Found setting '%s' = '%s'\n", key, out);
    return true;
}

int parse_keycode(char *str) {
    char clean[64] = {0};
    int j = 0;
    for (int i = 0; str[i]; i++) {
        if (isalnum(str[i]) || str[i] == '_') clean[j++] = toupper(str[i]);
    }

    if (strstr(clean, "VOLUMEUP") || strstr(clean, "VOLUME_UP")) return KEY_VOLUMEUP;
    if (strstr(clean, "VOLUMEDOWN") || strstr(clean, "VOLUME_DOWN")) return KEY_VOLUMEDOWN;
    if (strstr(clean, "POWER")) return KEY_POWER;
    if (strstr(clean, "BTN_TL")) return BTN_TL;
    if (strstr(clean, "BTN_TR")) return BTN_TR;
    if (strstr(clean, "BTN_SELECT")) return BTN_SELECT;
    if (strstr(clean, "BTN_START")) return BTN_START;
    if (strstr(clean, "BTN_NORTH")) return BTN_NORTH;
    if (strstr(clean, "BTN_SOUTH")) return BTN_SOUTH;
    if (strstr(clean, "BTN_EAST")) return BTN_EAST;
    if (strstr(clean, "BTN_WEST")) return BTN_WEST;
    return -1;
}

void load_config() {
    char buf[MAX_CMD_LEN] = {0};

    get_setting("key.volume.up", "KEY_VOLUMEUP", buf); cfg.key_vol_up = parse_keycode(buf);
    get_setting("key.volume.down", "KEY_VOLUMEDOWN", buf); cfg.key_vol_down = parse_keycode(buf);
    get_setting("key.function.a", "BTN_TL", buf); cfg.fn_a = parse_keycode(buf);
    get_setting("key.function.b", "BTN_TR", buf); cfg.fn_b = parse_keycode(buf);
    get_setting("key.hotkey.a", "BTN_TL", buf); cfg.hk_a = parse_keycode(buf);
    get_setting("key.hotkey.b", "BTN_SELECT", buf); cfg.hk_b = parse_keycode(buf);
    get_setting("key.hotkey.c", "BTN_START", buf); cfg.hk_c = parse_keycode(buf);

    get_setting("key.function.a.up", "brightness up", cfg.fn_a_up);
    get_setting("key.function.a.down", "brightness down", cfg.fn_a_down);
    get_setting("key.function.b.up", "ledcontrol", cfg.fn_b_up);
    get_setting("key.function.b.down", "ledcontrol poweroff", cfg.fn_b_down);
    get_setting("key.function.ab.up", "wifictl enable", cfg.fn_ab_up);
    get_setting("key.function.ab.down", "wifictl disable", cfg.fn_ab_down);

    get_setting("key.touchscreen.events", "0", buf); cfg.touch_events = (buf[0] == '1' || buf[0] == 't');
    get_setting("key.dpad.events", "0", buf); cfg.dpad_events = (buf[0] == '1' || buf[0] == 't');
}

void notify(const char *type, const char *setting) {
    char val[64], cmd[256];
    get_setting(setting, "50", val);

    snprintf(cmd, sizeof(cmd), "/usr/bin/mako-notify \"%s: %s%%\" -no-es &", type, val);
    run_cmd(cmd);
}

void set_vol_timer(bool enable) {
    struct itimerspec ts = {0};
    if (enable) {
        ts.it_value.tv_nsec = 300000000;
        ts.it_interval.tv_nsec = 100000000;
    }
    timerfd_settime(vol_timer_fd, 0, &ts, NULL);
}

void process_input(int type, int code, int val) {
    bool pressed = (val == 1);

    if (type == EV_KEY) {
        if (code == cfg.fn_a) state.fn_a = pressed;
        if (code == cfg.fn_b) state.fn_b = pressed;
        if (code == cfg.hk_a) state.hk_a = pressed;

        if (code == cfg.hk_b) {
            state.hk_b = pressed;
            if (pressed && state.hk_a && state.hk_c && access("/tmp/.process-kill-data", F_OK) == 0)
                run_cmd("killall $(cat /tmp/.process-kill-data) 2>/dev/null");
        }
        if (code == cfg.hk_c) {
            state.hk_c = pressed;
            if (pressed && state.hk_a && state.hk_b && access("/tmp/.process-kill-data", F_OK) == 0)
                run_cmd("killall $(cat /tmp/.process-kill-data) 2>/dev/null");
        }

        if (code == cfg.key_vol_up || code == cfg.key_vol_down) {
            bool is_up = (code == cfg.key_vol_up);
            if (pressed) {
                if (is_up) state.vol_up = true; else state.vol_down = true;

                if (!state.fn_a && !state.fn_b) {
                    run_cmd(is_up ? "volume up" : "volume down");
                    set_vol_timer(true);
                } else {
                    if (state.fn_a && state.fn_b) run_cmd(is_up ? cfg.fn_ab_up : cfg.fn_ab_down);
                    else if (state.fn_a) { run_cmd(is_up ? cfg.fn_a_up : cfg.fn_a_down); notify("Brightness", "display.brightness"); }
                    else if (state.fn_b) run_cmd(is_up ? cfg.fn_b_up : cfg.fn_b_down);
                }
            } else if (val == 0) {
                state.vol_up = state.vol_down = false;
                set_vol_timer(false);
                if (!state.fn_a && !state.fn_b) notify("Volume", "audio.volume");
            }
        }

        if (code == KEY_POWER && pressed) run_cmd("/usr/bin/rocknix-fake-suspend power &");

        if (pressed && state.hk_a) {
            if (code == BTN_EAST && system("/usr/bin/rocknix-screenshot") == 0)
                run_cmd("/usr/bin/mako-notify \"Screenshot Saved\" -no-ra &");
            if (code == BTN_WEST) run_cmd("/usr/bin/mangohud_set toggle");
            if (code == BTN_NORTH) run_cmd("/usr/bin/game-guides-tool &");
        }

        if (code == BTN_TOUCH && pressed && state.fn_a && cfg.touch_events)
            run_cmd("kill -34 $(pidof wvkbd-mobintl) 2>/dev/null");

        if (cfg.dpad_events && state.fn_a && pressed) {
            if (code == BTN_DPAD_UP) run_cmd("volume up");
            if (code == BTN_DPAD_DOWN) run_cmd("volume down");
            if (code == BTN_DPAD_RIGHT) { run_cmd("brightness up"); notify("Brightness", "display.brightness"); }
            if (code == BTN_DPAD_LEFT) { run_cmd("brightness down"); notify("Brightness", "display.brightness"); }
        }
    }

    else if (type == EV_ABS && cfg.dpad_events && state.fn_a) {
        if (code == ABS_HAT0Y && val == -1) run_cmd("volume up");
        if (code == ABS_HAT0Y && val == 1) run_cmd("volume down");
        if (code == ABS_HAT0X && val == 1) { run_cmd("brightness up"); notify("Brightness", "display.brightness"); }
        if (code == ABS_HAT0X && val == -1) { run_cmd("brightness down"); notify("Brightness", "display.brightness"); }
    }

    else if (type == EV_SW && code == SW_LID) {
        if (val == 0) run_cmd("/usr/bin/rocknix-fake-suspend lid open &");
        if (val == 1) run_cmd("/usr/bin/rocknix-fake-suspend lid close &");
    }
}

void add_device(const char *path) {
    int fd = open(path, O_RDONLY | O_NONBLOCK);
    if (fd >= 0) {
        struct epoll_event ev = { .events = EPOLLIN, .data.fd = fd };
        epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, &ev);
    }
}

int main(int argc, char **argv) {
    int opt;
    while ((opt = getopt(argc, argv, "dh")) != -1) {
        if (opt == 'd') debug_mode = true;
        else { printf("Usage: %s [-d]\n", argv[0]); return 0; }
    }

    load_config();
    epoll_fd = epoll_create1(0);
    vol_timer_fd = timerfd_create(CLOCK_MONOTONIC, TFD_NONBLOCK);

    struct epoll_event timer_ev = { .events = EPOLLIN, .data.fd = vol_timer_fd };
    epoll_ctl(epoll_fd, EPOLL_CTL_ADD, vol_timer_fd, &timer_ev);

    int ino_fd = inotify_init1(IN_NONBLOCK);
    inotify_add_watch(ino_fd, "/dev/input", IN_CREATE | IN_DELETE);
    struct epoll_event ino_ev = { .events = EPOLLIN, .data.fd = ino_fd };
    epoll_ctl(epoll_fd, EPOLL_CTL_ADD, ino_fd, &ino_ev);

    DIR *dir = opendir("/dev/input");
    struct dirent *entry;
    if (dir) {
        while ((entry = readdir(dir))) {
            if (strncmp(entry->d_name, "event", 5) == 0) {
                char path[512];
                snprintf(path, sizeof(path), "/dev/input/%s", entry->d_name);
                add_device(path);
            }
        }
        closedir(dir);
    }

    struct epoll_event events[MAX_EVENTS];
    while (1) {
        int n = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
        for (int i = 0; i < n; i++) {
            int fd = events[i].data.fd;

            if (fd == vol_timer_fd) {
                uint64_t exp;
                read(fd, &exp, sizeof(exp));
                if (state.vol_up) run_cmd("volume up");
                if (state.vol_down) run_cmd("volume down");
                continue;
            }

            if (fd == ino_fd) {
                char buf[INOTIFY_BUF_LEN] __attribute__ ((aligned(8)));
                int len = read(fd, buf, sizeof(buf));
                int idx = 0;
                while (idx < len) {
                    struct inotify_event *ev = (struct inotify_event *) &buf[idx];
                    if (ev->len && strncmp(ev->name, "event", 5) == 0 && (ev->mask & IN_CREATE)) {
                        char path[512];
                        snprintf(path, sizeof(path), "/dev/input/%s", ev->name);
                        add_device(path);
                        run_cmd("mkcontroller 2>/dev/null &");
                    }
                    idx += sizeof(struct inotify_event) + ev->len;
                }
                continue;
            }

            struct input_event ev_data;
            while (read(fd, &ev_data, sizeof(ev_data)) > 0) {
                process_input(ev_data.type, ev_data.code, ev_data.value);
            }
            if (errno == ENODEV) close(fd);
        }
    }
    return 0;
}
