/* drivers/input/touchscreen/sec_ts.c
 *
 * Copyright (C) 2016 Samsung Electronics Co., Ltd.
 * http://www.samsungsemi.com/
 *
 * Core file for Samsung TSC driver
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */
#include <asm/fb.h>
#include <linux/notifier.h>
#include <linux/delay.h>

#ifndef FB_EARLY_EVENT_BLANK
	#define FB_EARLY_EVENT_BLANK 0x10  // 通常的值是 0x10 (16)
#endif

#include <linux/firmware.h>
#include <linux/gpio.h>
#include <linux/i2c.h>
#include <linux/input.h>
#include <linux/input/mt.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/regulator/consumer.h>
#include <linux/slab.h>
#include <linux/wakelock.h>

#ifdef SAMSUNG_PROJECT
#include <linux/sec_sysfs.h>
#endif
#include <linux/irq.h>
#include <linux/of_gpio.h>
#include <linux/time.h>
#if defined(CONFIG_FB)
#include <linux/fb.h>
#include <linux/notifier.h>
#elif defined(CONFIG_HAS_EARLYSUSPEND)
#include <linux/earlysuspend.h>
#endif

#include "sec_ts.h"
#ifdef CONFIG_INPUT_PRESSURE
#include "../../pressure/pressure_func.h"
#endif

//#define SEC_TS_WAKEUP_GESTURE
struct sec_ts_data *tsp_data;

#ifdef SEC_TS_WAKEUP_GESTURE
static u32 keycode;
extern unsigned int gesture_enable;
void (*handle_sec)(u8) = 0;

void sec_ts_gesture_state(u8 gesture_state) {
	if (gesture_state != 0) {
		gesture_enable = 1;
		tsp_data->lowpower_status = TO_LOWPOWER_MODE;
	} else {
		gesture_enable = 0;
		tsp_data->lowpower_status = TO_TOUCH_MODE;
	}
	printk("[sec_ts]gesture_enable is %d\n", gesture_enable);
}

const uint16_t wakeup_gesture_key[] = {
		DOUBLE_TAP,			// GESTURE_DOUBLE_CLICK
		UNICODE_E,			// GESTURE_WORD_e
		UNICODE_O,			// GESTURE_WORD_O
		UNICODE_W,			// GESTURE_WORD_W
		UNICODE_M,			// GESTURE_WORD_M
		UNICODE_V_DOWN, // GESTURE_WORD_V
		UNICODE_S,			// GESTURE_WORD_S
		UNICODE_Z,			// GESTURE_WORD_Z
		UNICODE_C,			// GESTURE_WORD_C
		SWIPE_Y_UP,			// GESTURE_SLIDE_UP
		SWIPE_Y_DOWN,		// GESTURE_SLIDE_DOWN
		SWIPE_X_RIGHT,	// GESTURE_SLIDE_RIGHT
		SWIPE_X_LEFT,		// GESTURE_SLIDE_LEFT

};

#define GESTURE_DOUBLE_CLICK 0
#define GESTURE_WORD_e 1
#define GESTURE_WORD_O 2
#define GESTURE_WORD_W 3
#define GESTURE_WORD_M 4
#define GESTURE_WORD_V 6
#define GESTURE_WORD_S 7
#define GESTURE_WORD_Z 8
#define GESTURE_WORD_C 9
#define GESTURE_SLIDE_UP 10
#define GESTURE_SLIDE_DOWN 11
#define GESTURE_SLIDE_RIGHT 12
#define GESTURE_SLIDE_LEFT 13

static struct wake_lock gesture_wakelock;
#endif

struct device *sec_ts_dev;  // 去掉 static
EXPORT_SYMBOL(sec_ts_dev);
#ifndef SAMSUNG_PROJECT
struct class *sec_class;
static int sec_class_create(void) {
	sec_class = class_create(THIS_MODULE, "sec");
	if (IS_ERR_OR_NULL(sec_class)) {
		pr_err("%s:Failed to create class(sec) %ld\n", __func__,
					 PTR_ERR(sec_class));
		return PTR_ERR(sec_class);
	}
	return 0;
}
#endif

extern int32_t sec_ts_test_proc_init(struct sec_ts_data *ts);

struct sec_ts_fw_file {
	u8 *data;
	u32 pos;
	size_t size;
};

struct sec_ts_event_status {
	u8 tchsta : 3;
	u8 ttype : 3;
	u8 eid : 2;
	u8 sid;
	u8 buff2;
	u8 buff3;
	u8 buff4;
	u8 buff5;
	u8 buff6;
	u8 buff7;
} __packed;

struct sec_ts_gesture_status {
	u8 stype : 6;
	u8 eid : 2;
	u8 gesture;
	u8 y_4_2 : 3;
	u8 x : 5;
	u8 h_4 : 1;
	u8 w : 5;
	u8 y_1_0 : 2;
	u8 reserved : 4;
	u8 h_3_0 : 4;
} __packed;

struct sec_ts_exp_fn {
	int (*func_init)(void *device_data);
	void (*func_remove)(void);
};

#if defined(CONFIG_FB)
static int __maybe_unused fb_notifier_callback(struct notifier_block *self,
																unsigned long event, void *data);
/*#elif defined(CONFIG_HAS_EARLYSUSPEND)*/
/*static void sec_ts_early_suspend(struct early_suspend *h);*/
/*static void sec_ts_late_resume(struct early_suspend *h);*/
#endif

static struct workqueue_struct *sec_fwu_wq;
#if defined(CONFIG_FB)
static int sec_ts_input_open(struct input_dev *dev);
static void sec_ts_input_close(struct input_dev *dev);
static int sec_ts_start_device(struct sec_ts_data *ts);
#endif
static int sec_ts_stop_device(struct sec_ts_data *ts);
static void sec_ts_reset_work(struct work_struct *work);
static void sec_ts_fwupdate_work(struct work_struct *work);


u8 lv1cmd;
u8 *read_lv1_buff;
static int lv1_readsize;
static int lv1_readremain;
static int lv1_readoffset;

static ssize_t sec_ts_reg_store(struct device *dev,
																struct device_attribute *attr, const char *buf,
																size_t size);
static ssize_t sec_ts_regreadsize_store(struct device *dev,
																				struct device_attribute *attr,
																				const char *buf, size_t size);
static inline ssize_t sec_ts_store_error(struct device *dev,
																				 struct device_attribute *attr,
																				 const char *buf, size_t count);
static ssize_t sec_ts_enter_recovery_store(struct device *dev,
																					 struct device_attribute *attr,
																					 const char *buf, size_t size);

static ssize_t sec_ts_regread_show(struct device *dev,
																	 struct device_attribute *attr, char *buf);
static ssize_t sec_ts_gesture_status_show(struct device *dev,
																					struct device_attribute *attr,
																					char *buf);
static inline ssize_t
sec_ts_show_error(struct device *dev, struct device_attribute *attr, char *buf);

static DEVICE_ATTR(sec_ts_reg, 0660, NULL, sec_ts_reg_store);
static DEVICE_ATTR(sec_ts_regreadsize, 0660, NULL, sec_ts_regreadsize_store);
static DEVICE_ATTR(sec_ts_enter_recovery, 0660, NULL,
									 sec_ts_enter_recovery_store);
static DEVICE_ATTR(sec_ts_regread, 0660, sec_ts_regread_show, NULL);
static DEVICE_ATTR(sec_ts_gesture_status, 0660, sec_ts_gesture_status_show,
									 NULL);

static struct attribute *cmd_attributes[] = {
		&dev_attr_sec_ts_reg.attr,
		&dev_attr_sec_ts_regreadsize.attr,
		&dev_attr_sec_ts_enter_recovery.attr,
		&dev_attr_sec_ts_regread.attr,
		&dev_attr_sec_ts_gesture_status.attr,
		NULL,
};

static struct attribute_group cmd_attr_group = {
		.attrs = cmd_attributes,
};

static inline ssize_t sec_ts_show_error(struct device *dev,
																				struct device_attribute *attr,
																				char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);

	input_err(true, &ts->client->dev, "sec_ts :%s read only function, %s\n",
						__func__, attr->attr.name);
	return -EPERM;
}

static inline ssize_t sec_ts_store_error(struct device *dev,
																				 struct device_attribute *attr,
																				 const char *buf, size_t count) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);

	input_err(true, &ts->client->dev, "sec_ts :%s write only function, %s\n",
						__func__, attr->attr.name);
	return -EPERM;
}

int sec_ts_i2c_write(struct sec_ts_data *ts, u8 reg, u8 *data, int len) {
	u8 buf[I2C_WRITE_BUFFER_SIZE + 1];
	int ret;
	unsigned char retry;
#ifdef POR_AFTER_I2C_RETRY
	int retry_cnt = 0;
#endif
	struct i2c_msg msg;

	// input_info(true, &ts->client->dev,"%s\n", __func__);

	if (len > I2C_WRITE_BUFFER_SIZE) {
		input_err(true, &ts->client->dev,
							"sec_ts_i2c_write len is larger than buffer size\n");
		return -1;
	}

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_err(true, &ts->client->dev, "%s: fail to POWER_STATUS=OFF\n",
							__func__);
		goto err;
	}

	buf[0] = reg;
	memcpy(buf + 1, data, len);

	msg.addr = ts->client->addr;
	msg.flags = 0;
	msg.len = len + 1;
	msg.buf = buf;

#ifdef POR_AFTER_I2C_RETRY
retry_fail:
#endif
	mutex_lock(&ts->i2c_mutex);
	for (retry = 0; retry < SEC_TS_I2C_RETRY_CNT; retry++) {
		ret = i2c_transfer(ts->client->adapter, &msg, 1);
		if (ret == 1)
			break;

		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev,
								"%s: fail to POWER_STATUS=OFF ret = %d\n", __func__, ret);
			mutex_unlock(&ts->i2c_mutex);
			goto err;
		}
		if (retry > 0)
			sec_ts_delay(10);
	}
	mutex_unlock(&ts->i2c_mutex);
	if (retry == SEC_TS_I2C_RETRY_CNT) {
		input_err(true, &ts->client->dev, "%s: I2C write over retry limit\n",
							__func__);
#ifdef POR_AFTER_I2C_RETRY
		schedule_delayed_work(&ts->reset_work,
													msecs_to_jiffies(TOUCH_RESET_DWORK_TIME));

		if (!retry_cnt++)
			goto retry_fail;
#endif
		ret = -EIO;
	}

	if (ret == 1)
		return 0;
err:
	return -EIO;
}

int sec_ts_i2c_read(struct sec_ts_data *ts, u8 reg, u8 *data, int len) {
	u8 buf[4];
	int ret;
	unsigned char retry;
#ifdef POR_AFTER_I2C_RETRY
	int retry_cnt = 0;
#endif
	struct i2c_msg msg[2];

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_err(true, &ts->client->dev, "%s: fail to POWER_STATUS=OFF\n",
							__func__);
		return -EIO;
	}

	mutex_lock(&ts->i2c_mutex);

	buf[0] = reg;
	msg[0].addr = ts->client->addr;
	msg[0].flags = 0;
	msg[0].len = 1;
	msg[0].buf = buf;

#ifdef POR_AFTER_I2C_RETRY
retry_fail_write:
#endif

	for (retry = 0; retry < SEC_TS_I2C_RETRY_CNT; retry++) {
		ret = i2c_transfer(ts->client->adapter, msg, 1);
		if (ret == 1)
			break;

		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev,
								"%s: fail to POWER_STATUS=OFF ret = %d\n", __func__, ret);
			mutex_unlock(&ts->i2c_mutex);
			goto err;
		}
		if (retry > 0)
			sec_ts_delay(10);
	}

	if (retry == SEC_TS_I2C_RETRY_CNT) {
		input_err(true, &ts->client->dev, "%s: I2C write over retry limit\n",
							__func__);
#ifdef POR_AFTER_I2C_RETRY
		schedule_delayed_work(&ts->reset_work,
													msecs_to_jiffies(TOUCH_RESET_DWORK_TIME));

		if (!retry_cnt++)
			goto retry_fail_write;
#endif
	}

	if (ret != 1) {
		mutex_unlock(&ts->i2c_mutex);
		goto err;
	}
	udelay(100);

	msg[0].addr = ts->client->addr;
	msg[0].flags = I2C_M_RD;
	msg[0].len = len;
	msg[0].buf = data;

#ifdef POR_AFTER_I2C_RETRY
	retry_cnt = 0;
#endif

	for (retry = 0; retry < SEC_TS_I2C_RETRY_CNT; retry++) {
		ret = i2c_transfer(ts->client->adapter, msg, 1);
		if (ret == 1)
			break;

		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev,
								"%s: fail to POWER_STATUS=OFF ret = %d\n", __func__, ret);
			mutex_unlock(&ts->i2c_mutex);
			goto err;
		}
		if (retry > 0)
			sec_ts_delay(10);
	}

	if (retry == SEC_TS_I2C_RETRY_CNT) {
		input_err(true, &ts->client->dev, "%s: I2C read over retry limit\n",
							__func__);
#ifdef POR_AFTER_I2C_RETRY
		schedule_delayed_work(&ts->reset_work,
													msecs_to_jiffies(TOUCH_RESET_DWORK_TIME));

		if (!retry_cnt++)
			goto retry_fail_write;
#endif
		ret = -EIO;
	}

	mutex_unlock(&ts->i2c_mutex);
	return ret;
err:
	return -EIO;
}

#if defined(CONFIG_SEC_DEBUG_TSP_LOG)
struct delayed_work *p_ghost_check;

static void sec_ts_check_rawdata(struct work_struct *work) {
	struct sec_ts_data *ts =
			container_of(work, struct sec_ts_data, ghost_check.work);

	if (ts->tsp_dump_lock == 1) {
		input_err(true, &ts->client->dev, "%s, ignored ## already checking..\n",
							__func__);
		return;
	}
	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_err(true, &ts->client->dev, "%s, ignored ## IC is power off\n",
							__func__);
		return;
	}

	ts->tsp_dump_lock = 1;
	input_err(true, &ts->client->dev, "%s, start ##\n", __func__);
	sec_ts_run_rawdata_all((void *)ts);
	msleep(100);

	input_err(true, &ts->client->dev, "%s, done ##\n", __func__);
	ts->tsp_dump_lock = 0;
}

void tsp_dump_sec(void) {
	pr_err("%s: sec_ts %s: start\n", SECLOG, __func__);

	if (p_ghost_check == NULL) {
		pr_err("sec_ts %s, ignored ## tsp probe fail!!\n", __func__);
		return;
	}
	schedule_delayed_work(p_ghost_check, msecs_to_jiffies(100));
}
#else
void tsp_dump_sec(void) { pr_err("sec_ts %s: not support\n", __func__); }
#endif

static int sec_ts_i2c_read_bulk(struct sec_ts_data *ts, u8 *data, int len) {
	int ret;
	unsigned char retry;
	struct i2c_msg msg;
#ifdef POR_AFTER_I2C_RETRY
	int retry_cnt = 0;
#endif

	msg.addr = ts->client->addr;
	msg.flags = I2C_M_RD;
	msg.len = len;
	msg.buf = data;

	mutex_lock(&ts->i2c_mutex);

#ifdef POR_AFTER_I2C_RETRY
retry_fail:
#endif
	for (retry = 0; retry < SEC_TS_I2C_RETRY_CNT; retry++) {
		ret = i2c_transfer(ts->client->adapter, &msg, 1);
		if (ret == 1)
			break;

		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev,
								"%s: fail to POWER_STATUS=OFF ret = %d\n", __func__, ret);
			mutex_unlock(&ts->i2c_mutex);
			goto err;
		}
	}

	mutex_unlock(&ts->i2c_mutex);

	if (retry == 10) {
		input_err(true, &ts->client->dev, "%s: I2C read over retry limit\n",
							__func__);
#ifdef POR_AFTER_I2C_RETRY
		schedule_delayed_work(&ts->reset_work,
													msecs_to_jiffies(TOUCH_RESET_DWORK_TIME));

		if (!retry_cnt++)
			goto retry_fail;
#endif
		ret = -EIO;
	}

	if (ret == 1)
		return 0;
err:
	return -EIO;
}

void sec_ts_delay(unsigned int ms) {
	if (ms < 20)
		usleep_range(ms * 1000, ms * 1000);
	else
		msleep(ms);
}

int sec_ts_wait_for_ready(struct sec_ts_data *ts, unsigned int ack) {
	int rc = -1;
	int retry = 0;
	u8 tBuff[SEC_TS_Event_Buff_Size];

	while (sec_ts_i2c_read(ts, SEC_TS_READ_ONE_EVENT, tBuff,
												 SEC_TS_Event_Buff_Size) > 0) {
		if (tBuff[0] == TYPE_STATUS_EVENT_ACK) {
			if (tBuff[1] == ack) {
				rc = 0;
				break;
			}
		}

		if (retry++ > SEC_TS_WAIT_RETRY_CNT) {
			input_err(true, &ts->client->dev, "%s: Time Over\n", __func__);
			break;
		}
		sec_ts_delay(20);
	}

	input_info(true, &ts->client->dev,
						 "%s: %02X, %02X, %02X, %02X, %02X, %02X, %02X, %02X [%d]\n",
						 __func__, tBuff[0], tBuff[1], tBuff[2], tBuff[3], tBuff[4],
						 tBuff[5], tBuff[6], tBuff[7], retry);

	return rc;
}

int sec_ts_read_calibration_report(struct sec_ts_data *ts) {
	int ret;
	u8 buf[5] = {0};

	buf[0] = SEC_TS_READ_CALIBRATION_REPORT;

	ret = sec_ts_i2c_read(ts, buf[0], &buf[1], 4);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: failed to read, %d\n", __func__,
							ret);
		return ret;
	}

	input_info(true, &ts->client->dev,
						 "%s: count:%d, pass count:%d, fail count:%d, status:0x%X\n",
						 __func__, buf[1], buf[2], buf[3], buf[4]);

	return buf[4];
}

#ifdef SEC_TS_WAKEUP_GESTURE
int sec_ts_wakeup_gesture_report(struct sec_ts_data *ts, uint8_t gesture_id) {
	input_info(true, &ts->client->dev, "%s: gesture_id = %d\n", __func__,
						 gesture_id);
	if (gesture_enable == 1) {
		switch (gesture_id) {
		case GESTURE_DOUBLE_CLICK:
			keycode = wakeup_gesture_key[0];
			input_info(true, &ts->client->dev,
								 "Gesture : Double Click, keycode=0x%x\n", keycode);
			break;
		case GESTURE_WORD_e:
			keycode = wakeup_gesture_key[1];
			input_info(true, &ts->client->dev, "Gesture : Word e, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_WORD_O:
			keycode = wakeup_gesture_key[2];
			input_info(true, &ts->client->dev, "Gesture : Word O, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_WORD_W:
			keycode = wakeup_gesture_key[3];
			input_info(true, &ts->client->dev, "Gesture : Word W, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_WORD_M:
			keycode = wakeup_gesture_key[4];
			input_info(true, &ts->client->dev, "Gesture : Word M, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_WORD_V:
			keycode = wakeup_gesture_key[5];
			input_info(true, &ts->client->dev, "Gesture : Word V, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_WORD_S:
			keycode = wakeup_gesture_key[6];
			input_info(true, &ts->client->dev, "Gesture : Word S, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_WORD_Z:
			keycode = wakeup_gesture_key[7];
			input_info(true, &ts->client->dev, "Gesture : Word Z, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_WORD_C:
			keycode = wakeup_gesture_key[8];
			input_info(true, &ts->client->dev, "Gesture : Word C, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_SLIDE_UP:
			keycode = wakeup_gesture_key[9];
			input_info(true, &ts->client->dev, "Gesture : Slide Up, keycode=0x%x\n",
								 keycode);
			break;
		case GESTURE_SLIDE_DOWN:
			input_info(true, &ts->client->dev, "Gesture : Slide Down, keycode=0x%x\n",
								 keycode);
			keycode = wakeup_gesture_key[10];
			break;
		case GESTURE_SLIDE_RIGHT:
			keycode = wakeup_gesture_key[11];
			input_info(true, &ts->client->dev,
								 "Gesture : Slide Right, keycode=0x%x\n", keycode);
			break;
		case GESTURE_SLIDE_LEFT:
			keycode = wakeup_gesture_key[12];
			input_info(true, &ts->client->dev, "Gesture : Slide Left, keycode=0x%x\n",
								 keycode);
			break;
		}
	}
	return keycode;
}
#endif

#define MAX_EVENT_COUNT 128
static void sec_ts_read_event(struct sec_ts_data *ts) {
	int ret;
	int is_event_remain;
	int t_id;
	int event_id;
	int read_event_count;
	u8 read_event_buff[SEC_TS_Event_Buff_Size];
#ifdef SEC_TS_WAKEUP_GESTURE
	u32 wakeup_code;
	struct sec_ts_event_status *p_event_status;
#endif
	struct sec_ts_event_coordinate *p_event_coord;

	struct sec_ts_coordinate coordinate;

	is_event_remain = 0;
	read_event_count = 0;
	ret = t_id = event_id = 0;

	memset(&coordinate, 0x00, sizeof(struct sec_ts_coordinate));

	/* repeat READ_ONE_EVENT until buffer is empty(No event) */
	do {
		ret = sec_ts_i2c_read(ts, SEC_TS_READ_ONE_EVENT, read_event_buff,
													SEC_TS_Event_Buff_Size);
		if (ret < 0) {
			ts->event_errcnt++;
			if (ts->event_errcnt > 10) {
				// disable_irq(ts->client->irq);
				if (ts->probe_done && ts->fw_workdone)
					sec_ts_release_all_finger(ts);
			}
			input_err(true, &ts->client->dev, "%s: i2c read one event failed\n",
								__func__);
			return;
		}
		ts->event_errcnt = 0;

		read_event_count++;
		if (read_event_count > MAX_EVENT_COUNT) {
			input_err(true, &ts->client->dev, "%s : event buffer overflow\n",
								__func__);

			/* write clear event stack command when read_event_count > MAX_EVENT_COUNT
			 */
			ret = sec_ts_i2c_write(ts, SEC_TS_CMD_CLEAR_EVENT_STACK, NULL, 0);
			if (ret < 0)
				input_err(true, &ts->client->dev, "%s: i2c write clear event failed\n",
									__func__);

			return;
		}

		event_id = read_event_buff[0] >> 6;
		switch (event_id) {
		case SEC_TS_Status_Event:
			if ((read_event_buff[0] == TYPE_STATUS_EVENT_ACK) &&
					(read_event_buff[1] == SEC_TS_ACK_BOOT_COMPLETE)) {
				if (ts->probe_done && ts->fw_workdone) {
					sec_ts_release_all_finger(ts);
				}

				if (read_event_buff[2] == 0x20) { /* watchdog reset flag */
					input_err(true, &ts->client->dev, "%s: watchdog reset\n", __func__);
				}
				input_err(true, &ts->client->dev, "%s: Ack&Boot Complete\n", __func__);
			}

			if (read_event_buff[0] > 0)
				input_info(true, &ts->client->dev,
									 "%s: STATUS %x %x %x %x %x %x %x %x\n", __func__,
									 read_event_buff[0], read_event_buff[1], read_event_buff[2],
									 read_event_buff[3], read_event_buff[4], read_event_buff[5],
									 read_event_buff[6], read_event_buff[7]);

			if ((read_event_buff[0] == TYPE_STATUS_EVENT_ERR) &&
					(read_event_buff[1] == SEC_TS_ERR_ESD)) {
				input_err(true, &ts->client->dev, "%s: ESD detected. run reset\n",
									__func__);
				schedule_work(&ts->reset_work.work);
			}
			coordinate.action = SEC_TS_Coordinate_Action_None;
			is_event_remain = 0;
			break;

		case SEC_TS_Coordinate_Event:
			p_event_coord = (struct sec_ts_event_coordinate *)read_event_buff;

			t_id = (p_event_coord->tid - 1);

			if (t_id < MAX_SUPPORT_TOUCH_COUNT) {
				coordinate.id = t_id;
				coordinate.action = p_event_coord->tchsta;
				coordinate.x = (p_event_coord->x_11_4 << 4) | (p_event_coord->x_3_0);
				coordinate.y = (p_event_coord->y_11_4 << 4) | (p_event_coord->y_3_0);
				coordinate.touch_width = p_event_coord->z;
				coordinate.ttype = p_event_coord->ttype & 0x7;
				coordinate.major = p_event_coord->major;
				coordinate.minor = p_event_coord->minor;
				coordinate.mcount = ts->coord[t_id].mcount;
				coordinate.palm = (coordinate.ttype == SEC_TS_TOUCHTYPE_PALM) ? 1 : 0;

				if ((t_id == SEC_TS_EVENTID_HOVER) &&
						(coordinate.ttype == SEC_TS_TOUCHTYPE_PROXIMITY) &&
						(coordinate.action == SEC_TS_Coordinate_Action_Release)) {
					input_mt_slot(ts->input_dev, 0);
					input_mt_report_slot_state(ts->input_dev, MT_TOOL_FINGER, false);
					input_dbg(true, &ts->client->dev,
										"%s: Hover - Release - tid=%d, touch_count=%d\n", __func__,
										t_id, ts->touch_count);
				} else if ((t_id == SEC_TS_EVENTID_HOVER) &&
									 (coordinate.ttype == SEC_TS_TOUCHTYPE_PROXIMITY)) {
					input_mt_slot(ts->input_dev, 0);
					input_mt_report_slot_state(ts->input_dev, MT_TOOL_FINGER, true);

					input_report_key(ts->input_dev, BTN_TOUCH, false);
					input_report_key(ts->input_dev, BTN_TOOL_FINGER, true);

					input_report_abs(ts->input_dev, ABS_MT_POSITION_X, coordinate.x);
					input_report_abs(ts->input_dev, ABS_MT_POSITION_Y, coordinate.y);
					input_report_abs(ts->input_dev, ABS_MT_DISTANCE,
													 coordinate.touch_width);

					if (coordinate.action == SEC_TS_Coordinate_Action_Press)
						input_dbg(true, &ts->client->dev,
											"%s: Hover - Press - tid=%d, touch_count=%d\n", __func__,
											t_id, ts->touch_count);
					else if (coordinate.action == SEC_TS_Coordinate_Action_Move)
						input_dbg(true, &ts->client->dev,
											"%s: Hover - Move - tid=%d, touch_count=%d\n", __func__,
											t_id, ts->touch_count);
				} else if (coordinate.ttype == SEC_TS_TOUCHTYPE_NORMAL ||
									 coordinate.ttype == SEC_TS_TOUCHTYPE_PALM ||
									 coordinate.ttype == SEC_TS_TOUCHTYPE_GLOVE) {
					if (coordinate.action == SEC_TS_Coordinate_Action_Release) {
						coordinate.touch_width = 0;
						/*coordinate.action = SEC_TS_Coordinate_Action_None;*/
						input_mt_slot(ts->input_dev, t_id);
						input_mt_report_slot_state(ts->input_dev, MT_TOOL_FINGER, 0);

						if (ts->touch_count > 0)
							ts->touch_count--;
						if (ts->touch_count == 0) {
							input_report_key(ts->input_dev, BTN_TOUCH, 0);
							input_report_key(ts->input_dev, BTN_TOOL_FINGER, 0);
						}
					} else if (coordinate.action == SEC_TS_Coordinate_Action_Press) {
						ts->touch_count++;
						input_mt_slot(ts->input_dev, t_id);
						input_mt_report_slot_state(ts->input_dev, MT_TOOL_FINGER,
																			 1 + (coordinate.palm << 1));
						input_report_key(ts->input_dev, BTN_TOUCH, 1);
						input_report_key(ts->input_dev, BTN_TOOL_FINGER, 1);

						input_report_abs(ts->input_dev, ABS_MT_POSITION_X, coordinate.x);
						input_report_abs(ts->input_dev, ABS_MT_POSITION_Y, coordinate.y);
						input_report_abs(ts->input_dev, ABS_MT_TOUCH_MAJOR,
														 coordinate.major);
						input_report_abs(ts->input_dev, ABS_MT_TOUCH_MINOR,
														 coordinate.minor);
#ifdef SEC_TS_SUPPORT_SEC_SWIPE
						input_report_abs(ts->input_dev, ABS_MT_PALM, coordinate.palm);
#endif

#ifdef CONFIG_SEC_FACTORY
						input_report_abs(ts->input_dev, ABS_MT_PRESSURE,
														 coordinate.touch_width);
#endif
					} else if (coordinate.action == SEC_TS_Coordinate_Action_Move) {
#ifdef CONFIG_TOUCHSCREN_SEC_TS_GLOVEMODE
						if ((coordinate.ttype == SEC_TS_TOUCHTYPE_GLOVE) &&
								!ts->touchkey_glove_mode_status) {
							ts->touchkey_glove_mode_status = true;
							input_report_switch(ts->input_dev, SW_GLOVE, 1);
						}
#endif
						input_mt_slot(ts->input_dev, t_id);
						input_mt_report_slot_state(ts->input_dev, MT_TOOL_FINGER, 1);
						input_report_key(ts->input_dev, BTN_TOUCH, 1);
						input_report_key(ts->input_dev, BTN_TOOL_FINGER, 1);

						input_report_abs(ts->input_dev, ABS_MT_POSITION_X, coordinate.x);
						input_report_abs(ts->input_dev, ABS_MT_POSITION_Y, coordinate.y);
						input_report_abs(ts->input_dev, ABS_MT_TOUCH_MAJOR,
														 coordinate.major);
						input_report_abs(ts->input_dev, ABS_MT_TOUCH_MINOR,
														 coordinate.minor);
#ifdef SEC_TS_SUPPORT_SEC_SWIPE
						input_report_abs(ts->input_dev, ABS_MT_PALM, coordinate.palm);
#endif
#ifdef CONFIG_SEC_FACTORY
						input_report_abs(ts->input_dev, ABS_MT_PRESSURE,
														 coordinate.touch_width);
#endif
						coordinate.mcount++;
					}

					memcpy(&ts->coord[t_id], &coordinate,
								 sizeof(struct sec_ts_coordinate));
				}
			} else {
				input_err(true, &ts->client->dev, "%s: tid(%d) is  out of range\n",
									__func__, t_id);
			}

			is_event_remain = 1;
			break;

		case SEC_TS_Gesture_Event:
#ifdef SEC_TS_WAKEUP_GESTURE
			p_event_status = (struct sec_ts_event_status *)read_event_buff;

			if ((p_event_status->eid == 0x02) && (p_event_status->tchsta == 0x01)) {
				struct sec_ts_gesture_status *p_gesture_status =
						(struct sec_ts_gesture_status *)read_event_buff;
				wakeup_code =
						sec_ts_wakeup_gesture_report(ts, p_gesture_status->gesture);
				input_info(true, &ts->client->dev, "%s: GESTURE  wakeup_code=0x%x\n",
									 __func__, wakeup_code);
				mz_gesture_report(ts->input_dev, keycode);
			}
			is_event_remain = 1;
			break;
#endif
		default:
			input_err(true, &ts->client->dev,
								"%s: unknown event  %x %x %x %x %x %x\n", __func__,
								read_event_buff[0], read_event_buff[1], read_event_buff[2],
								read_event_buff[3], read_event_buff[4], read_event_buff[5]);

			is_event_remain = 0;
			break;
		}

#if !defined(CONFIG_SAMSUNG_PRODUCT_SHIP)
		if (coordinate.action == SEC_TS_Coordinate_Action_Press)
			input_dbg(
					true, &ts->client->dev,
					"%s: [P] tID:%d, x:%d, y:%d, major:%d, minor:%d, tc:%d palm:%d\n",
					__func__, t_id, coordinate.x, coordinate.y, coordinate.major,
					coordinate.minor, ts->touch_count, coordinate.palm);
#else
		if (coordinate.action == SEC_TS_Coordinate_Action_Press)
			input_dbg(true, &ts->client->dev, "%s: [P] tID:%d, tc:%d\n", __func__,
								t_id, ts->touch_count);
#endif
		else if (coordinate.action == SEC_TS_Coordinate_Action_Release) {
#if !defined(CONFIG_SAMSUNG_PRODUCT_SHIP)
			input_dbg(true, &ts->client->dev, "%s: [R] tID:%d mc:%d tc:%d lx:%d "
																				 "ly:%d cal:0x%x(%X|%X), "
																				 "[SE%02X%02X%02X]\n",
								__func__, t_id, ts->coord[t_id].mcount, ts->touch_count,
								ts->coord[t_id].x, ts->coord[t_id].y, ts->cal_status, ts->nv,
								ts->cal_count, ts->plat_data->panel_revision,
								ts->plat_data->img_version_of_ic[2],
								ts->plat_data->img_version_of_ic[3]);
#else
			input_dbg(
					true, &ts->client->dev,
					"%s: [R] tID:%d mc:%d tc:%d cal:0x%x(%X|%X) [SE%02X%02X%02X]\n",
					__func__, t_id, ts->coord[t_id].mcount, ts->touch_count,
					ts->cal_status, ts->nv, ts->cal_count, ts->plat_data->panel_revision,
					ts->plat_data->img_version_of_ic[2],
					ts->plat_data->img_version_of_ic[3]);
#endif
			ts->coord[t_id].mcount = 0;
		}
	} while (is_event_remain);
	input_sync(ts->input_dev);
}

static irqreturn_t sec_ts_irq_thread(int irq, void *ptr) {
	struct sec_ts_data *ts;

	ts = (struct sec_ts_data *)ptr;

#ifdef SEC_TS_WAKEUP_GESTURE
	if (ts->lowpower_mode)
		wake_lock_timeout(&gesture_wakelock, msecs_to_jiffies(5000));
#endif
	sec_ts_read_event(ts);

	return IRQ_HANDLED;
}

int get_tsp_status(void) { return 0; }
EXPORT_SYMBOL(get_tsp_status);

int sec_ts_glove_mode_enables(struct sec_ts_data *ts, int mode) {
	int ret;

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_err(true, &ts->client->dev,
							"%s: fail to enable glove status, POWER_STATUS=OFF\n", __func__);
		goto glove_enable_err;
	}

	if (mode)
		ts->touch_functions = (ts->touch_functions | SEC_TS_BIT_SETFUNC_GLOVE |
													 SEC_TS_BIT_SETFUNC_MUTUAL);
	else
		ts->touch_functions = ((ts->touch_functions & (~SEC_TS_BIT_SETFUNC_GLOVE)) |
													 SEC_TS_BIT_SETFUNC_MUTUAL);

	ret = sec_ts_i2c_write(ts, SEC_TS_CMD_SET_TOUCHFUNCTION, &ts->touch_functions,
												 1);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: Failed to send command", __func__);
		goto glove_enable_err;
	}

	input_err(true, &ts->client->dev, "%s: %s, status =%x\n", __func__,
						(mode) ? "glove enable" : "glove disable", ts->touch_functions);

	return 0;

glove_enable_err:
	(mode)
			? (ts->touch_functions = SEC_TS_BIT_SETFUNC_GLOVE) |
						SEC_TS_BIT_SETFUNC_MUTUAL
			: (ts->touch_functions =
						 (ts->touch_functions & (~SEC_TS_BIT_SETFUNC_GLOVE)) |
						 SEC_TS_BIT_SETFUNC_MUTUAL);
	input_err(true, &ts->client->dev, "%s: %s, status =%x\n", __func__,
						(mode) ? "glove enable" : "glove disable", ts->touch_functions);
	return -EIO;
}
EXPORT_SYMBOL(sec_ts_glove_mode_enables);

int sec_ts_hover_enables(struct sec_ts_data *ts, int enables) {
	int ret;

	if (enables)
		ts->touch_functions = (ts->touch_functions | SEC_TS_BIT_SETFUNC_HOVER |
													 SEC_TS_BIT_SETFUNC_MUTUAL);
	else
		ts->touch_functions = ((ts->touch_functions & (~SEC_TS_BIT_SETFUNC_HOVER)) |
													 SEC_TS_BIT_SETFUNC_MUTUAL);

	ret = sec_ts_i2c_write(ts, SEC_TS_CMD_SET_TOUCHFUNCTION, &ts->touch_functions,
												 1);

	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: Failed to send command", __func__);
		goto hover_enable_err;
	}

	input_err(true, &ts->client->dev, "%s: %s, status =%x\n", __func__,
						(enables) ? "hover enable" : "hover disable", ts->touch_functions);
	return 0;
hover_enable_err:
	ts->touch_functions =
			(enables) ? ((ts->touch_functions | SEC_TS_BIT_SETFUNC_HOVER) |
									 SEC_TS_BIT_SETFUNC_MUTUAL)
								: ((ts->touch_functions & (~SEC_TS_BIT_SETFUNC_HOVER)) |
									 SEC_TS_BIT_SETFUNC_MUTUAL);
	input_err(true, &ts->client->dev, "%s: %s, status =%x\n", __func__,
						(enables) ? "hover enable" : "hover disable", ts->touch_functions);
	return -EIO;
}
EXPORT_SYMBOL(sec_ts_hover_enables);

int sec_ts_i2c_write_burst(struct sec_ts_data *ts, u8 *data, int len) {
	int ret;
	int retry;

	mutex_lock(&ts->i2c_mutex);
	for (retry = 0; retry < SEC_TS_I2C_RETRY_CNT; retry++) {
		ret = i2c_master_send(ts->client, data, len);
		if (ret == len) {
			input_info(true, &ts->client->dev, "%s: i2c_master_send %d = %d\n",
								 __func__, ret, len);
			break;
		}
		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev,
								"%s: fail to POWER_STATUS=OFF ret = %d\n", __func__, ret);
			mutex_unlock(&ts->i2c_mutex);
			goto err;
		}
		if (retry > 0)
			sec_ts_delay(10);
	}
	mutex_unlock(&ts->i2c_mutex);
	if (retry == 10) {
		input_err(true, &ts->client->dev, "%s: I2C write over retry limit\n",
							__func__);
		ret = -EIO;
	}

	if (ret == len)
		return 0;
err:
	return -EIO;
}

/* for
 * debugging--------------------------------------------------------------------------------------*/
static ssize_t sec_ts_reg_store(struct device *dev,
																struct device_attribute *attr, const char *buf,
																size_t size) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	int length;
	int remain;
	int offset;
	int ret;

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_info(true, &ts->client->dev, "%s: Power off state\n", __func__);
		return -EIO;
	}

	mutex_lock(&ts->device_mutex);
	disable_irq(ts->client->irq);
	if (size > 0) {
		remain = size;
		offset = 0;
		do {
			if (remain >= ts->i2c_burstmax)
				length = ts->i2c_burstmax;
			else
				length = remain;
			ret = sec_ts_i2c_write_burst(ts, (u8 *)&buf[offset], length);
			if (ret < 0) {
				input_err(true, &ts->client->dev,
									"%s: i2c write %x command, remain = %d\n", __func__,
									buf[offset], remain);
				goto i2c_err;
			}

			remain -= length;
			offset += length;
		} while (remain > 0);
	}

i2c_err:
	enable_irq(ts->client->irq);
	input_info(true, &ts->client->dev, "%s: 0x%x, 0x%x, size %d\n", __func__,
						 buf[0], buf[1], (int)size);
	mutex_unlock(&ts->device_mutex);

	return size;
}

static ssize_t sec_ts_regread_show(struct device *dev,
																	 struct device_attribute *attr, char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	int ret;
	int length;
	int remain;
	int offset;

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_info(true, &ts->client->dev, "%s: Power off state\n", __func__);
		return -EIO;
	}

	disable_irq(ts->client->irq);

	read_lv1_buff = kcalloc(lv1_readsize, sizeof(u8), GFP_KERNEL);
	if (!read_lv1_buff)
		goto malloc_err;

	mutex_lock(&ts->device_mutex);
	remain = lv1_readsize;
	offset = 0;
	do {
		if (remain >= ts->i2c_burstmax)
			length = ts->i2c_burstmax;
		else
			length = remain;

		if (offset == 0)
			ret = sec_ts_i2c_read(ts, lv1cmd, &read_lv1_buff[offset], length);
		else
			ret = sec_ts_i2c_read_bulk(ts, &read_lv1_buff[offset], length);

		if (ret < 0) {
			input_err(true, &ts->client->dev, "%s: i2c read %x command, remain =%d\n",
								__func__, lv1cmd, remain);
			goto i2c_err;
		}

		remain -= length;
		offset += length;
	} while (remain > 0);

	input_info(true, &ts->client->dev, "%s: lv1_readsize = %d\n", __func__,
						 lv1_readsize);
	memcpy(buf, read_lv1_buff + lv1_readoffset, lv1_readsize);

i2c_err:
	kfree(read_lv1_buff);
malloc_err:
	mutex_unlock(&ts->device_mutex);
	lv1_readremain = 0;
	enable_irq(ts->client->irq);

	return lv1_readsize;
}

static ssize_t sec_ts_gesture_status_show(struct device *dev,
																					struct device_attribute *attr,
																					char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);

	mutex_lock(&ts->device_mutex);
	memcpy(buf, ts->gesture_status, sizeof(ts->gesture_status));
	input_info(true, &ts->client->dev, "%s: GESTURE STATUS %x %x %x %x %x %x\n",
						 __func__, ts->gesture_status[0], ts->gesture_status[1],
						 ts->gesture_status[2], ts->gesture_status[3],
						 ts->gesture_status[4], ts->gesture_status[5]);
	mutex_unlock(&ts->device_mutex);

	return sizeof(ts->gesture_status);
}

static ssize_t sec_ts_regreadsize_store(struct device *dev,
																				struct device_attribute *attr,
																				const char *buf, size_t size) {
	lv1cmd = buf[0];
	lv1_readsize = ((unsigned int)buf[4] << 24) | ((unsigned int)buf[3] << 16) |
								 ((unsigned int)buf[2] << 8) | ((unsigned int)buf[1] << 0);
	lv1_readoffset = 0;
	lv1_readremain = 0;
	return size;
}

static ssize_t sec_ts_enter_recovery_store(struct device *dev,
																					 struct device_attribute *attr,
																					 const char *buf, size_t size) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	struct sec_ts_plat_data *pdata = dev->platform_data;
	int ret;
	u8 on = (u8)buf[0];

	if (on == 1) {
		disable_irq(ts->client->irq);
		gpio_free(pdata->gpio);

		input_info(true, &ts->client->dev, "%s: gpio free\n", __func__);
		if (gpio_is_valid(pdata->gpio)) {
			ret = gpio_request_one(pdata->gpio, GPIOF_OUT_INIT_LOW, "sec,tsp_int");
			input_info(true, &ts->client->dev, "%s: gpio request one\n", __func__);
			if (ret) {
				input_err(true, &ts->client->dev, "Unable to request tsp_int [%d]\n",
									pdata->gpio);
				return -EINVAL;
			}
		} else {
			input_err(true, &ts->client->dev, "Failed to get irq gpio\n");
			return -EINVAL;
		}

		pdata->power(ts, false);
		sec_ts_delay(100);
		pdata->power(ts, true);
	} else {
		gpio_free(pdata->gpio);

		if (gpio_is_valid(pdata->gpio)) {
			ret = gpio_request_one(pdata->gpio, GPIOF_DIR_IN, "sec,tsp_int");
			if (ret) {
				input_err(true, &ts->client->dev, "Unable to request tsp_int [%d]\n",
									pdata->gpio);
				return -EINVAL;
			}
		} else {
			input_err(true, &ts->client->dev, "Failed to get irq gpio\n");
			return -EINVAL;
		}

		pdata->power(ts, false);
		sec_ts_delay(500);
		pdata->power(ts, true);
		sec_ts_delay(500);

		/* AFE Calibration */
		ret = sec_ts_i2c_write(ts, SEC_TS_CMD_CALIBRATION_AMBIENT, NULL, 0);
		if (ret < 0)
			input_err(true, &ts->client->dev, "%s: fail to write AFE_CAL\n",
								__func__);

		sec_ts_delay(1000);
		enable_irq(ts->client->irq);
	}

	return size;
}

#ifdef SEC_TS_SUPPORT_TA_MODE
static void sec_ts_charger_config(struct sec_ts_data *ts, int status) {
	int ret;

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_err(true, &ts->client->dev,
							"%s: fail to enalbe charger status, POWER_STATUS=OFF\n",
							__func__);
		goto charger_config_err;
	}

	if (status == 0x01 || status == 0x03)
		ts->touch_functions = ts->touch_functions | SEC_TS_BIT_SETFUNC_CHARGER |
													SEC_TS_BIT_SETFUNC_MUTUAL;
	else
		ts->touch_functions =
				((ts->touch_functions & (~SEC_TS_BIT_SETFUNC_CHARGER)) |
				 SEC_TS_BIT_SETFUNC_MUTUAL);

	ret = sec_ts_i2c_write(ts, SEC_TS_CMD_SET_TOUCHFUNCTION, &ts->touch_functions,
												 1);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: Failed to send command\n", __func__);
		goto charger_config_err;
	}

	input_err(true, &ts->client->dev, "%s: charger inform : read status = %x\n",
						__func__, ts->touch_functions);
	return;

charger_config_err:
	if (status == 0x01 || status == 0x03)
		ts->touch_functions = ts->touch_functions | SEC_TS_BIT_SETFUNC_CHARGER |
													SEC_TS_BIT_SETFUNC_MUTUAL;
	else
		ts->touch_functions =
				((ts->touch_functions & (~SEC_TS_BIT_SETFUNC_CHARGER)) |
				 SEC_TS_BIT_SETFUNC_MUTUAL);
	input_err(true, &ts->client->dev,
						"%s: charger inform : touch function status = %x\n", __func__,
						ts->touch_functions);
}

static void sec_ts_ta_cb(struct sec_ts_callbacks *cb, int status) {
	struct sec_ts_data *ts = container_of(cb, struct sec_ts_data, callbacks);
	input_err(true, &ts->client->dev, "[TSP] %s: status : %x\n", __func__,
						status);

	ts->ta_status = status;

	sec_ts_charger_config(ts, status);
}
#endif
static void sec_ts_raw_device_init(struct sec_ts_data *ts) {
	int ret;

	sec_ts_dev = device_create(sec_class, NULL, 0, ts, "sec_ts");

	ret = IS_ERR(sec_ts_dev);
	if (ret) {
		input_err(true, &ts->client->dev, "%s: fail - device_create\n", __func__);
		return;
	}

	ret = sysfs_create_group(&sec_ts_dev->kobj, &cmd_attr_group);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: fail - sysfs_create_group\n",
							__func__);
		goto err_sysfs;
	}
	return;

err_sysfs:
	input_err(true, &ts->client->dev, "%s: fail\n", __func__);
}

/* for
 * debugging--------------------------------------------------------------------------------------*/
static int sec_ts_power(void *data, bool on) {
	int ret = 0;
	return ret;
}

static int sec_ts_parse_dt(struct i2c_client *client) {
	struct device *dev = &client->dev;
	struct sec_ts_plat_data *pdata = dev->platform_data;
	struct device_node *np = dev->of_node;

	u32 coords[2], lines[2];
	int ret = 0;
	pdata->power = sec_ts_power;

	pdata->gpio = of_get_named_gpio(np, "sec,irq_gpio", 0);
	if (gpio_is_valid(pdata->gpio)) {
		ret = gpio_request_one(pdata->gpio, GPIOF_DIR_IN, "sec,tsp_int");
		if (ret) {
			input_err(true, &client->dev, "Unable to request tsp_int [%d]\n",
								pdata->gpio);
			return -EINVAL;
		}
	} else {
		input_err(true, &client->dev, "Failed to get irq gpio\n");
		return -EINVAL;
	}
	client->irq = gpio_to_irq(pdata->gpio);

	pdata->irq_type = IRQF_TRIGGER_LOW | IRQF_ONESHOT;
	if (of_property_read_u32_array(np, "sec,max_coords", coords, 2)) {
		input_err(true, &client->dev, "Failed to get max_coords property\n");
		return -EINVAL;
	}
	pdata->max_x = coords[0];
	pdata->max_y = coords[1];

	if (of_property_read_u32_array(np, "sec,num_lines", lines, 2))
		input_info(true, &client->dev, "skipped to get num_lines property\n");
	else {
		pdata->num_rx = lines[0];
		pdata->num_tx = lines[1];
		input_info(true, &client->dev, "num_of[rx,tx]: [%d,%d]\n", pdata->num_rx,
							 pdata->num_tx);
	}

	if (of_property_read_string_index(np, "sec,project_name", 0,
																		&pdata->project_name))
		input_info(true, &client->dev, "skipped to get project_name property\n");
	if (of_property_read_string_index(np, "sec,project_name", 1,
																		&pdata->model_name))
		input_info(true, &client->dev, "skipped to get model_name property\n");

	pdata->i2c_burstmax = SEC_TS_FW_MAX_BURSTSIZE;

	input_info(true, &client->dev, "irq:%d,irq_type:0x%04x,max[x,y]:[%d,%d],"
																 "project/model_name:%s/%s,panel_revision:%d\n",
						 pdata->gpio, pdata->irq_type, pdata->max_x, pdata->max_y,
						 pdata->project_name, pdata->model_name, pdata->panel_revision);

	return ret;
}

static int sec_ts_setup_drv_data(struct i2c_client *client) {
	int ret = 0;
	struct sec_ts_data *ts;
	struct sec_ts_plat_data *pdata;

	/* parse dt */
	if (client->dev.of_node) {
		pdata =
				devm_kzalloc(&client->dev, sizeof(struct sec_ts_plat_data), GFP_KERNEL);

		if (!pdata) {
			input_err(true, &client->dev, "Failed to allocate platform data\n");
			return -ENOMEM;
		}

		client->dev.platform_data = pdata;
		ret = sec_ts_parse_dt(client);
		if (ret) {
			input_err(true, &client->dev, "Failed to parse dt\n");
			return ret;
		}
	} else
		pdata = client->dev.platform_data;

	if (!pdata) {
		input_err(true, &client->dev, "No platform data found\n");
		return -EINVAL;
	}
	if (!pdata->power) {
		input_err(true, &client->dev, "No power contorl found\n");
		return -EINVAL;
	}

	pdata->pinctrl = devm_pinctrl_get(&client->dev);
	if (IS_ERR(pdata->pinctrl)) {
		input_err(true, &client->dev, "could not get pinctrl\n");
		return PTR_ERR(pdata->pinctrl);
	}

	pdata->pins_default = pinctrl_lookup_state(pdata->pinctrl, "on_state");
	if (IS_ERR(pdata->pins_default))
		input_err(true, &client->dev, "could not get default pinstate\n");

	pdata->pins_sleep = pinctrl_lookup_state(pdata->pinctrl, "off_state");
	if (IS_ERR(pdata->pins_sleep))
		input_err(true, &client->dev, "could not get sleep pinstate\n");

	ts = kzalloc(sizeof(struct sec_ts_data), GFP_KERNEL);
	if (!ts)
		return -ENOMEM;

	ts->client = client;
	ts->plat_data = pdata;
	ts->crc_addr = 0x0001FE00;
	ts->fw_addr = 0x00002000;
	ts->para_addr = 0x18000;
	ts->sec_ts_i2c_read = sec_ts_i2c_read;
	ts->sec_ts_i2c_write = sec_ts_i2c_write;
	ts->sec_ts_i2c_read_bulk = sec_ts_i2c_read_bulk;
	ts->sec_ts_i2c_write_burst = sec_ts_i2c_write_burst;
	ts->i2c_burstmax = pdata->i2c_burstmax;
	ts->fw_workdone = false;
	ts->force_fwup = false;

	INIT_DELAYED_WORK(&ts->reset_work, sec_ts_reset_work);

	i2c_set_clientdata(client, ts);

	return ret;
}

static int sec_ts_read_information(struct sec_ts_data *ts) {
	unsigned char data[20] = {0};
	unsigned char device_id[3] = {0};
	int ret;

	memset(data, 0x0, 3);
	ret = sec_ts_i2c_read(ts, SEC_TS_READ_DEVICE_ID, device_id, 3);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: failed to read device id(%d)\n",
							__func__, ret);
		return ret;
	}

	input_info(true, &ts->client->dev, "%s: %X, %X, %X\n", __func__, device_id[0],
						 device_id[1], device_id[2]);

	memset(data, 0x0, 20);
	ret = sec_ts_i2c_read(ts, SEC_TS_READ_SUB_ID, data, 20);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: failed to read sub id(%d)\n",
							__func__, ret);
		return ret;
	}

	input_info(true, &ts->client->dev,
						 "%s: AP/BL(%X), DEV1:%X, DEV2:%X, nT:%X, nR:%X, rY:%d, rX:%d\n",
						 __func__, data[0], data[1], data[2], data[3], data[4],
						 (data[5] << 8) | data[6], (data[7] << 8) | data[8]);

	data[0] = sec_ts_read_calibration_report(ts);
	input_err(true, &ts->client->dev, "%s: cal info (%d)\n", __func__, data[0]);

	data[0] = 0;
	ret = sec_ts_i2c_read(ts, SEC_TS_READ_BOOT_STATUS, data, 1);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: failed to read sub id(%d)\n",
							__func__, ret);
		return ret;
	}

	input_info(true, &ts->client->dev, "%s: %X\n", __func__, data[0]);

	if (device_id[0] == SEC_TS_ID_ON_FW)
		ret = 1;
	else {
		input_err(true, &ts->client->dev, "%s: device id = %X\n", __func__,
							device_id[0]);
		ret = 0;
	}

	return ret;
}

int sec_ts_i2c_probe_read(struct sec_ts_data *ts, u8 reg, u8 *data, int len) {
	u8 buf[4];
	int ret;
	unsigned char retry;
#ifdef POR_AFTER_I2C_RETRY
	int retry_cnt = 0;
#endif
	struct i2c_msg msg[2];

	input_info(true, &ts->client->dev, "%s\n", __func__);

	mutex_lock(&ts->i2c_mutex);

	buf[0] = reg;
	msg[0].addr = ts->client->addr;
	msg[0].flags = 0;
	msg[0].len = 1;
	msg[0].buf = buf;

#ifdef POR_AFTER_I2C_RETRY
retry_fail_write:
#endif

	for (retry = 0; retry < SEC_TS_I2C_RETRY_CNT; retry++) {
		ret = i2c_transfer(ts->client->adapter, msg, 1);
		if (ret == 1)
			break;

		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev,
								"%s: fail to POWER_STATUS=OFF ret = %d\n", __func__, ret);
			mutex_unlock(&ts->i2c_mutex);
			goto err;
		}
		if (retry > 0)
			sec_ts_delay(10);
	}

	if (retry == SEC_TS_I2C_RETRY_CNT) {
		input_err(true, &ts->client->dev, "%s: I2C write over retry limit\n",
							__func__);
#ifdef POR_AFTER_I2C_RETRY
		schedule_delayed_work(&ts->reset_work,
													msecs_to_jiffies(TOUCH_RESET_DWORK_TIME));

		if (!retry_cnt++)
			goto retry_fail_write;
#endif
	}

	if (ret != 1) {
		mutex_unlock(&ts->i2c_mutex);
		goto err;
	}
	udelay(100);

	msg[0].addr = ts->client->addr;
	msg[0].flags = I2C_M_RD;
	msg[0].len = len;
	msg[0].buf = data;

#ifdef POR_AFTER_I2C_RETRY
	retry_cnt = 0;
#endif

	for (retry = 0; retry < SEC_TS_I2C_RETRY_CNT; retry++) {
		ret = i2c_transfer(ts->client->adapter, msg, 1);
		if (ret == 1)
			break;

		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev,
								"%s: fail to POWER_STATUS=OFF ret = %d\n", __func__, ret);
			mutex_unlock(&ts->i2c_mutex);
			goto err;
		}
		if (retry > 0)
			sec_ts_delay(10);
	}

	if (retry == SEC_TS_I2C_RETRY_CNT) {
		input_err(true, &ts->client->dev, "%s: I2C read over retry limit\n",
							__func__);
#ifdef POR_AFTER_I2C_RETRY
		schedule_delayed_work(&ts->reset_work,
													msecs_to_jiffies(TOUCH_RESET_DWORK_TIME));

		if (!retry_cnt++)
			goto retry_fail_write;
#endif
		ret = -EIO;
	}

	mutex_unlock(&ts->i2c_mutex);
	return ret;
	input_info(true, &ts->client->dev, "%s ret=%d\n", __func__, ret);
err:
	return -EIO;
}

static int sec_ts_read_device_id(struct sec_ts_data *ts) {
	unsigned char device_id[3] = {0};
	int ret;
	ret = sec_ts_i2c_probe_read(ts, SEC_TS_READ_DEVICE_ID, device_id, 3);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: failed to read device id(%d)\n",
							__func__, ret);
		return -EIO;
	}

	input_info(true, &ts->client->dev, "%s: %X, %X, %X ret=%d\n", __func__,
						 device_id[0], device_id[1], device_id[2], ret);

	return ret;
}

#define T_BUFF_SIZE 5
/**/
static int sec_ts_probe(struct i2c_client *client,
												const struct i2c_device_id *id) {
#ifdef SEC_TS_WAKEUP_GESTURE
	int i;
#endif
	struct sec_ts_data *ts;

	static char sec_ts_phys[64] = {0};
	int ret = 0;

	input_info(true, &client->dev, "SEC_TS Driver [%s]\n", SEC_TS_DRV_VERSION);

	if (!i2c_check_functionality(client->adapter, I2C_FUNC_I2C)) {
		input_err(true, &client->dev, "%s : EIO err!\n", __func__);
		return -EIO;
	}

	ret = sec_ts_setup_drv_data(client);
	if (ret < 0) {
		input_err(true, &client->dev, "%s: Failed to set up driver data\n",
							__func__);
		goto err_setup_drv_data;
	}

	ts = (struct sec_ts_data *)i2c_get_clientdata(client);
	if (!ts) {
		input_err(true, &client->dev, "%s: Failed to get driver data\n", __func__);
		ret = -ENODEV;
		goto err_get_drv_data;
	}

	if (!(IS_ERR_OR_NULL(ts->plat_data->pins_default) ||
				IS_ERR_OR_NULL(ts->plat_data->pinctrl))) {
		ret = pinctrl_select_state(ts->plat_data->pinctrl,
															 ts->plat_data->pins_default);
		if (ret < 0)
			input_err(true, &ts->client->dev,
								"%s: Failed to configure tsp_attn pin\n", __func__);
	}

	ts->input_dev = input_allocate_device();
	if (!ts->input_dev) {
		input_err(true, &ts->client->dev, "%s: allocate device err!\n", __func__);
		ret = -ENOMEM;
		goto err_allocate_device;
	}

	ts->input_dev->name = "Samsung Electronics Touchscreen 1223";
	snprintf(sec_ts_phys, sizeof(sec_ts_phys), "%s/input1", ts->input_dev->name);
	ts->input_dev->name = "Samsung Electronics Touchscreen 1223";
	snprintf(sec_ts_phys, sizeof(sec_ts_phys), "%s/input1",
		ts->input_dev->name);
	ts->input_dev->phys = sec_ts_phys;
	ts->input_dev->id.bustype = BUS_I2C;
	ts->input_dev->dev.parent = &client->dev;
	ts->touch_count = 0;

	mutex_init(&ts->lock);
	mutex_init(&ts->device_mutex);
	mutex_init(&ts->i2c_mutex);

#ifdef CONFIG_TOUCHSCREN_SEC_TS_GLOVEMODE
	input_set_capability(ts->input_dev, EV_SW, SW_GLOVE);
#endif
	set_bit(EV_SYN, ts->input_dev->evbit);
	set_bit(EV_KEY, ts->input_dev->evbit);
	set_bit(EV_ABS, ts->input_dev->evbit);
	set_bit(BTN_TOUCH, ts->input_dev->keybit);
	set_bit(BTN_TOOL_FINGER, ts->input_dev->keybit);

#ifdef SEC_TS_SUPPORT_TOUCH_KEY
	if (ts->plat_data->support_mskey) {
		for (i = 0; i < ts->plat_data->num_touchkey; i++)
			set_bit(ts->plat_data->touchkey[i].keycode, ts->input_dev->keybit);

		set_bit(EV_LED, ts->input_dev->evbit);
		set_bit(LED_MISC, ts->input_dev->ledbit);
	}
#endif

#ifdef INPUT_PROP_DIRECT
	set_bit(INPUT_PROP_DIRECT, ts->input_dev->propbit);
#endif

	ts->input_dev->evbit[0] = BIT_MASK(EV_ABS) | BIT_MASK(EV_KEY);
	set_bit(INPUT_PROP_DIRECT, ts->input_dev->propbit);

	input_mt_init_slots(ts->input_dev, MAX_SUPPORT_TOUCH_COUNT, INPUT_MT_DIRECT);
	input_set_abs_params(ts->input_dev, ABS_MT_POSITION_X, 0,
											 ts->plat_data->max_x, 0, 0);
	input_set_abs_params(ts->input_dev, ABS_MT_POSITION_Y, 0,
											 ts->plat_data->max_y, 0, 0);
	input_set_abs_params(ts->input_dev, ABS_MT_TOUCH_MAJOR, 0, 255, 0, 0);
	input_set_abs_params(ts->input_dev, ABS_MT_TOUCH_MINOR, 0, 255, 0, 0);
#ifdef SEC_TS_SUPPORT_SEC_SWIPE
	input_set_abs_params(ts->input_dev, ABS_MT_PALM, 0, 1, 0, 0);
#endif
#if defined(SEC_TS_SUPPORT_GRIP_EVENT)
	input_set_abs_params(ts->input_dev, ABS_MT_GRIP, 0, 1, 0, 0);
#endif
	input_set_abs_params(ts->input_dev, ABS_MT_DISTANCE, 0, 255, 0, 0);

#ifdef CONFIG_SEC_FACTORY
	input_set_abs_params(ts->input_dev, ABS_MT_PRESSURE, 0, 255, 0, 0);
#endif
#ifdef SEC_TS_WAKEUP_GESTURE
	handle_sec = sec_ts_gesture_state;
	for (i = 0; i < (sizeof(wakeup_gesture_key) / sizeof(wakeup_gesture_key[0]));
			 i++) {
		input_set_capability(ts->input_dev, EV_KEY, wakeup_gesture_key[i]);
	}

	input_set_capability(ts->input_dev, EV_KEY, KEY_POWER);
	mz_gesture_handle_register(handle_sec);
	wake_lock_init(&gesture_wakelock, WAKE_LOCK_SUSPEND, "poll-wake-lock");
#endif
	input_set_drvdata(ts->input_dev, ts);
	i2c_set_clientdata(client, ts);

	ret = sec_ts_read_device_id(ts);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: allocate device err!\n", __func__);
		ret = -ENOMEM;
		goto err_input_register_device;
	}

	ret = input_register_device(ts->input_dev);
	if (ret) {
		input_err(true, &ts->client->dev,
							"%s: Unable to register %s input device\n", __func__,
							ts->input_dev->name);
		goto err_input_register_device;
	}

	ts->power_status = SEC_TS_STATE_POWER_ON;

	input_info(true, &ts->client->dev, "sec_ts_probe request_irq = %d\n",
						 client->irq);
#ifdef SEC_TS_WAKEUP_GESTURE
	ret = request_threaded_irq(client->irq, NULL, sec_ts_irq_thread,
														 ts->plat_data->irq_type | IRQF_ONESHOT |
																 IRQF_NO_SUSPEND,
														 SEC_TS_I2C_NAME, ts);
#else
	ret = request_threaded_irq(client->irq, NULL, sec_ts_irq_thread,
														 ts->plat_data->irq_type | IRQF_ONESHOT,
														 SEC_TS_I2C_NAME, ts);
#endif
	if (ret < 0) {
		input_err(true, &ts->client->dev,
							"sec_ts_probe: Unable to request threaded irq\n");
		goto err_irq;
	}
	disable_irq(ts->client->irq);
	ts->interrupt_enable = SEC_TS_INTERRUPT_EN;
	input_info(true, &ts->client->dev, "sec_ts_probe request_irq done\n");

#ifdef SEC_TS_SUPPORT_TA_MODE
	ts->callbacks.inform_charger = sec_ts_ta_cb;
	if (ts->plat_data->register_cb)
		ts->plat_data->register_cb(&ts->callbacks);
#endif
#ifndef SAMSUNG_PROJECT
	ret = sec_class_create();
#endif
	if (!IS_ERR_OR_NULL(sec_class)) {
		sec_ts_raw_device_init(ts);
		sec_ts_fn_init(ts);
	}

	ret = sec_ts_test_proc_init(ts);
	if (ret != 0) {
		input_err(true, &ts->client->dev, "sec_ts test proc init failed. ret=%d\n",
							ret);
		goto err_proc_init;
	}

#if defined(CONFIG_FB)
	// 注释掉 FB notifier 注册，防止触摸屏驱动控制背光
	// ts->fb_notif.notifier_call = fb_notifier_callback;
	// ret = fb_register_client(&ts->fb_notif);
	// if (ret) {
	// 	input_err(true, &ts->client->dev, "register fb_notifier failed\n");
	// 	goto err_register_fb_notif;
	// }
	input_info(true, &ts->client->dev, "%s: FB notifier disabled to prevent backlight control\n", __func__);
#elif defined(CONFIG_HAS_EARLYSUSPEND)
	// 同样注释掉 early suspend
	// ts->early_suspend.level = EARLY_SUSPEND_LEVEL_BLANK_SCREEN + 1;
	// ts->early_suspend.suspend = sec_ts_early_suspend;
	// ts->early_suspend.resume = sec_ts_late_resume;
	// ret = register_early_suspend(&ts->early_suspend);
	// if (ret) {
	// 	input_err(true, &ts->client->dev, "register early suspend failed. ret=%d\n",
	// 					ret);
	// 	goto err_register_early_suspend;
	// }
	input_info(true, &ts->client->dev, "%s: Early suspend disabled to prevent backlight control\n", __func__);
#endif

	sec_fwu_wq = create_singlethread_workqueue("sec_fwu_wq");
	if (!sec_fwu_wq) {
		input_err(true, &ts->client->dev, "sec_fwu_wq create workqueue failed\n");
		ret = -ENOMEM;
		goto err_create_sec_fwu_wq_failed;
	}
	INIT_DELAYED_WORK(&ts->fwupdate_work, sec_ts_fwupdate_work);
	queue_delayed_work(sec_fwu_wq, &ts->fwupdate_work,
										 msecs_to_jiffies(TOUCH_FWUPDATE_DWORK_TIME));

	ts->lowpower_mode = TO_TOUCH_MODE;
	ts->probe_done = true;
	tsp_data = ts;
	device_init_wakeup(&client->dev, true);
	input_info(true, &ts->client->dev, "sec_ts_probe done\n");

	return 0;

#if defined(CONFIG_FB)

#endif
err_create_sec_fwu_wq_failed:
err_proc_init:
err_irq:
	input_unregister_device(ts->input_dev);
	ts->input_dev = NULL;
err_input_register_device:
	if (ts->input_dev)
		input_free_device(ts->input_dev);

err_allocate_device:
err_get_drv_data:
	kfree(ts);
err_setup_drv_data:
	return ret;
}

void sec_ts_release_all_finger(struct sec_ts_data *ts) {
	int i;

	for (i = 0; i < MAX_SUPPORT_TOUCH_COUNT; i++) {
		input_mt_slot(ts->input_dev, i);
		input_mt_report_slot_state(ts->input_dev, MT_TOOL_FINGER, false);

		if ((ts->coord[i].action == SEC_TS_Coordinate_Action_Press) ||
				(ts->coord[i].action == SEC_TS_Coordinate_Action_Move)) {
			ts->touch_count--;
			if (ts->touch_count < 0)
				ts->touch_count = 0;

			ts->coord[i].action = SEC_TS_Coordinate_Action_Release;

			input_info(
					true, &ts->client->dev,
					"%s: [RA] tID:%d mc:%d tc:%d cal:0x%x(%X|%X) [SE%02X%02X%02X]\n",
					__func__, i, ts->coord[i].mcount, ts->touch_count, ts->cal_status,
					ts->nv, ts->cal_count, ts->plat_data->panel_revision,
					ts->plat_data->img_version_of_ic[2],
					ts->plat_data->img_version_of_ic[3]);
		}

		ts->coord[i].mcount = 0;
	}

	input_report_key(ts->input_dev, BTN_TOUCH, false);
	input_report_key(ts->input_dev, BTN_TOOL_FINGER, false);
#ifdef CONFIG_TOUCHSCREN_SEC_TS_GLOVEMODE
	input_report_switch(ts->input_dev, SW_GLOVE, false);
#endif
	ts->touchkey_glove_mode_status = false;
	ts->touch_count = 0;

	input_sync(ts->input_dev);
}
#if defined(CONFIG_FB)
static int sec_ts_set_lowpowermode(struct sec_ts_data *ts, u8 mode) {
	int ret = -1;

	input_err(true, &ts->client->dev, "%s: %s\n", __func__,
						mode == TO_LOWPOWER_MODE ? "ENTER" : "EXIT");

	ts->power_status = SEC_TS_STATE_POWER_ON;
	if (mode) {
		ret = sec_ts_i2c_write(ts, SEC_TS_CMD_SET_POWER_MODE, &mode, 1);
		if (ret < 0)
			input_err(true, &ts->client->dev, "%s: failed\n", __func__);
	}

	ts->lowpower_mode = mode;
	sec_ts_release_all_finger(ts);

	return ret;
}
#endif

static void sec_ts_reset_work(struct work_struct *work) {
	struct sec_ts_data *ts =
			container_of(work, struct sec_ts_data, reset_work.work);

	if (!ts->probe_done)
		return;

	input_err(true, &ts->client->dev, "%s start\n", __func__);
	sec_ts_delay(30);
	input_info(true, &ts->client->dev, "%s done\n", __func__);
}

static void sec_ts_fwupdate_work(struct work_struct *work) {
	u8 tBuff[T_BUFF_SIZE];
	int ret = 0;

	struct sec_ts_data *ts =
			container_of(work, struct sec_ts_data, fwupdate_work.work);

	if (!ts->probe_done)
		return;
	input_err(true, &ts->client->dev, "%s start\n", __func__);

	mutex_lock(&ts->device_mutex);

	/* Enable Power */
	ts->plat_data->power(ts, true);
	ts->power_status = SEC_TS_STATE_POWER_ON;
	ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SW_RESET, NULL, 0);
	sec_ts_delay(500);
	sec_ts_wait_for_ready(ts, SEC_TS_ACK_BOOT_COMPLETE);

#ifndef CONFIG_FW_UPDATE_ON_PROBE
	input_info(true, &ts->client->dev, "%s: fw update on probe disabled!\n",
						 __func__);
	sec_ts_check_firmware_version(ts, sec_get_fwdata());

	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_CALIBRATION_OFFSET_SDC, NULL, 0);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: calibration fail\n", __func__);
	}
	sec_ts_delay(1000);

	ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SW_RESET, NULL, 0);
	sec_ts_delay(500);
#endif

#ifdef CONFIG_FW_UPDATE_ON_PROBE
	ret = sec_ts_firmwarei_update_on_probe(ts);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: fw update fail, ret = %d!\n",
							__func__, ret);
		goto err_init;
	} else
		input_err(true, &ts->client->dev, "%s: fw update success, ret = %d!\n",
							__func__, ret);
#endif

	ret = sec_ts_read_information(ts);
	if ((ts->tx_count == 0) || (ts->rx_count == 0)) {

		/* Read Raw Channel Info */
		ret = sec_ts_i2c_read(ts, SEC_TS_READ_SUB_ID, tBuff, 5);
		if (ret < 0) {
			input_err(true, &ts->client->dev, "%s: fail to read raw channel info\n",
								__func__);
			goto err_init;
		} else {
			ts->tx_count = tBuff[3];
			ts->rx_count = tBuff[4];
			input_info(true, &ts->client->dev, "%s: S6SSEC_TS Tx : %d, Rx : %d\n",
								 __func__, ts->tx_count, ts->rx_count);
		}
	}

	ts->pFrame = kzalloc(ts->tx_count * ts->rx_count * 2, GFP_KERNEL);
	if (!ts->pFrame) {
		ret = -ENOMEM;
		goto err_allocate_frame;
	}
	ts->fw_workdone = true;
	mutex_unlock(&ts->device_mutex);
	enable_irq(ts->client->irq);
	input_info(true, &ts->client->dev, "%s done\n", __func__);
	return;

err_allocate_frame:
err_init:
	mutex_unlock(&ts->device_mutex);
	enable_irq(ts->client->irq);
	input_info(true, &ts->client->dev, "%s failed\n", __func__);
}
#if defined(CONFIG_FB)
static int sec_ts_input_open(struct input_dev *dev) {
	struct sec_ts_data *ts = input_get_drvdata(dev);
	int ret;

	if (ts->fw_workdone) {
		if (ts->lowpower_status) {
			sec_ts_delay(200);
			sec_ts_set_lowpowermode(ts, TO_TOUCH_MODE);
			enable_irq(ts->client->irq);
		} else {
			ret = sec_ts_start_device(ts);
			if (ret < 0)
				input_err(true, &ts->client->dev, "%s: Failed to start device\n",
									__func__);
		}
	}
	input_err(true, &ts->client->dev, "%s : Done", __func__);

	return 0;
}

static void sec_ts_input_close(struct input_dev *dev) {
	struct sec_ts_data *ts = input_get_drvdata(dev);
	input_err(true, &ts->client->dev, "%s\n", __func__);

	cancel_delayed_work(&ts->reset_work);

	if (ts->fw_workdone) {
		if (ts->lowpower_status) {
			sec_ts_set_lowpowermode(ts, TO_LOWPOWER_MODE);
			enable_irq_wake(ts->client->irq);
		} else
			sec_ts_stop_device(ts);
	}
}
#endif

static void sec_ts_remove(struct i2c_client *client) {
	struct sec_ts_data *ts = i2c_get_clientdata(client);

	pr_err("%s\n", __func__);
#if defined(CONFIG_FB)
	if (fb_unregister_client(&ts->fb_notif))
		input_err(true, &ts->client->dev, "unregistering fb_notifier err\n");

#endif

	free_irq(client->irq, ts);

	input_mt_destroy_slots(ts->input_dev);
	input_unregister_device(ts->input_dev);

	ts->input_dev = NULL;
	ts->plat_data->power(ts, false);

	kfree(ts);
	// return 0;
}

static void sec_ts_shutdown(struct i2c_client *client) {
	struct sec_ts_data *ts = i2c_get_clientdata(client);
	pr_err("%s\n", __func__);

	sec_ts_stop_device(ts);
}

static int sec_ts_stop_device(struct sec_ts_data *ts) {
	input_info(true, &ts->client->dev, "%s\n", __func__);

	mutex_lock(&ts->device_mutex);

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_err(true, &ts->client->dev, "%s: already power off\n", __func__);
		goto out;
	}

	disable_irq(ts->client->irq);
	sec_ts_release_all_finger(ts);

	ts->plat_data->power(ts, false);
	ts->power_status = SEC_TS_STATE_POWER_OFF;

	if (ts->plat_data->enable_sync)
		ts->plat_data->enable_sync(false);

out:
	mutex_unlock(&ts->device_mutex);
	input_info(true, &ts->client->dev, "%s: done\n", __func__);
	return 0;
}
#if defined(CONFIG_FB)
static int sec_ts_start_device(struct sec_ts_data *ts) {
	input_info(true, &ts->client->dev, "%s\n", __func__);

	mutex_lock(&ts->device_mutex);
	if (ts->power_status == SEC_TS_STATE_POWER_ON) {
		input_err(true, &ts->client->dev, "%s: already power on\n", __func__);
		goto out;
	}
	sec_ts_release_all_finger(ts);
	if (!ts->interrupt_enable) {
		input_err(true, &ts->client->dev, "%s: interrupt work not finished\n",
							__func__);
		goto out;
	}
	ts->plat_data->power(ts, true);
	sec_ts_delay(200);
	ts->power_status = SEC_TS_STATE_POWER_ON;
	input_err(true, &ts->client->dev, "%s: SEC_TS_STATE_POWER_ON\n", __func__);
	if (ts->plat_data->enable_sync)
		ts->plat_data->enable_sync(true);

#ifdef SEC_TS_SUPPORT_TA_MODE
	if (ts->ta_status)
		sec_ts_charger_config(ts, ts->ta_status);
#endif
	enable_irq(ts->client->irq);
out:
	mutex_unlock(&ts->device_mutex);
	input_info(true, &ts->client->dev, "%s: done\n", __func__);
	return 0;
}
#endif
#if defined(CONFIG_FB)
static int __maybe_unused fb_notifier_callback(struct notifier_block *self,
																unsigned long event, void *data) {
	struct fb_event *evdata = data;
	int *blank;

	struct sec_ts_data *ts = container_of(self, struct sec_ts_data, fb_notif);
	input_info(true, &ts->client->dev, "%s event = %ld\n", __func__, event);
	if (evdata && evdata->data && event == FB_EARLY_EVENT_BLANK) {
		blank = evdata->data;
		input_info(true, &ts->client->dev,
							 "%s event = FB_EARLY_EVENT_BLANK, blank = %d\n", __func__,
							 *blank);
		if (*blank == FB_BLANK_POWERDOWN) {
			input_info(true, &ts->client->dev, "%s blank = FB_BLANK_POWERDOWN\n",
								 __func__);
			sec_ts_input_close(ts->input_dev);
		} else if (*blank == FB_BLANK_UNBLANK) {
			input_info(true, &ts->client->dev, "%s blank = FB_BLANK_UNBLANK\n",
								 __func__);
			if (ts->lowpower_status && ts->fw_workdone) {
				disable_irq(ts->client->irq);
			}
		}
	} else if (evdata && evdata->data && event == FB_EVENT_BLANK) {
		blank = evdata->data;
		input_info(true, &ts->client->dev,
							 "%s event = FB_EVENT_BLANK, blank = %d\n", __func__, *blank);
		if (*blank == FB_BLANK_UNBLANK) {
			input_info(true, &ts->client->dev, "%s blank = FB_BLANK_UNBLANK\n",
								 __func__);
			sec_ts_input_open(ts->input_dev);
		} else if (*blank == FB_BLANK_POWERDOWN) {
			input_info(true, &ts->client->dev, "%s blank = FB_BLANK_POWERDOWN\n",
								 __func__);
		}
	}

	return 0;
}

#endif
static const struct i2c_device_id sec_ts_id[] = {
		{SEC_TS_I2C_NAME, 0}, {},
};
MODULE_DEVICE_TABLE(i2c, sec_ts_id);

#ifdef CONFIG_OF
static const struct of_device_id sec_ts_match_table[] = {
		{
				.compatible = "sec,sec_ts",
		},
		{},
};
MODULE_DEVICE_TABLE(of, sec_ts_match_table);
#endif

static struct i2c_driver sec_ts_driver = {
		.probe = sec_ts_probe,
		.remove = sec_ts_remove,
		.shutdown = sec_ts_shutdown,
		.id_table = sec_ts_id,
		.driver =
				{
						.owner = THIS_MODULE,
						.name = SEC_TS_I2C_NAME,
						.of_match_table = of_match_ptr(sec_ts_match_table),
				},
};

static int __init sec_ts_init(void) {
	int ret;

	ret = i2c_add_driver(&sec_ts_driver);
	if (ret)
		pr_err("%s:fail to i2c_add_driver\n", __func__);

	return ret;
}

static void __exit sec_ts_exit(void) {
	i2c_del_driver(&sec_ts_driver);

	if (sec_fwu_wq)
		destroy_workqueue(sec_fwu_wq);
}

late_initcall_sync(sec_ts_init);
module_exit(sec_ts_exit);

MODULE_AUTHOR("Younghee, Won<younghee46.won@samsung.com>");
MODULE_DESCRIPTION("Samsung Electronics TouchScreen driver");
MODULE_LICENSE("GPL");
