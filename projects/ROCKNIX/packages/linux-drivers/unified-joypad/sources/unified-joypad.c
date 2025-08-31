/*
 * unified_joypad.c - A kernel module to merge multiple input devices.
 *
 * This module creates a single virtual input device that combines events from
 * multiple physical input devices. It is configured via a Device Tree node,
 * including optional button remapping by device name or unique physical path.
 *
 * It will also grab the source devices to prevent them from reporting events
 * independently to the system.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/input.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/workqueue.h>
#include <linux/mutex.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/jiffies.h>

#define DRV_NAME "unified_joypad"

/* --- Data Structures --- */

struct key_remap {
	u32 from;
	u32 to;
};

struct event_filter {
	u32 type;
	u32 code;
};

struct device_remap_config {
	const char *name;
	const char *phys;
	int num_remaps;
	struct key_remap *remaps;
};

/* --- Module Information --- */

MODULE_AUTHOR("ROCKNIX");
MODULE_DESCRIPTION("Merges multiple input devices into one unified input device");
MODULE_LICENSE("GPL");
MODULE_VERSION("1.0");
MODULE_INFO(intree, "Y");

/* --- Global Variables --- */

static struct input_dev *vdev;
static struct input_dev **source_devs;
static int num_target_devices;
static char **target_device_names;

static const char *vdev_name;
static u16 vdev_vendor;
static u16 vdev_product;
static u16 vdev_version;

static struct device_remap_config *remap_configs;
static int num_remap_configs;

static struct event_filter *ignored_events;
static int num_ignored_events;

static struct delayed_work rebuild_work;
static struct mutex dev_mutex;

/* --- Forward Declarations --- */

static void rebuild_virtual_device_work(struct work_struct *work);

/* --- Functions --- */

static void copy_attributes(struct input_dev *dev, struct input_dev *vdev)
{
	int i;

	for (i = 0; i < BITS_TO_LONGS(EV_MAX); i++)
		vdev->evbit[i] |= dev->evbit[i];
	for (i = 0; i < BITS_TO_LONGS(KEY_MAX); i++)
		vdev->keybit[i] |= dev->keybit[i];
	for (i = 0; i < BITS_TO_LONGS(REL_MAX); i++)
		vdev->relbit[i] |= dev->relbit[i];
	for (i = 0; i < BITS_TO_LONGS(ABS_MAX); i++)
		vdev->absbit[i] |= dev->absbit[i];

	for (i = 0; i < ABS_MAX; i++) {
		if (test_bit(i, dev->absbit)) {
			input_set_abs_params(vdev, i,
					   dev->absinfo[i].minimum,
					   dev->absinfo[i].maximum,
					   dev->absinfo[i].fuzz,
					   dev->absinfo[i].flat);
		}
	}
}

static void rebuild_virtual_device(void)
{
	int error;
	int i, j;
	bool has_devices = false;

	if (vdev) {
		pr_info(DRV_NAME ": Destroying virtual device.\n");
		input_unregister_device(vdev);
		vdev = NULL;
	}

	for (i = 0; i < num_target_devices; i++) {
		if (source_devs[i]) {
			has_devices = true;
			break;
		}
	}

	if (!has_devices)
		return;

	pr_info(DRV_NAME ": Rebuilding virtual device...\n");
	vdev = input_allocate_device();
	if (!vdev) {
		pr_err(DRV_NAME ": Failed to allocate virtual device\n");
		return;
	}

	vdev->name = vdev_name;
	vdev->id.bustype = BUS_VIRTUAL;
	vdev->id.vendor = vdev_vendor;
	vdev->id.product = vdev_product;
	vdev->id.version = vdev_version;

	for (i = 0; i < num_target_devices; i++) {
		if (source_devs[i])
			copy_attributes(source_devs[i], vdev);
	}

	__set_bit(EV_KEY, vdev->evbit);
	for (i = 0; i < num_remap_configs; i++) {
		for (j = 0; j < remap_configs[i].num_remaps; j++)
			__set_bit(remap_configs[i].remaps[j].to, vdev->keybit);
	}

	error = input_register_device(vdev);
	if (error) {
		pr_err(DRV_NAME ": Failed to register virtual device, error %d\n", error);
		input_free_device(vdev);
		vdev = NULL;
	} else {
		pr_info(DRV_NAME ": Virtual device '%s' created/rebuilt successfully.\n", vdev->name);
	}
}

static void joypad_event(struct input_handle *handle, unsigned int type,
			 unsigned int code, int value)
{
	struct device_remap_config *remap_cfg = handle->private;
	int i;

	for (i = 0; i < num_ignored_events; i++) {
		if (type == ignored_events[i].type && code == ignored_events[i].code)
			return; /* This is an ignored event, do nothing. */
	}

	if (vdev) {
		if (type == EV_KEY && remap_cfg) {
			for (i = 0; i < remap_cfg->num_remaps; i++) {
				if (code == remap_cfg->remaps[i].from) {
					code = remap_cfg->remaps[i].to;
					break;
				}
			}
		}
		input_event(vdev, type, code, value);
	}
}

static int joypad_connect(struct input_handler *handler, struct input_dev *dev,
			  const struct input_device_id *id)
{
	struct input_handle *handle;
	struct device_remap_config *name_match = NULL;
	struct device_remap_config *phys_match = NULL;
	int error, i, slot = -1;
	bool is_target = false;

	for (i = 0; i < num_target_devices; i++) {
		if (strcmp(dev->name, target_device_names[i]) == 0) {
			is_target = true;
			break;
		}
	}
	if (!is_target)
		return -ENODEV;

	handle = kzalloc(sizeof(struct input_handle), GFP_KERNEL);
	if (!handle)
		return -ENOMEM;

	handle->dev = dev;
	handle->handler = handler;
	handle->name = "joypad_handle";

	for (i = 0; i < num_remap_configs; i++) {
		if (remap_configs[i].phys && dev->phys &&
		    strcmp(remap_configs[i].phys, dev->phys) == 0) {
			phys_match = &remap_configs[i];
			break;
		}
		if (!name_match && remap_configs[i].name &&
		    strcmp(remap_configs[i].name, dev->name) == 0) {
			name_match = &remap_configs[i];
		}
	}

	if (phys_match)
		handle->private = phys_match;
	else if (name_match)
		handle->private = name_match;

	error = input_register_handle(handle);
	if (error) {
		kfree(handle);
		return error;
	}

	error = input_open_device(handle);
	if (error) {
		input_unregister_handle(handle);
		kfree(handle);
		return error;
	}

	input_grab_device(handle);

	mutex_lock(&dev_mutex);
	for (i = 0; i < num_target_devices; i++) {
		if (strcmp(dev->name, target_device_names[i]) == 0 && !source_devs[i]) {
			source_devs[i] = dev;
			slot = i;
			break;
		}
	}
	mutex_unlock(&dev_mutex);

	if (slot != -1) {
		pr_info(DRV_NAME ": Successfully connected to and grabbed '%s'\n", dev->name);
		/* Schedule a rebuild in 200ms. If another device connects, this will reset the timer. */
		schedule_delayed_work(&rebuild_work, msecs_to_jiffies(200));
	} else {
		pr_warn(DRV_NAME ": No free slot for '%s'\n", dev->name);
		input_release_device(handle);
		input_close_device(handle);
		input_unregister_handle(handle);
		kfree(handle);
		return -EBUSY;
	}

	return 0;
}

static void joypad_disconnect(struct input_handle *handle)
{
	int i;
	pr_info(DRV_NAME ": Disconnecting from '%s'\n", handle->dev->name);

	mutex_lock(&dev_mutex);
	for (i = 0; i < num_target_devices; i++) {
		if (source_devs[i] == handle->dev) {
			source_devs[i] = NULL;
			break;
		}
	}
	mutex_unlock(&dev_mutex);

	/* Also schedule a rebuild on disconnect */
	schedule_delayed_work(&rebuild_work, msecs_to_jiffies(200));

	input_release_device(handle);
	input_close_device(handle);
	input_unregister_handle(handle);
	kfree(handle);
}

static const struct input_device_id joypad_ids[] = {
	{ .driver_info = 1 },
	{ }
};

static struct input_handler joypad_handler = {
	.event      = joypad_event,
	.connect    = joypad_connect,
	.disconnect = joypad_disconnect,
	.name       = "unified_joypad_handler",
	.id_table   = joypad_ids,
};

static void rebuild_virtual_device_work(struct work_struct *work)
{
	mutex_lock(&dev_mutex);
	rebuild_virtual_device();
	mutex_unlock(&dev_mutex);
}

static int parse_ignore_list(struct platform_device *pdev)
{
	struct device_node *np = pdev->dev.of_node;
	int n_vals;

	n_vals = of_property_count_u32_elems(np, "ignore-events");
	if (n_vals <= 0)
		return 0; /* No property found, which is fine */

	if (n_vals % 2 != 0) {
		dev_warn(&pdev->dev, "Property 'ignore-events' must have an even number of elements (type/code pairs).\n");
		return -EINVAL;
	}

	num_ignored_events = n_vals / 2;
	ignored_events = devm_kcalloc(&pdev->dev, num_ignored_events, sizeof(*ignored_events), GFP_KERNEL);
	if (!ignored_events) {
		num_ignored_events = 0;
		return -ENOMEM;
	}

	if (of_property_read_u32_array(np, "ignore-events", (u32 *)ignored_events, n_vals)) {
		dev_err(&pdev->dev, "Failed to read 'ignore-events' property.\n");
		num_ignored_events = 0;
		return -EINVAL;
	}

	pr_info(DRV_NAME ": Will ignore %d event types.\n", num_ignored_events);
	return 0;
}

static int parse_remaps(struct platform_device *pdev)
{
	struct device_node *remaps_np, *child;
	int count = 0;
	int valid_configs = 0;

	remaps_np = of_get_child_by_name(pdev->dev.of_node, "remaps");
	if (!remaps_np)
		return 0;

	count = of_get_child_count(remaps_np);
	if (count == 0) {
		of_node_put(remaps_np);
		return 0;
	}

	remap_configs = devm_kcalloc(&pdev->dev, count, sizeof(*remap_configs), GFP_KERNEL);
	if (!remap_configs) {
		of_node_put(remaps_np);
		return -ENOMEM;
	}

	for_each_child_of_node(remaps_np, child) {
		struct device_remap_config *cfg = &remap_configs[valid_configs];
		int n_vals;

		of_property_read_string(child, "target-device-name", &cfg->name);
		of_property_read_string(child, "target-device-phys", &cfg->phys);

		if (!cfg->name && !cfg->phys)
			continue;

		n_vals = of_property_count_u32_elems(child, "key-remaps");
		if (n_vals <= 0 || n_vals % 2 != 0)
			continue;

		cfg->num_remaps = n_vals / 2;
		cfg->remaps = devm_kcalloc(&pdev->dev, cfg->num_remaps, sizeof(*cfg->remaps), GFP_KERNEL);
		if (!cfg->remaps) {
			of_node_put(remaps_np);
			return -ENOMEM;
		}

		if (of_property_read_u32_array(child, "key-remaps", (u32 *)cfg->remaps, n_vals)) {
			cfg->num_remaps = 0;
			continue;
		}

		valid_configs++;
	}

	num_remap_configs = valid_configs;
	of_node_put(remaps_np);
	return 0;
}

static int unified_joypad_probe(struct platform_device *pdev)
{
	struct device_node *np = pdev->dev.of_node;
	int i, count, ret;
	u32 temp_val;

	pr_info(DRV_NAME ": Loading module...\n");

	count = of_property_count_strings(np, "target-device-names");
	if (count <= 0)
		return count == 0 ? -ENODEV : count;
	num_target_devices = count;

	source_devs = devm_kcalloc(&pdev->dev, num_target_devices, sizeof(struct input_dev *), GFP_KERNEL);
	target_device_names = devm_kcalloc(&pdev->dev, num_target_devices, sizeof(char *), GFP_KERNEL);
	if (!source_devs || !target_device_names)
		return -ENOMEM;

	for (i = 0; i < num_target_devices; i++) {
		if (of_property_read_string_index(np, "target-device-names", i, (const char **)&target_device_names[i]))
			return -EINVAL;
	}

	if (of_property_read_string(np, "virtual-device-name", &vdev_name))
		vdev_name = "ROCKNIX Unified Joypad";
	if (of_property_read_u32(np, "virtual-vendor-id", &temp_val) == 0)
		vdev_vendor = (u16)temp_val;
	if (of_property_read_u32(np, "virtual-product-id", &temp_val) == 0)
		vdev_product = (u16)temp_val;
	if (of_property_read_u32(np, "virtual-version-id", &temp_val) == 0)
		vdev_version = (u16)temp_val;

	ret = parse_ignore_list(pdev);
	if (ret)
		return ret;

	ret = parse_remaps(pdev);
	if (ret)
		return ret;

	mutex_init(&dev_mutex);
	INIT_DELAYED_WORK(&rebuild_work, rebuild_virtual_device_work);

	return input_register_handler(&joypad_handler);
}

static void unified_joypad_remove(struct platform_device *pdev)
{
	input_unregister_handler(&joypad_handler);

	/* Cancel any pending work before cleaning up */
	cancel_delayed_work_sync(&rebuild_work);

	mutex_lock(&dev_mutex);
	if (vdev)
		input_unregister_device(vdev);
	mutex_unlock(&dev_mutex);

	pr_info(DRV_NAME ": Module unloaded.\n");
}

static const struct of_device_id unified_joypad_of_match[] = {
	{ .compatible = "rocknix,unified-joypad" },
	{ }
};
MODULE_DEVICE_TABLE(of, unified_joypad_of_match);

static struct platform_driver unified_joypad_platform_driver = {
	.driver = {
		.name           = DRV_NAME,
		.of_match_table = unified_joypad_of_match,
	},
	.probe  = unified_joypad_probe,
	.remove = unified_joypad_remove,
};

module_platform_driver(unified_joypad_platform_driver);
