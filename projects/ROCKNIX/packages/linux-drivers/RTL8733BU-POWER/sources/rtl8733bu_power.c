// SPDX-License-Identifier: GPL-2.0-only
/*
 * RTL8733BU WiFi/BT power control driver
 *
 * Controls the power enable GPIO of the RTL8733BU combo chip via rfkill.
 * Registers both RFKILL_TYPE_WLAN and RFKILL_TYPE_BLUETOOTH so the stack
 * (wifictl, bluetooth settings) can control WiFi and BT independently.  Power
 * is kept on if either WiFi or BT is unblocked; power is cut only when both
 * are blocked (maximum battery when both are off).  Uses the same GPIO as
 * the original vcc_wifi regulator (enable-active-low).
 */

#include <linux/gpio/consumer.h>
#include <linux/module.h>
#include <linux/mod_devicetable.h>
#include <linux/platform_device.h>
#include <linux/rfkill.h>

struct rtl8733bu_power {
	struct gpio_desc *enable_gpio;
	struct rfkill *rfkill_wlan;
	struct rfkill *rfkill_bt;
	bool wlan_blocked;
	bool bt_blocked;
};

static void rtl8733bu_power_update_gpio(struct rtl8733bu_power *power)
{
	/* Power on if at least one of WiFi or BT is unblocked. */
	bool on = !power->wlan_blocked || !power->bt_blocked;

	/*
	 * gpiod handles active-low: gpiod_set_value(1) = assert = power on,
	 * gpiod_set_value(0) = deassert = power off.
	 */
	gpiod_set_value_cansleep(power->enable_gpio, on ? 1 : 0);
}

static int rtl8733bu_power_set_block_wlan(void *data, bool blocked)
{
	struct rtl8733bu_power *power = data;

	power->wlan_blocked = blocked;
	rtl8733bu_power_update_gpio(power);
	return 0;
}

static int rtl8733bu_power_set_block_bt(void *data, bool blocked)
{
	struct rtl8733bu_power *power = data;

	power->bt_blocked = blocked;
	rtl8733bu_power_update_gpio(power);
	return 0;
}

static const struct rfkill_ops rtl8733bu_power_rfkill_ops_wlan = {
	.set_block = rtl8733bu_power_set_block_wlan,
};

static const struct rfkill_ops rtl8733bu_power_rfkill_ops_bt = {
	.set_block = rtl8733bu_power_set_block_bt,
};

static int rtl8733bu_power_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct rtl8733bu_power *power;
	int ret;

	power = devm_kzalloc(dev, sizeof(*power), GFP_KERNEL);
	if (!power)
		return -ENOMEM;

	power->enable_gpio = devm_gpiod_get(dev, "enable", GPIOD_OUT_HIGH);
	if (IS_ERR(power->enable_gpio)) {
		ret = PTR_ERR(power->enable_gpio);
		dev_err(dev, "failed to get enable GPIO: %d\n", ret);
		return ret;
	}

	power->wlan_blocked = false;
	power->bt_blocked = false;
	rtl8733bu_power_update_gpio(power);

	power->rfkill_wlan = rfkill_alloc("rtl8733bu wifi", dev, RFKILL_TYPE_WLAN,
					  &rtl8733bu_power_rfkill_ops_wlan, power);
	if (!power->rfkill_wlan)
		return -ENOMEM;
	rfkill_set_states(power->rfkill_wlan, false, false);
	ret = rfkill_register(power->rfkill_wlan);
	if (ret) {
		dev_err(dev, "failed to register rfkill wlan: %d\n", ret);
		rfkill_destroy(power->rfkill_wlan);
		return ret;
	}

	power->rfkill_bt = rfkill_alloc("rtl8733bu bluetooth", dev, RFKILL_TYPE_BLUETOOTH,
					&rtl8733bu_power_rfkill_ops_bt, power);
	if (!power->rfkill_bt) {
		ret = -ENOMEM;
		goto err_unregister_wlan;
	}
	rfkill_set_states(power->rfkill_bt, false, false);
	ret = rfkill_register(power->rfkill_bt);
	if (ret) {
		dev_err(dev, "failed to register rfkill bt: %d\n", ret);
		rfkill_destroy(power->rfkill_bt);
		goto err_unregister_wlan;
	}

	platform_set_drvdata(pdev, power);
	dev_info(dev, "rtl8733bu-power: WiFi/BT power via rfkill (power off when both blocked)\n");
	return 0;

err_unregister_wlan:
	rfkill_unregister(power->rfkill_wlan);
	rfkill_destroy(power->rfkill_wlan);
	return ret;
}

static void rtl8733bu_power_remove(struct platform_device *pdev)
{
	struct rtl8733bu_power *power = platform_get_drvdata(pdev);

	if (!power)
		return;
	if (power->rfkill_bt) {
		rfkill_unregister(power->rfkill_bt);
		rfkill_destroy(power->rfkill_bt);
	}
	if (power->rfkill_wlan) {
		rfkill_unregister(power->rfkill_wlan);
		rfkill_destroy(power->rfkill_wlan);
	}
}

static const struct of_device_id rtl8733bu_power_of_match[] = {
	{ .compatible = "rockchip,rtl8733bu-power" },
	{ }
};
MODULE_DEVICE_TABLE(of, rtl8733bu_power_of_match);

static struct platform_driver rtl8733bu_power_driver = {
	.probe  = rtl8733bu_power_probe,
	.remove = rtl8733bu_power_remove,
	.driver = {
		.name = "rtl8733bu-power",
		.of_match_table = rtl8733bu_power_of_match,
	},
};
module_platform_driver(rtl8733bu_power_driver);

MODULE_DESCRIPTION("RTL8733BU WiFi/BT power via rfkill (WLAN+BT); power off when both blocked");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("ROCKNIX");
