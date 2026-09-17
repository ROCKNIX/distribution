/* drivers/input/touchscreen/sec_ts.h
 *
 * Copyright (C) 2015 Samsung Electronics Co., Ltd.
 * http://www.samsungsemi.com/
 *
 * Core file for Samsung TSC driver
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#ifndef __SEC_TS_H__
#define __SEC_TS_H__

#ifdef CONFIG_SEC_DEBUG_TSP_LOG
#endif

/*add for samsung sec class*/
/*#define SAMSUNG_PROJECT*/

#define SEC_TS_I2C_NAME										"sec_ts"
#define SEC_TS_DEVICE_NAME								"SEC_TS"

#define USE_OPEN_CLOSE
#define TOUCH_RESET_DWORK_TIME						10
#define TOUCH_INTERRUPT_DWORK_TIME				110000
#define TOUCH_FWUPDATE_DWORK_TIME					4000
#define CALIBRATION_BY_FACTORY

/* LCD ID  0x ID1 ID2 ID3 */
#define LCD_ID2_MODEL_MASK								0x003000	/* ID2 - 00110000*/

#define MASK_1_BITS												0x0001
#define MASK_2_BITS												0x0003
#define MASK_3_BITS												0x0007
#define MASK_4_BITS												00x000F
#define MASK_5_BITS												00x001F
#define MASK_6_BITS												00x003F
#define MASK_7_BITS												00x007F
#define MASK_8_BITS												00x00FF

#define TYPE_STATUS_EVENT_ACK							1
#define TYPE_STATUS_EVENT_ERR							2
#define TYPE_STATUS_EVENT_INFO						3
#define TYPE_STATUS_EVENT_GEST						6

#define SEC_TS_ERR_ESD 										0xFF

#define BIT_STATUS_EVENT_ACK(a)						(a << TYPE_STATUS_EVENT_ACK)
#define BIT_STATUS_EVENT_ERR(a)						(a << TYPE_STATUS_EVENT_ERR)
#define BIT_STATUS_EVENT_INFO(a)					(a << TYPE_STATUS_EVENT_INFO)
#define BIT_STATUS_EVENT_GEST(a)					(a << TYPE_STATUS_EVENT_GEST)

#define DO_FW_CHECKSUM										(0x1 << 0)
#define DO_PARA_CHECKSUM									(0x1 << 1)

#define MAX_SUPPORT_TOUCH_COUNT 					10
#define MAX_SUPPORT_HOVER_COUNT 					1

#define SEC_TS_EVENTID_HOVER 							10

#define SEC_TS_STATE_POWER_ON  						1
#define SEC_TS_STATE_POWER_OFF 						0

#define I2C_WRITE_BUFFER_SIZE 						7

#define SEC_TS_DRV_VERSION 								"g_6ft0.v00"

#define SEC_TS_FW_MAX_BURSTSIZE 					256
#define CONFIG_FW_UPDATE_ON_PROBE

//#define POR_AFTER_I2C_RETRY
/*#define SEC_TS_SUPPORT_SEC_SWIPE */

#define AMBIENT_CAL 											0
#define OFFSET_CAL_SDC										1
#define OFFSET_CAL_SEC										2

#define SEC_TS_NVM_OFFSET_FAC_RESULT			0
#define SEC_TS_NVM_OFFSET_CAL_COUNT				1

/* SEC_TS READ REGISTER ADDRESS */
#define SEC_TS_READ_FW_STATUS							0x51
#define SEC_TS_READ_DEVICE_ID							0x52
#define SEC_TS_READ_SUB_ID								0x53
#define SEC_TS_READ_BOOT_STATUS						0x55
#define SEC_TS_READ_RAW_CHANNEL						0x58
#define SEC_TS_READ_FLASH_ERASE_STATUS		0x59
#define SEC_TS_READ_SET_TOUCHFUNCTION			0x64
#define SEC_TS_READ_THRESHOLD							0x6D
#define SEC_TS_READ_TS_STATUS							0x70
#define SEC_TS_READ_ONE_EVENT							0x71
#define SEC_TS_READ_CALIBRATION_REPORT		0x73
#define SEC_TS_READ_TOUCH_RAWDATA					0x76
#define SEC_TS_READ_TOUCH_SELF_RAWDAT	A		0x77
#define SEC_TS_READ_SELFTEST_RESULT				0x80
#define SEC_TS_READ_NVM										0x85
#define SEC_TS_READ_FW_INFO								0xA2
#define SEC_TS_READ_FW_VERSION						0xA3
#define SEC_TS_READ_PARA_VERSION					0xA4
#define SEC_TS_READ_IMG_VERSION						0xA5
#define SEC_TS_READ_LV3										0xD2
#define SEC_TS_READ_BL_UPDATE_STATUS			0xDB

#define SEC_TS_CMD_DEADZONE_RANGE					0x30
#define SEC_TS_CMD_LONGPRESSZONE_RANGE		0x31
#define SEC_TS_CMD_LONGPRESS_DROP_AREA		0x32
#define SEC_TS_CMD_LONGPRESS_DROP_DIFF		0x33
#define SEC_TS_CMD_SENSE_ON								0x40
#define SEC_TS_CMD_SENSE_OFF							0x41
#define SEC_TS_CMD_SW_RESET								0x42
#define SEC_TS_CMD_CALIBRATION_AMBIENT		0x43
#define SEC_TS_CMD_ERASE_FLASH						0x45
#define SEC_TS_CMD_STATEMANAGE_ON					0x48
#define SEC_TS_CMD_CALIBRATION_OFFSET_SDC	0x4C
#define SEC_TS_CMD_CALIBRATION_OFFSET_SEC	0x4F
#define SEC_TS_CMD_SELFTEST								0x51
#define SEC_TS_CMD_WRITE_FW_BLK						0x53
#define SEC_TS_CMD_WRITE_FW_SHORT					0x54
#define SEC_TS_CMD_WRITE_FW_LONG					0x5A
#define SEC_TS_CMD_ENTER_FW_MODE					0x57
#define SEC_TS_CMD_SELFTEST_TYPE					0x5F
#define SEC_TS_CMD_CLEAR_EVENT_STACK			0x60
#define SEC_TS_CMD_SET_TOUCHFUNCTION			0x63
#define SEC_TS_CMD_SET_POWER_MODE					0x65
#define SEC_TS_CMD_STATUS_EVENT_TYPE			0x6B
#define SEC_TS_CMD_GESTURE_MODE						0x6C
#define SEC_TS_CMD_EDGE_DEADZONE					0x6E
#define SEC_TS_CMD_NOISE_MODE							0x77
#define SEC_TS_CMD_NVM										0x85
#define SEC_TS_CMD_SELFTEST_PTOP					0x82
#define SEC_TS_CMD_GET_CHECKSUM						0xA6
#define SEC_TS_CMD_CHG_SYSMODE						0xD7

#define SEC_TS_CMD_MUTU_RAW_TYPE					0xF4
#define SEC_TS_CMD_SELF_RAW_TYPE					0xFA

#define SEC_TS_SELFTEST_REPORT_SIZE				17508

#define SEC_TS_ID_ON_FW										0xAC
#define SEC_TS_ID_ON_BOOT									0xD0

#define SEC_TS_Status_Event								0
#define SEC_TS_Coordinate_Event						1
#define SEC_TS_Gesture_Event							2
#define SEC_TS_Event_Buff_Size						8
#define SEC_TS_SID_GESTURE								0x14
#define SEC_TS_GESTURE_CODE_AOD						0x00
#define SEC_TS_GESTURE_CODE_SPAY					0x0A
#define SEC_TS_GESTURE_CODE_SIDE_GESTURE	0x11

#define SEC_TS_Coordinate_Action_None			0
#define SEC_TS_Coordinate_Action_Press		1
#define SEC_TS_Coordinate_Action_Release	3
#define SEC_TS_Coordinate_Action_Move 		2

#define SEC_TS_TOUCHTYPE_NORMAL						0
#define SEC_TS_TOUCHTYPE_PROXIMITY				1
#define SEC_TS_TOUCHTYPE_GLOVE						3
#define SEC_TS_TOUCHTYPE_STYLUS						4
#define SEC_TS_TOUCHTYPE_HOVER						5
#define SEC_TS_TOUCHTYPE_PALM							6

/* SEC_TS_ACK : acknowledge event */
#define SEC_TS_ACK_OFFSET_CAL_DONE				0x01
#define SEC_TS_ACK_SELF_TEST_DONE					0x0A
#define SEC_TS_ACK_BOOT_COMPLETE					0x0C

#define SEC_TS_BIT_SETFUNC_TOUCH					(0x1<<0)
#define SEC_TS_BIT_SETFUNC_MUTUAL					(0x1<<0)
#define SEC_TS_BIT_SETFUNC_HOVER					(0x1<<1)
#define SEC_TS_BIT_SETFUNC_GLOVE					(0x1<<3)
#define SEC_TS_BIT_SETFUNC_CHARGER				(0x1<<4)
#define SEC_TS_BIT_SETFUNC_STYLUS					(0x1<<5)

#define SEC_TS_STATUS_NOT_CALIBRATION			0x50
#define SEC_TS_STATUS_CALIBRATION_SDC			0xA1
#define SEC_TS_STATUS_CALIBRATION_SEC			0xA2

#define STATE_MANAGE_ON										1
#define STATE_MANAGE_OFF									0

#define SEC_TS_MAX_FW_PATH								64
#define SEC_TS_FW_BLK_SIZE								256
#define SEC_TS_FW_HEADER_SIGN							0x53494654
#define SEC_TS_FW_CHUNK_SIGN							0x53434654
#define SEC_TS_DEFAULT_FW_NAME						"app.bin"
#define SEC_TS_DEFAULT_PARA_NAME					"para.bin"
#define SEC_TS_DEFAULT_UMS_FW							"lsi.bin"

#define SEC_TS_INTERRUPT_EN 							1
#define SEC_TS_INTERRUPT_DIS							0

#define CONFIG_6FT0

enum {
	BUILT_IN = 0,
	UMS,
	NONE,
	FFU,
};

struct fw_header {
	u32 signature;			/*signature*/
	u32 version;				/*img_version*/
	u32 FlashInfo0;			/*max flash size*/
	u32 FlashInfo1;			/*parameter area*/
	u32 flag;						/*mode select/bootloader mode*/
	u32 setting;				/*HWB settings*/
	u32 checksum;				/*checksum*/
	u32 BootStartAddr[3];
	u32 FlashLoadAddr[3];
	u32 NumberOfChunk[3];
};

struct fw_chunk {
	u32 signature;
	u32 addr;
	u32 size;
	u32 reserved;
};

enum TOUCH_SYSTEM_MODE {
	TOUCH_SYSTEM_MODE_BOOT = 0,
	TOUCH_SYSTEM_MODE_CALIBRATION = 1,
	TOUCH_SYSTEM_MODE_TOUCH = 2,
	TOUCH_SYSTEM_MODE_SELFTEST = 3,
	TOUCH_SYSTEM_MODE_FLASH = 4,
	TOUCH_SYSTEM_MODE_LOWPOWER = 5,
	TOUCH_SYSTEM_MODE_LISTEN
};

enum TOUCH_MODE_STATE {
	TOUCH_MODE_STATE_IDLE = 0,
	TOUCH_MODE_STATE_HOVER = 1,
	TOUCH_MODE_STATE_TOUCH = 2,
	TOUCH_MODE_STATE_NOISY = 3,
	TOUCH_MODE_STATE_CAL = 4,
	TOUCH_MODE_STATE_CAL2 = 5,
	TOUCH_MODE_STATE_WAKEUP = 10
};

enum switch_system_mode {
	TO_TOUCH_MODE = 0,
	TO_LOWPOWER_MODE,
	TO_SELFTEST_MODE,
	TO_FLASH_MODE = 3,
};

#define CMD_STR_LEN 						256
#define CMD_PARAM_NUM 					8
#define CMD_RESULT_STR_LEN		 	4095
#define SEC_CMD_BUF_SIZE				4095
#define CMD_RESULT_WORD_LEN			10

#define SEC_TS_I2C_RETRY_CNT 		10
#define SEC_TS_WAIT_RETRY_CNT 	100

#define SEC_TS_LOWP_FLAG_AOD							(1 << 4)
#define SEC_TS_LOWP_FLAG_SPAY							(1 << 5)
#define SEC_TS_LOWP_FLAG_SIDE_GESTURE			(1 << 6)

extern struct sec_ts_callbacks *charger_callbacks;
struct sec_ts_callbacks {
	void (*inform_charger)(struct sec_ts_callbacks *, int type);
};

/* ----------------------------------------
 * write 0xE4 [ 11 | 10 | 01 | 00 ]
 * MSB <-------------------> LSB
 * read 0xE4
 * mapping sequnce : LSB -> MSB
 * struct sec_ts_test_result {
 * * assy : front + OCTA assay
 * * module : only OCTA
 *	 union {
 *		 struct {
 *			 u8 assy_count:2;		-> 00
 *			 u8 assy_result:2;		-> 01
 *			 u8 module_count:2;	-> 10
 *			 u8 module_result:2;	-> 11
 *		 } __attribute__ ((packed));
 *		 unsigned char data[1];
 *	 };
 *};
 * ---------------------------------------- */
struct sec_ts_test_result {
	union {
		struct {
			u8 assy_count:2;
			u8 assy_result:2;
			u8 module_count:2;
			u8 module_result:2;
		} __packed;
		unsigned char data[1];
	};
};

struct sec_ts_coordinate {
	u16 x;
	u16 y;
	u16 mcount;
	u8 id;
	u8 ttype;
	u8 action;
	u8 touch_width;
	u8 hover_flag;
	u8 glove_flag;
	u8 touch_height;
	u8 major;
	u8 minor;
	u8 palm;
};

struct sec_ts_event_coordinate {
	u8 tchsta:3;
	u8 ttype:3;
	u8 eid:2;

	u8 tid:4;
	u8 nt:4;

	u8 x_11_4;

	u8 y_11_4;

	u8 y_3_0:4;
	u8 x_3_0:4;

	u8 z;
	u8 major;
	u8 minor;
/*	u8 reserved_7:7; */
} __packed;

#define TEST_MODE_MIN_MAX		false
#define TEST_MODE_ALL_NODE		true
#define TEST_MODE_READ_FRAME		false
#define TEST_MODE_READ_CHANNEL		true

/* factory test mode */
struct sec_ts_test_mode {
	u8 type;
	short min;
	short max;
	bool allnode;
	bool frame_channel;
};

struct sec_ts_data {
	u32 isr_pin;

	u32 crc_addr;
	u32 fw_addr;
	u32 para_addr;

	u8 boot_ver[3];

	struct device *dev;
	struct i2c_client *client;
	struct input_dev *input_dev;
	struct sec_ts_plat_data *plat_data;
	struct factory_data *f_data;
	struct sec_ts_coordinate coord[MAX_SUPPORT_TOUCH_COUNT + 1];
	struct completion init_done;
#if defined(CONFIG_FB)
	struct notifier_block fb_notif;
#endif
	uint32_t flags;
	unsigned char lowpower_flag;
	bool lowpower_mode;
	int lowpower_status;
	int touch_count;
	int tx_count;
	int rx_count;
	int i2c_burstmax;
	int ta_status;
	int power_status;
	int raw_status;
	int event_errcnt;
	int touchkey_glove_mode_status;
	u8 touch_functions;
	u8 hover_enables;
	u8 interrupt_enable;
	struct sec_ts_event_coordinate touchtype;
	bool touched[11];
	u8 gesture_status[SEC_TS_Event_Buff_Size];
	u8 cal_status;
	bool fw_workdone;
	bool force_fwup;

	struct sec_ts_callbacks callbacks;

	struct mutex lock;
	struct mutex device_mutex;
	struct mutex i2c_mutex;

	struct delayed_work reset_work;
	struct delayed_work interrupt_work;
	struct delayed_work fwupdate_work;
	struct delayed_work  open_work;

	int irq;
	bool enabled;

	/* factory_data */
	struct device *fac_dev_ts;
	bool cmd_is_running;
	unsigned char cmd_state;
	char cmd[CMD_STR_LEN];
	int cmd_param[CMD_PARAM_NUM];
	char cmd_buff[CMD_STR_LEN];
	char cmd_result[CMD_RESULT_STR_LEN];
	int cmd_buffer_size;
	struct mutex cmd_lock;
	struct list_head cmd_list_head;
	void (*sec_ts_fn_init)(void *device_data);
	int SenseChannelLength;
	int ForceChannelLength;
	short *pFrame;
	short *sFrame;
	unsigned char *cx_data;
	int delayed_cmd_param[2];

	struct delayed_work read_nv_work;

	bool touch_stopped;
	bool reinit_done;
	bool flip_enable;
	bool probe_done;
#ifdef FTS_SUPPORT_2NDSCREEN
	u8 SIDE_Flag;
	u8 previous_SIDE_value;
#endif

	unsigned int scrub_id;
	unsigned int scrub_x;
	unsigned int scrub_y;

	int nv;
	int cal_count;

#ifdef CONFIG_SEC_DEBUG_TSP_LOG
	struct delayed_work ghost_check;
	u8 tsp_dump_lock;
#endif

	int tspid_val;
	int tspid2_val;

	int (*sec_ts_i2c_write)(struct sec_ts_data *ts, u8 reg, u8 *data, int len);
	int (*sec_ts_i2c_read)(struct sec_ts_data *ts, u8 reg, u8 *data, int len);
	int (*sec_ts_i2c_read_bulk)(struct sec_ts_data *ts, u8 *data, int len);
	int (*sec_ts_i2c_write_burst)(struct sec_ts_data *ts, u8 *data, int len);
};

struct sec_ts_plat_data {
	int max_x;
	int max_y;
	/*int intx_pin;*/
	int num_tx;
	int num_rx;
	unsigned gpio;
	unsigned gpio_det;
	int irq_type;
	int i2c_burstmax;

	const char *firmware_name;
	const char *parameter_name;
	const char *model_name;
	const char *project_name;
	const char *regulator_dvdd;
	const char *regulator_avdd;

	int panel_revision;
	u8 img_version_of_ic[4];
	u8 img_version_of_bin[4];
	u8 para_version_of_ic[4];
	u8 para_version_of_bin[4];

	struct pinctrl *pinctrl;
	struct pinctrl_state *pins_default;
	struct pinctrl_state *pins_sleep;

	int (*power)(void *data, bool on);
	void (*recovery_mode)(bool on);
	void (*enable_sync)(bool on);
	void (*register_cb)(struct sec_ts_callbacks *);

	unsigned tspid;
	unsigned tspid2;
};

int sec_ts_firmware_update_on_probe(struct sec_ts_data *ts);
int sec_ts_firmwarei_update_on_probe(struct sec_ts_data *ts);
int sec_ts_firmware_update_on_hidden_menu(struct sec_ts_data *ts, int update_type);
int sec_ts_check_firmware_version(struct sec_ts_data *ts, const u8 *fw_info);
int sec_ts_glove_mode_enables(struct sec_ts_data *ts, int mode);
int sec_ts_hover_enables(struct sec_ts_data *ts, int enables);
int sec_ts_wait_for_ready(struct sec_ts_data *ts, unsigned int ack);
int sec_ts_function(int(*func_init)(void *device_data), void(*func_remove)(void));
int sec_ts_read_calibration_report(struct sec_ts_data *ts);
int sec_ts_execute_force_calibration(struct sec_ts_data *ts, int cal_mode);
int get_tsp_nvm_data(struct sec_ts_data *ts, u8 offset);
void sec_ts_release_all_finger(struct sec_ts_data *ts);

int sec_ts_sw_reset(struct sec_ts_data *ts);
void sec_ts_delay(unsigned int ms);
int sec_ts_fn_init(struct sec_ts_data *ts);
u8 *sec_get_fwdata(void);

extern struct class *sec_class;

#if defined(CONFIG_SEC_DEBUG_TSP_LOG)
extern void sec_ts_run_rawdata_all(struct sec_ts_data *ts);
#endif
#ifndef input_dbg
#define input_dbg(mode, dev, fmt, ...) dev_dbg(dev, fmt, ## __VA_ARGS__)
#endif
#ifndef input_info
#define input_info(mode, dev, fmt, ...)	dev_info(dev, fmt, ## __VA_ARGS__)
#endif
#ifndef input_err
#define input_err(mode, dev, fmt, ...) dev_err(dev, fmt, ## __VA_ARGS__)
#endif
#endif
