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
#include <float.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <modbus/modbus.h>
#include "ucix.h"

#define MODBIT 0
#define MODINT 1
#define MODFLOAT 2
#define MODDOUBLEFLOAT 3
#define MODDWORD 4
#define MODUINT 5
#define MODUDOUBLEFLOAT 6
#define MODUFLOAT 7

#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))
#define SET_BIT(var,pos) ((var) |= 1<<(pos))
#define RESET_BIT(var,pos) ((pos) &= ~(1<<(var)))

#define BIT(x) (1 << (x))
#define SETBITS(x,y) ((x) |= (y))
#define CLEARBITS(x,y) ((x) &= (~(y)))
#define SETBIT(x,y) SETBITS((x), (BIT((y))))
#define CLEARBIT(x,y) CLEARBITS((x), (BIT((y))))
#define BITSET(x,y) ((x) & (BIT(y)))
#define BITCLEAR(x,y) !BITSET((x), (y))
#define BITSSET(x,y) (((x) & (y)) == (y))
#define BITSCLEAR(x,y) (((x) & (y)) == 0)
#define BITVAL(x,y) (((x)>>(y)) & 1)
#define BITFLIP(x,y) ((x)^=(y))

/* Proto */
enum {
    TCP,
    TCP_PI,
    RTU
};

/* value/name tuples */
struct station_tuple {
	char idx[18];
	char tagname[16];
	int port;
	char ipaddr[16];
	int unit_id;
	struct station_tuple *next;
};

/* structure to hold tuple-list and uci context during iteration */
struct station_itr_ctx {
	struct station_tuple *list;
	struct uci_context *ctx;
	char *section;
};

typedef struct station_tuple station_tuple_t;

/* value/name tuples */
struct pv_tuple {
	char idx[18];
	char name[16];
	char section[16];
	int section_idx;
	char type[16];
	int func;
	int unit_id;
	int addr;
	int si_unit;
	char dead_limit[18];
	char cov_increment[18];
	char value[18];
	float value_float;
	int value_int;
	int value_time;
	float res;
	int modtype;
	int bit;
	bool Out_Of_Service;
	int err_counter;
	struct station_tuple *next;
};

/* structure to hold tuple-list and uci context during iteration */
struct pv_itr_ctx {
	struct pv_tuple *list;
	struct uci_context *ctx;
	const char *tagname;
	char *section;
	int section_idx;
	char *type;
};

typedef struct pv_tuple pv_tuple_t;

void load_pv(const char *sec_idx, struct pv_itr_ctx *itr_pv)
{
	pv_tuple_t *t;
	bool disable;
	const char *tagname;
	const char *name;
	int unit_id;
	int addr;
	int func;
	int func_def;
	int si_unit;
	int Out_Of_Service;
	const char *dead_limit;
	const char *cov_increment;
	const char *value;
	const char *res;
	int bitv=0;
	int val_i;
	int usign=0;
	float val_f;
	time_t value_time;

	if (!strcmp(sec_idx, "default")) {
		printf("ignore default %s,%s\n",itr_pv->section,sec_idx);
		return;
	}

	disable = ucix_get_option(itr_pv->ctx, itr_pv->section, sec_idx, "disable");
	if (disable) {
		printf("ignore disable %s,%s\n",itr_pv->section,sec_idx);
		return;
	}

	tagname = ucix_get_option(itr_pv->ctx, itr_pv->section, sec_idx, "tagname");
	if ( tagname != NULL ) {
		if (strcmp(tagname, itr_pv->tagname)) {
			printf("ignore wrong tagname %s,%s\n",tagname, itr_pv->tagname);
			return;
		}
	} else {
		printf("no tagname %s,%s\n",itr_pv->section,sec_idx);
		return;
	}

	addr = ucix_get_option_int(itr_pv->ctx, itr_pv->section, sec_idx, "addr",-1);
	if ( addr < 0 ) {
		printf("no addr %s,%s\n",itr_pv->section,sec_idx);
		return;
	}
	if (strcmp("ai", itr_pv->type) == 0)
		func_def=4;
	else
		func_def=3;

	func = ucix_get_option_int(itr_pv->ctx, itr_pv->section, sec_idx, "func",func_def);

	unit_id = ucix_get_option_int(itr_pv->ctx, itr_pv->section, sec_idx, "unit_id",0);

	if( (t = (pv_tuple_t *)malloc(sizeof(pv_tuple_t))) != NULL ) {
		strncpy(t->idx, sec_idx, sizeof(t->idx));
		strncpy(t->section, itr_pv->section, sizeof(t->section));
		t->section_idx = itr_pv->section_idx;
		strncpy(t->type, itr_pv->type, sizeof(t->type));
		name = ucix_get_option(itr_pv->ctx, itr_pv->section, sec_idx,
			"name");
		if ( name != NULL ) {
			strncpy(t->name, name, sizeof(t->name));
		}

		res = ucix_get_option(itr_pv->ctx, itr_pv->section, sec_idx,
			"resolution");
		usign = ucix_get_option_int(itr_pv->ctx, itr_pv->section, sec_idx,
			"unsigned",0);

		if (res == NULL) {
			if (usign==0) {
				t->modtype = MODINT;
			} else {
				t->modtype = MODUINT;
			}
			t->bit = 0;
			t->res = 1;
		} else if (!strcmp(res, "doublefloat")) {
			if (usign==0) {
				t->modtype = MODDOUBLEFLOAT;
			} else {
				t->modtype = MODUDOUBLEFLOAT;
			}
			t->bit = 0;
			t->res = 1;
		} else if (!strcmp(res, "float")) {
			if (usign==0) {
				t->modtype = MODFLOAT;
			} else {
				t->modtype = MODUFLOAT;
			}
			t->bit = 0;
			t->res = 1;
		} else if (!strcmp(res, "bit")) {
			t->modtype = MODBIT;
			t->bit = 0;
			t->res = 1;
		} else if (!strcmp(res, "dword")) {
			t->modtype = MODDWORD;
			bitv = ucix_get_option_int(itr_pv->ctx, itr_pv->section, 
				sec_idx, "bit",0);
			t->bit = bitv;
			t->res = 1;
		} else if (res != NULL ) {
			if (usign==0) {
				t->modtype = MODINT;
			} else {
				t->modtype = MODUINT;
			}
			if (atoi(res) == 1 ) {
				t->res = 1;
			} else {
				t->res = strtof(res,NULL);
			}
			t->bit = 0;
		}


		t->unit_id = unit_id;
		t->addr = addr;
		t->func = func;
		si_unit = ucix_get_option_int(itr_pv->ctx, itr_pv->section, sec_idx,
			"si_unit",0);
		t->si_unit = si_unit;

		Out_Of_Service = ucix_get_option_int(itr_pv->ctx, itr_pv->section, sec_idx,
			"Out_Of_Service",1);
		t->Out_Of_Service = Out_Of_Service;

		dead_limit = ucix_get_option(itr_pv->ctx, itr_pv->section, sec_idx,
			"dead_limit");
		if ( dead_limit != NULL ) {
			strncpy(t->dead_limit, dead_limit, sizeof(t->dead_limit));
		}

		cov_increment = ucix_get_option(itr_pv->ctx, itr_pv->section, sec_idx,
			"cov_increment");
		if ( cov_increment != NULL ) {
			strncpy(t->cov_increment, cov_increment, sizeof(t->cov_increment));
		}

		value = ucix_get_option(itr_pv->ctx, itr_pv->section, sec_idx,
			"value");
		if ( value != NULL ) {
			strncpy(t->value, value, sizeof(t->value));
			val_f = strtof(value,NULL);
			val_i = atoi(value);
			if (t->modtype == MODDOUBLEFLOAT) {
				t->value_float=val_f;
			} else if (t->modtype == MODBIT) {
				t->value_int = val_i;
			} else if (t->modtype == MODDWORD) {
				if ( val_i > 0 ) {
					SETBIT(val_i,bitv);
				} else {
					CLEARBIT(val_i,bitv);
				}
				t->value_int = val_i;
			} else {
				val_f = val_f/t->res;
				val_f += 0.5;
				t->value_int = (int)val_f;
			}
		}


		value_time = ucix_get_option_int(itr_pv->ctx, itr_pv->section, sec_idx,
			"value_time",0);
		t->value_time = value_time;


		t->next = itr_pv->list;
		itr_pv->list = t;
	}
}

void load_bacnet(char *idx) {
	char tagname[128];
	int port;
	char port6[128];
	const char *backend;
	int use_backend=TCP;
	char ip4addr[128];
	char ip6addr[128];
	char ttydev[128];
	int baud=115200;
	char parity_bit;
	int data_bit=8;
	int stop_bit=1;
	int unit_id_tag = 1;
	struct uci_context *uctx_m;
	char pv_section[16][32] = {
		"bacnet_bi","bacnet_ao","bacnet_av","bacnet_ai","bacnet_mv"
	};
	char pv_type[16][32] = {
		"bi","ao","av","ai","mv"
	};
	int section_n=5;
	char *section;
	struct uci_context *uct_b;
	char *type;
	const char *value;
	modbus_t *mctx;
	uint16_t *tab_reg;
	int offset = 2;
	int max_offset = 2;
	int unit_id = 0;
	int addr = 0;
	int func = 7;
	int rc = -1;
	int rewrite = 1;
	float val_f, pval_f,val_fab;
	int j,k,l,m,n,write,bitv,val_i;
	bool uci_change[16],uci_change_ext[16];
	bool newval;
	time_t chk_mtime[16];
	time_t mtime_bacnet[16];
	int pimage[65535];
	bool pimage_read[65535];
	int input_reg[65535];
	bool input_reg_read[65535];


	section = "modbus";

	uctx_m = ucix_init(section);
	if(uctx_m) {
		if (ucix_get_option_int(uctx_m, section, idx, "enable",0) == 1) {
			snprintf(tagname, sizeof(tagname),
				"%s", ucix_get_option(uctx_m, section, idx,
				"tagname"));
			unit_id_tag = ucix_get_option_int(uctx_m, section, idx,
				"unit_id",1);
			backend = ucix_get_option(uctx_m, section, idx,
				"backend");
			if (strcmp(backend, "tcp") == 0) {
				use_backend = TCP;
				snprintf(ip4addr, sizeof(ip4addr),
				"%s", ucix_get_option(uctx_m, section, idx,
					"ip4addr"));
				if (strcmp(ip4addr,"") == 0) {
					return;
				}
				port = ucix_get_option_int(uctx_m, section, idx,
					"port",502);
			} else if (strcmp(backend, "tcp_pi") == 0) {
				use_backend = TCP_PI;
				snprintf(ip6addr, sizeof(ip6addr),
				"%s", ucix_get_option(uctx_m, section, idx,
					"ip6addr"));
				if (strcmp(ip6addr,"") == 0) {
					return;
				}
				snprintf(port6, sizeof(port6),
				"%s", ucix_get_option(uctx_m, section, idx,
					"port"));
				if (strcmp(port6,"") == 0) {
					return;
				}
			} else if (strcmp(backend, "rtu") == 0) {
				use_backend = RTU;
				snprintf(ttydev, sizeof(ttydev),
				"%s", ucix_get_option(uctx_m, section, idx,
					"ttydev"));
				if (strcmp(ttydev,"") == 0) {
					return;
				}
				baud = ucix_get_option_int(uctx_m, section, idx,
					"baud",115200);
				const char *uci_parity_bit;
				uci_parity_bit = ucix_get_option(uctx_m, section, idx,
					"parity_bit");
				if (uci_parity_bit==NULL) {
					parity_bit = 'N';
				} else if (strcmp(uci_parity_bit, "N") == 0) {
					parity_bit = 'N';
				} else if (strcmp(uci_parity_bit, "O") == 0) {
					parity_bit = 'O';
				} else if (strcmp(uci_parity_bit, "E") == 0) {
					parity_bit = 'E';
				} else {
					return;
				}
				data_bit = ucix_get_option_int(uctx_m, section, idx,
					"data_bit",8);
				stop_bit = ucix_get_option_int(uctx_m, section, idx,
					"stop_bit",1);
			} else {
				return;
			}
		} else {
			return;
		}
		ucix_cleanup(uctx_m);
	} else {
		return;
	}

	struct pv_itr_ctx itr_b;
	itr_b.list = NULL;
	pv_tuple_t *cur_pv;
	for( n=0; n<section_n; n++ ) {
		uct_b = ucix_init(pv_section[n]);
		if(uct_b) {
			type = pv_type[n];
			fprintf(stderr,"%s load section %s type %s\n",tagname,pv_section[n],type);
			itr_b.section = pv_section[n];
			itr_b.section_idx = n;
			itr_b.ctx = uct_b;
			itr_b.tagname = tagname;
			itr_b.type = type;
			ucix_for_each_section_type(uct_b, pv_section[n], 
				pv_type[n], (void *)load_pv, &itr_b);
			ucix_cleanup(uct_b);
		}
	}

	// loop forever
	for (;;) {
		usleep(10000);
		for( m=0; m<65535; m++ ) {
			if (pimage_read[m]) {
				pimage_read[m]=NULL;
			}
			if (input_reg_read[m]) {
				input_reg_read[m]=NULL;
			}
		}
		for( l=0; l<section_n; l++ ) {
			uci_change[l] = NULL;
			uci_change_ext[l] = NULL;
			chk_mtime[l] = 0;
			chk_mtime[l] = check_uci_update(pv_section[l], mtime_bacnet[l]);
			if(chk_mtime[l] != 0) {
				mtime_bacnet[l] = chk_mtime[l];
			}
		}
		if (mctx == NULL) {
			if (use_backend == TCP) {
				fprintf(stderr, "New Connection tcp %s:%i\n",ip4addr, port);
				mctx = modbus_new_tcp(ip4addr, port);
			} else if (use_backend == TCP_PI) {
				fprintf(stderr, "New Connection tcp_pi %s:%s\n",ip6addr, port6);
				mctx = modbus_new_tcp_pi(ip6addr, port6);
			} else if (use_backend == RTU) {
				fprintf(stderr, "New Connection serial %s\n",ttydev);
				mctx = modbus_new_rtu(ttydev, baud, parity_bit, data_bit, stop_bit);
			}
			if (mctx == NULL) {
				fprintf(stderr, "Unable to allocate libmodbus context\n");
			} else {
				modbus_set_slave(mctx, unit_id_tag);
				if (modbus_connect(mctx) == -1) {
					fprintf(stderr, "Connection failed: %s\n",
						modbus_strerror(errno));
					modbus_close(mctx);
					modbus_free(mctx);
					sleep(3);
					mctx=NULL;
				}
			}
		}
		j = 0;
		for( cur_pv = itr_b.list; cur_pv; cur_pv = cur_pv->next ) {
			usleep(100);
			if (cur_pv->unit_id > 0) {
				unit_id = cur_pv->unit_id;
				if (mctx) {
					modbus_set_slave(mctx, unit_id);
				}
			} else {
				unit_id = unit_id_tag;
			}
			/*
			printf("idx %s ", idx);
			printf("tagname %s ", tagname);
			printf("unit_id %i ", unit_id);
			printf("idx %s ", cur_pv->idx);
			printf("addr %i ", cur_pv->addr);
			printf("si_unit %i ", cur_pv->si_unit);
			printf("value %s \n", cur_pv->value);
			*/
			addr = cur_pv->addr;
			tab_reg = (uint16_t *) malloc(max_offset * sizeof(uint16_t));
			memset(tab_reg, 0, max_offset * sizeof(uint16_t));
			rc= -1;
			j = cur_pv->section_idx;
			uci_change[j] = NULL;
			uct_b = ucix_init(pv_section[j]);
			if (mctx) {
				write = ucix_get_option_int(uct_b, pv_section[j], cur_pv->idx,"write",0);
				if (write != 0) {
					if(chk_mtime[j] != 0) {
						value = ucix_get_option(uct_b, pv_section[j], cur_pv->idx,"value");
						fprintf(stderr,"bac change %i %s=%s\n",(int)chk_mtime[j],cur_pv->name,value);
						if ( value != NULL ) {
							offset = 1;
							strncpy(cur_pv->value, value, sizeof(cur_pv->value));
							val_f = strtof(cur_pv->value,NULL);
							if (cur_pv->modtype == MODDOUBLEFLOAT) {
								cur_pv->value_float = val_f;
								offset = 2;
								modbus_set_float(val_f, tab_reg);
							} else if (cur_pv->modtype == MODBIT) {
								val_i = atoi(cur_pv->value);
								cur_pv->value_int = val_i;
								tab_reg[0] = val_i;
							} else if (cur_pv->modtype == MODDWORD) {
								val_i = atoi(cur_pv->value);
								bitv = cur_pv->bit;
								if (pimage_read[addr] && (cur_pv->func == 3)) {
									cur_pv->value_int = pimage[addr];
								}
								if (input_reg_read[addr] && (cur_pv->func == 4)) {
									cur_pv->value_int = input_reg[addr];
								}
								if (val_i > 0) {
									SETBIT(cur_pv->value_int,bitv);
								} else {
									CLEARBIT(cur_pv->value_int,bitv);
								}
								tab_reg[0] = cur_pv->value_int;
							} else if (cur_pv->modtype == MODUINT) {
								val_f = val_f/cur_pv->res;
								val_f += 0.5;
								tab_reg[0] = (int)val_f;
								cur_pv->value_int = (int)val_f;
							} else {
								val_f = val_f/cur_pv->res;
								val_f += 0.5;
								val_i = (int)val_f;
								if (val_i < 0)
									val_i = (val_i*1)+65536;
								tab_reg[0] = val_i;
								cur_pv->value_int = val_i;
							}
							k=0;
							for (n=addr;n<addr+offset;n++) {
								pimage[n]=tab_reg[k];
								pimage_read[n]=true;
								k++;
							}
							if (cur_pv->func == 3) {
								rc = modbus_write_registers(mctx, addr, offset, tab_reg);
							}
						}
					}
					uci_change_ext[j] = true;
					uci_change[j] = true;
					ucix_del(uct_b, pv_section[j], cur_pv->idx,"write");
					ucix_save_state(uct_b);
				}
				if (!uci_change_ext[j]) {
					offset = 1;
					if (cur_pv->modtype == MODDOUBLEFLOAT) {
						offset = 2;
					}
					if (cur_pv->func == 3) {
						if (pimage_read[addr]) {
							k=0;
							for (n=addr;n<addr+offset;n++) {
								tab_reg[k]=pimage[n];
								k++;
							}
							rc=k;
						} else {
							rc = modbus_read_registers(mctx, addr, offset, tab_reg);
							k=0;
							for (n=addr;n<addr+offset;n++) {
								pimage[n]=tab_reg[k];
								pimage_read[n]=true;
								k++;
							}
						}
					} else if (cur_pv->func == 4) {
						if (input_reg_read[addr]) {
							k=0;
							for (n=addr;n<addr+offset;n++) {
								tab_reg[k]=input_reg[n];
								k++;
							}
							rc=k;
						} else {
							rc = modbus_read_input_registers(mctx, addr, offset, tab_reg);
							k=0;
							for (n=addr;n<addr+offset;n++) {
								input_reg[n]=tab_reg[k];
								input_reg_read[n]=true;
								k++;
							}
						}
					}
					if (rc != -1 && cur_pv->Out_Of_Service == 1) {
						cur_pv->err_counter = 0;
						cur_pv->value_time = time(NULL);
						cur_pv->Out_Of_Service = 0;
						ucix_add_option_int(uct_b, pv_section[j], cur_pv->idx,
							"Out_Of_Service",0);
						uci_change[j] = true;
					}
				}
			}
			uci_change_ext[j] = NULL;
			if (rc == -1) {
				if (mctx) {
					fprintf(stderr,"Return err -1 modbus close conection\n");
					modbus_close(mctx);
					modbus_free(mctx);
					mctx=NULL;
				}
				if (cur_pv->err_counter <= 2) cur_pv->err_counter++;
				if (cur_pv->Out_Of_Service == 0 && cur_pv->err_counter > 2) {
					fprintf(stderr,"Out_Of_Service %s %s\n",pv_section[j],cur_pv->idx);
					cur_pv->Out_Of_Service = 1;
					uct_b = ucix_init(pv_section[j]);
					ucix_add_option_int(uct_b, pv_section[j], cur_pv->idx,
						"Out_Of_Service",1);
					uci_change[j] = true;
				}
			} else {
				cur_pv->err_counter=0;
				newval=false;
				if (cur_pv->modtype == MODDOUBLEFLOAT) {
					val_f = cur_pv->value_float;
					pval_f = modbus_get_float(&tab_reg[0]);
					val_fab = val_f - pval_f;
					if ( val_fab > 0.001 ) {
						cur_pv->value_float = pval_f;
						sprintf(cur_pv->value,"%f",pval_f);
						newval=true;
					}
					if ( rewrite == 0) {
						sprintf(cur_pv->value,"%f",pval_f);
						newval=true;
					}
				} else if (cur_pv->modtype == MODBIT) {
					val_i = tab_reg[0];
					if ( cur_pv->value_int != val_i ) {
						cur_pv->value_int = val_i;
						if (val_i > 0 ) {
							sprintf(cur_pv->value,"%i",1);
						} else {
							sprintf(cur_pv->value,"%i",0);
						}
						newval=true;
					}
					if ( rewrite == 0) {
						cur_pv->value_int = val_i;
						if ( val_i > 0 ) {
							sprintf(cur_pv->value,"%i",1);
						} else {
							sprintf(cur_pv->value,"%i",0);
						}
						newval=true;
					}
				} else if ( cur_pv->modtype == MODDWORD ) {
					val_i = tab_reg[0];
					if ( cur_pv->value_int != val_i ) {
						cur_pv->value_int = val_i;
						bitv=cur_pv->bit;
						if (BITVAL(val_i, bitv)) {
							sprintf(cur_pv->value,"%i",1);
						} else {
							sprintf(cur_pv->value,"%i",0);
						}
						newval=true;
					}
					if ( rewrite == 0) {
						cur_pv->value_int = val_i;
						bitv=cur_pv->bit;
						if (BITVAL(val_i, bitv)) {
							sprintf(cur_pv->value,"%i",1);
						} else {
							sprintf(cur_pv->value,"%i",0);
						}
						newval=true;
					}
				} else if ( cur_pv->modtype == MODUINT ) {
					val_i = tab_reg[0];
					if ( cur_pv->value_int != val_i ) {
						cur_pv->value_int = val_i;
						pval_f = (float)val_i;
						sprintf(cur_pv->value,"%f",pval_f*cur_pv->res);
						newval=true;
					}
					if ( rewrite == 0) {
						cur_pv->value_int = tab_reg[0];
						pval_f = (float)tab_reg[0];
						sprintf(cur_pv->value,"%f",pval_f*cur_pv->res);
						newval=true;
					}
				} else {
					val_i = tab_reg[0];
					if (val_i > 32767)
						val_i = val_i - 65536;
					if ( cur_pv->value_int != val_i ) {
						cur_pv->value_int = val_i;
						pval_f = (float)val_i;
						sprintf(cur_pv->value,"%f",pval_f*cur_pv->res);
						newval=true;
					}
					if ( rewrite == 0) {
						cur_pv->value_int = tab_reg[0];
						pval_f = (float)tab_reg[0];
						sprintf(cur_pv->value,"%f",pval_f*cur_pv->res);
						newval=true;
					}
				}
				if (newval) {
					ucix_add_option(uct_b, pv_section[j], cur_pv->idx,
						"value",cur_pv->value);
					ucix_add_option_int(uct_b, pv_section[j], cur_pv->idx,
						"value_time",cur_pv->value_time);
					if (cur_pv->Out_Of_Service == 1) {
						ucix_add_option_int(uct_b, pv_section[j], cur_pv->idx,
							"Out_Of_Service",0);
					}
					uci_change[j] = true;
				}
				free(tab_reg);
			}
			if (uci_change[j]) {
				ucix_commit(uct_b, pv_section[j]);
				mtime_bacnet[j] = time(NULL);
				uci_change[j] = NULL;
			}
			if(uct_b)
				ucix_cleanup(uct_b);
		}
		if (mctx) {
			rewrite++;
			if (rewrite>1000) {
				rewrite=0;
			}
		}
	}
}

void load_station(const char *sec_idx, struct station_itr_ctx *itr)
{
	station_tuple_t *t = malloc(sizeof (station_tuple_t));
	bool enable;
	enable = ucix_get_option(itr->ctx, itr->section, sec_idx, "enable");
	if (!enable)
		return;
	if( (t = (station_tuple_t *)malloc(sizeof(station_tuple_t))) != NULL ) {
		strncpy(t->idx, sec_idx, sizeof(t->idx));
		t->next = itr->list;
		itr->list = t;
	}
}

int main(int argc, char *argv[])
{
	struct uci_context *uctx;
	char *section;
	char *type;
	char idx[18];
	struct station_itr_ctx itr_m;


	section = "modbus";
	uctx = ucix_init(section);
	if(uctx) {
		type = "station";
		station_tuple_t *cur = malloc(sizeof (station_tuple_t));
		itr_m.list = NULL;
		itr_m.section = section;
		itr_m.ctx = uctx;
		ucix_for_each_section_type(uctx, section, type,
			(void *)load_station, &itr_m);
		ucix_cleanup(uctx);

		for( cur = itr_m.list; cur; cur = cur->next ) {
			strncpy(idx, cur->idx, sizeof(idx));
			printf ("fork(%s)\n",idx);
			pid_t pid=fork();
			//int pid = 0;
			/* only execute this if child */
			if (pid==0) {
				load_bacnet(idx);
				exit(0);
			} else {
				/* only the parent waits */
				//wait(&status);
				/* only the parent sleep */
				sleep(1);
			}
		}
	}
	return 0;
}
