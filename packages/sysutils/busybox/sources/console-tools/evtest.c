/* vi: set sw=4 ts=4: */
/*
 * Checks if a key is pressed. Inspired by evtest tool
 *
 * Copyright (C) 2024 by Danil Zagoskin <z@gosk.in>
 *
 * Licensed under GPLv2, see file LICENSE in this source tree.
 */
//config:config EVTEST
//config:	bool "evtest (2.9 kb)"
//config:	default y
//config:	help
//config:	Tests for pressed key.

//applet:IF_EVTEST(APPLET(evtest, BB_DIR_USR_BIN, BB_SUID_DROP))

//kbuild:lib-$(CONFIG_EVTEST) += evtest.o

//usage:#define evtest_trivial_usage
//usage:		"--query /dev/input/eventX EV_KEY <value>"
//usage:#define evtest_full_usage "\n\n"
//usage:	"Tests for pressed key\n"
//usage:	"\n	<value>        numerical keycode to test"

#include "libbb.h"
#include <linux/kd.h>
#include <linux/input.h>


#define BITS_PER_LONG (sizeof(long) * 8)
#define NBITS(x) ((((x)-1)/BITS_PER_LONG)+1)
#define OFF(x)  ((x)%BITS_PER_LONG)
#define BIT(x)  (1UL<<OFF(x))
#define LONG(x) ((x)/BITS_PER_LONG)
#define test_bit(bit, array)	((array[LONG(bit)] >> OFF(bit)) & 1)

int evtest_main(int argc, char **argv) MAIN_EXTERNALLY_VISIBLE;
int evtest_main(int argc UNUSED_PARAM, char **argv)
{
	unsigned opts;
	char* arg_q;
	int fd;
	unsigned int keycode;
	unsigned long state[NBITS(KEY_MAX)];
	int r;

	enum {
		OPT_q = (1<<0), // query
	};

#if ENABLE_LONG_OPTS
	static const char evtest_longopts[] ALIGN1 =
		"query\0"     Required_argument    "q"
		;
#endif

	opts = getopt32long(argv, "^"
			"q:"
			"\0" "=2", evtest_longopts,
			&arg_q
			);

	if (strcmp(argv[optind], "EV_KEY") != 0) {
		bb_perror_msg_and_die("Unrecognised event type: %s", argv[optind]);
	}

	keycode = xatou(argv[optind + 1]);
	if (keycode >= KEY_MAX) {
		bb_perror_msg_and_die("key %u is out of bounds", keycode);
	}


	if (opts & OPT_q) {
		fd = open(arg_q, O_RDONLY);
		if (fd < 0) {
			bb_perror_msg_and_die("Cannot open %s", arg_q);
		}
	} else {
		bb_perror_msg_and_die("Only query mode is supported, pass --query /dev/input/eventX parameter");
	}

	memset(state, 0, sizeof(state));
	r = ioctl(fd, EVIOCGKEY(KEY_MAX), state);
	close(fd);

	if (r == -1) {
		bb_perror_msg_and_die("ioctl failed");
	}

	if (test_bit(keycode, state))
		return 10; /* different from EXIT_FAILURE */
	else
		return 0;
}
