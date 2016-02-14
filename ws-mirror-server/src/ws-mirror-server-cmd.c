/*
 * libwebsockets-test-client - libwebsockets test implementation
 *
 * Copyright (C) 2011 Andy Green <andy@warmcat.com>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation:
 *  version 2.1 of the License.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *  MA  02110-1301  USA
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>

#include "libwebsockets.h"

static unsigned int opts;
//static int was_closed;
static int deny_deflate;
static int deny_mux;
static struct libwebsocket *wsi_mirror;
const char *message;


/*
 * This demo shows how to connect multiple websockets simultaneously to a
 * websocket server (there is no restriction on their having to be the same
 * server just it simplifies the demo).
 *
 *  dumb-increment-protocol:  we connect to the server and print the number
 *				we are given
 *
 *  lws-mirror-protocol: draws random circles, which are mirrored on to every
 *				client (see them being drawn in every browser
 *				session also using the test server)
 */

enum demo_protocols {

//	PROTOCOL_DUMB_INCREMENT,
	PROTOCOL_LWS_MIRROR,

	/* always last */
	DEMO_PROTOCOL_COUNT
};



/* lws-mirror_protocol */


static int
callback_lws_mirror(struct libwebsocket_context * this,
			struct libwebsocket *wsi,
			enum libwebsocket_callback_reasons reason,
					       void *user, void *in, size_t len)
{
	unsigned char buf[LWS_SEND_BUFFER_PRE_PADDING + 4096 +
						  LWS_SEND_BUFFER_POST_PADDING];
	int l;

	switch (reason) {

	case LWS_CALLBACK_CLOSED:
		fprintf(stderr, "mirror: LWS_CALLBACK_CLOSED\n");
		wsi_mirror = NULL;
		break;

	case LWS_CALLBACK_CLIENT_ESTABLISHED:

		/*
		 * start the ball rolling,
		 * LWS_CALLBACK_CLIENT_WRITEABLE will come next service
		 */

		libwebsocket_callback_on_writable(this, wsi);
		break;

	case LWS_CALLBACK_CLIENT_RECEIVE:
/*		fprintf(stderr, "rx %d '%s'\n", (int)len, (char *)in); */
		break;

	case LWS_CALLBACK_CLIENT_WRITEABLE:

//		l = sprintf((char *)&buf[LWS_SEND_BUFFER_PRE_PADDING],
//					"Random 90: %d;",
//					(int)random() % 90);
		l = sprintf((char *)&buf[LWS_SEND_BUFFER_PRE_PADDING],
					"console: %s",
					message);

		libwebsocket_write(wsi,
		   &buf[LWS_SEND_BUFFER_PRE_PADDING], l, opts | LWS_WRITE_TEXT);

		/* get notified as soon as we can write again */

		libwebsocket_callback_on_writable(this, wsi);

		/*
		 * without at least this delay, we choke the browser
		 * and the connection stalls, despite we now take care about
		 * flow control
		 */

		usleep(1000000);
		break;

	default:
		break;
	}

	return 0;
}


/* list of supported protocols and callbacks */

static struct libwebsocket_protocols protocols[] = {
	{
		"lws-mirror-protocol",
		callback_lws_mirror,
		0,
	},
	{  /* end of list */
		NULL,
		NULL,
		0
	}
};

static struct option options[] = {
	{ "help",	no_argument,		NULL, 'h' },
	{ "port",	required_argument,	NULL, 'p' },
	{ "ssl",	no_argument,		NULL, 's' },
	{ "killmask",	no_argument,		NULL, 'k' },
	{ "version",	required_argument,	NULL, 'v' },
	{ "undeflated",	no_argument,		NULL, 'u' },
	{ "nomux",	no_argument,		NULL, 'n' },
	{ NULL, 0, 0, 0 }
};


int main(int argc, char **argv)
{
	int n = 0;
	int port = 7681;
	int use_ssl = 0;
	struct libwebsocket_context *context;
	const char *address;
	//struct libwebsocket *wsi_dumb;
	int ietf_version = -1; /* latest */
	int mirror_lifetime = 0;
//	fprintf(stderr, "libwebsockets test client\n"
//			"(C) Copyright 2010 Andy Green <andy@warmcat.com> "
//						    "licensed under LGPL2.1\n");

	if (argc < 2)
		goto usage;

	while (n >= 0) {
		n = getopt_long(argc, argv, "nuv:khspm:", options, NULL);
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
		case 'm':
			message = optarg;
			break;
		case 'h':
			goto usage;
		}
	}

	if (optind >= argc)
		goto usage;

	address = argv[optind];

	/*
	 * create the websockets context.  This tracks open connections and
	 * knows how to route any traffic and which protocol version to use,
	 * and if each connection is client or server side.
	 *
	 * For this client-only demo, we tell it to not listen on any port.
	 */

	context = libwebsocket_create_context(CONTEXT_PORT_NO_LISTEN, NULL,
				protocols, libwebsocket_internal_extensions,
							 NULL, NULL, -1, -1, 0);
	if (context == NULL) {
		fprintf(stderr, "Creating libwebsocket context failed\n");
		return 1;
	}


	/*
	 * sit there servicing the websocket context to handle incoming
	 * packets, and drawing random circles on the mirror protocol websocket
	 */

	n = 0;
	mirror_lifetime = 0;
//	while (n >= 0 && !was_closed) {
	while (n >= 0) {
		fprintf(stderr, "while %i\n",n);
		n = libwebsocket_service(context, 1);
		fprintf(stderr, "while context %i\n",n);
		if (wsi_mirror == NULL) {
			fprintf(stderr, "wsi_mirror == NULL\n");

			/* create a client websocket using mirror protocol */
			fprintf(stderr, "argv %s\n",argv[optind]);
			wsi_mirror = libwebsocket_client_connect(context, address, port,
			     use_ssl,  "/", argv[optind], argv[optind],
					     protocols[PROTOCOL_LWS_MIRROR].name, ietf_version);

			if (wsi_mirror == NULL) {
				fprintf(stderr, "libwebsocket dumb connect failed\n");
				return -1;
			}
		} else {
			fprintf(stderr, "wsi_mirror == NULL else\n");
			mirror_lifetime--;
		}
		if (mirror_lifetime < -1) {
			fprintf(stderr, "break\n");
			break;
		}
	}

	fprintf(stderr, "Exiting\n");

	libwebsocket_context_destroy(context);

	return 0;

usage:
	fprintf(stderr, "Usage: libwebsockets-test-client "
					     "-m <Message> <server address> [--port=<p>] "
					     "[--ssl] [-k] [-v <ver>]\n");
	return 1;
}
