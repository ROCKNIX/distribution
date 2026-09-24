// SPDX-License-Identifier: GPL-2.0+
/*
 * Steam Deck EC sensors driver
 *
 * Copyright (C) 2021-2022 Valve Corporation
 */

#include <linux/acpi.h>
#include <linux/hwmon.h>
#include <linux/platform_device.h>

#define STEAMDECK_HWMON_NAME	"steamdeck-hwmon"

struct steamdeck_hwmon {
	struct acpi_device *adev;
};

static long
steamdeck_hwmon_get(struct steamdeck_hwmon *sd, const char *method)
{
	unsigned long long val;
	if (ACPI_FAILURE(acpi_evaluate_integer(sd->adev->handle,
					       (char *)method, NULL, &val)))
		return -EIO;

	return val;
}

static int
steamdeck_hwmon_read(struct device *dev, enum hwmon_sensor_types type,
		     u32 attr, int channel, long *out)
{
	struct steamdeck_hwmon *sd = dev_get_drvdata(dev);

	switch (type) {
	case hwmon_curr:
		if (attr != hwmon_curr_input)
			return -EOPNOTSUPP;

		*out = steamdeck_hwmon_get(sd, "PDAM");
		if (*out < 0)
			return *out;
		break;
	case hwmon_in:
		if (attr != hwmon_in_input)
			return -EOPNOTSUPP;

		*out = steamdeck_hwmon_get(sd, "PDVL");
		if (*out < 0)
			return *out;
		break;
	case hwmon_temp:
		if (attr != hwmon_temp_input)
			return -EOPNOTSUPP;

		*out = steamdeck_hwmon_get(sd, "BATT");
		if (*out < 0)
			return *out;
		/*
		 * Assuming BATT returns deg C we need to mutiply it
		 * by 1000 to convert to mC
		 */
		*out *= 1000;
		break;
	case hwmon_fan:
		switch (attr) {
		case hwmon_fan_input:
			*out = steamdeck_hwmon_get(sd, "FANR");
			if (*out < 0)
				return *out;
			break;
		case hwmon_fan_target:
			*out = steamdeck_hwmon_get(sd, "FSSR");
			if (*out < 0)
				return *out;
			break;
		case hwmon_fan_fault:
			*out = steamdeck_hwmon_get(sd, "FANC");
			if (*out < 0)
				return *out;
			/*
			 * FANC (Fan check):
			 * 0: Abnormal
			 * 1: Normal
			 */
			*out = !*out;
			break;
		default:
			return -EOPNOTSUPP;
		}
		break;
	default:
		return -EOPNOTSUPP;
	}

	return 0;
}

static int
steamdeck_hwmon_read_string(struct device *dev, enum hwmon_sensor_types type,
			    u32 attr, int channel, const char **str)
{
	switch (type) {
		/*
		 * These two aren't, strictly speaking, measured. EC
		 * firmware just reports what PD negotiation resulted
		 * in.
		 */
	case hwmon_curr:
		*str = "PD Contract Current";
		break;
	case hwmon_in:
		*str = "PD Contract Voltage";
		break;
	case hwmon_temp:
		*str = "Battery Temp";
		break;
	case hwmon_fan:
		*str = "System Fan";
		break;
	default:
		return -EOPNOTSUPP;
	}

	return 0;
}

static int
steamdeck_hwmon_write(struct device *dev, enum hwmon_sensor_types type,
		      u32 attr, int channel, long val)
{
	struct steamdeck_hwmon *sd = dev_get_drvdata(dev);

	if (type != hwmon_fan ||
	    attr != hwmon_fan_target)
		return -EOPNOTSUPP;

	val = clamp_val(val, 0, 7300);

	if (ACPI_FAILURE(acpi_execute_simple_method(sd->adev->handle,
						    "FANS", val)))
		return -EIO;

	return 0;
}

static umode_t
steamdeck_hwmon_is_visible(const void *data, enum hwmon_sensor_types type,
			   u32 attr, int channel)
{
	if (type == hwmon_fan &&
	    attr == hwmon_fan_target)
		return 0644;

	return 0444;
}

static const struct hwmon_channel_info *steamdeck_hwmon_info[] = {
	HWMON_CHANNEL_INFO(in,
			   HWMON_I_INPUT | HWMON_I_LABEL),
	HWMON_CHANNEL_INFO(curr,
			   HWMON_C_INPUT | HWMON_C_LABEL),
	HWMON_CHANNEL_INFO(temp,
			   HWMON_T_INPUT | HWMON_T_LABEL),
	HWMON_CHANNEL_INFO(fan,
			   HWMON_F_INPUT | HWMON_F_LABEL |
			   HWMON_F_TARGET | HWMON_F_FAULT),
	NULL
};

static const struct hwmon_ops steamdeck_hwmon_ops = {
	.is_visible = steamdeck_hwmon_is_visible,
	.read = steamdeck_hwmon_read,
	.read_string = steamdeck_hwmon_read_string,
	.write = steamdeck_hwmon_write,
};

static const struct hwmon_chip_info steamdeck_hwmon_chip_info = {
	.ops = &steamdeck_hwmon_ops,
	.info = steamdeck_hwmon_info,
};


static ssize_t
steamdeck_hwmon_simple_store(struct device *dev, const char *buf, size_t count,
			     const char *method,
			     unsigned long upper_limit)
{
	struct steamdeck_hwmon *sd = dev_get_drvdata(dev);
	unsigned long value;

	if (kstrtoul(buf, 10, &value) || value >= upper_limit)
		return -EINVAL;

	if (ACPI_FAILURE(acpi_execute_simple_method(sd->adev->handle,
						    (char *)method, value)))
		return -EIO;

	return count;
}

static ssize_t
steamdeck_hwmon_simple_show(struct device *dev, char *buf,
			    const char *method)
{
	struct steamdeck_hwmon *sd = dev_get_drvdata(dev);
	unsigned long value;

	value = steamdeck_hwmon_get(sd, method);
	if (value < 0)
		return value;

	return sprintf(buf, "%ld\n", value);
}

#define STEAMDECK_HWMON_ATTR_RW(_name, _set_method, _get_method,	\
				_upper_limit)				\
	static ssize_t _name##_show(struct device *dev,			\
				    struct device_attribute *attr,	\
				    char *buf)				\
	{								\
		return steamdeck_hwmon_simple_show(dev, buf,		\
						   _get_method);	\
	}								\
	static ssize_t _name##_store(struct device *dev,		\
				     struct device_attribute *attr,	\
				     const char *buf, size_t count)	\
	{								\
		return steamdeck_hwmon_simple_store(dev, buf, count,	\
						    _set_method,	\
						    _upper_limit);	\
	}								\
	static DEVICE_ATTR_RW(_name)

STEAMDECK_HWMON_ATTR_RW(max_battery_charge_level, "FCBL", "SFBL", 101);
STEAMDECK_HWMON_ATTR_RW(max_battery_charge_rate,  "CHGR", "GCHR", 101);

static struct attribute *steamdeck_hwmon_attributes[] = {
	&dev_attr_max_battery_charge_level.attr,
	&dev_attr_max_battery_charge_rate.attr,
	NULL
};

static const struct attribute_group steamdeck_hwmon_group = {
	.attrs = steamdeck_hwmon_attributes,
};

static const struct attribute_group *steamdeck_hwmon_groups[] = {
	&steamdeck_hwmon_group,
	NULL
};

static int steamdeck_hwmon_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct steamdeck_hwmon *sd;
	struct device *hwmon;

	sd = devm_kzalloc(dev, sizeof(*sd), GFP_KERNEL);
	if (!sd)
		return -ENOMEM;

	sd->adev = ACPI_COMPANION(dev->parent);
	hwmon = devm_hwmon_device_register_with_info(dev,
						     "steamdeck_hwmon",
						     sd,
						     &steamdeck_hwmon_chip_info,
						     steamdeck_hwmon_groups);
	if (IS_ERR(hwmon)) {
		dev_err(dev, "Failed to register HWMON device");
		return PTR_ERR(hwmon);
	}

	return 0;
}

static const struct platform_device_id steamdeck_hwmon_id_table[] = {
	{ .name = STEAMDECK_HWMON_NAME },
	{}
};
MODULE_DEVICE_TABLE(platform, steamdeck_hwmon_id_table);

static struct platform_driver steamdeck_hwmon_driver = {
	.probe = steamdeck_hwmon_probe,
	.driver = {
		.name = STEAMDECK_HWMON_NAME,
	},
	.id_table = steamdeck_hwmon_id_table,
};
module_platform_driver(steamdeck_hwmon_driver);

MODULE_AUTHOR("Andrey Smirnov <andrew.smirnov@gmail.com>");
MODULE_DESCRIPTION("Steam Deck EC sensors driver");
MODULE_LICENSE("GPL");
