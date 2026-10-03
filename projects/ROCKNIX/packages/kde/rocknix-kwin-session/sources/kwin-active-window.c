// SPDX-License-Identifier: GPL-2.0
// Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wayland-client.h>
#include "plasma-window-management-client-protocol.h"

struct window {
    struct org_kde_plasma_window *handle;
    char *app_id;
    uint32_t state;
    struct wl_list link;
};

static struct wl_list windows;

static void app_id_changed(void *data, struct org_kde_plasma_window *handle, const char *app_id)
{
    struct window *window = data;
    free(window->app_id);
    window->app_id = strdup(app_id);
}

static void state_changed(void *data, struct org_kde_plasma_window *handle, uint32_t flags)
{
    ((struct window *)data)->state = flags;
}

static void ignore(void *data, struct org_kde_plasma_window *handle) {}
static void ignore_string(void *data, struct org_kde_plasma_window *handle, const char *string) {}
static void ignore_int(void *data, struct org_kde_plasma_window *handle, int32_t number) {}
static void ignore_uint(void *data, struct org_kde_plasma_window *handle, uint32_t number) {}
static void ignore_parent(void *data, struct org_kde_plasma_window *handle, struct org_kde_plasma_window *parent) {}
static void ignore_geometry(void *data, struct org_kde_plasma_window *handle,
                            int32_t x, int32_t y, uint32_t width, uint32_t height) {}
static void ignore_menu(void *data, struct org_kde_plasma_window *handle, const char *service, const char *path) {}

static const struct org_kde_plasma_window_listener window_listener = {
    .title_changed = ignore_string,
    .app_id_changed = app_id_changed,
    .state_changed = state_changed,
    .virtual_desktop_changed = ignore_int,
    .themed_icon_name_changed = ignore_string,
    .unmapped = ignore,
    .initial_state = ignore,
    .parent_window = ignore_parent,
    .geometry = ignore_geometry,
    .icon_changed = ignore,
    .pid_changed = ignore_uint,
    .virtual_desktop_entered = ignore_string,
    .virtual_desktop_left = ignore_string,
    .application_menu = ignore_menu,
};

static void window_with_uuid(void *data, struct org_kde_plasma_window_management *management,
                             uint32_t id, const char *uuid)
{
    struct window *window = calloc(1, sizeof(*window));
    window->handle = org_kde_plasma_window_management_get_window_by_uuid(management, uuid);
    org_kde_plasma_window_add_listener(window->handle, &window_listener, window);
    wl_list_insert(&windows, &window->link);
}

static void ignore_value(void *data, struct org_kde_plasma_window_management *management, uint32_t value) {}
static void ignore_ids(void *data, struct org_kde_plasma_window_management *management, struct wl_array *ids) {}
static void ignore_uuids(void *data, struct org_kde_plasma_window_management *management, const char *uuids) {}

static const struct org_kde_plasma_window_management_listener management_listener = {
    .show_desktop_changed = ignore_value,
    .window = ignore_value,
    .stacking_order_changed = ignore_ids,
    .stacking_order_uuid_changed = ignore_uuids,
    .window_with_uuid = window_with_uuid,
};

static void global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version)
{
    struct org_kde_plasma_window_management **management = data;

    if (strcmp(interface, org_kde_plasma_window_management_interface.name) == 0 && version >= 13) {
        *management = wl_registry_bind(registry, name, &org_kde_plasma_window_management_interface, 13);
        org_kde_plasma_window_management_add_listener(*management, &management_listener, NULL);
    }
}

static void global_remove(void *data, struct wl_registry *registry, uint32_t name) {}

static const struct wl_registry_listener registry_listener = {
    .global = global,
    .global_remove = global_remove,
};

int main(void)
{
    struct org_kde_plasma_window_management *management = NULL;
    struct wl_display *display = wl_display_connect(NULL);
    struct window *window;

    if (!display) {
        fprintf(stderr, "no Wayland display\n");
        return 1;
    }
    wl_list_init(&windows);
    wl_registry_add_listener(wl_display_get_registry(display), &registry_listener, &management);

    wl_display_roundtrip(display);
    if (!management) {
        fprintf(stderr, "window management not offered, check X-KDE-Wayland-Interfaces\n");
        return 1;
    }
    wl_display_roundtrip(display);
    wl_display_roundtrip(display);

    wl_list_for_each(window, &windows, link) {
        if ((window->state & ORG_KDE_PLASMA_WINDOW_MANAGEMENT_STATE_ACTIVE) && window->app_id) {
            puts(window->app_id);
            break;
        }
    }
    wl_display_disconnect(display);
    return 0;
}
