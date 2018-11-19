#Test
CFLAGS += -Wall -std=gnu99 -pedantic -DDATADIR=\"/www/ws-chat\" -DCONFIGDIR=\"/etc\"
OBJ = ws-mirror-server.o
OBJ_UBUS = ws-mirror-server-ubus.o
LIB = -lwebsockets -lz -lubus -lubox -lblobmsg_json

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

compile: $(OBJ) $(OBJ_UBUS)
	$(CC) -o ws-mirror-server $(LDFLAGS) $(LIB) $(OBJ)
	$(CC) -o ws-mirror-server-ubus $(LDFLAGS) $(LIB) $(OBJ_UBUS)


clean:
	rm -f *.o *.so ws-mirror-server ws-mirror-server-cmd ws-mirror-server-ubus

