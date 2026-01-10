// SPDX-License-Identifier: GPL-2.0-only
//
// aw87391.c  --  AW87391 amplifier shim driver
//
// Very basic register poker to enable/disable speaker amplifiers
//

#include <linux/gpio/consumer.h>
#include <linux/i2c.h>
#include <linux/module.h>
#include <linux/regmap.h>
#include <linux/regulator/consumer.h>
#include <sound/soc.h>

struct aw87391_regval {
	u8 reg;
	u8 val;
};

struct aw87391_priv {
	struct regmap *regmap;
	struct gpio_desc *enable_gpiod;
	struct regulator *vcc;
	bool initialized;
	bool powered;
};

static const struct aw87391_regval aw87391_init_reg[] = {
	{ 0x02, 0x08 },
	{ 0x03, 0x00 },
	{ 0x04, 0x45 },
	{ 0x05, 0x4e },
};

static const struct aw87391_regval aw87391_on_reg[] = {
	{ 0x01, 0x3f },
};

static const struct aw87391_regval aw87391_off_reg[] = {
	{ 0x01, 0x00 },
};

static const struct regmap_config aw87391_regmap_config = {
	.val_bits = 8,
	.reg_bits = 8,
	.max_register = 0x7f,
	.cache_type = REGCACHE_NONE,
};

static int aw87391_apply_seq(struct aw87391_priv *aw,
			     const struct aw87391_regval *seq,
			     size_t count)
{
	size_t i;
	int ret;

	for (i = 0; i < count; i++) {
		ret = regmap_write(aw->regmap, seq[i].reg, seq[i].val);
		if (ret)
			return ret;
	}

	return 0;
}

static int aw87391_enable(struct aw87391_priv *aw)
{
	int ret;

	if (aw->powered)
		return 0;

	if (aw->vcc) {
		ret = regulator_enable(aw->vcc);
		if (ret)
			return ret;
	}

	if (aw->enable_gpiod) {
		gpiod_set_value_cansleep(aw->enable_gpiod, 1);
		usleep_range(1000, 2000);
	}

	if (!aw->initialized) {
		ret = aw87391_apply_seq(aw, aw87391_init_reg,
					ARRAY_SIZE(aw87391_init_reg));
		if (ret)
			goto err_power;

		aw->initialized = true;
	}

	ret = aw87391_apply_seq(aw, aw87391_on_reg,
				ARRAY_SIZE(aw87391_on_reg));
	if (ret)
		goto err_power;

	aw->powered = true;

	return 0;

err_power:
	if (aw->enable_gpiod) {
		gpiod_set_value_cansleep(aw->enable_gpiod, 0);
		usleep_range(1000, 2000);
	}

	if (aw->vcc)
		regulator_disable(aw->vcc);

	aw->initialized = false;

	return ret;
}

static int aw87391_disable(struct aw87391_priv *aw)
{
	int ret;

	if (!aw->powered)
		return 0;

	ret = aw87391_apply_seq(aw, aw87391_off_reg,
				ARRAY_SIZE(aw87391_off_reg));
	if (ret)
		return ret;

	if (aw->enable_gpiod) {
		gpiod_set_value_cansleep(aw->enable_gpiod, 0);
		usleep_range(1000, 2000);
	}

	if (aw->vcc)
		regulator_disable(aw->vcc);

	if (aw->enable_gpiod || aw->vcc)
		aw->initialized = false;

	aw->powered = false;

	return 0;
}

static int aw87391_suspend(struct device *dev)
{
	struct aw87391_priv *aw = dev_get_drvdata(dev);

	if (!aw)
		return 0;

	return aw87391_disable(aw);
}

static int aw87391_resume(struct device *dev)
{
	/* Keep amps off after resume; DAPM will re-enable when needed. */
	return 0;
}

static void aw87391_shutdown(struct i2c_client *i2c)
{
	struct aw87391_priv *aw = i2c_get_clientdata(i2c);

	if (!aw)
		return;

	aw87391_disable(aw);
}

static SIMPLE_DEV_PM_OPS(aw87391_pm_ops, aw87391_suspend, aw87391_resume);

static int aw87391_drv_event(struct snd_soc_dapm_widget *w,
			     struct snd_kcontrol *kcontrol, int event)
{
	struct snd_soc_component *component = snd_soc_dapm_to_component(w->dapm);
	struct aw87391_priv *aw = snd_soc_component_get_drvdata(component);

	switch (event) {
	case SND_SOC_DAPM_PRE_PMU:
		return aw87391_enable(aw);
	case SND_SOC_DAPM_POST_PMD:
		return aw87391_disable(aw);
	default:
		return 0;
	}
}

static const struct snd_soc_dapm_widget aw87391_dapm_widgets[] = {
	SND_SOC_DAPM_INPUT("IN"),
	SND_SOC_DAPM_PGA_E("SPK PA", SND_SOC_NOPM, 0, 0, NULL, 0,
			   aw87391_drv_event,
			   SND_SOC_DAPM_PRE_PMU | SND_SOC_DAPM_POST_PMD),
	SND_SOC_DAPM_OUTPUT("OUT"),
};

static const struct snd_soc_dapm_route aw87391_dapm_routes[] = {
	{ "SPK PA", NULL, "IN" },
	{ "OUT", NULL, "SPK PA" },
};

static const struct snd_soc_component_driver aw87391_component_driver = {
	.dapm_widgets = aw87391_dapm_widgets,
	.num_dapm_widgets = ARRAY_SIZE(aw87391_dapm_widgets),
	.dapm_routes = aw87391_dapm_routes,
	.num_dapm_routes = ARRAY_SIZE(aw87391_dapm_routes),
};

static int aw87391_i2c_probe(struct i2c_client *i2c)
{
	struct aw87391_priv *aw;

	aw = devm_kzalloc(&i2c->dev, sizeof(*aw), GFP_KERNEL);
	if (!aw)
		return -ENOMEM;

	aw->regmap = devm_regmap_init_i2c(i2c, &aw87391_regmap_config);
	if (IS_ERR(aw->regmap))
		return dev_err_probe(&i2c->dev, PTR_ERR(aw->regmap),
				     "failed to init regmap\n");

	aw->enable_gpiod = devm_gpiod_get_optional(&i2c->dev, "enable",
						   GPIOD_OUT_LOW);
	if (IS_ERR(aw->enable_gpiod))
		return dev_err_probe(&i2c->dev, PTR_ERR(aw->enable_gpiod),
				     "failed to get enable gpio\n");

	aw->vcc = devm_regulator_get_optional(&i2c->dev, "vcc");
	if (IS_ERR(aw->vcc)) {
		if (PTR_ERR(aw->vcc) == -ENODEV)
			aw->vcc = NULL;
		else
			return dev_err_probe(&i2c->dev, PTR_ERR(aw->vcc),
					     "failed to get vcc regulator\n");
	}

	i2c_set_clientdata(i2c, aw);

	return devm_snd_soc_register_component(&i2c->dev,
					       &aw87391_component_driver,
					       NULL, 0);
}

static const struct i2c_device_id aw87391_i2c_id[] = {
	{ "aw87391" },
	{ }
};
MODULE_DEVICE_TABLE(i2c, aw87391_i2c_id);

static const struct of_device_id aw87391_of_match[] = {
	{ .compatible = "aw,aw87391-left" },
	{ .compatible = "aw,aw87391-right" },
	{ .compatible = "awinic,aw87391" },
	{ }
};
MODULE_DEVICE_TABLE(of, aw87391_of_match);

static struct i2c_driver aw87391_i2c_driver = {
	.driver = {
		.name = "aw87391",
		.of_match_table = aw87391_of_match,
		.pm = &aw87391_pm_ops,
	},
	.probe = aw87391_i2c_probe,
	.shutdown = aw87391_shutdown,
	.id_table = aw87391_i2c_id,
};
module_i2c_driver(aw87391_i2c_driver);

MODULE_DESCRIPTION("ASoC AW87391 PA Driver");
MODULE_LICENSE("GPL v2");
