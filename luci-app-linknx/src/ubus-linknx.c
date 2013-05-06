/*
 * Copyright (C) 2011 Felix Fietkau <nbd@openwrt.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 2.1
 * as published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#include <unistd.h>

#include <libubox/blobmsg_json.h>
#include <libubox/uloop.h>
#include <libubus.h>

static struct blob_buf b;
static int timeout = 30;
static bool simple_output = false;
static int verbose = 0;

static void receive_event(struct ubus_context *ctx, struct ubus_event_handler *ev,
			  const char *type, struct blob_attr *msg)
{
	char *str;

	str = blobmsg_format_json(msg, true);
	//printf("{ \"%s\": %s }\n\n", type, str);
	pid_t pid = fork();
	if (pid == 0)
	{
		execl("/usr/bin/lua", "lua", "/usr/bin/ubus-linknx.lua",  type, str, NULL);
	}
	free(str);
}


static int ubus_cli_listen(struct ubus_context *ctx, char *event)
{
	static struct ubus_event_handler listener;
	int ret = 0;

	memset(&listener, 0, sizeof(listener));
	listener.cb = receive_event;

	ret = ubus_register_event_handler(ctx, &listener, event);

	if (ret) {
		fprintf(stderr, "Error while registering for event '%s': %s\n",
			event, ubus_strerror(ret));
		return -1;
	}

	uloop_init();
	ubus_add_uloop(ctx);
	uloop_run();
	uloop_done();

	return 0;
}


static int usage(const char *prog)
{
	fprintf(stderr,
		"Usage: %s [<options>] <command> [arguments...]\n"
		"Options:\n"
		" -s <socket>:		Set the unix domain socket to connect to\n"
		" -t <timeout>:		Set the timeout (in seconds) for a command to complete\n"
		" -S:			Use simplified output (for scripts)\n"
		" -r <path>			receive List objects path\n"
		" -v:			More verbose output\n"
		"\n", prog);
	return 1;
}


int main(int argc, char **argv)
{
	const char *ubus_socket = NULL;
	static struct ubus_context *ctx;
	char ubus_event[128] = "";
	const char * ubusevent = NULL;
	char *cmd;
	int ret = 0;
	int i, ch;

	while ((ch = getopt(argc, argv, "r:vs:t:S")) != -1) {
		switch (ch) {
		case 's':
			ubus_socket = optarg;
			break;
		case 't':
			timeout = atoi(optarg);
			break;
		case 'S':
			simple_output = true;
			break;
		case 'r':
			strncpy(ubus_event, optarg, sizeof ubus_event);
			ubus_event[(sizeof ubus_event) - 1] = '\0';
			ubusevent = ubus_event;
			break;
		case 'v':
			verbose++;
			break;
		default:
			return usage("ubus-linknx");
		}
	}


	ctx = ubus_connect(ubus_socket);
	if (!ctx) {
		if (!simple_output)
			fprintf(stderr, "Failed to connect to ubus\n");
		return -1;
	}

	ret = -2;
	ret = ubus_cli_listen(ctx,ubusevent);
	if (ret > 0)
		fprintf(stderr, "Command failed: %s\n", ubus_strerror(ret));

	ubus_free(ctx);
	return 0;
}
