/* drivers/input/touchscreen/sec_ts_selftest.c
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
#include <asm/pgtable.h>
#include <asm/uaccess.h>
#include <linux/delay.h>

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
#include <linux/proc_fs.h>
#include <linux/regulator/consumer.h>
#include <linux/seq_file.h>
#include <linux/slab.h>
#include <linux/slab.h>
#include <linux/wakelock.h>

#ifdef SAMSUNG_PROJECT
#include <linux/sec_sysfs.h>
#endif
#include <linux/irq.h>
#include <linux/of_gpio.h>
#include <linux/time.h>
#if defined(CONFIG_FB)
#include <asm/fb.h>
#include <linux/notifier.h>
#elif defined(CONFIG_HAS_EARLYSUSPEND)
#include <linux/earlysuspend.h>
#endif

#include "sec_ts.h"
#include "sec_ts_selftest.h"

#if SEC_TS_SELFTEST

#define sec_ts_seq_printf(m, fmt, args...)                                     \
	do {                                                                         \
		seq_printf(m, fmt, ##args);                                                \
		if (!sec_ts_test_result_printed)                                           \
			printk(fmt, ##args);                                                     \
	} while (0)

static uint8_t *sec_ts_report_buf = NULL;
static struct sec_ts_data *ts_data;

static struct proc_dir_entry *android_touch_entry = NULL;
static struct proc_dir_entry *sec_ts_proc_selftest_entry = NULL;
static int8_t sec_ts_test_result_printed = 0;
static int8_t sec_ts_test_result = -1;

void sec_ts_print_report_frame(struct sec_ts_data *ts, u16 *pFrame, bool digit,
															 bool data16) {
	int i = 0;
	int j = 0;
	unsigned char *pStr = NULL;
	unsigned char pTmp[16] = {0};
	u16 *pFrame_u16 = (u16 *)pFrame;
	u8 *pFrame_u8 = (u8 *)pFrame;
	s16 *pFrame_s16 = (s16 *)pFrame;
	s8 *pFrame_s8 = (s8 *)pFrame;

	pStr = kzalloc(6 * (ts->tx_count + 1), GFP_KERNEL);
	if (pStr == NULL)
		return;

	memset(pStr, 0x0, 6 * (ts->tx_count + 1));
	snprintf(pTmp, sizeof(pTmp), "           ");
	strncat(pStr, pTmp, 6 * ts->tx_count);

	for (i = 0; i < ts->tx_count; i++) {
		snprintf(pTmp, sizeof(pTmp), "Tx%02d  ", i);
		strncat(pStr, pTmp, 6 * ts->tx_count);
	}

	printk("SEC_TS %s\n", pStr);
	memset(pStr, 0x0, 6 * (ts->tx_count + 1));
	snprintf(pTmp, sizeof(pTmp), "      +");
	strncat(pStr, pTmp, 6 * ts->tx_count);

	for (i = 0; i < ts->tx_count; i++) {
		snprintf(pTmp, sizeof(pTmp), "------");
		strncat(pStr, pTmp, 6 * ts->rx_count);
	}

	printk("SEC_TS %s\n", pStr);

	for (i = 0; i < ts->rx_count; i++) {
		memset(pStr, 0x0, 6 * (ts->tx_count + 1));
		snprintf(pTmp, sizeof(pTmp), "Rx%02d | ", i);
		strncat(pStr, pTmp, 6 * ts->tx_count);

		for (j = 0; j < ts->tx_count; j++) {
			if (digit && data16)
				snprintf(pTmp, sizeof(pTmp), "%5d ",
								 pFrame_u16[(j * ts->rx_count) + i]);
			else if (!digit && data16)
				snprintf(pTmp, sizeof(pTmp), "%5d ",
								 pFrame_s16[(j * ts->rx_count) + i]);
			else if (digit && !data16)
				snprintf(pTmp, sizeof(pTmp), "%5d ", pFrame_u8[(j * ts->rx_count) + i]);
			else
				snprintf(pTmp, sizeof(pTmp), "%5d ", pFrame_s8[(j * ts->rx_count) + i]);
			strncat(pStr, pTmp, 6 * ts->rx_count);
		}
		printk("SEC_TS %s\n", pStr);
	}
	kfree(pStr);
}

/*******************************************************
Description:
	Novatek touchscreen self-test sequence print show
	function.

return:
	Executive outcomes. 0---succeed.
*******************************************************/
#define SUCCESS 0
#define FAIL -1
static int32_t c_show_selftest(struct seq_file *m, void *v) {
#if 0	
	struct sec_ts_data *ts = ts_data;
	struct selftest_header *st_header; 
	u8 *ptrBuff = sec_ts_report_buf;
	u16 *ptrBuff16 = (u16 *)sec_ts_report_buf;
	int i,j;
	u8 failcnt = 0;
	int result = SUCCESS;

	sec_ts_test_result_printed = 0;
	printk( "FW Version: %d.%d.%d.%d\n",
		ts->plat_data->img_version_of_ic[0],
		ts->plat_data->img_version_of_ic[1],
		ts->plat_data->img_version_of_ic[2],
		ts->plat_data->img_version_of_ic[3]);
	
	st_header = (struct selftest_header *)ptrBuff;	
	printk( "selftest signature:%08X\n", st_header->signature);
	printk( "selftest version:%08X\n", st_header->version);
	printk( "selftest total size:%d\n", st_header->totalsize);	
	printk( "selftest crc32:%08X\n", st_header->crc32);	
	printk( "selftest result:%08X\n", st_header->result);	
	printk( "selftest trycnt:%d\n", st_header->trycnt);	
	printk( "selftest passcnt:%d\n", st_header->passcnt);	
	printk( "selftest failcnt:%d\n", st_header->failcnt);
	ptrBuff += sizeof(struct selftest_header);	
	ptrBuff += sizeof(u32)*12;

	ptrBuff16 = (u16 *)ptrBuff;
	printk( "ambient:\n");
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, false, true);

	result = SUCCESS;
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			int ratio = ((sec_ts_selftest_ambient[j*ts->rx_count] / 100) * 25);
			int min = sec_ts_selftest_ambient[j*ts->rx_count] - ratio;
			int max = sec_ts_selftest_ambient[j*ts->rx_count] + ratio;
			if ((ptrBuff16[j*ts->rx_count] < min) ||
				(ptrBuff16[j*ts->rx_count] > max))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "ambient 1st Fail\n");
		failcnt++;
	}
	else
		printk( "ambient 1st Pass\n");

	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk( "ambient 2nd:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j*ts->rx_count] < sec_ts_selftest_ambient_2nd[0]) ||
				(ptrBuff16[j*ts->rx_count] > sec_ts_selftest_ambient_2nd[1]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "ambient 2nd Fail\n");
		failcnt++;
	}
	else
		printk( "ambient 2nd Pass\n");
		
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk( "ambient 3rd:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, true, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j*ts->rx_count] < sec_ts_selftest_ambient_3rd[0]) ||
				(ptrBuff16[j*ts->rx_count] > sec_ts_selftest_ambient_3rd[1]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "ambient 3rd Fail\n");
		failcnt++;
	}
	else
		printk( "ambient 3rd Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;

	printk( "P2P min:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (s16 *)ptrBuff, m, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j*ts->rx_count] < sec_ts_selftest_p2pmin[0]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "P2P Min Fail\n");
		failcnt++;
	}
	else
		printk( "P2P Min Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;

	printk( "P2P Max:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, true, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j*ts->rx_count] > sec_ts_selftest_p2pmax[1]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "P2P Max Fail\n");
		failcnt++;
	}
	else
		printk( "P2P Max Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk( "Raw variance X:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, true, false);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff[j*ts->rx_count] < sec_ts_selftest_rawvarX[0]) ||
				(ptrBuff[j*ts->rx_count] > sec_ts_selftest_rawvarX[1]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "Raw variance X Fail\n");
		failcnt++;
	}
	else
		printk( "Raw variance X Pass\n");
	ptrBuff += (SEC_TS_RAWDATA_MAXSIZE/2);
	ptrBuff16 = (u16 *)ptrBuff;

	printk( "Raw variance Y:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, true, false);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff[j*ts->rx_count] < sec_ts_selftest_rawvarY[0]) ||
				(ptrBuff[j*ts->rx_count] > sec_ts_selftest_rawvarY[1]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "Raw variance Y Fail\n");
		failcnt++;
	}
	else
		printk( "Raw variance Y Pass\n");
	ptrBuff += (SEC_TS_RAWDATA_MAXSIZE/2);
	ptrBuff16 = (u16 *)ptrBuff;

	printk( "Short :\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j*ts->rx_count] < sec_ts_selftest_short2nd[0]) ||
				(ptrBuff16[j*ts->rx_count] > sec_ts_selftest_short2nd[1]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "Short Fail\n");
		failcnt++;
	}
	else
		printk( "Short Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;

	printk( "Rawdata:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j*ts->rx_count] < sec_ts_selftest_rawdata[0]) ||
				(ptrBuff16[j*ts->rx_count] > sec_ts_selftest_rawdata[1]))
				result = FAIL;			
		}
	}
	if (result == FAIL) {
		printk( "Rawdata Fail\n");
		failcnt++;
	}
	else
		printk( "Short Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk( "Offset Cal data:\n");
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, m, true, false);
	ptrBuff += (SEC_TS_RAWDATA_MAXSIZE/2);
	ptrBuff16 = (u16 *)ptrBuff;
	printk( "\n");
#endif

	if (sec_ts_test_result < 0) {
		sec_ts_seq_printf(m, "%d\n", 0);
	} else {

		sec_ts_seq_printf(m, "%d\n", 1);
	}
	sec_ts_test_result_printed = 1;
	return 0;
}

/*******************************************************
Description:
	Sec touchscreen self-test sequence print start
	function.

return:
	Executive outcomes. 1---call next function.
	NULL---not call next function and sequence loop
	stop.
*******************************************************/
static void *c_start(struct seq_file *m, loff_t *pos) {
	return *pos < 1 ? (void *)1 : NULL;
}

/*******************************************************
Description:
	Sec touchscreen self-test sequence print next
	function.

return:
	Executive outcomes. NULL---no next and call sequence
	stop function.
*******************************************************/
static void *c_next(struct seq_file *m, void *v, loff_t *pos) {
	++*pos;
	return NULL;
}

/*******************************************************
Description:
	Sec touchscreen self-test sequence print stop
	function.

return:
	n.a.
*******************************************************/
static void c_stop(struct seq_file *m, void *v) { return; }

const struct seq_operations sec_ts_selftest_seq_ops = {
		.start = c_start, .next = c_next, .stop = c_stop, .show = c_show_selftest};

static int32_t sec_ts_print_selftest(void) {
	struct sec_ts_data *ts = ts_data;
	struct selftest_header *st_header;
	u8 *ptrBuff = sec_ts_report_buf;
	u16 *ptrBuff16 = (u16 *)sec_ts_report_buf;
	int i, j;
	u8 failcnt = 0;
	int result = SUCCESS;
	int ratio, min, max;

	sec_ts_test_result_printed = 0;
	printk("FW Version: %d.%d.%d.%d\n", ts->plat_data->img_version_of_ic[0],
				 ts->plat_data->img_version_of_ic[1],
				 ts->plat_data->img_version_of_ic[2],
				 ts->plat_data->img_version_of_ic[3]);

	st_header = (struct selftest_header *)ptrBuff;
	printk("selftest signature:%08X\n", st_header->signature);
	printk("selftest version:%08X\n", st_header->version);
	printk("selftest total size:%d\n", st_header->totalsize);
	printk("selftest crc32:%08X\n", st_header->crc32);
	printk("selftest result:%08X\n", st_header->result);
	printk("selftest trycnt:%d\n", st_header->trycnt);
	printk("selftest passcnt:%d\n", st_header->passcnt);
	printk("selftest failcnt:%d\n", st_header->failcnt);
	ptrBuff += sizeof(struct selftest_header);
	ptrBuff += sizeof(u32) * 12;

	ptrBuff16 = (u16 *)ptrBuff;
	printk("ambient:\n");
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, false, true);

	result = SUCCESS;
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			ratio = ((sec_ts_selftest_ambient[j * ts->rx_count] / 100) * 25);
			min = sec_ts_selftest_ambient[j * ts->rx_count] - ratio;
			max = sec_ts_selftest_ambient[j * ts->rx_count] + ratio;
			if ((ptrBuff16[j * ts->rx_count] < min) ||
					(ptrBuff16[j * ts->rx_count] > max))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("ambient 1st Fail\n");
		failcnt++;
	} else
		printk("ambient 1st Pass\n");

	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk("ambient 2nd:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j * ts->rx_count] < sec_ts_selftest_ambient_2nd[0]) ||
					(ptrBuff16[j * ts->rx_count] > sec_ts_selftest_ambient_2nd[1]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("ambient 2nd Fail\n");
		failcnt++;
	} else
		printk("ambient 2nd Pass\n");

	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk("ambient 3rd:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, true, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j * ts->rx_count] < sec_ts_selftest_ambient_3rd[0]) ||
					(ptrBuff16[j * ts->rx_count] > sec_ts_selftest_ambient_3rd[1]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("ambient 3rd Fail\n");
		failcnt++;
	} else
		printk("ambient 3rd Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;

	printk("P2P min:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (s16 *)ptrBuff, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j * ts->rx_count] < sec_ts_selftest_p2pmin[0]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("P2P Min Fail\n");
		failcnt++;
	} else
		printk("P2P Min Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;

	printk("P2P Max:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, true, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j * ts->rx_count] > sec_ts_selftest_p2pmax[1]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("P2P Max Fail\n");
		failcnt++;
	} else
		printk("P2P Max Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk("Raw variance X:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, true, false);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff[j * ts->rx_count] < sec_ts_selftest_rawvarX[0]) ||
					(ptrBuff[j * ts->rx_count] > sec_ts_selftest_rawvarX[1]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("Raw variance X Fail\n");
		failcnt++;
	} else
		printk("Raw variance X Pass\n");
	ptrBuff += (SEC_TS_RAWDATA_MAXSIZE / 2);
	ptrBuff16 = (u16 *)ptrBuff;

	printk("Raw variance Y:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, true, false);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff[j * ts->rx_count] < sec_ts_selftest_rawvarY[0]) ||
					(ptrBuff[j * ts->rx_count] > sec_ts_selftest_rawvarY[1]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("Raw variance Y Fail\n");
		failcnt++;
	} else
		printk("Raw variance Y Pass\n");
	ptrBuff += (SEC_TS_RAWDATA_MAXSIZE / 2);
	ptrBuff16 = (u16 *)ptrBuff;

	printk("Short :\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j * ts->rx_count] < sec_ts_selftest_short2nd[0]) ||
					(ptrBuff16[j * ts->rx_count] > sec_ts_selftest_short2nd[1]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("Short Fail\n");
		failcnt++;
	} else
		printk("Short Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;

	printk("Rawdata:\n");
	result = SUCCESS;
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, false, true);
	for (i = 0; i < ts->rx_count; i++) {
		for (j = 0; j < ts->tx_count; j++) {
			if ((ptrBuff16[j * ts->rx_count] < sec_ts_selftest_rawdata[0]) ||
					(ptrBuff16[j * ts->rx_count] > sec_ts_selftest_rawdata[1]))
				result = FAIL;
		}
	}
	if (result == FAIL) {
		printk("Rawdata Fail\n");
		failcnt++;
	} else
		printk("Short Pass\n");
	ptrBuff += SEC_TS_RAWDATA_MAXSIZE;
	ptrBuff16 = (u16 *)ptrBuff;
	printk("Offset Cal data:\n");
	sec_ts_print_report_frame(ts, (u16 *)ptrBuff, true, false);
	ptrBuff += (SEC_TS_RAWDATA_MAXSIZE / 2);
	ptrBuff16 = (u16 *)ptrBuff;
	/*for (i = 0; i < 8; i++) {
		printk( "%d, ", *((u32 *)ptrBuff));
		ptrBuff += sizeof(u16);
	}*/
	printk("\n");
	if (failcnt > 0) {
		printk("Selftest result Fail\n");
		sec_ts_test_result_printed = 1;
		return -1;
	} else {
		printk("Selftest result Pass\n");
		sec_ts_test_result_printed = 1;
		return 0;
	}
}

/*******************************************************
Description:
	Sec touchscreen /proc/sec_ts_selftest open function.

return:
	Executive outcomes. 0---succeed. negative---failed.
*******************************************************/
static int32_t sec_ts_selftest_open(struct inode *inode, struct file *file) {
	struct sec_ts_data *ts = ts_data;
	int rc;
	u8 tpara = 0x03;
	u8 cmd_data[10];
	u8 *report_buff;
	u32 result_size = SEC_TS_SELFTEST_REPORT_SIZE;
	u32 remain_size;
	u32 read_size;

	disable_irq(ts->client->irq);
	input_info(true, &ts->client->dev, "%s: Self test start!\n", __func__);
	cmd_data[0] = 0xFF;
	rc = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SELFTEST_TYPE, cmd_data, 1);
	if (rc < 0) {
		input_err(true, &ts->client->dev, "%s: Send selftest cmd failed!\n",
							__func__);
		goto err_exit;
	}
	sec_ts_delay(100);

	cmd_data[0] = 0x0;
	cmd_data[1] = 0x64;
	rc = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SELFTEST_PTOP, cmd_data, 4);
	if (rc < 0) {
		input_err(true, &ts->client->dev, "%s: Send selftest cmd failed!\n",
							__func__);
		goto err_init;
	}
	sec_ts_delay(100);

	input_info(true, &ts->client->dev, "%s: send selftest cmd!\n", __func__);
	rc = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SELFTEST, &tpara, 1);
	if (rc < 0) {
		input_err(true, &ts->client->dev, "%s: Send selftest cmd failed!\n",
							__func__);
		goto err_init;
	}
	sec_ts_delay(1000);
	rc = sec_ts_wait_for_ready(ts, SEC_TS_ACK_SELF_TEST_DONE);
	if (rc < 0) {
		input_err(true, &ts->client->dev, "%s: Selftest execution time out!\n",
							__func__);
		goto err_init;
	}

	sec_ts_sw_reset(ts);
	sec_ts_delay(500);

	input_info(true, &ts->client->dev, "%s: Self test done!\n", __func__);

	sec_ts_report_buf = kzalloc(result_size, GFP_KERNEL);
	if (!sec_ts_report_buf)
		goto err_init;

	rc = ts->sec_ts_i2c_write(ts, SEC_TS_READ_SELFTEST_RESULT, NULL, 0);
	if (rc < 0) {
		input_err(true, &ts->client->dev,
							"%s: Send selftest read result cmd failed!\n", __func__);
		goto err_exit;
	}
	report_buff = sec_ts_report_buf;
	remain_size = result_size;
	read_size = (remain_size > 256) ? (256) : (remain_size);
	do {
		rc = ts->sec_ts_i2c_read_bulk(ts, report_buff, read_size);
		if (rc < 0) {
			input_err(true, &ts->client->dev,
								"%s: Selftest result read failed remain = %d!\n", __func__,
								remain_size);
			goto err_exit;
		}
		remain_size -= read_size;
		report_buff += read_size;
		read_size = (remain_size > 256) ? 256 : remain_size;
		sec_ts_delay(1);
	} while (remain_size > 0);

	sec_ts_test_result = sec_ts_print_selftest();

	enable_irq(ts->client->irq);
	if(sec_ts_report_buf)
		kfree(sec_ts_report_buf);

	return seq_open(file, &sec_ts_selftest_seq_ops);

err_exit:
	if(sec_ts_report_buf)
		kfree(sec_ts_report_buf);
err_init:
	enable_irq(ts->client->irq);
	return -1;
}

// 替换原有的 file_operations 定义
static const struct proc_ops sec_ts_selftest_proc_ops = {
    .proc_open = sec_ts_selftest_open,
    .proc_read = seq_read,
    .proc_lseek = seq_lseek,
    .proc_release = seq_release,
};

/*******************************************************
Description:
	Novatek touchscreen MP function proc. file node
	initial function.

return:
	Executive outcomes. 0---succeed. -1---failed.
*******************************************************/
int32_t sec_ts_test_proc_init(struct sec_ts_data *ts) {
	ts_data = ts;

	android_touch_entry = proc_mkdir("android_touch", NULL);
	if (android_touch_entry == NULL) {
		input_err(true, &ts->client->dev, "create /proc/android_touch Failed!\n");
		return -1;
	}

sec_ts_proc_selftest_entry = proc_create(
    "self_test", 0444, android_touch_entry, &sec_ts_selftest_proc_ops);
	if (sec_ts_proc_selftest_entry == NULL) {
		input_err(true, &ts->client->dev, "create /proc/self_test Failed!\n");
		return -1;
	} else {
		input_info(true, &ts->client->dev, "create /proc/self_test Succeeded!\n");
		return 0;
	}
}

#endif /* #if SEC_TS_SELFTEST */
