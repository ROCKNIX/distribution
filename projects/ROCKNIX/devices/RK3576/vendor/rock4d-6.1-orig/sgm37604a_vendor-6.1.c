/*
 * SGM37604A Backlight Driver - Final Optimized Version
 * Optimized for Rockchip RK3588 Linux 6.1.84 BSP
 * Feature: System 100% (255) mapped to Hardware 70% (2866)
 */

#include <linux/module.h>
#include <linux/init.h>
#include <linux/i2c.h>
#include <linux/regmap.h>
#include <linux/slab.h>
#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/backlight.h>
#include <linux/gpio/consumer.h>
#include <linux/of.h>

#define SGM37604A_DEV_NAME "sgm37604a"

/* 硬件物理最大值为 4095 */
#define SGM37604A_MAX_HW_VAL            4095
/* 用户层标准最大值为 255 */
#define SGM37604A_MAX_USER_VAL          255
/* 限制物理输出上限为 70% */
#define SGM37604A_LIMIT_PERCENT         70

/* Register Map */
#define SGM37604A_REG_LED_CTRL          0x10
#define SGM37604A_REG_MODE_CTRL         0x11
#define SGM37604A_REG_BRIGHTNESS_MSB    0x19
#define SGM37604A_REG_BRIGHTNESS_LSB    0x1A
#define SGM37604A_REG_CURRENT_CTRL      0x1B

struct sgm37604a_data {
    struct device *dev;
    struct regmap *regmap;
    struct backlight_device *bl;
    struct gpio_desc *en_gpio;
    
    u8 led_channels;
    u8 max_current;
    bool powered_on;
};

static const struct regmap_config sgm37604a_regmap_config = {
    .reg_bits = 8,
    .val_bits = 8,
    .max_register = 0x1F,
    .cache_type = REGCACHE_RBTREE,
};

/* 芯片上电序列 */
static int sgm37604a_hw_init(struct sgm37604a_data *chip)
{
    int ret;

    /* 1. 拉高 EN */
    if (chip->en_gpio) {
        gpiod_set_value_cansleep(chip->en_gpio, 1);
        msleep(50); 
    }

    /* 2. 写入配置 */
    ret = regmap_write(chip->regmap, SGM37604A_REG_MODE_CTRL, 0x00);
    ret |= regmap_write(chip->regmap, SGM37604A_REG_LED_CTRL, chip->led_channels);
    ret |= regmap_write(chip->regmap, SGM37604A_REG_CURRENT_CTRL, chip->max_current);

    if (ret) {
        dev_err(chip->dev, "Failed to init hardware registers\n");
        return ret;
    }

    chip->powered_on = true;
    return 0;
}

static int sgm37604a_update_status(struct backlight_device *bl)
{
    struct sgm37604a_data *chip = bl_get_data(bl);
    int brightness = bl->props.brightness;
    u32 hw_val;
    u32 target_hw_limit;
    u8 lsb, msb;
    int ret;

    /* 处理系统休眠或屏幕 Blank */
    if (backlight_is_blank(bl))
        brightness = 0;

    if (brightness == 0) {
        regmap_write(chip->regmap, SGM37604A_REG_BRIGHTNESS_LSB, 0x00);
        regmap_write(chip->regmap, SGM37604A_REG_BRIGHTNESS_MSB, 0x00);
        if (chip->en_gpio)
            gpiod_set_value_cansleep(chip->en_gpio, 0);
        chip->powered_on = false;
        return 0;
    }

    /* 保证驱动已上电 */
    if (!chip->powered_on) {
        ret = sgm37604a_hw_init(chip);
        if (ret) return ret;
    }

    /* * 核心逻辑修改：
     * 计算硬件限制值：4095 * 70 / 100 = 2866
     * 线性映射：将用户 0-255 映射到硬件 0-2866
     */
    target_hw_limit = (SGM37604A_MAX_HW_VAL * SGM37604A_LIMIT_PERCENT) / 100;
    hw_val = (u32)brightness * target_hw_limit / SGM37604A_MAX_USER_VAL;

    /* 边界检查 */
    if (hw_val > target_hw_limit) hw_val = target_hw_limit;
    if (hw_val < 16) hw_val = 16; /* 防止极低亮度闪烁 */

    lsb = (0xF << 4) | (hw_val & 0x00F);
    msb = (hw_val >> 4) & 0xFF;

    regmap_write(chip->regmap, SGM37604A_REG_BRIGHTNESS_LSB, lsb);
    regmap_write(chip->regmap, SGM37604A_REG_BRIGHTNESS_MSB, msb);

    return 0;
}

static const struct backlight_ops sgm37604a_bl_ops = {
    .options        = BL_CORE_SUSPENDRESUME,
    .update_status  = sgm37604a_update_status,
};

static int sgm37604a_probe(struct i2c_client *client)
{
    struct device *dev = &client->dev;
    struct sgm37604a_data *chip;
    struct backlight_properties props;
    u32 val32;
    int ret;

    chip = devm_kzalloc(dev, sizeof(*chip), GFP_KERNEL);
    if (!chip) return -ENOMEM;
    chip->dev = dev;

    chip->regmap = devm_regmap_init_i2c(client, &sgm37604a_regmap_config);
    if (IS_ERR(chip->regmap)) return PTR_ERR(chip->regmap);

    /* 获取设备树参数 */
    if (device_property_read_u32(dev, "sgmicro,led-channels", &val32) == 0)
        chip->led_channels = (u8)val32;
    else
        chip->led_channels = 0x07;

    if (device_property_read_u32(dev, "sgmicro,max-current", &val32) == 0)
        chip->max_current = (u8)val32;
    else
        chip->max_current = 0x1F; /* 默认最大电流配置 */

    chip->en_gpio = devm_gpiod_get_optional(dev, "enable", GPIOD_OUT_LOW);

    /* 配置 Backlight 属性 */
    memset(&props, 0, sizeof(props));
    props.type = BACKLIGHT_RAW;
    props.max_brightness = SGM37604A_MAX_USER_VAL; // 255
    
    if (device_property_read_u32(dev, "default-brightness", &val32) == 0)
        props.brightness = val32;
    else
        props.brightness = 128; // 默认 50%

    chip->bl = devm_backlight_device_register(dev, SGM37604A_DEV_NAME,
                                              dev, chip,
                                              &sgm37604a_bl_ops, &props);
    if (IS_ERR(chip->bl)) return PTR_ERR(chip->bl);

    /* 强制同步一次，开机即亮 */
    backlight_update_status(chip->bl);

    i2c_set_clientdata(client, chip);
    return 0;
}

static const struct of_device_id sgm37604a_of_match[] = {
    { .compatible = "sgmicro,sgm37604a" },
    { }
};
MODULE_DEVICE_TABLE(of, sgm37604a_of_match);

static struct i2c_driver sgm37604a_i2c_driver = {
    .driver = {
        .name = SGM37604A_DEV_NAME,
        .of_match_table = sgm37604a_of_match,
    },
    .probe = sgm37604a_probe,
};
module_i2c_driver(sgm37604a_i2c_driver);

MODULE_AUTHOR("Custom Backlight Driver");
MODULE_DESCRIPTION("SGM37604A Backlight Driver with 70% Limit");
MODULE_LICENSE("GPL");
