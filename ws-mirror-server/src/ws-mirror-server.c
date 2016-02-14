/*
 * libwebsockets-test-server - libwebsockets test implementation
 *
 * Copyright (C) 2010-2011 Andy Green <andy@warmcat.com>
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
#include <sys/time.h>

#include <libubox/blobmsg_json.h>
#include <libubox/uloop.h>
#include <libubus.h>
#include <libwebsockets.h>

volatile int force_exit = 0;
struct lws_context *context;

static int close_testing;
char ubus_xevent[128] = "";
const char * ubusxevent = NULL;

/*
 *  lws-mirror-protocol: send messages, which are mirrored on to every
 *				client (see them being drawn in every browser
 *				session also using the test server)
 */

enum demo_protocols {
	/* always first */
	PROTOCOL_HTTP = 0,

	PROTOCOL_LWS_MIRROR,

	/* always last */
	DEMO_PROTOCOL_COUNT
};


#define LOCAL_RESOURCE_PATH DATADIR
#define LOCAL_CONFIG_PATH CONFIGDIR

/*
 * We take a strict whitelist approach to stop ../ attacks
 */

struct serveable {
	const char *urlpath;
	const char *mimetype;
}; 

static const struct serveable whitelist[] = {
	{ "/favicon.ico", "image/x-icon" },
	{ "/cascade.css", "text/css" },
	{ "/mobile.css", "text/css" },
	{ "/chat.js", "text/javascript" },

	/* last one is the default served if no match */
	{ "/index.html", "text/html" },
};

struct per_session_data__http {
	int fd;
};

int callback_http(struct lws *wsi,
		enum lws_callback_reasons reason, void *user,
		void *in, size_t len)
{
#if 0
	char client_name[128];
	char client_ip[128];
#endif
	char buf[256];
	int n;
	char *other_headers;
#ifdef EXTERNAL_POLL
	int fd = (int)(long)in;
#endif

	switch (reason) {
	case LWS_CALLBACK_HTTP:
		fprintf(stderr, "serving HTTP URI %s\n", (char *)in);

		for (n = 0; n < (sizeof(whitelist) / sizeof(whitelist[0]) - 1); n++)
			if (in && strcmp((const char *)in, whitelist[n].urlpath) == 0)
				break;

		sprintf(buf, LOCAL_RESOURCE_PATH"%s", whitelist[n].urlpath);
			other_headers = NULL;
		n = lws_serve_http_file(wsi, buf, whitelist[n].mimetype,other_headers, n);
		if (n < 0 || ((n > 0) && lws_http_transaction_completed(wsi)))
			return -1; /* through completion or error, close the socket */

		break;

	case LWS_CALLBACK_FILTER_NETWORK_CONNECTION:
#if 0
		lws_get_peer_addresses((int)(long)user, client_name,
			     sizeof(client_name), client_ip, sizeof(client_ip));

		fprintf(stderr, "Received network connect from %s (%s)\n",
							client_name, client_ip);
#endif
		/* if we returned non-zero from here, we kill the connection */
		break;

	default:
		break;
	}

	return 0;
}


/*
 * this is just an example of parsing handshake headers, you don't need this
 * in your code unless you will filter allowing connections by the header
 * content
 */

void
dump_handshake_info(struct lws *wsi)
{
	int n = 0, len;
	char buf[256];
	const unsigned char *c;

	do {
		c = lws_token_to_string(n);
		if (!c) {
			n++;
			continue;
		}

		len = lws_hdr_total_length(wsi, n);
		if (!len || len > sizeof(buf) - 1) {
			n++;
			continue;
		}

		lws_hdr_copy(wsi, buf, sizeof buf, n);
		buf[sizeof(buf) - 1] = '\0';

		fprintf(stderr, "    %s = %s\n", (char *)c, buf);
		n++;
	} while (c);
}


/* lws-mirror_protocol */

#define MAX_MESSAGE_QUEUE 64

struct per_session_data__lws_mirror {
	struct lws *wsi;
	int ringbuffer_tail;
};

struct a_message {
	void *payload;
	size_t len;
};

static struct a_message ringbuffer[MAX_MESSAGE_QUEUE];
static int ringbuffer_head;

int
callback_lws_mirror(struct lws *wsi, enum lws_callback_reasons reason,
			void *user, void *in, size_t len)
{
	struct per_session_data__lws_mirror *pss =
			(struct per_session_data__lws_mirror *)user;
	int m,n;

	switch (reason) {

	case LWS_CALLBACK_ESTABLISHED:
		lwsl_info("callback_lws_mirror: LWS_CALLBACK_ESTABLISHED\n", __func__);
		pss->ringbuffer_tail = ringbuffer_head;
		pss->wsi = wsi;
		break;

	case LWS_CALLBACK_PROTOCOL_DESTROY:
		lwsl_notice("mirror protocol cleaning up\n");
		for (n = 0; n < sizeof ringbuffer / sizeof ringbuffer[0]; n++)
			if (ringbuffer[n].payload)
				free(ringbuffer[n].payload);
		break;

	case LWS_CALLBACK_SERVER_WRITEABLE:
		if (close_testing)
			break;
		while (pss->ringbuffer_tail != ringbuffer_head) {
			m = ringbuffer[pss->ringbuffer_tail].len;
			n = lws_write(wsi, (unsigned char *)
					ringbuffer[pss->ringbuffer_tail].payload +
					LWS_PRE, m, LWS_WRITE_TEXT);
			if (n < 0) {
				lwsl_err("ERROR %d writing to mirror socket\n", n);
				return -1;
			}
			if (n < m)
				lwsl_err("mirror partial write %d vs %d\n", n, m);

			if (pss->ringbuffer_tail == (MAX_MESSAGE_QUEUE - 1))
				pss->ringbuffer_tail = 0;
			else
				pss->ringbuffer_tail++;

			if (((ringbuffer_head - pss->ringbuffer_tail) &
				  (MAX_MESSAGE_QUEUE - 1)) == (MAX_MESSAGE_QUEUE - 15))
				lws_rx_flow_allow_all_protocol(lws_get_context(wsi),
						lws_get_protocol(wsi));

			if (lws_send_pipe_choked(wsi)) {
				lws_callback_on_writable(wsi);
				break;
			}
			/*
			 * for tests with chrome on same machine as client and
			 * server, this is needed to stop chrome choking
			 */
			usleep(1);
		}
		break;

	case LWS_CALLBACK_RECEIVE:

		if (((ringbuffer_head - pss->ringbuffer_tail) &
				  (MAX_MESSAGE_QUEUE - 1)) == (MAX_MESSAGE_QUEUE - 1)) {
			lwsl_err("dropping!\n");
			goto choke;
		}

		if (ringbuffer[ringbuffer_head].payload)
			free(ringbuffer[ringbuffer_head].payload);

		ringbuffer[ringbuffer_head].payload =
				malloc(LWS_SEND_BUFFER_PRE_PADDING + len +
						  LWS_SEND_BUFFER_POST_PADDING);
		ringbuffer[ringbuffer_head].len = len;
		memcpy((char *)ringbuffer[ringbuffer_head].payload +
					  LWS_SEND_BUFFER_PRE_PADDING, in, len);
		if (ringbuffer_head == (MAX_MESSAGE_QUEUE - 1))
			ringbuffer_head = 0;
		else
			ringbuffer_head++;

		if (((ringbuffer_head - pss->ringbuffer_tail) &
				  (MAX_MESSAGE_QUEUE - 1)) != (MAX_MESSAGE_QUEUE - 2))
			goto done;

choke:
		lwsl_debug("LWS_CALLBACK_RECEIVE: throttling %p\n", wsi);
		lws_rx_flow_control(wsi, 0);

done:
		lws_callback_on_writable_all_protocol(lws_get_context(wsi),
						lws_get_protocol(wsi));

		const char *ubus_socket = NULL;
		struct ubus_context *ctx;
		static struct blob_buf b;
		ctx = ubus_connect(ubus_socket);
		if (!ctx) {
			fprintf(stderr, "Failed to connect to ubus\n");
			return -1;
		}		
		blob_buf_init(&b, 0);
		blobmsg_add_json_from_string(&b, (char *)in);
		ubus_send_event(ctx, ubusxevent, b.head);
		ubus_free(ctx);

		break;
	/*
	 * this just demonstrates how to use the protocol filter. If you won't
	 * study and reject connections based on header content, you don't need
	 * to handle this callback
	 */

	case LWS_CALLBACK_FILTER_PROTOCOL_CONNECTION:
		dump_handshake_info(wsi);
		/* you could return non-zero here and kill the connection */
		break;

	default:
		break;
	}

	return 0;
}


/* list of supported protocols and callbacks */

static struct lws_protocols protocols[] = {
	/* first protocol must always be HTTP handler */

	{
		"http-only",		/* name */
		callback_http,		/* callback */
		sizeof (struct per_session_data__http),	/* per_session_data_size */
		0,			/* max frame size / rx buffer */
	},
	{
		"lws-mirror-protocol",
		callback_lws_mirror,
		sizeof(struct per_session_data__lws_mirror),
		128,
	},
	{
		NULL, NULL, 0		/* terminator */
	}
};

void sighandler(int sig)
{
	force_exit = 1;
}

static const struct lws_extension exts[] = {
	{
		"permessage-deflate",
		lws_extension_callback_pm_deflate,
		"permessage-deflate"
	},
	{
		"deflate-frame",
		lws_extension_callback_pm_deflate,
		"deflate_frame"
	},
	{ NULL, NULL, NULL /* terminator */ }
};

static struct option options[] = {
	{ "help",	no_argument,		NULL, 'h' },
	{ "port",	required_argument,	NULL, 'p' },
	{ "ssl",	no_argument,		NULL, 's' },
	{ "ssl_cert", no_argument,		NULL, 'c' },
	{ "ssl_private_key", no_argument,	NULL, 'k' },
	{ "interface",  required_argument, 	NULL, 'i' },
	{ "ubusxevent",  required_argument,		NULL, 'x' },
	{ NULL, 0, 0, 0 }
};

int main(int argc, char **argv)
{
	struct lws_context_creation_info info;
	char interface_name[128] = "";
	//unsigned int ms, oldms = 0;
	const char *iface = NULL;
	const char *ssl_cert = NULL;
	const char *ssl_private_key = NULL;
	char cert_path[1024];
	char key_path[1024];
	int use_ssl = 0;
	int opts = 0;
	int n = 0;
	//int daemonize = 0;

	/*
	 * take care to zero down the info struct, he contains random garbaage
	 * from the stack otherwise
	 */
	memset(&info, 0, sizeof info);
	info.port = 7681;

	/*
	 * define ubus struct
	 */
	const char *ubus_socket = NULL;
	struct ubus_context *ctx;
	
	while (n >= 0) {
		n = getopt_long(argc, argv, "r:x:i:u:hsc:k:p:", options, NULL);
		if (n < 0)
			continue;
		switch (n) {
		//case 'd':
		//	debug_level = atoi(optarg);
		//	break;
		case 's':
			use_ssl = 1;
			break;
		case 'c':
			ssl_cert = optarg;
			printf("Setting ssl_cert path to \"%s\"\n", ssl_cert);
			break;
		case 'k':
			ssl_private_key = optarg;
			printf("Setting ssl_private_key path to \"%s\"\n", ssl_private_key);
			break;
		case 'p':
			info.port = atoi(optarg);
			break;
		case 'i':
			strncpy(interface_name, optarg, sizeof interface_name);
			interface_name[(sizeof interface_name) - 1] = '\0';
			iface = interface_name;
			break;
		case 'x':
			strncpy(ubus_xevent, optarg, sizeof ubus_xevent);
			ubus_xevent[(sizeof ubus_xevent) - 1] = '\0';
			ubusxevent = ubus_xevent;
			break;
		case 'h':
			fprintf(stderr, "Usage: ws-mirror-server "
						"-x <x> -[--port=<p>] [--ssl]\n"
						"-c <c> ssl_cert path -k <k> ssl_private_key path\n"
						"-x <x> ubus send path from ws e.g. \"linknxws\" or \"ws\"\n");
			exit(1);
		}
	}
	
	signal(SIGINT, sighandler);
	
	/* Create ubus conection */
	ctx = ubus_connect(ubus_socket);
	if (!ctx) {
		lwsl_err("Failed to connect to ubus\n");
		return -1;
	}

	info.iface = iface;
	info.protocols = protocols;

	if (!use_ssl) {
		info.ssl_cert_filepath = NULL;
		info.ssl_private_key_filepath = NULL;
	} else {
		if (strlen(ssl_cert) > sizeof(cert_path) - 32) {
			lwsl_err("resource path too long\n");
			return -1;
		}
		sprintf(cert_path, "%s",ssl_cert);
		if (strlen(ssl_private_key) > sizeof(key_path) - 32) {
			lwsl_err("resource path too long\n");
			return -1;
		}
		sprintf(key_path, "%s",ssl_private_key);

		info.ssl_cert_filepath = cert_path;
		info.ssl_private_key_filepath = key_path;
	}	
	info.gid = -1;
	info.uid = -1;
	info.max_http_header_pool = 1;
	info.options = opts;
	info.extensions = exts;
	context = lws_create_context(&info);
	if (context == NULL) {
		lwsl_err("libwebsocket init failed\n");
		return -1;
	}

	n = 0;
	while (n >= 0 && !force_exit) {
		struct timeval tv;
		gettimeofday(&tv, NULL);
		n = lws_service(context, 50);
		if (n < 0) {
		    lwsl_err("Unable to fork service loop %d\n", n);
		    return -1;
		}
	}

	lws_context_destroy(context);
	lwsl_notice("libwebsockets-test-server exited cleanly\n");
	return 0;
}
