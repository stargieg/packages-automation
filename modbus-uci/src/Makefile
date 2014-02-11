
CFLAGS += -Wall -std=gnu99 -pedantic
OBJ = modbus-uci.o 
OBJ-L = ucix.o
LIB = -lmodbus -luci

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

compile: $(OBJ)
	$(CC) -o modbus-uci $(LDFLAGS) $(LIB) $(OBJ)

compile: $(OBJ-L) $(OBJ)
	$(CC) -o modbus-uci $(LDFLAGS) $(LIB) $(OBJ-L) $(OBJ)

clean:
	rm -f *.o *.so modbus-uci
