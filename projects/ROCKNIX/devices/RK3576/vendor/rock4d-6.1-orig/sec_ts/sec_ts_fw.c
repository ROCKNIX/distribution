/* drivers/input/touchscreen/sec_ts_fw.c
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

#include <linux/delay.h>
#include <linux/firmware.h>
#include <linux/gpio.h>
#include <linux/i2c.h>
#include <linux/input.h>
#include <linux/input/mt.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/irq.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/of_gpio.h>
#include <linux/platform_device.h>
#include <linux/regulator/consumer.h>
#include <linux/slab.h>
#include <linux/time.h>

#include <linux/uaccess.h>

#include "sec_ts.h"

#define SEC_TS_FW_BLK_SIZE 256
/*for hardware info get tp fw version */
extern unsigned int ctp_fw_version_1;
extern unsigned int ctp_fw_version_2;
static u8 sec_ts_fw_data[] = {
	#include "s6d6ft0_v1.10_20170918.h"
};

u8 *sec_get_fwdata(void) { return sec_ts_fw_data; }

int sec_ts_sw_reset(struct sec_ts_data *ts) {
	int ret;

	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SW_RESET, NULL, 0);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: write fail, sw_reset\n", __func__);
		return 0;
	}

	sec_ts_delay(500);
	input_info(true, &ts->client->dev, "%s: sw_reset\n", __func__);

	return 1;
}

int sec_ts_check_firmware_version(struct sec_ts_data *ts, const u8 *fw_info) {
	struct fw_header *fw_hd;
	u8 data[20] = {0};
	u8 device_id[3] = {0};
	u8 fw_ver[4];
	int ret;
	/*
	 * sec_ts_check_firmware_version
	 * return value = 2 : bootloader mode
	 * return value = 1 : firmware download needed,
	 * return value = 0 : skip firmware download
	 */

	fw_hd = (struct fw_header *)fw_info;

	ret = ts->sec_ts_i2c_read(ts, SEC_TS_READ_DEVICE_ID, device_id, 3);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: failed to read device id(%d)\n",
							__func__, ret);
		return -1;
	}

	input_info(true, &ts->client->dev, "%s: %X, %X, %X\n", __func__, device_id[0],
						 device_id[1], device_id[2]);

	if (device_id[0] == SEC_TS_ID_ON_BOOT)
		return 2;

	ret = ts->sec_ts_i2c_read(ts, SEC_TS_READ_SUB_ID, data, 20);
	if (ret < 0) {
		input_info(true, &ts->client->dev, "%s: firmware version read error\n ",
							 __func__);
		return -1;
	}
	input_info(true, &ts->client->dev,
						 "%s: [IC] Image version info : %x.%x.%x.%x // [BIN] %08X\n",
						 __func__, data[9], data[10], data[11], data[12], fw_hd->version);

	fw_ver[0] = data[9];
	fw_ver[1] = data[10];
	fw_ver[2] = data[11];
	fw_ver[3] = data[12];

	ts->plat_data->img_version_of_ic[0] = fw_ver[0];
	ts->plat_data->img_version_of_ic[1] = fw_ver[1];
	ts->plat_data->img_version_of_ic[2] = fw_ver[2];
	ts->plat_data->img_version_of_ic[3] = fw_ver[3];

	ts->plat_data->img_version_of_bin[0] = (fw_hd->version & 0xFF);
	ts->plat_data->img_version_of_bin[1] = (fw_hd->version >> 8 & 0xFF);
	ts->plat_data->img_version_of_bin[2] = (fw_hd->version >> 16 & 0xFF);
	ts->plat_data->img_version_of_bin[3] = (fw_hd->version >> 24 & 0xFF);

	input_info(true, &ts->client->dev,
						 "%s: [FW] IMG version : %x.%x. [IC] IMG version %x.%x.\n",
						 __func__, (fw_hd->version >> 16) & 0xff,
						 (fw_hd->version >> 24) & 0xff, fw_ver[2], fw_ver[3]);

	if (((fw_hd->version) & 0xff) != fw_ver[0]) {
		input_err(true, &ts->client->dev, "%s: f/w product 0 is not equal: %x\n ",
							__func__, fw_ver[0]);
		return -1;
	}
	if (((fw_hd->version >> 8) & 0xff) != fw_ver[1]) {
		input_err(true, &ts->client->dev, "%s: f/w project 1 is not equal : %x\n ",
							__func__, fw_ver[1]);
		return -1;
	}

	if (((fw_hd->version >> 16) & 0xff) > fw_ver[2]) {
		return 1;
	} else if ((((fw_hd->version >> 16) & 0xff) == fw_ver[2]) &&
						 (((fw_hd->version >> 24) & 0xff) > fw_ver[3])) {
		return 1;
	}

	return 0;
}

static u8 sec_ts_checksum(u8 *data, int offset, int size) {
	int i;
	u8 checksum = 0;

	for (i = 0; i < size; i++)
		checksum += data[i + offset];

	return checksum;
}

/***********************/
/** Ext-flash control **/
/***********************/
#define SEC_TS_CMD_CS_CONTROL				0x8B
#define SEC_TS_CMD_SET_DATA_NUM			0xD1
#define FLASH_CMD_RDSR							0x05
#define FLASH_CMD_WREN							0x06
#define FLASH_CMD_SE 								0x20
#define FLASH_CMD_PP								0x02
#define SEC_TS_CMD_FLASH_SEND_DATA	0xEB
#define SEC_TS_CMD_FLASH_READ_DATA	0xEC

#define CS_LOW	0
#define CS_HIGH	1

#define BYTE_PER_SECTOR				4096
#define BYTE_PER_PAGE					256
#define PAGE_DATA_HEADER_SIZE	4

#define SEC_TS_FLASH_WIP_MASK	0x01
#define SEC_TS_FLASH_SIZE_256	256

#define BYTE_PER_SECTOR				4096
#define BYTE_PER_PAGE					256
#define PAGE_PER_SECTOR				16

static int sec_ts_flash_set_datanum(struct sec_ts_data *ts, u16 num) {
	u8 tData[2];
	int ret;

	tData[0] = (num >> 8) & 0xFF;
	tData[1] = num & 0xFF;

	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SET_DATA_NUM, tData, 2);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s: Set datanum Fail %d\n", __func__,
							num);

	return ret;
}

static int sec_ts_flash_cs_control(struct sec_ts_data *ts, bool cs_level) {
	u8 tData;
	int ret;

	tData = cs_level ? 1 : 0;

	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_CS_CONTROL, &tData, 1);
	if (ret < 0)
		input_info(true, &ts->client->dev, "%s: %s control Fail!\n", __func__,
							 cs_level ? "CS High" : "CS Low");
	return ret;
}

static int sec_ts_wren(struct sec_ts_data *ts) {
	u8 tData[2];
	int ret;

	sec_ts_flash_cs_control(ts, CS_LOW);

	sec_ts_flash_set_datanum(ts, 6);

	tData[0] = FLASH_CMD_WREN;
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_FLASH_SEND_DATA, &tData[0], 1);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s: Send WREN fail!\n", __func__);

	sec_ts_flash_cs_control(ts, CS_HIGH);

	return ret;
}

static u8 sec_ts_rdsr(struct sec_ts_data *ts) {
	u8 tData[2];

	sec_ts_flash_cs_control(ts, CS_LOW);

	sec_ts_flash_set_datanum(ts, 2);

	tData[0] = FLASH_CMD_RDSR;
	ts->sec_ts_i2c_write(ts, SEC_TS_CMD_FLASH_SEND_DATA, tData, 1);

	sec_ts_flash_set_datanum(ts, 1);

	ts->sec_ts_i2c_read(ts, SEC_TS_CMD_FLASH_READ_DATA, tData, 1);

	sec_ts_flash_cs_control(ts, CS_HIGH);

	return tData[0];
}

static bool IsFlashBusy(struct sec_ts_data *ts) {
	u8 tBuf;

	sec_ts_wren(ts);
	tBuf = sec_ts_rdsr(ts);
	if ((tBuf & SEC_TS_FLASH_WIP_MASK) == SEC_TS_FLASH_WIP_MASK)
		return true;

	return false;
}

static int sec_ts_wait_for_flash_busy(struct sec_ts_data *ts) {
	int retry_cnt = 0;
	int ret = 0;

	while (IsFlashBusy(ts)) {
		sec_ts_delay(10);

		if (retry_cnt++ > SEC_TS_WAIT_RETRY_CNT) { /*RETRY_CNT = 100*/
			input_err(true, &ts->client->dev, "%s: Retry Cnt over!\n", __func__);
			ret = -1;
		}
	}

	return ret;
}

static int sec_ts_cmd_flash_se(struct sec_ts_data *ts, u32 flash_addr) {
	int ret;
	u8 tBuf[5];

	if (IsFlashBusy(ts))
		return false;

	sec_ts_wren(ts);

	sec_ts_flash_cs_control(ts, CS_LOW);

	sec_ts_flash_set_datanum(ts, 5);

	tBuf[0] = SEC_TS_CMD_FLASH_SEND_DATA;
	tBuf[1] = FLASH_CMD_SE;
	tBuf[2] = (flash_addr >> 16) & 0xFF;
	tBuf[3] = (flash_addr >> 8) & 0xFF;
	tBuf[4] = (flash_addr >> 0) & 0xFF;
	ret = ts->sec_ts_i2c_write_burst(ts, tBuf, 5);
	sec_ts_flash_cs_control(ts, CS_HIGH);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: Send sector erase cmd fail!\n",
							__func__);
		return ret;
	}

	ret = sec_ts_wait_for_flash_busy(ts);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s: Time out! - flash busy wait\n",
							__func__);

	return ret;
}

#ifdef CONFIG_CMD_PP
bool sec_ts_cmd_pp(struct sec_ts_data *ts, int flash_address, u8 *source_data,
									 int byte_length) {
	int data_byte_total_length;
	u8 *tCmd;
	int ret, i;

	if (IsFlashBusy(ts))
		return false;

	sec_ts_wren(ts);

	data_byte_total_length = 1 + 3 + byte_length + 1;
	tCmd = kzalloc(data_byte_total_length, GFP_KERNEL);

	sec_ts_flash_cs_control(ts, CS_LOW);
	sec_ts_flash_set_datanum(ts, 0x104);

	tCmd[0] = SEC_TS_CMD_FLASH_SEND_DATA;
	tCmd[1] = FLASH_CMD_PP;
	tCmd[2] = (flash_address >> 16) & 0xFF;
	tCmd[3] = (flash_address >> 8) & 0xFF;
	tCmd[4] = (flash_address >> 0) & 0xFF;

	for (i = 0; i < byte_length; i++)
		tCmd[5 + i] = source_data[i];

	ret = ts->sec_ts_i2c_write_burst(ts, tCmd, data_byte_total_length);
	sec_ts_flash_cs_control(ts, CS_HIGH);

	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: PP cmd fail!\n", __func__);
		return false;
	}
	input_dbg(true, &ts->client->dev, "%s : addr = %X%X%X\n", __func__, tCmd[2],
						tCmd[3], tCmd[4]);

	kfree(tCmd);

	while (IsFlashBusy(ts))
		sec_ts_delay(10);

	return true;
}
#endif

static int sec_ts_FlashSectorErase(struct sec_ts_data *ts, u32 sector_idx) {
	u32 addr;
	int ret = 0;

	addr = sector_idx * BYTE_PER_PAGE;

	ret = sec_ts_cmd_flash_se(ts, addr);
	if (ret < 0)
		input_err(true, &ts->client->dev, "%s: Fail!\n", __func__);

	return ret;
}

static bool sec_ts_flashpagewrite(struct sec_ts_data *ts, u32 page_idx,
																	u8 *page_data) {
#ifndef CONFIG_CMD_PP
	int ret;
	int i, j;
	u8 *tCmd;
	u8 copy_data[3 + SEC_TS_FLASH_SIZE_256];
	int copy_left = SEC_TS_FLASH_SIZE_256 + 3;
	int copy_size = 0;
	int copy_max = SEC_TS_FLASH_SIZE_256 + 3;

	copy_data[0] = (u8)((page_idx >> 8) & 0xFF);
	copy_data[1] = (u8)((page_idx >> 0) & 0xFF);
	for (i = 0; i < SEC_TS_FLASH_SIZE_256; i++)
		copy_data[2 + i] = page_data[i];
	copy_data[2 + SEC_TS_FLASH_SIZE_256] =
			sec_ts_checksum(copy_data, 0, 2 + SEC_TS_FLASH_SIZE_256);

	sec_ts_flash_cs_control(ts, CS_LOW);
	while (copy_left > 0) {
		int copy_cur = (copy_left > copy_max) ? copy_max : copy_left;
		tCmd = (u8 *)kzalloc(copy_cur + 1, GFP_KERNEL);
		if (copy_size == 0)
			tCmd[0] = 0xD9;
		else
			tCmd[0] = 0xDA;

		for (j = 0; j < copy_cur; j++)
			tCmd[j + 1] = copy_data[copy_size + j];
		ret = ts->sec_ts_i2c_write_burst(ts, tCmd, 1 + copy_cur);
		if (ret < 0)
			input_err(true, &ts->client->dev, "%s i2c error =  %d\n", __func__,
								copy_left);
		copy_size += copy_cur;
		copy_left -= copy_cur;
		kfree(tCmd);
	}
	sec_ts_delay(5); // add for test
	sec_ts_flash_cs_control(ts, CS_HIGH);

	return ret;
#else
	int size;
	int addr;

	size = BYTE_PER_PAGE;
	addr = page_idx * BYTE_PER_PAGE;

	sec_ts_cmd_pp(ts, addr, page_data, size);

	return true;
#endif
}
/*
static bool sec_ts_flashlimitread(struct sec_ts_data *ts, u32 mem_addr,
																	u32 mem_size, u8 *mem_data) {
	int ret = 0;
	int copy_left = mem_size;
	int copy_size = 0;
	int copy_max = 32;
	u32 copy_addr = mem_addr;
	u8 tCmd[5];
	u8 *copy_data = mem_data;

	sec_ts_flash_cs_control(ts, CS_LOW);
	while (copy_left > 0) {
		int copy_cur = (copy_left > copy_max) ? copy_max : copy_left;

		tCmd[0] = 0xD0;
		tCmd[1] = (u8)((copy_addr >> 24) & 0xff);
		tCmd[2] = (u8)((copy_addr >> 16) & 0xff);
		tCmd[3] = (u8)((copy_addr >> 8) & 0xff);
		tCmd[4] = (u8)((copy_addr >> 0) & 0xff);
		ret = ts->sec_ts_i2c_write_burst(ts, tCmd, 5);
		if (ret < 0) {
			input_info(true, &ts->client->dev, "%s: D0 fail\n", __func__);
			goto burst_err;
		}

		tCmd[0] = 0xD1;
		tCmd[1] = (u8)((copy_cur >> 8) & 0xff);
		tCmd[2] = (u8)((copy_cur >> 0) & 0xff);
		ret = ts->sec_ts_i2c_write_burst(ts, tCmd, 3);
		if (ret < 0) {
			input_info(true, &ts->client->dev, "%s: D1 fail\n", __func__);
			goto burst_err;
		}

		tCmd[0] = 0xDC;
		ret = ts->sec_ts_i2c_read(ts, tCmd[0], &copy_data[copy_size], copy_cur);
		if (ret < 0) {
			input_info(true, &ts->client->dev, "%s: memroy read fail\n", __func__);
			goto burst_err;
		}

		copy_addr += copy_cur;
		copy_size += copy_cur;
		copy_left -= copy_cur;
	}

	sec_ts_flash_cs_control(ts, CS_HIGH);

burst_err:
	return ret;
}
*/
static int sec_ts_flashwrite(struct sec_ts_data *ts, u32 mem_addr, u8 *mem_data,
														 u32 mem_size) {
	int ret;
	int page_idx;
	int size_left;
	int size_copy;
	u32 flash_page_size;
	u32 page_idx_start;
	u32 page_idx_end;
	u32 page_num;
	u8 page_buf[SEC_TS_FLASH_SIZE_256];

	if (mem_size == 0) {
		input_err(true, &ts->client->dev,
							"%s, mem_size 0\n", __func__);
		return 0;
	}

	flash_page_size = SEC_TS_FLASH_SIZE_256;
	page_idx_start = mem_addr / flash_page_size;
	page_idx_end = (mem_addr + mem_size - 1) / flash_page_size;
	page_num = page_idx_end - page_idx_start + 1;

	for (page_idx = (int)((page_num - 1) / 16); page_idx >= 0; page_idx--) {
		ret = sec_ts_FlashSectorErase(ts, (page_idx_start + page_idx * 16));
		if (ret < 0) {
			input_err(true, &ts->client->dev,
								"%s: Sector erase fail! sector_idx = %08X\n", __func__,
								page_idx_start + page_idx * 16);
			return -EIO;
		}
	}
	input_info(true, &ts->client->dev, "%s flash sector erase done\n", __func__);

	sec_ts_delay(page_num + 10);

	size_left = (int)mem_size;
	size_copy = (int)(mem_size % flash_page_size);
	if (size_copy == 0)
		size_copy = (int)flash_page_size;

	memset(page_buf, 0, SEC_TS_FLASH_SIZE_256);

	for (page_idx = (int)page_num - 1; page_idx >= 0; page_idx--) {
		memcpy(page_buf, mem_data + (page_idx * flash_page_size), size_copy);
		ret = sec_ts_flashpagewrite(ts, (u32)(page_idx + page_idx_start), page_buf);
		if (ret < 0) {
			input_err(true, &ts->client->dev, "%s fw write failed, page_idx = %d\n",
								__func__, page_idx);
			goto err;
		}

		size_copy = (int)flash_page_size;
		sec_ts_delay(5);
	}
	input_info(true, &ts->client->dev, "%s flash page write done\n", __func__);

	return mem_size;
err:
	return -EIO;
}
/*
static int sec_ts_flashread(struct sec_ts_data *ts, u32 mem_addr, u8 *mem_data,
														u32 mem_size) {
	int ret;

	if ((mem_size == 0) || (mem_size > 128000))
		return 0;

	ret = sec_ts_flashlimitread(ts, mem_addr, mem_size, mem_data);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s fw read failed\n", __func__);
		goto err;
	}
	return mem_size;
err:
	return -EIO;
}*/
static int sec_ts_chunk_update(struct sec_ts_data *ts, u32 addr, u32 size,
															 u8 *data) {

	u32 fw_size;
	u32 write_size;
	u8 *mem_data;

	fw_size = size;

	mem_data = kzalloc(fw_size, GFP_KERNEL);
	if (!mem_data)
		return -ENOMEM;

	memcpy(mem_data, data, sizeof(u8) * fw_size);

	write_size = sec_ts_flashwrite(ts, addr, mem_data, fw_size);
	if (write_size != fw_size) {
		input_err(true, &ts->client->dev, "%s fw write failed\n", __func__);
		return -1;
	}

	input_info(true, &ts->client->dev, "%s flash write done\n", __func__);
	kfree(mem_data);
	sec_ts_delay(1000);

	return 0;
}

static int sec_ts_firmware_update(struct sec_ts_data *ts, const u8 *data,
																	size_t size) {
	int i, ret;
	u8 device_id[3];
	u8 *fd = (u8 *)data;
	u8 num_chunk;
	struct fw_header *fw_hd;

	fw_hd = (struct fw_header *)fd;

	if (fw_hd->signature != SEC_TS_FW_HEADER_SIGN) {
		input_err(true, &ts->client->dev, "%s: firmware header error = %08X\n",
							__func__, fw_hd->signature);
		return -1;
	}

	num_chunk = fw_hd->NumberOfChunk[0] & 0xFF;
	input_info(true, &ts->client->dev, "%s: num_chunk : %d\n", __func__,
						 num_chunk);
	input_info(true, &ts->client->dev, "%s: 0x%08X, 0x%08X, 0x%zu, 0x%08X\n",
						 __func__, fw_hd->signature, fw_hd->flag, size, fw_hd->setting);

	for (i = 0; i < num_chunk; i++) {
		ret = sec_ts_chunk_update(ts, 0, (u32)size, fd);
		if (ret < 0) {
			input_err(true, &ts->client->dev, "%s: firmware chunk write failed\n",
								__func__);
			return -1;
		}
	}

	ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SW_RESET, NULL, 0);
	sec_ts_delay(500);
	sec_ts_wait_for_ready(ts, SEC_TS_ACK_BOOT_COMPLETE);

	if (ts->sec_ts_i2c_read(ts, SEC_TS_READ_DEVICE_ID, device_id, 3) < 0) {
		input_err(true, &ts->client->dev,
							"%s: read fail, read_boot_status = 0x%x\n", __func__,
							device_id[0]);
		return -1;
	}

	if (device_id[0] != SEC_TS_ID_ON_FW) {
		input_err(
				true, &ts->client->dev,
				"%s: fw update sequence done, BUT fw is not loaded (id[0] = 0x%x)\n",
				__func__, device_id[0]);
		return -1;
	}

	input_err(true, &ts->client->dev, "%s: fw update Success! id[0] = 0x%x\n",
						__func__, device_id[0]);

	return 0;
}

int sec_ts_firmware_update_on_probe(struct sec_ts_data *ts) {
	const struct firmware *fw_entry;
	char fw_path[SEC_TS_MAX_FW_PATH];
	int result = -1;

	disable_irq(ts->client->irq);

	if (!ts->plat_data->firmware_name)
		snprintf(fw_path, SEC_TS_MAX_FW_PATH, "%s", SEC_TS_DEFAULT_FW_NAME);
	else
		snprintf(fw_path, SEC_TS_MAX_FW_PATH, "%s", ts->plat_data->firmware_name);

	input_info(true, &ts->client->dev, "%s: initial firmware update  %s\n",
						 __func__, fw_path);

	/* Loading Firmware */
	if (request_firmware(&fw_entry, fw_path, &ts->client->dev) != 0) {
		input_err(true, &ts->client->dev, "%s: firmware is not available\n",
							__func__);
		goto err_request_fw;
	}
	input_info(true, &ts->client->dev, "%s: request firmware done! size = %d\n",
						 __func__, (int)fw_entry->size);

	result = sec_ts_check_firmware_version(ts, fw_entry->data);
	if (result <= 0)
		goto err_request_fw;

	if (sec_ts_firmware_update(ts, fw_entry->data, fw_entry->size) < 0)
		result = -1;
	else
		result = 0;

err_request_fw:
	release_firmware(fw_entry);
	enable_irq(ts->client->irq);
	return result;
}

int sec_ts_firmwarei_update_on_probe(struct sec_ts_data *ts) {
	int ret;
	int result = -1;
	int fw_size;
	int ctp_fw_version_1;
	int ctp_fw_version_2;

	input_info(true, &ts->client->dev,
						 "%s: initial firmware update with i file\n", __func__);

	fw_size = sizeof(sec_ts_fw_data);
	/* Loading Firmware */
	input_info(true, &ts->client->dev, "%s: request firmware done! size = %d\n",
						 __func__, (int)fw_size);

	result = sec_ts_check_firmware_version(ts, sec_ts_fw_data);
	/*for hardware info get tp fw version */
	ctp_fw_version_1 = ts->plat_data->img_version_of_ic[2];
	ctp_fw_version_2 = ts->plat_data->img_version_of_ic[3];
	if (!ts->force_fwup) {
		if (result < 0)
			goto err_request_fw;
		else if (result == 0)
			goto skip_request_fw;
	}
	if (sec_ts_firmware_update(ts, sec_ts_fw_data, fw_size) < 0) {
		result = -1;
		return result;
	}
	ret = ts->sec_ts_i2c_write(ts, SEC_TS_CMD_CALIBRATION_OFFSET_SDC, NULL, 0);
	if (ret < 0) {
		input_err(true, &ts->client->dev, "%s: calibration fail\n", __func__);
		goto err_request_fw;
	}
	sec_ts_delay(1000);

	ts->sec_ts_i2c_write(ts, SEC_TS_CMD_SW_RESET, NULL, 0);
	sec_ts_delay(500);
	sec_ts_wait_for_ready(ts, SEC_TS_ACK_BOOT_COMPLETE);
	if (result >= 1)
		sec_ts_check_firmware_version(ts, sec_ts_fw_data);
	ctp_fw_version_1 = ts->plat_data->img_version_of_bin[2];
	ctp_fw_version_2 = ts->plat_data->img_version_of_bin[3];
	// after update
	return 0;

err_request_fw:
	return -1;
skip_request_fw:
	return result;
}

static int sec_ts_load_fw_from_ums(struct sec_ts_data *ts)
{
	struct fw_header *fw_hd;
	struct file *fp;
	loff_t pos = 0;
	loff_t fw_size;
	ssize_t nread;
	unsigned char *fw_data;
	int error = 0;

	fp = filp_open(SEC_TS_DEFAULT_UMS_FW, O_RDONLY, 0);
	if (IS_ERR(fp)) {
		input_err(true, ts->dev, "%s: failed to open %s\n",
			  __func__, SEC_TS_DEFAULT_UMS_FW);
		return PTR_ERR(fp);
	}

	fw_size = i_size_read(file_inode(fp));
	if (fw_size <= 0) {
		input_err(true, ts->dev, "%s: invalid firmware size %lld\n",
			  __func__, fw_size);
		error = -EINVAL;
		goto out_close;
	}

	fw_data = kzalloc(fw_size, GFP_KERNEL);
	if (!fw_data) {
		error = -ENOMEM;
		goto out_close;
	}

	nread = kernel_read(fp, fw_data, fw_size, &pos);

	input_info(true, ts->dev,
		   "%s: start, file path %s, size %lld Bytes\n",
		   __func__, SEC_TS_DEFAULT_UMS_FW, fw_size);

	if (nread != fw_size) {
		input_err(true, ts->dev,
			  "%s: failed to read firmware file, nread %zd Bytes\n",
			  __func__, nread);
		error = -EIO;
		goto out_free;
	}

	fw_hd = (struct fw_header *)fw_data;

	input_info(true, &ts->client->dev,
		   "%s: IMG version %08X\n",
		   __func__, fw_hd->version);

	if (ts->irq)
		disable_irq(ts->irq);

	if (sec_ts_firmware_update(ts, fw_data, fw_size) < 0)
		error = -EIO;

	if (ts->irq)
		enable_irq(ts->irq);

	if (error < 0)
		input_err(true, ts->dev,
			  "%s: failed update firmware\n", __func__);

out_free:
	kfree(fw_data);

out_close:
	filp_close(fp, NULL);
	return error;
}

int sec_ts_firmware_update_on_hidden_menu(struct sec_ts_data *ts,
																					int update_type) {
	int ret = 0;

	/* Factory cmd for firmware update
	 * argument represent what is source of firmware like below.
	 *
	 * 0 : [BUILT_IN] Getting firmware which is for user.
	 * 1 : [UMS] Getting firmware from sd card.
	 * 2 : none
	 * 3 : [FFU] Getting firmware from air.
	 */

	switch (update_type) {
	case BUILT_IN:
		ret = sec_ts_firmware_update_on_probe(ts);
		break;
	case UMS:
		ret = sec_ts_load_fw_from_ums(ts);
		break;
	case FFU:
		input_err(true, ts->dev, "%s: Not support yet\n", __func__);
		break;
	default:
		input_err(true, ts->dev, "%s: Not support command[%d]\n", __func__,
							update_type);
		break;
	}
	return ret;
}
EXPORT_SYMBOL(sec_ts_firmware_update_on_hidden_menu);
