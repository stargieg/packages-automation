/*
 * Copyright © 2008-2010 Stéphane Raimbault <stephane.raimbault@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <modbus/modbus.h>

void about (char *arg0)
{
	printf ("%s -<r|w> -ip <Remote IP> -port <Remote Port> -id <Station ID> -base <Base Address> -off <Offset> -[h?]\n", arg0);
	printf (" -<r|w>		Read or write Register.\n");
	printf (" -ip		IP Address of the Remote Modbus Station\n");
	printf (" -port		TCP Port of the Remote Modbus Station [Default 502]\n");
	printf (" -id		Modebus Station Address [0-255] of the Remote Modbus Station [Default 255]\n");
	printf (" -base		Modebus Base Register Address\n");
	printf ("		(New SAIA DDC 0-16383 and other 0-4096)\n");
	printf (" -off		Offset (read Register from Base Register up too Base+Offset Register)[Max 0-63]\n");
	printf (" -? | -h	Show this help\n");
}


int main(int argc, char *argv[])
{
	modbus_t *ctx;
	uint16_t tab_reg[64];
	uint16_t tab_f[2];
	int nb_points;
	int rc;
	int i;
	int read_flag = 1;
	int write_flag = 0;
	//char *station_ip = "127.0.0.1";
	char *station_ip = NULL;
	int station_port = 502;
	int station_id = 255;
	int base = 0;
	int offset = 1;
	float real;
	if (argc < 4) {
		about(argv[0]);
		exit(0);
	}
	if (argc > 12) {
		about(argv[0]);
		exit(0);
	}
	for (i = 1; i < argc; ++i) {
		if (strcmp(argv[i], "-ip") == 0) {
			station_ip = argv[++i];
		} else if (strcmp(argv[i], "-port") == 0) {
			station_port = atoi(argv[++i]);
		} else if (strcmp(argv[i], "-id") == 0) {
			station_id = atoi(argv[++i]);
		} else if (strcmp(argv[i], "-r") == 0) {
			read_flag = 1;
		} else if (strcmp(argv[i], "-w") == 0) {
			write_flag = 1;
			read_flag = 0;
		} else if (strcmp(argv[i], "-base") == 0) {
			base = atoi(argv[++i]);
		} else if (strcmp(argv[i], "-off") == 0) {
			offset = atoi(argv[++i]);
		} else if (strcmp(argv[i], "-h")==0 || strcmp(argv[i], "-?")==0) {
			about(argv[0]);
			exit(0);
		}
	}
	if (station_ip==NULL) {
		about(argv[0]);
		exit(0);
	}
	if (station_id < 0) {
		about(argv[0]);
		exit(0);
	}
	if (station_id > 255) {
		about(argv[0]);
		exit(0);
	}
	if (base < 0) {
		about(argv[0]);
		exit(0);
	}
	if (base > 16383) {
		about(argv[0]);
		exit(0);
	}
	if (offset < 0) {
		about(argv[0]);
		exit(0);
	}
	if (offset > 63) {
		about(argv[0]);
		exit(0);
	}

	ctx = modbus_new_tcp(station_ip, station_port);
	if (modbus_connect(ctx) == -1) {
			fprintf(stderr, "Connection failed: %s\n", modbus_strerror(errno));
			modbus_free(ctx);
			return -1;
	}
	modbus_set_slave(ctx, station_id);
	
	if (read_flag==1) {
		rc = modbus_read_registers(ctx, base, offset, tab_reg);
		if (rc == -1) {
				fprintf(stderr, "%s\n", modbus_strerror(errno));
		//    return -1;
		}
		
		for (i=0; i < rc; i++) {
				printf("reg[%d]=%d (0x%X)\n", i, tab_reg[i], tab_reg[i]);
		}
		modbus_read_registers(ctx, base, 2, tab_f);
		real = modbus_get_float(tab_f);
		printf("real: %f\n",real);
	}
	
	modbus_close(ctx);
	modbus_free(ctx);
	return 0;
}

