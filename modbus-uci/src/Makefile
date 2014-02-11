
CFLAGS += -Wall -std=gnu99 -pedantic
OBJ = modbus-client.o 
OBJ-S = modbus-client-s.o
LIB = -lmodbus

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

compile: $(OBJ) $(OBJ-S)
	$(CC) -o modbus-client $(LDFLAGS) $(LIB) $(OBJ)
	$(CC) -o modbus-client-s $(LDFLAGS) $(LIB) $(OBJ-S)


clean:
	rm -f *.o *.so modbus-client modbus-client-s
