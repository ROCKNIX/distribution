// SPDX-License-Identifier: GPL-2.0+

/*
 * Steam Deck EC MFD core driver
 *
 * Copyright (C) 2021-2022 Valve Corporation
 *
 */

#include <linux/acpi.h>
#include <linux/platform_device.h>
#include <linux/mfd/core.h>

#define STEAMDECK_STA_OK			\
	(ACPI_STA_DEVICE_ENABLED |		\
	 ACPI_STA_DEVICE_PRESENT |		\
	 ACPI_STA_DEVICE_FUNCTIONING)

struct steamdeck {
	struct acpi_device *adev;
	struct device *dev;
};

#define STEAMDECK_ATTR_RO(_name, _method)				\
	static ssize_t _name##_show(struct device *dev,			\
				    struct device_attribute *attr,	\
				    char *buf)				\
	{								\
		struct steamdeck *sd = dev_get_drvdata(dev);		\
		unsigned long long val;					\
									\
		if (ACPI_FAILURE(acpi_evaluate_integer(			\
					 sd->adev->handle,		\
					 _method, NULL, &val)))		\
			return -EIO;					\
									\
		return sysfs_emit(buf, "%llu\n", val);			\
	}								\
	static DEVICE_ATTR_RO(_name)

STEAMDECK_ATTR_RO(firmware_version, "PDFW");
STEAMDECK_ATTR_RO(board_id, "BOID");

static ssize_t controller_board_power_store(struct device *dev,
					    struct device_attribute *attr,
					    const char *buf, size_t count)
{
	struct steamdeck *sd = dev_get_drvdata(dev);
	bool enabled;
	ssize_t ret = kstrtobool(buf, &enabled);

	if (ret)
		return ret;

	if (ACPI_FAILURE(acpi_execute_simple_method(sd->adev->handle,
						    "SCBP", enabled)))
		return -EIO;

	return count;
}
static DEVICE_ATTR_WO(controller_board_power);

static struct attribute *steamdeck_attrs[] = {
	&dev_attr_firmware_version.attr,
	&dev_attr_board_id.attr,
	&dev_attr_controller_board_power.attr,
	NULL
};

ATTRIBUTE_GROUPS(steamdeck);

static const struct mfd_cell steamdeck_cells[] = {
	{ .name = "steamdeck-hwmon"  },
	{ .name = "steamdeck-leds"   },
	{ .name = "steamdeck-extcon" },
};

static void steamdeck_remove_sysfs_groups(void *data)
{
	struct steamdeck *sd = data;

	sysfs_remove_groups(&sd->dev->kobj, steamdeck_groups);
}

static int steamdeck_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	unsigned long long sta;
	struct steamdeck *sd;
	acpi_status status;
	int ret;

	sd = devm_kzalloc(dev, sizeof(*sd), GFP_KERNEL);
	if (!sd)
		return -ENOMEM;
	sd->adev = ACPI_COMPANION(dev);
	sd->dev = dev;
	platform_set_drvdata(pdev, sd);

	status = acpi_evaluate_integer(sd->adev->handle, "_STA",
				       NULL, &sta);
	if (ACPI_FAILURE(status)) {
		dev_err(dev, "Status check failed (0x%x)\n", status);
		return -EINVAL;
	}

	if ((sta & STEAMDECK_STA_OK) != STEAMDECK_STA_OK) {
		dev_err(dev, "Device is not ready\n");
		return -EINVAL;
	}

	ret = sysfs_create_groups(&dev->kobj, steamdeck_groups);
	if (ret) {
		dev_err(dev, "Failed to create sysfs group\n");
		return ret;
	}

	ret = devm_add_action_or_reset(dev, steamdeck_remove_sysfs_groups,
				       sd);
	if (ret) {
		dev_err(dev, "Failed to register devres action\n");
		return ret;
	}

	return devm_mfd_add_devices(dev, PLATFORM_DEVID_NONE,
				    steamdeck_cells, ARRAY_SIZE(steamdeck_cells),
				    NULL, 0, NULL);
}

static const struct acpi_device_id steamdeck_device_ids[] = {
	{ "VLV0100", 0 },
	{ "", 0 },
};
MODULE_DEVICE_TABLE(acpi, steamdeck_device_ids);

static struct platform_driver steamdeck_driver = {
	.probe = steamdeck_probe,
	.driver = {
		.name = "steamdeck",
		.acpi_match_table = steamdeck_device_ids,
	},
};
module_platform_driver(steamdeck_driver);

MODULE_AUTHOR("Andrey Smirnov <andrew.smirnov@gmail.com>");
MODULE_DESCRIPTION("Steam Deck EC MFD core driver");
MODULE_LICENSE("GPL");
