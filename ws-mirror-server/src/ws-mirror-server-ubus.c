/*
 * libwebsockets-test-client - libwebsockets test implementation
 *
 * Copyright (C) 2011-2016 Andy Green <andy@warmcat.com>
 *
 * This file is made available under the Creative Commons CC0 1.0
 * Universal Public Domain Dedication.
 *
 * The person who associated a work with this deed has dedicated
 * the work to the public domain by waiving all of his or her rights
 * to the work worldwide under copyright law, including all related
 * and neighboring rights, to the extent allowed by law. You can copy,
 * modify, distribute and perform the work, even for commercial purposes,
 * all without asking permission.
 *
 * The test apps are intended to be adapted for use in your code, which
 * may be proprietary.  So unlike the library itself, they are licensed
 * Public Domain.
 */

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <signal.h>

#include <libubox/blobmsg_json.h>
#include <libubox/uloop.h>
#include <libubus.h>
#include <libwebsockets.h>

static unsigned int opts;
static int was_closed;
static int deny_deflate;
static int deny_mux;
const char *message;

static struct lws *wsi_mirror;
const char *address;
int port = 7681;
int use_ssl = 0;
int ietf_version = -1; /* latest */
struct lws_context_creation_info info;
struct lws_context *lws_context;

static int force_exit = 0;

char ubus_event[128] = "";
const char * ubusevent = NULL;

/*
 *  lws-mirror-protocol: send messages, which are mirrored on to every
 *				client (see them being drawn in every browser
 *				session also using the test server)
 */

enum demo_protocols {
	PROTOCOL_LWS_MIRROR,
	/* always last */
	DEMO_PROTOCOL_COUNT
};

/* lws-mirror_protocol */

static int
callback_lws_mirror(struct lws *wsi, enum lws_callback_reasons reason,
		void *user, void *in, size_t len)
{
	unsigned char buf[LWS_PRE + 4096];
	int l = 0;
	int n;

	switch (reason) {
	case LWS_CALLBACK_CLOSED:
		wsi_mirror = NULL;
		was_closed = 1;
		break;

	case LWS_CALLBACK_CLIENT_ESTABLISHED:
		l += sprintf((char *)&buf[LWS_PRE + l],
					"%s",message);

		n = lws_write(wsi, &buf[LWS_PRE], l,
			opts | LWS_WRITE_TEXT);
		/* get notified as soon as we can write again */
		if (n < 0)
			fprintf(stderr, "Write LWS_CALLBACK_CLIENT_ESTABLISHED %i < 0\n",n);
			return -1;
		if (n < l) {
			fprintf(stderr, "Partial write LWS_CALLBACK_CLIENT_ESTABLISHED %i < %i \n",n,l);
			return -1;
		}
		break;

	default:
		break;
	}
	return 0;
}

/* list of supported protocols and callbacks */

static struct lws_protocols protocols[] = {
	{
		"lws-mirror-protocol",
		callback_lws_mirror,
		0,
		128,
	},
	{ NULL, NULL, 0, 0 }
};

void sighandler(int sig)
{
	force_exit = 1;
}


static void receive_event(struct ubus_context *ctx, struct ubus_event_handler *ev,
			const char *type, struct blob_attr *msg)
{
	int use_ssl = 0, j = 0;
	struct lws_client_connect_info i;
	char path[300];
	wsi_mirror = NULL;

	message = blobmsg_format_json(msg, true);

	memset(&i, 0, sizeof(i));
	i.port = port;
	i.address = "127.0.0.1";
	/* add back the leading / on path */
	path[0] = '/';
	//strncpy(path + 1, address, sizeof(path) - 2);
	//path[sizeof(path) - 1] = '\0';

	i.context = lws_context;
	i.ssl_connection = use_ssl;
	i.path = path;
	i.host = i.address;
	i.origin = i.address;
	i.ietf_version_or_minus_one = ietf_version;
	i.protocol = protocols[PROTOCOL_LWS_MIRROR].name;
	wsi_mirror = lws_client_connect_via_info(&i);
	was_closed = 0;
	while (j >= 0 && !was_closed) {
		j = lws_service(lws_context, 100);
	}
	lws_cancel_service(lws_context);
}

static struct option options[] = {
	{ "help",	no_argument,		NULL, 'h' },
	{ "port",	required_argument,	NULL, 'p' },
	{ "ssl",	no_argument,		NULL, 's' },
	{ "killmask",	no_argument,		NULL, 'k' },
	{ "version",	required_argument,	NULL, 'v' },
	{ "undeflated",	no_argument,		NULL, 'u' },
	{ "nomux",	no_argument,		NULL, 'n' },
	{ "ubusevent",  required_argument,		NULL, 'r' },
	{ NULL, 0, 0, 0 }
};


int main(int argc, char **argv)
{
	int n = 0;
	const char *ubus_socket = NULL;
	struct ubus_context *ctx;
	struct ubus_event_handler listener;
	int ret;

	if (argc < 2)
		goto usage;

	while (n >= 0) {
		n = getopt_long(argc, argv, "nuv:khsp:r:", options, NULL);
		if (n < 0)
			continue;
		switch (n) {
		case 's':
			use_ssl = 2; /* 2 = allow selfsigned */
			break;
		case 'p':
			port = atoi(optarg);
			break;
		case 'k':
			opts = LWS_WRITE_CLIENT_IGNORE_XOR_MASK;
			break;
		case 'v':
			ietf_version = atoi(optarg);
			break;
		case 'u':
			deny_deflate = 1;
			break;
		case 'n':
			deny_mux = 1;
			break;
		case 'r':
			strncpy(ubus_event, optarg, sizeof ubus_event);
			ubus_event[(sizeof ubus_event) - 1] = '\0';
			ubusevent = ubus_event;
			break;
		case 'h':
			goto usage;
		}
	}

	if (optind >= argc)
		goto usage;

	address = argv[optind];
	
	memset(&info, 0, sizeof info);
	info.port = CONTEXT_PORT_NO_LISTEN;
	info.iface = NULL;
	info.protocols = protocols;
	info.gid = -1;
	info.uid = -1;

	lws_context = lws_create_context(&info);
	if (lws_context == NULL) {
		fprintf(stderr, "Creating libwebsocket lws_context failed\n");
		return -1;
	}

	ctx = ubus_connect(ubus_socket);
	if (!ctx) {
		lwsl_err("Failed to connect to ubus\n");
		return -1;
	}
	memset(&listener, 0, sizeof(listener));
	listener.cb = receive_event;

	ret = ubus_register_event_handler(ctx, &listener, ubusevent);
	if (ret) {
		fprintf(stderr, "Error while registering for event '%s': %s\n",
				ubusevent, ubus_strerror(ret));
		return -1;
	}
	uloop_init();
	ubus_add_uloop(ctx);

	uloop_run();
	uloop_done();
	fprintf(stderr, "Exiting\n");
	ubus_free(ctx);

	return 0;

usage:
	fprintf(stderr, "Usage: libwebsockets-test-client "
						"-m <Message> <server address> [--port=<p>] "
						"[--ssl] [-k] [-v <ver>]\n");
	return 1;
}
