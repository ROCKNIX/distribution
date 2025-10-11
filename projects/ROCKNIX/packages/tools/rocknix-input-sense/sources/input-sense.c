// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <errno.h>
#include <stdbool.h>
#include <stdarg.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <libevdev-1.0/libevdev/libevdev.h>
#include <linux/input-event-codes.h>

// --- Defines ---
#define MAX_DEVICES 10
#define ES_CONF "/storage/.config/system/configs/system.cfg"

// --- Global State & Configuration ---
static bool DEBUG_MODE = false;

// Modifier key states
static bool FN_A_PRESSED = false;
static bool FN_B_PRESSED = false;
static bool HOTKEY_A_PRESSED = false;
static bool HOTKEY_B_PRESSED = false;
static bool HOTKEY_C_PRESSED = false;

// Feature flags
static bool TOUCHSCREEN_EVENTS_ENABLED = false;
static bool DPAD_EVENTS_ENABLED = false;

// Mapped key codes from config
static int KEY_VOLUME_UP_CODE = KEY_VOLUMEUP;
static int KEY_VOLUME_DOWN_CODE = KEY_VOLUMEDOWN;
static int KEY_POWER_CODE = KEY_POWER;
static int SW_LID_CODE = SW_LID;
static int KEYA_MODIFIER_CODE = -1;
static int KEYB_MODIFIER_CODE = -1;
static int BTN_HOTKEY_A_MODIFIER_CODE = BTN_TL;
static int BTN_HOTKEY_B_MODIFIER_CODE = BTN_SELECT;
static int BTN_HOTKEY_C_MODIFIER_CODE = BTN_START;


// --- Utility Functions ---

/**
 * @brief Prints a message to stdout if DEBUG_MODE is enabled.
 */
static void log_msg(const char *format, ...) {
    if (DEBUG_MODE) {
        va_list args;
        va_start(args, format);
        vprintf(format, args);
        va_end(args);
    }
}

/**
 * @brief Executes a shell command using system().
 */
static void execute_command(const char *command) {
    if (!command || strlen(command) == 0) return;
    log_msg("Executing command: %s\n", command);
    system(command);
}

/**
 * @brief Converts a string key name (e.g., "BTN_SELECT") to its Linux integer code.
 * @return The integer code, or -1 if not found.
 */
static int get_code_from_name(const char *name) {
    if (!name || strlen(name) == 0) return -1;
    int code = libevdev_event_code_from_name(EV_KEY, name);
    if (code != -1) return code;
    code = libevdev_event_code_from_name(EV_SW, name);
    if (code != -1) return code;
    fprintf(stderr, "Warning: Key name '%s' not found by libevdev.\n", name);
    return -1;
}


// --- Configuration File Parser ---

/**
 * @brief Searches a file for a key and returns its value.
 * @note The caller is responsible for freeing the returned string.
 * @return Allocated string with the value, or NULL if not found.
 */
static char* find_value_for_key(const char* filepath, const char* full_key) {
    FILE* f = fopen(filepath, "r");
    if (!f) return NULL;

    char* line = NULL;
    size_t len = 0;
    char* result = NULL;
    char search_pattern[256];
    snprintf(search_pattern, sizeof(search_pattern), "%s=", full_key);
    size_t pattern_len = strlen(search_pattern);

    while (getline(&line, &len, f) != -1) {
        if (strncmp(line, search_pattern, pattern_len) == 0) {
            char* value_start = line + pattern_len;
            value_start[strcspn(value_start, "\r\n")] = 0; // Trim newline
            result = strdup(value_start);
            break;
        }
    }

    free(line);
    fclose(f);
    return result;
}

/**
 * @brief Gets a setting from ES_CONF, mimicking the shell function's priority.
 * @note The caller is responsible for freeing the returned string.
 * @return Allocated string with the value, or NULL if not found.
 */
static char* get_setting(const char* key) {
    char* result = NULL;
    char full_key[256];

    // 1. Try the key directly (e.g., "system.loglevel")
    result = find_value_for_key(ES_CONF, key);
    if (result) return result;

    // 2. Try with "system." prefix if it doesn't have one
    if (strncmp(key, "system.", 7) != 0) {
        snprintf(full_key, sizeof(full_key), "system.%s", key);
        result = find_value_for_key(ES_CONF, full_key);
        if (result) return result;
    }

    // 3. Try with "global." prefix
    snprintf(full_key, sizeof(full_key), "global.%s", key);
    result = find_value_for_key(ES_CONF, full_key);
    if (result) return result;

    // 4. Try the key name without any prefix
    const char* key_part = strrchr(key, '.');
    if (key_part && *(key_part + 1) != '\0') {
         result = find_value_for_key(ES_CONF, key_part + 1);
    }

    return result;
}


// --- Core Logic ---

/**
 * @brief Reads /tmp/.process-kill-data and kills the specified process.
 */
static void execute_kill() {
    FILE *f = fopen("/tmp/.process-kill-data", "r");
    if (f) {
        char to_kill[256] = {0};
        if (fgets(to_kill, sizeof(to_kill) - 1, f)) {
            to_kill[strcspn(to_kill, "\r\n")] = 0;
            if (strlen(to_kill) > 0) {
                char kill_cmd[300];
                snprintf(kill_cmd, sizeof(kill_cmd), "killall %s 2>/dev/null", to_kill);
                execute_command(kill_cmd);
            }
        }
        fclose(f);
    }
}

/**
 * @brief Executes actions based on which function keys are held down.
 */
static void execute_action(const char* direction) {
    log_msg("Action Trigger: %s | FN_A:%d | FN_B:%d\n", direction, FN_A_PRESSED, FN_B_PRESSED);

    char* action = NULL;
    char key[64]; // Buffer for the setting key

    // Check for FN key combinations first
    if (FN_A_PRESSED && FN_B_PRESSED) {
        snprintf(key, sizeof(key), "key.function.ab.%s", direction);
        action = get_setting(key);
    } else if (FN_A_PRESSED) {
        snprintf(key, sizeof(key), "key.function.a.%s", direction);
        action = get_setting(key);
    } else if (FN_B_PRESSED) {
        snprintf(key, sizeof(key), "key.function.b.%s", direction);
        action = get_setting(key);
    }

    // If an action was found in the config, execute it.
    // Otherwise, fall back to the default volume command.
    if (action && strlen(action) > 0) {
        execute_command(action);
    } else {
        char cmd[32];
        snprintf(cmd, sizeof(cmd), "volume %s", direction);
        execute_command(cmd);
    }
    free(action); // Safely free memory (free(NULL) is safe)
}

/**
 * @brief Reads the config file and populates all global setting variables,
 * using environment variables as fallbacks for function keys.
 */
static void load_configuration() {
    char* temp_setting;

    temp_setting = get_setting("system.loglevel");
    if (temp_setting && strcmp(temp_setting, "verbose") == 0) {
        DEBUG_MODE = true;
        printf("Verbose logging enabled.\n");
    }
    free(temp_setting);

    // --- Macro Definitions ---

    // Macro for keys that ONLY read from the config file.
    #define LOAD_KEY(config_key, var_name) \
    do { \
        temp_setting = get_setting(config_key); \
        if (temp_setting) { \
            var_name = get_code_from_name(temp_setting); \
            log_msg("Loaded %s: %s -> %d\n", config_key, temp_setting, var_name); \
            free(temp_setting); \
        } \
    } while (0)

    // Macro for keys that check config file FIRST, then an environment variable.
    #define LOAD_KEY_WITH_ENV_FALLBACK(config_key, var_name, env_var_name) \
    do { \
        char* key_name_str = NULL; \
        temp_setting = get_setting(config_key); \
        if (temp_setting && strlen(temp_setting) > 0) { \
            key_name_str = temp_setting; \
        } else { \
            free(temp_setting); \
            char* env_val = getenv(env_var_name); \
            if (env_val && strlen(env_val) > 0) { \
                key_name_str = strdup(env_val); \
            } \
        } \
        if (key_name_str) { \
            var_name = get_code_from_name(key_name_str); \
            log_msg("Loaded %s (fallback %s): %s -> %d\n", config_key, env_var_name, key_name_str, var_name); \
            free(key_name_str); \
        } \
    } while (0)

    // --- Key Loading ---

    // Load standard keys (no fallback)
    LOAD_KEY("key.volume.up", KEY_VOLUME_UP_CODE);
    LOAD_KEY("key.volume.down", KEY_VOLUME_DOWN_CODE);
    LOAD_KEY("key.hotkey.a", BTN_HOTKEY_A_MODIFIER_CODE);
    LOAD_KEY("key.hotkey.b", BTN_HOTKEY_B_MODIFIER_CODE);
    LOAD_KEY("key.hotkey.c", BTN_HOTKEY_C_MODIFIER_CODE);

    // Load function keys WITH environment variable fallbacks
    LOAD_KEY_WITH_ENV_FALLBACK("key.function.a", KEYA_MODIFIER_CODE, "DEVICE_FUNC_KEYA_MODIFIER");
    LOAD_KEY_WITH_ENV_FALLBACK("key.function.b", KEYB_MODIFIER_CODE, "DEVICE_FUNC_KEYB_MODIFIER");

    // Undefine the macros to keep the namespace clean
    #undef LOAD_KEY
    #undef LOAD_KEY_WITH_ENV_FALLBACK

    // Load feature flags
    temp_setting = get_setting("key.touchscreen.events");
    if (temp_setting && strcmp(temp_setting, "0") != 0) TOUCHSCREEN_EVENTS_ENABLED = true;
    free(temp_setting);

    temp_setting = get_setting("key.dpad.events");
    if (temp_setting && strcmp(temp_setting, "0") != 0) DPAD_EVENTS_ENABLED = true;
    free(temp_setting);

    log_msg("Config loaded. VOL_UP:%d, VOL_DOWN:%d, FN_A:%d, FN_B:%d\n",
        KEY_VOLUME_UP_CODE, KEY_VOLUME_DOWN_CODE, KEYA_MODIFIER_CODE, KEYB_MODIFIER_CODE);
}


// --- Device and Event Handling ---

/**
 * @brief Scans /dev/input for usable event devices and opens them.
 * @return The number of devices opened.
 */
static int find_and_open_devices(int fds[], int max_fds) {
    DIR *dir;
    struct dirent *entry;
    int count = 0;

    if ((dir = opendir("/dev/input")) == NULL) {
        perror("Error opening /dev/input");
        return 0;
    }

    while ((entry = readdir(dir)) != NULL && count < max_fds) {
        if (strncmp(entry->d_name, "event", 5) == 0) {
            char path[512];
            snprintf(path, sizeof(path), "/dev/input/%s", entry->d_name);
            int fd = open(path, O_RDONLY | O_NONBLOCK);
            if (fd < 0) continue;

            // Check if device has keys, switches, or absolute axes (for joysticks)
            unsigned long ev_bits[EV_MAX / (sizeof(long) * 8) + 1] = {0};
            ioctl(fd, EVIOCGBIT(0, sizeof(ev_bits)), ev_bits);
            if ((ev_bits[0] & (1 << EV_KEY)) || (ev_bits[0] & (1 << EV_SW)) || (ev_bits[0] & (1 << EV_ABS))) {
                fds[count++] = fd;
                log_msg("Monitoring device: %s\n", path);
            } else {
                close(fd);
            }
        }
    }
    closedir(dir);
    return count;
}

/**
 * @brief Processes a single input event and takes action if necessary.
 */
static void process_event(const struct input_event *ev) {
    // Modifier key state updates
    if (ev->type == EV_KEY) {
        if (ev->code == KEYA_MODIFIER_CODE) { FN_A_PRESSED = ev->value; log_msg("FN_A state: %d\n", ev->value); }
        if (ev->code == KEYB_MODIFIER_CODE) { FN_B_PRESSED = ev->value; log_msg("FN_B state: %d\n", ev->value); }
        if (ev->code == BTN_HOTKEY_A_MODIFIER_CODE) { HOTKEY_A_PRESSED = ev->value; log_msg("HOTKEY_A state: %d\n", ev->value); }
        if (ev->code == BTN_HOTKEY_B_MODIFIER_CODE) { HOTKEY_B_PRESSED = ev->value; log_msg("HOTKEY_B state: %d\n", ev->value); }
        if (ev->code == BTN_HOTKEY_C_MODIFIER_CODE) { HOTKEY_C_PRESSED = ev->value; log_msg("HOTKEY_C state: %d\n", ev->value); }
    }

    // Handle actions that occur only on press (value=1) or HAT events
    if (ev->value == 1 || ev->type == EV_ABS) {
        // System-level actions (Volume, Power)
        if (ev->type == EV_KEY && ev->code == KEY_VOLUME_UP_CODE) execute_action("up");
        if (ev->type == EV_KEY && ev->code == KEY_VOLUME_DOWN_CODE) execute_action("down");
        if (ev->type == EV_KEY && ev->code == KEY_POWER_CODE) execute_command("/usr/bin/rocknix-fake-suspend power &");

        // Hotkey combinations
        if (HOTKEY_A_PRESSED && HOTKEY_B_PRESSED && ev->code == BTN_HOTKEY_C_MODIFIER_CODE) execute_kill();
        if (HOTKEY_A_PRESSED && HOTKEY_C_PRESSED && ev->code == BTN_HOTKEY_B_MODIFIER_CODE) execute_kill();

        // FN+A combinations
        if (FN_A_PRESSED) {
            if (ev->type == EV_KEY && ev->code == BTN_EAST) execute_command("/usr/bin/rocknix-screenshot");
            if (ev->type == EV_KEY && ev->code == BTN_WEST) execute_command("/usr/bin/mangohud_set toggle");
            if (TOUCHSCREEN_EVENTS_ENABLED && ev->type == EV_KEY && ev->code == BTN_TOUCH) execute_command("kill -34 $(pidof wvkbd-mobintl)");
            if (DPAD_EVENTS_ENABLED) {
                if (ev->type == EV_KEY && ev->code == BTN_DPAD_UP) execute_command("volume up");
                if (ev->type == EV_KEY && ev->code == BTN_DPAD_DOWN) execute_command("volume down");
                if (ev->type == EV_KEY && ev->code == BTN_DPAD_RIGHT) execute_command("brightness up");
                if (ev->type == EV_KEY && ev->code == BTN_DPAD_LEFT) execute_command("brightness down");
                if (ev->type == EV_ABS && ev->code == ABS_HAT0Y && ev->value == -1) execute_command("volume up");
                if (ev->type == EV_ABS && ev->code == ABS_HAT0Y && ev->value == 1) execute_command("volume down");
                if (ev->type == EV_ABS && ev->code == ABS_HAT0X && ev->value == 1) execute_command("brightness up");
                if (ev->type == EV_ABS && ev->code == ABS_HAT0X && ev->value == -1) execute_command("brightness down");
            }
        }
    }

    // Lid switch (value 1=closed, 0=open)
    if (ev->type == EV_SW && ev->code == SW_LID_CODE) {
        if (ev->value == 1) execute_command("/usr/bin/rocknix-fake-suspend lid close &");
        if (ev->value == 0) execute_command("/usr/bin/rocknix-fake-suspend lid open &");
    }
}


// --- Main Application Loop ---

int main(void) {
    int fds[MAX_DEVICES];
    int device_count;

    load_configuration();
    execute_command("mkcontroller 2>/dev/null || :");

    while (1) {
        device_count = find_and_open_devices(fds, MAX_DEVICES);
        if (device_count == 0) {
            fprintf(stderr, "No input devices found. Retrying in 5 seconds...\n");
            sleep(5);
            continue;
        }
        printf("Monitoring %d devices. Waiting for events...\n", device_count);

        bool devices_changed = false;
        while (!devices_changed) {
            fd_set read_fds;
            FD_ZERO(&read_fds);
            int max_fd = 0;
            for (int i = 0; i < device_count; i++) {
                FD_SET(fds[i], &read_fds);
                if (fds[i] > max_fd) max_fd = fds[i];
            }

            // Wait for an event on any device
            int result = select(max_fd + 1, &read_fds, NULL, NULL, NULL);
            if (result < 0 && errno != EINTR) {
                perror("select() error");
                devices_changed = true; // Break inner loop to rescan
                continue;
            }

            for (int i = 0; i < device_count; i++) {
                if (FD_ISSET(fds[i], &read_fds)) {
                    struct input_event ev;
                    ssize_t bytes = read(fds[i], &ev, sizeof(ev));
                    if (bytes < (ssize_t)sizeof(ev)) {
                        // Error or device disconnected
                        fprintf(stderr, "Error reading from device fd %d. Assuming disconnect.\n", fds[i]);
                        devices_changed = true;
                        break;
                    } else {
                        process_event(&ev);
                    }
                }
            }
        }

        // Cleanup FDs before rescanning
        for (int i = 0; i < device_count; i++) close(fds[i]);
        printf("Device change detected. Rescanning devices...\n");
        execute_command("mkcontroller 2>/dev/null || :");
        sleep(1);
    }

    return 0; // Unreachable
}
