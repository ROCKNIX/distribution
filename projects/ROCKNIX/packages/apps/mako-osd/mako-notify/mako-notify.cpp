// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

#include <dbus/dbus.h>
#include <cstdint>
#include <iostream>
#include <string>
#include <fstream>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <array>
#include <memory>

const std::string CONFIG_DIR = "/storage/.config/mako";
const std::string CONFIG_FILE = CONFIG_DIR + "/config";

void ensure_mako_config() {
    // Check if directory exists
    struct stat st{};
    if (stat(CONFIG_DIR.c_str(), &st) != 0) {
        // Directory does not exist, create it
        if (mkdir(CONFIG_DIR.c_str(), 0755) != 0) {
            perror("Failed to create config directory");
            return;
        }
    }

    // Check if file exists
    if (stat(CONFIG_FILE.c_str(), &st) != 0) {
        // File does not exist, create it with default contents
        std::ofstream ofs(CONFIG_FILE);
        if (!ofs) {
            std::cerr << "Failed to create config file at " << CONFIG_FILE << std::endl;
            return;
        }

        ofs <<
"max-visible=1\n"
"layer=overlay\n"
"font=monospace 30\n"
"text-color=#ffffff\n"
"text-alignment=center\n"
"background-color=#000000\n"
"border-size=0\n"
"border-radius=10\n"
"default-timeout=1500\n"
"anchor=top-center\n"
"width=500\n";

        ofs.close();
    }
}

// Check focused app function
std::string get_focused_app() {
    std::string result;
    std::array<char, 128> buffer;
    std::unique_ptr<FILE, void(*)(FILE*)> pipe(
        popen("swaymsg -t get_tree | jq -r '.. | select(.focused?) | .app_id'", "r"),
        [](FILE* f){ if(f) pclose(f); }
    );
    if (!pipe) return "";
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    if (!result.empty() && result.back() == '\n') result.pop_back();
    return result;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <message>" << std::endl;
        std::cerr << "Example: " << argv[0] << " \"Hello World\"" << std::endl;
        return 1;
    }

    // check for -no-es / -no-ra option
    bool no_es_flag = false;
    bool no_ra_flag = false;
    for (int i = 2; i < argc; ++i) {
        if (std::string(argv[i]) == "-no-es") {
            no_es_flag = true;
        }
        if (std::string(argv[i]) == "-no-ra") {
            no_ra_flag = true;
        }
    }

    if (no_es_flag || no_ra_flag) {
        std::string focused_app = get_focused_app();
        // skip notification if -no-es and EmulationStation focused
        if (no_es_flag && focused_app == "emulationstation") {
            return 0;
        }
        // skip notification if -no-ra and Retorarch focused
        if (no_ra_flag && focused_app == "com.libretro.RetroArch") {
            return 0;
        }
    }

    // Ensure the Mako config exists
    ensure_mako_config();

    DBusError err;
    dbus_error_init(&err);

    // Connect to the session bus
    DBusConnection* conn = dbus_bus_get(DBUS_BUS_SESSION, &err);
    if (dbus_error_is_set(&err)) {
        std::cerr << "Connection Error: " << err.message << std::endl;
        dbus_error_free(&err);
        return 1;
    }
    if (!conn) return 1;

    // Create a method call
    DBusMessage* msg = dbus_message_new_method_call(
        "org.freedesktop.Notifications",  // destination
        "/org/freedesktop/Notifications", // object path
        "org.freedesktop.Notifications",  // interface
        "Notify"                          // method
    );

    if (!msg) {
        std::cerr << "Message Null" << std::endl;
        return 1;
    }

    // Build arguments
    DBusMessageIter args;
    dbus_message_iter_init_append(msg, &args);

    const char* app_name = "mako-notify";
    uint32_t replaces_id = 0;
    const char* icon = "";
    const char* summary = argv[1];
    const char* body = argv[1];
    int32_t timeout = 2000;

    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &app_name);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_UINT32, &replaces_id);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &icon);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &summary);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &body);

    // empty array of actions
    DBusMessageIter array_iter;
    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, "s", &array_iter);
    dbus_message_iter_close_container(&args, &array_iter);

    // empty dictionary for hints
    DBusMessageIter dict_iter;
    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, "{sv}", &dict_iter);
    dbus_message_iter_close_container(&args, &dict_iter);

    dbus_message_iter_append_basic(&args, DBUS_TYPE_INT32, &timeout);

    // Send message
    DBusPendingCall* pending = nullptr;
    if (!dbus_connection_send_with_reply(conn, msg, &pending, -1)) {
        std::cerr << "Failed to send message" << std::endl;
        return 1;
    }

    dbus_connection_flush(conn);
    dbus_message_unref(msg);

    // Wait for reply
    if (pending) dbus_pending_call_block(pending);
    if (pending) dbus_pending_call_unref(pending);

    return 0;
}
