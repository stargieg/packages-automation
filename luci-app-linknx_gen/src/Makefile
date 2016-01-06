
CFLAGS += -Wall -std=gnu99 -pedantic
OBJ = ubus-linknx.o
LIB = -lz -lubus -lubox -lblobmsg_json -ljson

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

compile: $(OBJ)
	$(CC) -o ubus-linknx $(LDFLAGS) $(LIB) $(OBJ)
#	$(MAKE) -C luasrc


clean:
	rm -f *.o *.so ubus-linknx

