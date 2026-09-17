/* Samsung Touchscreen Controller Driver.
 *
 * Copyright (c) 2007-2012, Samsung Electronics
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include <asm/unaligned.h>
#include <linux/ctype.h>
#include <linux/delay.h>
#include <linux/firmware.h>
#include <linux/hrtimer.h>
#include <linux/i2c.h>
#include <linux/input.h>
#include <linux/interrupt.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#ifdef SAMSUNG_PROJECT
#include <linux/sec_sysfs.h>
#endif
#include "sec_ts.h"
#include <linux/uaccess.h>

#define tostring(x) (#x)

#define FT_CMD(name, func) .cmd_name = name, .cmd_func = func

/*extern struct class *sec_class;*/

enum {
	TYPE_RAW_DATA = 0, /*  Tota cap - offset(19) = remnant dta */
	TYPE_SIGNAL_DATA = 1,
	TYPE_AMBIENT_BASELINE = 2, /* Cap Baseline */
	TYPE_AMBIENT_DATA = 3,		 /* Cap Ambient */
	TYPE_REMV_BASELINE_DATA = 4,
	TYPE_DECODED_DATA = 5,
	TYPE_REMV_AMB_DATA = 6,
	TYPE_OFFSET_DATA_SEC = 19, /* Cap Offset for Normal Touch */
	TYPE_OFFSET_DATA_SDC = 29, /* Cap Offset in SDC */
	TYPE_INVALID_DATA = 0xFF,	/* Invalid data type for release factory mode*/
};

enum CMD_STATUS {
	CMD_STATUS_WAITING = 0,
	CMD_STATUS_RUNNING,
	CMD_STATUS_OK,
	CMD_STATUS_FAIL,
	CMD_STATUS_NOT_APPLICABLE,
};

struct ft_cmd {
	struct list_head list;
	const char *cmd_name;
	void (*cmd_func)(void *device_data);
};

static ssize_t cmd_store(struct device *dev, struct device_attribute *attr,
												 const char *buf, size_t count);
static ssize_t cmd_status_show(struct device *dev,
															 struct device_attribute *attr, char *buf);
static ssize_t cmd_result_show(struct device *dev,
															 struct device_attribute *attr, char *buf);
static ssize_t cmd_list_show(struct device *dev, struct device_attribute *attr,
														 char *buf);
static ssize_t scrub_position_show(struct device *dev,
																	 struct device_attribute *attr, char *buf);
static ssize_t edge_x_position(struct device *dev,
															 struct device_attribute *attr, char *buf);

static DEVICE_ATTR(cmd, S_IWUSR | S_IWGRP, NULL, cmd_store);
static DEVICE_ATTR(cmd_status, S_IRUGO, cmd_status_show, NULL);
static DEVICE_ATTR(cmd_result, S_IRUGO, cmd_result_show, NULL);
static DEVICE_ATTR(cmd_list, S_IRUGO, cmd_list_show, NULL);
static DEVICE_ATTR(scrub_pos, S_IRUGO, scrub_position_show, NULL);
static DEVICE_ATTR(edge_pos, S_IRUGO, edge_x_position, NULL);

static int execute_selftest(struct sec_ts_data *ts);

static void fw_update(void *device_data);
static void get_fw_ver_bin(void *device_data);
static void get_fw_ver_ic(void *device_data);
static void get_config_ver(void *device_data);
static void get_threshold(void *device_data);
static void module_off_master(void *device_data);
static void module_on_master(void *device_data);
static void get_chip_vendor(void *device_data);
static void get_chip_name(void *device_data);
static void get_x_num(void *device_data);
static void get_y_num(void *device_data);
static void get_x_cross_routing(void *device_data);
static void get_y_cross_routing(void *device_data);
static void get_checksum_data(void *device_data);
static void run_force_calibration(void *device_data);
static void get_force_calibration(void *device_data);
static void glove_mode(void *device_data);
static void hover_enable(void *device_data);
static void set_lowpower_mode(void *device_data);
static void set_log_level(void *device_data);
static void not_support_cmd(void *device_data);

struct ft_cmd ft_cmds[] = {
		{
				FT_CMD("fw_update", fw_update),
		},
		{
				FT_CMD("get_fw_ver_bin", get_fw_ver_bin),
		},
		{
				FT_CMD("get_fw_ver_ic", get_fw_ver_ic),
		},
		{
				FT_CMD("get_config_ver", get_config_ver),
		},
		{
				FT_CMD("get_threshold", get_threshold),
		},
		{
				FT_CMD("module_off_master", module_off_master),
		},
		{
				FT_CMD("module_on_master", module_on_master),
		},
		{
				FT_CMD("get_chip_vendor", get_chip_vendor),
		},
		{
				FT_CMD("get_chip_name", get_chip_name),
		},
		{
				FT_CMD("get_x_num", get_x_num),
		},
		{
				FT_CMD("get_y_num", get_y_num),
		},
		{
				FT_CMD("get_x_cross_routing", get_x_cross_routing),
		},
		{
				FT_CMD("get_y_cross_routing", get_y_cross_routing),
		},
		{
				FT_CMD("get_checksum_data", get_checksum_data),
		},
		{
				FT_CMD("run_force_calibration", run_force_calibration),
		},
		{
				FT_CMD("get_force_calibration", get_force_calibration),
		},
		{
				FT_CMD("glove_mode", glove_mode),
		},
		{
				FT_CMD("hover_enable", hover_enable),
		},
		{
				FT_CMD("set_lowpower_mode", set_lowpower_mode),
		},
		{
				FT_CMD("set_log_level", set_log_level),
		},
		{
				FT_CMD("not_support_cmd", not_support_cmd),
		},
};

static struct attribute *cmd_attributes[] = {
		&dev_attr_cmd.attr,
		&dev_attr_cmd_status.attr,
		&dev_attr_cmd_list.attr,
		&dev_attr_cmd_result.attr,
		&dev_attr_scrub_pos.attr,
		&dev_attr_edge_pos.attr,
		NULL,
};

static struct attribute_group cmd_attr_group = {
		.attrs = cmd_attributes,
};

static void set_default_result(struct sec_ts_data *data) {
	char delim = ':';

	memset(data->cmd_result, 0x00, CMD_RESULT_STR_LEN);
	memcpy(data->cmd_result, data->cmd, strnlen(data->cmd, CMD_STR_LEN));
	strncat(data->cmd_result, &delim, 1);
}

static void set_cmd_result(struct sec_ts_data *data, char *buf, int length) {
	strncat(data->cmd_result, buf, length);
}

static ssize_t cmd_store(struct device *dev, struct device_attribute *attr,
												 const char *buf, size_t count) {
	unsigned char param_cnt = 0;
	char *start;
	char *end;
	char *pos;
	char delim = ',';
	char buffer[CMD_STR_LEN];
	bool cmd_found = false;
	int *param;
	int length;
	struct ft_cmd *ft_cmd_ptr = NULL;
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	int i;

	if (!ts) {
		pr_err("%s: No platform data found\n", __func__);
		return -EINVAL;
	}

#if 1
	if (ts->cmd_is_running == true) {
		input_err(true, &ts->client->dev, "%s: other cmd is running.\n", __func__);

		return -EBUSY;
	} else if (ts->reinit_done == false) {
		input_err(true, &ts->client->dev, "ft_cmd: reinit is working\n");
	}
#endif
	mutex_lock(&ts->cmd_lock);
	ts->cmd_is_running = true;
	mutex_unlock(&ts->cmd_lock);

	ts->cmd_state = CMD_STATUS_RUNNING;

	length = (int)count;
	if (*(buf + length - 1) == '\n')
		length--;

	memset(ts->cmd, 0x00, sizeof(ts->cmd));
	memcpy(ts->cmd, buf, length);
	memset(ts->cmd_param, 0, sizeof(ts->cmd_param));
	memset(buffer, 0x00, sizeof(buffer));

	pos = strchr(buf, (int)delim);
	if (pos)
		memcpy(buffer, buf, pos - buf);
	else
		memcpy(buffer, buf, length);

	/* find command */
	list_for_each_entry(ft_cmd_ptr, &ts->cmd_list_head, list) {
		if (!strcmp(buffer, ft_cmd_ptr->cmd_name)) {
			cmd_found = true;
			break;
		}
	}

	/* set not_support_cmd */
	if (!cmd_found) {
		list_for_each_entry(ft_cmd_ptr, &ts->cmd_list_head, list) {
			if (!strcmp("not_support_cmd", ft_cmd_ptr->cmd_name))
				break;
		}
	}

	/* parsing parameters */
	if (cmd_found && pos) {
		pos++;
		start = pos;
		memset(buffer, 0x00, sizeof(buffer));
		do {
			if ((*pos == delim) || (pos - buf == length)) {
				end = pos;
				memcpy(buffer, start, end - start);
				*(buffer + strlen(buffer)) = '\0';
				param = ts->cmd_param + param_cnt;
				if (kstrtoint(buffer, 10, param) < 0)
					goto err_out;
				param_cnt++;
				memset(buffer, 0x00, sizeof(buffer));
				start = pos + 1;
			}
			pos++;
		} while (pos - buf <= length);
	}

	input_err(true, &ts->client->dev, "%s: Command = %s\n", __func__, buf);
	for (i = 0; i < param_cnt; i++)
		input_info(true, &ts->client->dev, "cmd param %d= %d\n", i,
							 ts->cmd_param[i]);

	ft_cmd_ptr->cmd_func(ts);

err_out:
	return count;
}

static ssize_t cmd_status_show(struct device *dev,
															 struct device_attribute *attr, char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	char buffer[16];

	input_err(true, &ts->client->dev, "%s: Command status = %d\n", __func__,
						ts->cmd_state);

	switch (ts->cmd_state) {
	case CMD_STATUS_WAITING:
		snprintf(buffer, sizeof(buffer), "%s", tostring(WAITING));
		break;
	case CMD_STATUS_RUNNING:
		snprintf(buffer, sizeof(buffer), "%s", tostring(RUNNING));
		break;
	case CMD_STATUS_OK:
		snprintf(buffer, sizeof(buffer), "%s", tostring(OK));
		break;
	case CMD_STATUS_FAIL:
		snprintf(buffer, sizeof(buffer), "%s", tostring(FAIL));
		break;
	case CMD_STATUS_NOT_APPLICABLE:
		snprintf(buffer, sizeof(buffer), "%s", tostring(NOT_APPLICABLE));
		break;
	default:
		snprintf(buffer, sizeof(buffer), "%s", tostring(NOT_APPLICABLE));
		break;
	}

	return snprintf(buf, CMD_RESULT_STR_LEN, "%s\n", buffer);
}

static ssize_t cmd_result_show(struct device *dev,
															 struct device_attribute *attr, char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);

	input_info(true, &ts->client->dev, "%s: Command result = %s\n", __func__,
						 ts->cmd_result);

	mutex_lock(&ts->cmd_lock);
	ts->cmd_is_running = false;
	mutex_unlock(&ts->cmd_lock);

	ts->cmd_state = CMD_STATUS_WAITING;

	return snprintf(buf, CMD_RESULT_STR_LEN, "%s\n", ts->cmd_result);
}
/*
static ssize_t cmd_list_show(struct device *dev, struct device_attribute *attr,
														 char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	char buffer[ts->cmd_buffer_size];
	char buffer_name[CMD_STR_LEN];
	int ii = 0;

	snprintf(buffer, CMD_STR_LEN, "++factory command list++\n");
	while (strncmp(ft_cmds[ii].cmd_name, "not_support_cmd", 16) != 0) {
		snprintf(buffer_name, CMD_STR_LEN, "%s\n", ft_cmds[ii].cmd_name);
		strcat(buffer, buffer_name);
		ii++;
	}

	input_info(true, &ts->client->dev, "%s: length : %u / %d\n", __func__,
						 (unsigned int)strlen(buffer), ts->cmd_buffer_size + CMD_STR_LEN);

	return snprintf(buf, SEC_CMD_BUF_SIZE, "%s\n", buffer);
}
*/

static ssize_t cmd_list_show(struct device *dev, struct device_attribute *attr,
                                 char *buf) {
        struct sec_ts_data *ts = dev_get_drvdata(dev);
        char *buffer;
        char buffer_name[CMD_STR_LEN];
        int ii = 0;
        int ret;

        buffer = kzalloc(ts->cmd_buffer_size, GFP_KERNEL);
        if (!buffer)
                return -ENOMEM;

        snprintf(buffer, CMD_STR_LEN, "++factory command list++\n");
        while (strncmp(ft_cmds[ii].cmd_name, "not_support_cmd", 16) != 0) {
                snprintf(buffer_name, CMD_STR_LEN, "%s\n", ft_cmds[ii].cmd_name);
                strcat(buffer, buffer_name);
                ii++;
        }
        input_info(true, &ts->client->dev, "%s: length : %u / %d\n", __func__,
                                                 (unsigned int)strlen(buffer), ts->cmd_buffer_size + CMD_STR_LEN);
        ret = snprintf(buf, SEC_CMD_BUF_SIZE, "%s\n", buffer);
        kfree(buffer);
        return ret;
}

static ssize_t scrub_position_show(struct device *dev,
																	 struct device_attribute *attr, char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	char buff[256] = {0};

	input_info(true, &ts->client->dev, "%s: scrub_id: %d, X:%d, Y:%d\n", __func__,
						 ts->scrub_id, ts->scrub_x, ts->scrub_y);

	snprintf(buff, sizeof(buff), "%d %d %d", ts->scrub_id, ts->scrub_x,
					 ts->scrub_y);

	ts->scrub_id = 0;
	ts->scrub_x = 0;
	ts->scrub_y = 0;

	return snprintf(buf, PAGE_SIZE, "%s", buff);
}

static ssize_t edge_x_position(struct device *dev,
															 struct device_attribute *attr, char *buf) {
	struct sec_ts_data *ts = dev_get_drvdata(dev);
	char buff[256] = {0};
	int edge_position_left = 0, edge_position_right = 0;

	if (!ts) {
		pr_err("%s: No platform data found\n", __func__);
		return -EINVAL;
	}

	if (!ts->input_dev) {
		pr_err("%s: No input_dev data found\n", __func__);
		return -EINVAL;
	}

	input_info(true, &ts->client->dev, "%s: %d,%d\n", __func__,
						 edge_position_left, edge_position_right);
	snprintf(buff, sizeof(buff), "%d,%d", edge_position_left,
					 edge_position_right);

	return snprintf(buf, SEC_CMD_BUF_SIZE, "%s\n", buff);
}
static void fw_update(void *device_data) {
#ifdef CONFIG_6FT0
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[64] = {0};
	int retval = 0;

	set_default_result(ts);
	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_info(true, &ts->client->dev, "%s: [ERROR] Touch is stopped\n",
							 __func__);
		snprintf(buff, sizeof(buff), "%s", "TSP turned off");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_NOT_APPLICABLE;
		return;
	}

	retval = sec_ts_firmware_update_on_hidden_menu(ts, ts->cmd_param[0]);
	if (retval < 0) {
		snprintf(buff, sizeof(buff), "%s", "NA");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_FAIL;
		input_info(true, &ts->client->dev, "%s: failed [%d]\n", __func__, retval);
	} else {
		snprintf(buff, sizeof(buff), "%s", "OK");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_OK;
		input_info(true, &ts->client->dev, "%s: success [%d]\n", __func__, retval);
	}
#endif
}

void sec_ts_print_frame(struct sec_ts_data *ts, short *min, short *max) {
	int i = 0;
	int j = 0;
	unsigned char *pStr = NULL;
	unsigned char pTmp[16] = {0};

	pStr = kzalloc(6 * (ts->tx_count + 1), GFP_KERNEL);
	if (pStr == NULL) {
		pr_err("%s: kzalloc %d bytes failed for pStr\n", __func__,
					 6 * (ts->tx_count + 1));
		return;
	}

	snprintf(pTmp, sizeof(pTmp), "    ");
	strncat(pStr, pTmp, 6 * ts->tx_count);

	for (i = 0; i < ts->tx_count; i++) {
		snprintf(pTmp, sizeof(pTmp), "Tx%02d  ", i);
		strncat(pStr, pTmp, 6 * ts->tx_count);
	}

	input_info(true, &ts->client->dev, "SEC_TS %s\n", pStr);
	memset(pStr, 0x0, 6 * (ts->tx_count + 1));
	snprintf(pTmp, sizeof(pTmp), " +");
	strncat(pStr, pTmp, 6 * ts->tx_count);

	for (i = 0; i < ts->tx_count; i++) {
		snprintf(pTmp, sizeof(pTmp), "------");
		strncat(pStr, pTmp, 6 * ts->rx_count);
	}

	input_info(true, &ts->client->dev, "SEC_TS %s\n", pStr);

	for (i = 0; i < ts->rx_count; i++) {
		memset(pStr, 0x0, 6 * (ts->tx_count + 1));
		snprintf(pTmp, sizeof(pTmp), "Rx%02d | ", i);
		strncat(pStr, pTmp, 6 * ts->tx_count);

		for (j = 0; j < ts->tx_count; j++) {
			snprintf(pTmp, sizeof(pTmp), "%5d ", ts->pFrame[(j * ts->rx_count) + i]);

			if (i > 0) {
				if (ts->pFrame[(j * ts->rx_count) + i] < *min)
					*min = ts->pFrame[(j * ts->rx_count) + i];

				if (ts->pFrame[(j * ts->rx_count) + i] > *max)
					*max = ts->pFrame[(j * ts->rx_count) + i];
			}
			strncat(pStr, pTmp, 6 * ts->rx_count);
		}
		input_info(true, &ts->client->dev, "SEC_TS %s\n", pStr);
	}
	kfree(pStr);
}

int sec_ts_read_frame(struct sec_ts_data *ts, u8 type, short *min, short *max) {
	unsigned int readbytes = 0xFF;
	unsigned char *pRead = NULL;
	u8 mode = TYPE_INVALID_DATA;
	int rc = 0;
	int ret = 0;
	int i = 0;
	int j = 0;
	short *temp = NULL;

	input_info(true, &ts->client->dev, "%s\n", __func__);

	/* set data length, allocation buffer memory */
	readbytes = ts->rx_count * ts->tx_count * 2;

	pRead = kzalloc(readbytes, GFP_KERNEL);
	if (pRead == NULL) {
		rc = 1;
		pr_err("%s: kzalloc %d bytes failed for pRead\n", __func__, readbytes);
		return rc;
	}

	/* set OPCODE and data type */
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_MUTU_RAW_TYPE, &type, 1);
	if (ret < 0) {
		input_info(true, &ts->client->dev, "Set rawdata type failed\n");
		rc = 2;
		goto ErrorExit;
	}

	sec_ts_delay(50);
	if (type == TYPE_OFFSET_DATA_SDC) {
		/* excute selftest for real cap offset data,
		* because real cap data is not memory data in normal touch.
		*/
		char para = TO_TOUCH_MODE;

		disable_irq(ts->client->irq);
		execute_selftest(ts);
		ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SET_POWER_MODE, &para, 1);
		if (ret < 0) {
			input_err(true, &ts->client->dev, "%s: set rawdata type failed!\n",
								__func__);
			enable_irq(ts->client->irq);
			goto ErrorRelease;
		}
		enable_irq(ts->client->irq);
		/* end */
	}

	/* read data */
	ret = ts->sec_ts_i2c_read(ts, SEC_TS_READ_TOUCH_RAWDATA, pRead, readbytes);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: read rawdata failed!\n", __func__);
		rc = 3;
		goto ErrorRelease;
	}

	memset(ts->pFrame, 0x00, readbytes);

	for (i = 0; i < readbytes; i += 2)
		ts->pFrame[i / 2] = pRead[i + 1] + (pRead[i] << 8);

	*min = *max = ts->pFrame[0];

#ifdef DEBUG_MSG
	input_info(true, &ts->client->dev, "02X%02X%02X readbytes=%d\n", pRead[0],
						 pRead[1], pRead[2], readbytes);
#endif
	sec_ts_print_frame(ts, min, max);

	temp = kzalloc(readbytes, GFP_KERNEL);
	if (temp == NULL) {
		pr_err("%s: kzalloc %d bytes failed for temp\n", __func__, readbytes);
		goto ErrorRelease;
	}

	memcpy(temp, ts->pFrame, readbytes);
	memset(ts->pFrame, 0x00, readbytes);

	for (i = 0; i < ts->tx_count; i++) {
		for (j = 0; j < ts->rx_count; j++)
			ts->pFrame[(j * ts->tx_count) + i] = temp[(i * ts->rx_count) + j];
	}

	kfree(temp);

ErrorRelease:
	/* release data monitory (unprepare AFE data memory) */
	ret = ts->sec_ts_i2c_read(ts, SEC_TS_CMD_MUTU_RAW_TYPE, &mode, 1);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s: set rawdata failed!\n", __func__);

ErrorExit:
	kfree(pRead);

	return rc;
}

void sec_ts_print_self_frame(struct sec_ts_data *ts, short *min, short *max,
														 unsigned int num_long_ch,
														 unsigned int num_short_ch) {
	int i = 0;
	unsigned char *pStr = NULL;
	unsigned char pTmp[16] = {0};

	pStr = kzalloc(6 * (num_short_ch + 1), GFP_KERNEL);
	if (pStr == NULL) {
		pr_err("%s: kzalloc %d bytes failed for pStr\n", __func__,
					 6 * (num_short_ch + 1));
		return;
	}

	snprintf(pTmp, sizeof(pTmp), "          ");
	strncat(pStr, pTmp, 6 * num_short_ch);

	for (i = 0; i < num_short_ch; i++) {
		snprintf(pTmp, sizeof(pTmp), "Sc%02d  ", i);
		strncat(pStr, pTmp, 6 * num_short_ch);
	}

	input_info(true, &ts->client->dev, "SEC_TS %s\n", pStr);
	memset(pStr, 0x0, 6 * (num_short_ch + 1));
	snprintf(pTmp, sizeof(pTmp), "      +");
	strncat(pStr, pTmp, 6 * num_short_ch);

	for (i = 0; i < num_short_ch; i++) {
		snprintf(pTmp, sizeof(pTmp), "------");
		strncat(pStr, pTmp, 6 * num_short_ch);
	}

	input_info(true, &ts->client->dev, "SEC_TS %s\n", pStr);

	memset(pStr, 0x0, 6 * (num_short_ch + 1));
	for (i = 0; i < num_short_ch; i++) {
		snprintf(pTmp, sizeof(pTmp), "%5d ", ts->sFrame[i]);
		strncat(pStr, pTmp, 6 * num_short_ch);
		if (ts->sFrame[i] < *min)
			*min = ts->sFrame[i];
		if (ts->sFrame[i] > *max)
			*max = ts->sFrame[i];
	}

	input_info(true, &ts->client->dev, "SEC_TS        %s\n", pStr);

	for (i = 0; i < num_long_ch; i++) {
		memset(pStr, 0x0, 6 * (num_short_ch + 1));
		snprintf(pTmp, sizeof(pTmp), "Lc%02d | ", i);
		strncat(pStr, pTmp, 6 * num_short_ch);
		snprintf(pTmp, sizeof(pTmp), "%5d ", ts->sFrame[num_short_ch + i]);
		strncat(pStr, pTmp, 6 * num_short_ch);

		if (ts->sFrame[num_short_ch + i] < *min)
			*min = ts->sFrame[num_short_ch + i];
		if (ts->sFrame[num_short_ch + i] > *max)
			*max = ts->sFrame[num_short_ch + i];

		input_info(true, &ts->client->dev, "SEC_TS %s\n", pStr);
	}
	kfree(pStr);
}

#define PRE_DEFINED_DATA_LENGTH 208
static void get_fw_ver_bin(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};

	set_default_result(ts);

	sprintf(buff, "SE%02X%02X%02X", ts->plat_data->panel_revision,
					ts->plat_data->img_version_of_bin[2],
					ts->plat_data->img_version_of_bin[3]);

	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_fw_ver_ic(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};
	u8 img_ver[4];
	int ret;

	set_default_result(ts);

	ret = ts->sec_ts_i2c_read(ts, SEC_TS_READ_IMG_VERSION, img_ver, 4);
	if (ret < 0) {
		input_info(true, &ts->client->dev, "%s: Image version read error\n ",
							 __func__);
		ts->cmd_state = CMD_STATUS_FAIL;
	}

	sprintf(buff, "SE%02X%02X%02X", ts->plat_data->panel_revision, img_ver[2],
					img_ver[3]);

	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_config_ver(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[20] = {0};

	set_default_result(ts);

	sprintf(buff, "%s_SE_%02X%02X",
					ts->plat_data->project_name ?: ts->plat_data->model_name
																						 ?: SEC_TS_DEVICE_NAME,
					ts->plat_data->para_version_of_ic[2],
					ts->plat_data->para_version_of_ic[3]);

	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_threshold(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[20] = {0};

	char w_param[1];
	char r_param[2];
	int threshold = 0;
	int ret;

	set_default_result(ts);

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		char buff[CMD_STR_LEN] = {0};

		input_info(true, &ts->client->dev, "%s: [ERROR] Touch is stopped\n",
							 __func__);
		snprintf(buff, sizeof(buff), "%s", "TSP turned off");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_NOT_APPLICABLE;
		return;
	}

	w_param[0] = 0;
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_READ_THRESHOLD, w_param, 1);
	if (ret < 0)
		input_err(true, &ts->client->dev,
							"%s: threshold write type failed. ret: %d\n", __func__, ret);

	ret = ts->sec_ts_i2c_read_bulk(ts, r_param, 2);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s threshold read failed. ret: %d\n",
							__func__, ret);

	threshold = (r_param[0] << 8 | r_param[1]);
	snprintf(buff, sizeof(buff), "%d", threshold);

	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void module_off_master(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[3] = {0};
	int ret = 0;

	mutex_lock(&ts->lock);
	if (ts->power_status) {
		disable_irq(ts->client->irq);
		ts->power_status = SEC_TS_STATE_POWER_OFF;
	}
	mutex_unlock(&ts->lock);

	if (ts->plat_data->power)
		ts->plat_data->power(ts, false);
	else
		ret = 1;

	if (ret == 0)
		snprintf(buff, sizeof(buff), "%s", "OK");
	else
		snprintf(buff, sizeof(buff), "%s", "NG");

	set_default_result(ts);
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	if (strncmp(buff, "OK", 2) == 0)
		ts->cmd_state = CMD_STATUS_OK;
	else
		ts->cmd_state = CMD_STATUS_FAIL;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void module_on_master(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[3] = {0};
	int ret = 0;

	mutex_lock(&ts->lock);
	if (!ts->power_status) {
		enable_irq(ts->client->irq);
		ts->power_status = SEC_TS_STATE_POWER_ON;
	}
	mutex_unlock(&ts->lock);

	if (ts->plat_data->power) {
		ts->plat_data->power(ts, true);
		ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SENSE_ON, NULL, 0);
		if (ret < 0)
			input_err(true, &ts->client->dev, "%s: fail to write Sense_on\n",
								__func__);
	} else
		ret = 1;

	if (ret == 0)
		snprintf(buff, sizeof(buff), "%s", "OK");
	else
		snprintf(buff, sizeof(buff), "%s", "NG");

	set_default_result(ts);
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	if (strncmp(buff, "OK", 2) == 0)
		ts->cmd_state = CMD_STATUS_OK;
	else
		ts->cmd_state = CMD_STATUS_FAIL;

	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_chip_vendor(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};

	strncpy(buff, "SEC", sizeof(buff));
	set_default_result(ts);
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_chip_name(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};

	if (ts->plat_data->img_version_of_ic[0] == 2)
		strncpy(buff, "MC44", sizeof(buff));
	else if (ts->plat_data->img_version_of_ic[0] == 5)
		strncpy(buff, "A552", sizeof(buff));

	set_default_result(ts);
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_x_num(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};

	set_default_result(ts);
	snprintf(buff, sizeof(buff), "%d", ts->tx_count);
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = 2;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_y_num(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};

	set_default_result(ts);
	snprintf(buff, sizeof(buff), "%d", ts->rx_count);
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_x_cross_routing(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};

	set_default_result(ts);
	snprintf(buff, sizeof(buff), "NG");
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_y_cross_routing(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};
	int ret;

	set_default_result(ts);

	ret = strncmp(ts->plat_data->model_name, "G935", 4);
	if (ret == 0)
		snprintf(buff, sizeof(buff), "13,14");
	else
		snprintf(buff, sizeof(buff), "NG");
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void get_checksum_data(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[16] = {0};
	char csum_result[4] = {0};
	u8 nv_result;
	u8 cal_result;
	u8 temp = 0;
	u8 csum = 0;
	int ret, i;

	set_default_result(ts);
	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_info(true, &ts->client->dev, "%s: [ERROR] Touch is stopped\n",
							 __func__);
		snprintf(buff, sizeof(buff), "%s", "TSP turned off");
		goto err;
	}

	temp = DO_FW_CHECKSUM | DO_PARA_CHECKSUM;
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_GET_CHECKSUM, &temp, 1);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: send get_checksum_cmd fail!\n",
							__func__);
		snprintf(buff, sizeof(buff), "%s", "SendCMDfail");
		goto err;
	}

	sec_ts_delay(20);

	ret = ts->sec_ts_i2c_read_bulk(ts, csum_result, 4);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: read get_checksum result fail!\n",
							__func__);
		snprintf(buff, sizeof(buff), "%s", "ReadCSUMfail");
		goto err;
	}

	nv_result = get_tsp_nvm_data(ts, SEC_TS_NVM_OFFSET_FAC_RESULT);
	nv_result += get_tsp_nvm_data(ts, SEC_TS_NVM_OFFSET_CAL_COUNT);

	cal_result = sec_ts_read_calibration_report(ts);

	for (i = 0; i < 4; i++)
		csum += csum_result[i];

	csum += temp;
	csum += cal_result;
	csum = ~csum;

	input_info(true, &ts->client->dev, "%s: checksum = %02X\n", __func__, csum);
	snprintf(buff, sizeof(buff), "%02X", csum);
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	return;

err:
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_NOT_APPLICABLE;
}

static void set_tsp_nvm_data_clear(struct sec_ts_data *ts) {
	char buff[4] = {0};
	int ret;

	input_info(true, &ts->client->dev, "%s\n", __func__);

	/* Use TSP NV area
	 * buff[0] : offset from user NVM storage
	 * buff[1] : length of stroed data - 1 (ex. using 1byte, value is  1 - 1 = 0)
	 * buff[2] : write data
	 */
	buff[1] = 2 - 1;
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_NVM, buff, 4);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s nvm write failed. ret: %d\n",
							__func__, ret);

	sec_ts_delay(20);

	ts->nv = get_tsp_nvm_data(ts, SEC_TS_NVM_OFFSET_FAC_RESULT);
	ts->cal_count = get_tsp_nvm_data(ts, SEC_TS_NVM_OFFSET_CAL_COUNT);

	input_info(true, &ts->client->dev, "%s: fac_nv:%02X, cal_nv:%02X\n", __func__,
						 ts->nv, ts->cal_count);
}

int get_tsp_nvm_data(struct sec_ts_data *ts, u8 offset) {
	char buff[2] = {0};
	int ret;

	input_info(true, &ts->client->dev, "%s, offset:%u\n", __func__, offset);

	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SENSE_OFF, NULL, 0);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: sense off failed\n", __func__);
		goto out_nvm;
	}
	input_dbg(true, &ts->client->dev, "%s: SENSE OFF\n", __func__);

	sec_ts_delay(100);

	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_CLEAR_EVENT_STACK, NULL, 0);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: clear event failed\n", __func__);
		goto out_nvm;
	}
	input_dbg(true, &ts->client->dev, "%s: CLEAR EVENT STACK\n", __func__);

	sec_ts_delay(100);

	sec_ts_release_all_finger(ts);

	/* send NV data using command
	 * Use TSP NV area : in this model, use only one byte
	 * buff[0] : offset from user NVM storage
	 * buff[1] : length of stroed data - 1 (ex. using 1byte, value is  1 - 1 = 0)
	 */
	memset(buff, 0x00, 2);
	buff[0] = offset;
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_NVM, buff, 2);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s nvm send command failed. ret: %d\n",
							__func__, ret);
		goto out_nvm;
	}

	sec_ts_delay(10);

	/* read NV data
	 * Use TSP NV area : in this model, use only one byte
	 */
	ret = ts->sec_ts_i2c_read_bulk(ts, buff, 1);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s nvm send command failed. ret: %d\n",
							__func__, ret);
		goto out_nvm;
	}

	input_info(true, &ts->client->dev, "%s: data:%X\n", __func__, buff[0]);

out_nvm:
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SENSE_ON, NULL, 0);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s: sense on failed\n", __func__);

	input_dbg(true, &ts->client->dev, "%s: SENSE ON\n", __func__);

	return buff[0];
}

/* FACTORY TEST RESULT SAVING FUNCTION
 * bit 3 ~ 0 : OCTA Assy
 * bit 7 ~ 4 : OCTA module
 * param[0] : OCTA modue(1) / OCTA Assy(2)
 * param[1] : TEST NONE(0) / TEST FAIL(1) / TEST PASS(2) : 2 bit
 */

#define TEST_OCTA_MODULE 1
#define TEST_OCTA_ASSAY 2

#define TEST_OCTA_NONE 0
#define TEST_OCTA_FAIL 1
#define TEST_OCTA_PASS 2

#define GLOVE_MODE_EN (1 << 0)
#define FAST_GLOVE_MODE_EN (1 << 2)

static void glove_mode(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	int glove_mode_enables = 0;

	set_default_result(ts);

	if (ts->cmd_param[0] < 0 || ts->cmd_param[0] > 1) {
		snprintf(ts->cmd_buff, sizeof(ts->cmd_buff), "NG");
		ts->cmd_state = CMD_STATUS_FAIL;
	} else {
		int retval;

		if (ts->cmd_param[0])
			glove_mode_enables |= GLOVE_MODE_EN;
		else
			glove_mode_enables &= ~(GLOVE_MODE_EN);

		retval = sec_ts_glove_mode_enables(ts, glove_mode_enables);

		if (retval < 0) {
			input_err(true, &ts->client->dev, "%s failed, retval = %d\n", __func__,
								retval);
			snprintf(ts->cmd_buff, sizeof(ts->cmd_buff), "NG");
			ts->cmd_state = CMD_STATUS_FAIL;
		} else {
			snprintf(ts->cmd_buff, sizeof(ts->cmd_buff), "OK");
			ts->cmd_state = CMD_STATUS_OK;
		}
	}

	set_cmd_result(ts, ts->cmd_buff, strlen(ts->cmd_buff));

	mutex_lock(&ts->cmd_lock);
	ts->cmd_is_running = false;
	mutex_unlock(&ts->cmd_lock);

	ts->cmd_state = CMD_STATUS_WAITING;
}

static void hover_enable(void *device_data) {
	int enables;
	int retval;
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;

	input_info(true, &ts->client->dev, "%s: enter hover enable, param = %d\n",
						 __func__, ts->cmd_param[0]);

	set_default_result(ts);

	if (ts->cmd_param[0] < 0 || ts->cmd_param[0] > 1) {
		snprintf(ts->cmd_buff, sizeof(ts->cmd_buff), "NG");
		ts->cmd_state = CMD_STATUS_FAIL;
	} else {
		enables = ts->cmd_param[0];
		retval = sec_ts_hover_enables(ts, enables);

		if (retval < 0) {
			input_err(true, &ts->client->dev, "%s failed, retval = %d\n", __func__,
								retval);
			snprintf(ts->cmd_buff, sizeof(ts->cmd_buff), "NG");
			ts->cmd_state = CMD_STATUS_FAIL;
		} else {
			snprintf(ts->cmd_buff, sizeof(ts->cmd_buff), "OK");
			ts->cmd_state = CMD_STATUS_OK;
		}
	}

	set_cmd_result(ts, ts->cmd_buff, strlen(ts->cmd_buff));
	mutex_lock(&ts->cmd_lock);
	ts->cmd_is_running = false;
	mutex_unlock(&ts->cmd_lock);

	ts->cmd_state = CMD_STATUS_WAITING;
}

static void sec_ts_swap(u8 *a, u8 *b) {
	u8 temp = *a;
	*a = *b;
	*b = temp;
}

static void rearrange_sft_result(u8 *data, int length) {
	int i;

	for (i = 0; i < length; i += 4) {
		sec_ts_swap(&data[i], &data[i + 3]);
		sec_ts_swap(&data[i + 1], &data[i + 2]);
	}
}

static int execute_selftest(struct sec_ts_data *ts) {
	int rc;
	u8 tpara = 0x23;
	u8 *rBuff;
	int i;
	int result = 0;
	int result_size =
			SEC_TS_SELFTEST_REPORT_SIZE + ts->tx_count * ts->rx_count * 2;

	input_info(true, &ts->client->dev, "%s: Self test start!\n", __func__);
	rc = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SELFTEST, &tpara, 1);
	if (rc < 0) {
		input_err(true, &ts->client->dev, "%s: Send selftest cmd failed!\n",
							__func__);
		goto err_exit;
	}
	sec_ts_delay(350);

	rc = sec_ts_wait_for_ready(ts, SEC_TS_ACK_SELF_TEST_DONE);
	if (rc < 0) {
		input_err(true, &ts->client->dev, "%s: Selftest execution time out!\n",
							__func__);
		goto err_exit;
	}

	input_info(true, &ts->client->dev, "%s: Self test done!\n", __func__);

	rBuff = kzalloc(result_size, GFP_KERNEL);
	if (!rBuff) {
		pr_err("%s: kzalloc %d bytes failed for rBuff\n", __func__, result_size);
		goto err_exit;
	}

	rc = ts->sec_ts_i2c_read(ts, SEC_TS_READ_SELFTEST_RESULT, rBuff, result_size);
	if (rc < 0) {
		input_err(true, &ts->client->dev, "%s: Selftest execution time out!\n",
							__func__);
		goto err_exit;
	}
	rearrange_sft_result(rBuff, result_size);

	for (i = 0; i < 80; i += 4) {
		if (i % 8 == 0)
			pr_cont("\n");
		if (i % 4 == 0)
			pr_cont("sec_ts : ");

		if (i / 4 == 0)
			pr_cont("SIG");
		else if (i / 4 == 1)
			pr_cont("VER");
		else if (i / 4 == 2)
			pr_cont("SIZ");
		else if (i / 4 == 3)
			pr_cont("CRC");
		else if (i / 4 == 4)
			pr_cont("RES");
		else if (i / 4 == 5)
			pr_cont("COU");
		else if (i / 4 == 6)
			pr_cont("PAS");
		else if (i / 4 == 7)
			pr_cont("FAI");
		else if (i / 4 == 8)
			pr_cont("CHA");
		else if (i / 4 == 9)
			pr_cont("AMB");
		else if (i / 4 == 10)
			pr_cont("RXS");
		else if (i / 4 == 11)
			pr_cont("TXS");
		else if (i / 4 == 12)
			pr_cont("RXO");
		else if (i / 4 == 13)
			pr_cont("TXO");
		else if (i / 4 == 14)
			pr_cont("RXG");
		else if (i / 4 == 15)
			pr_cont("TXG");
		else if (i / 4 == 16)
			pr_cont("RXR");
		else if (i / 4 == 17)
			pr_cont("TXT");
		else if (i / 4 == 18)
			pr_cont("RXT");
		else if (i / 4 == 19)
			pr_cont("TXR");

		pr_cont(" %2X, %2X, %2X, %2X  ", rBuff[i], rBuff[i + 1], rBuff[i + 2],
						rBuff[i + 3]);

		if (i / 4 == 4) {
			if ((rBuff[i + 3] & 0x30) != 0) /*RX, RX open check.*/
				result = 0;
			else
				result = 1;
		}
	}

	return result;
err_exit:

	return 0;
}

int sec_ts_execute_force_calibration(struct sec_ts_data *ts, int cal_mode) {
	int rc = -1;
	u8 cmd = 0;

	if (cal_mode == OFFSET_CAL_SEC)
		cmd = SEC_TS_CMD_CALIBRATION_OFFSET_SDC;
	else if (cal_mode == AMBIENT_CAL)
		cmd = SEC_TS_CMD_CALIBRATION_AMBIENT;

	if (ts->sec_ts_i2c_write(ts, cmd, NULL, 0) < 0) {
		input_err(true, &ts->client->dev, "%s: Write Cal commend failed!\n",
							__func__);
		return rc;
	}

	sec_ts_delay(1000);

	rc = sec_ts_wait_for_ready(ts, SEC_TS_ACK_OFFSET_CAL_DONE);

	ts->cal_status = sec_ts_read_calibration_report(ts);
	return rc;
}

static void get_force_calibration(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[CMD_STR_LEN] = {0};
	char cal_result[4] = {0};

	set_default_result(ts);

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_info(true, &ts->client->dev, "%s: Touch is stopped!\n", __func__);
		snprintf(buff, sizeof(buff), "%s", "TSP turned off");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_NOT_APPLICABLE;
		return;
	}

	cal_result[0] = sec_ts_read_calibration_report(ts);

	if (cal_result[0] == SEC_TS_STATUS_CALIBRATION_SEC) {
		snprintf(buff, sizeof(buff), "%s", "OK");
		ts->cmd_state = CMD_STATUS_OK;
	} else {
		snprintf(buff, sizeof(buff), "%s", "NG");
	}

	input_info(true, &ts->client->dev, "%s: %d, %d\n", __func__, cal_result[0],
						 (cal_result[0] == SEC_TS_STATUS_CALIBRATION_SEC));

	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}

static void run_force_calibration(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[CMD_STR_LEN] = {0};
	int rc;

	set_default_result(ts);

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_info(true, &ts->client->dev, "%s: Touch is stopped!\n", __func__);
		snprintf(buff, sizeof(buff), "%s", "TSP turned off");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_NOT_APPLICABLE;
		return;
	}

	sec_ts_read_calibration_report(ts);

	if (ts->touch_count > 0) {
		snprintf(buff, sizeof(buff), "%s", "NG_FINGER_ON");
		ts->cmd_state = CMD_STATUS_FAIL;
		goto out_force_cal;
	}

	disable_irq(ts->client->irq);

	rc = sec_ts_execute_force_calibration(ts, OFFSET_CAL_SEC);
	if (rc < 0) {
		snprintf(buff, sizeof(buff), "%s", "FAIL");
		ts->cmd_state = CMD_STATUS_FAIL;
	} else {
#ifdef CALIBRATION_BY_FACTORY
		buff[0] = get_tsp_nvm_data(ts, SEC_TS_NVM_OFFSET_FAC_RESULT);
		buff[1] = get_tsp_nvm_data(ts, SEC_TS_NVM_OFFSET_CAL_COUNT);
		if (buff[0] == 0 && buff[1] == 0)
			set_tsp_nvm_data_clear(ts);
		else if (buff[1] == 0xFF)
			buff[1] = 0;

		/* count the number of calibration */
		if (buff[1] < 0xFE)
			ts->cal_count = buff[1] + 1;

		/* Use TSP NV area : in this model, use only one byte
		 * buff[0] : offset from user NVM storage
		 * buff[1] : length of stored data - 1 (ex. using 1byte, value is  1 - 1 =
		 * 0)
		 * buff[2] : write data
		 */
		buff[0] = SEC_TS_NVM_OFFSET_CAL_COUNT;
		buff[1] = 0;
		buff[2] = ts->cal_count;

		input_info(true, &ts->client->dev, "%s: write to nvm %X\n", __func__,
							 buff[2]);

		rc = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_NVM, buff, 3);
		if (rc < 0) {
			input_err(true, &ts->client->dev, "%s nvm write failed. ret: %d\n",
								__func__, rc);
		}

		sec_ts_delay(20);

		ts->cal_count = get_tsp_nvm_data(ts, SEC_TS_NVM_OFFSET_CAL_COUNT);
#endif
		snprintf(buff, sizeof(buff), "%s", "OK");
		ts->cmd_state = CMD_STATUS_OK;
	}

	enable_irq(ts->client->irq);

out_force_cal:
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));

	mutex_lock(&ts->cmd_lock);
	ts->cmd_is_running = false;
	mutex_unlock(&ts->cmd_lock);

	input_info(true, &ts->client->dev, "%s: %s\n", __func__, buff);
}
static void set_log_level(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[CMD_STR_LEN] = {0};
	char tBuff[2] = {0};
	int ret;

	set_default_result(ts);

	if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
		input_err(true, &ts->client->dev, "%s: Touch is stopped!\n", __func__);
		snprintf(buff, sizeof(buff), "%s", "TSP turned off");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_FAIL;
		return;
	}

	if ((ts->cmd_param[0] < 0 || ts->cmd_param[0] > 1) ||
			(ts->cmd_param[1] < 0 || ts->cmd_param[1] > 1) ||
			(ts->cmd_param[2] < 0 || ts->cmd_param[2] > 1) ||
			(ts->cmd_param[3] < 0 || ts->cmd_param[3] > 1)) {
		input_err(true, &ts->client->dev, "%s: para out of range\n", __func__);
		snprintf(buff, sizeof(buff), "%s", "Para out of range");
		set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
		ts->cmd_state = CMD_STATUS_FAIL;
		return;
	}

	ret = ts->sec_ts_i2c_read(ts, SEC_TS_CMD_STATUS_EVENT_TYPE, tBuff, 2);
	if (ret < 0) {
		input_err(true, &ts->client->dev,
							"%s: Read Event type enable status fail\n", __func__);
		snprintf(buff, sizeof(buff), "%s", "Read Stat Fail");
		goto err;
	}

	input_info(true, &ts->client->dev,
						 "%s: STATUS_EVENT enable = 0x%02X, 0x%02X\n", __func__, tBuff[0],
						 tBuff[1]);

	tBuff[0] = 0x0;
	tBuff[1] = BIT_STATUS_EVENT_ACK(ts->cmd_param[0]) |
						 BIT_STATUS_EVENT_ERR(ts->cmd_param[1]) |
						 BIT_STATUS_EVENT_INFO(ts->cmd_param[2]) |
						 BIT_STATUS_EVENT_GEST(ts->cmd_param[3]);

	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_STATUS_EVENT_TYPE, tBuff, 2);
	if (ret < 0) {
		input_err(true, &ts->client->dev,
							"%s: Write Event type enable status fail\n", __func__);
		snprintf(buff, sizeof(buff), "%s", "Write Stat Fail");
		goto err;
	}
	input_info(true, &ts->client->dev,
						 "%s: ACK : %d, ERR : %d, INFO : %d, GEST : %d\n", __func__,
						 ts->cmd_param[0], ts->cmd_param[1], ts->cmd_param[2],
						 ts->cmd_param[3]);

	snprintf(buff, sizeof(buff), "%s", "OK");
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_OK;
	return;
err:
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	ts->cmd_state = CMD_STATUS_NOT_APPLICABLE;
}

bool check_lowpower_flag(struct sec_ts_data *ts) {
	bool ret = 0;
	unsigned char flag = ts->lowpower_flag & 0xFF;

	if (flag)
		ret = 1;

	input_info(true, &ts->client->dev, "%s: lowpower_mode flag : %d, ret:%d\n",
						 __func__, flag, ret);

	if (flag & SEC_TS_LOWP_FLAG_AOD)
		input_info(true, &ts->client->dev, "%s: aod cmd on\n", __func__);
	if (flag & SEC_TS_LOWP_FLAG_SPAY)
		input_info(true, &ts->client->dev, "%s: spay cmd on\n", __func__);
	if (flag & SEC_TS_LOWP_FLAG_SIDE_GESTURE)
		input_info(true, &ts->client->dev, "%s: side cmd on\n", __func__);

	return ret;
}

static void set_lowpower_mode(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;
	char buff[CMD_STR_LEN] = {0};

	set_default_result(ts);

	if (ts->cmd_param[0] < 0 || ts->cmd_param[0] > 1) {
		goto set_lowpower_fail;
	} else {
		if (ts->power_status == SEC_TS_STATE_POWER_OFF) {
			input_err(true, &ts->client->dev, "%s: ERR, POWER OFF\n", __func__);
			goto set_lowpower_fail;
		}

		ts->lowpower_mode = ts->cmd_param[0];
	}

	snprintf(buff, sizeof(buff), "%s", "OK");
	ts->cmd_state = CMD_STATUS_OK;
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
	return;

set_lowpower_fail:
	snprintf(buff, sizeof(buff), "%s", "set_lowpower_fail");
	ts->cmd_state = CMD_STATUS_FAIL;
	set_cmd_result(ts, buff, strnlen(buff, sizeof(buff)));
}

static void not_support_cmd(void *device_data) {
	struct sec_ts_data *ts = (struct sec_ts_data *)device_data;

	set_default_result(ts);
	snprintf(ts->cmd_buff, sizeof(ts->cmd_buff), "%s", tostring(NA));

	set_cmd_result(ts, ts->cmd_buff, strlen(ts->cmd_buff));
	ts->cmd_state = CMD_STATUS_NOT_APPLICABLE;

	mutex_lock(&ts->cmd_lock);
	ts->cmd_is_running = false;
	mutex_unlock(&ts->cmd_lock);
}

int sec_ts_fn_init(struct sec_ts_data *ts) {
	int retval;
	unsigned short ii;

	INIT_LIST_HEAD(&ts->cmd_list_head);

	ts->cmd_buffer_size = 0;
	for (ii = 0; ii < ARRAY_SIZE(ft_cmds); ii++) {
		list_add_tail(&ft_cmds[ii].list, &ts->cmd_list_head);
		if (ft_cmds[ii].cmd_name)
			ts->cmd_buffer_size += strlen(ft_cmds[ii].cmd_name) + 1;
	}

	mutex_init(&ts->cmd_lock);
	ts->cmd_is_running = false;

	ts->fac_dev_ts = device_create(sec_class, NULL, 0, ts, "tsp");

	retval = IS_ERR(ts->fac_dev_ts);
	if (retval) {
		input_err(true, &ts->client->dev,
							"%s: Failed to create device for the sysfs\n", __func__);
		retval = IS_ERR(ts->fac_dev_ts);
		goto exit;
	}

	dev_set_drvdata(ts->fac_dev_ts, ts);

	retval = sysfs_create_group(&ts->fac_dev_ts->kobj, &cmd_attr_group);
	if (retval < 0) {
		input_err(true, &ts->client->dev, "%s: Failed to create sysfs attributes\n",
							__func__);
		goto exit;
	}

	retval = sysfs_create_link(&ts->fac_dev_ts->kobj, &ts->input_dev->dev.kobj,
														 "input");

	if (retval < 0) {
		input_err(true, &ts->client->dev, "%s: fail - sysfs_create_link\n",
							__func__);
		goto exit;
	}
	ts->reinit_done = true;

	return 0;

exit:
	return retval;
}
