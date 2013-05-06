CFLAGS += -Wall
LIB = -lpiface-1.0
OBJ_IR = input_reader.o
OBJ_TALS = the_amazing_led_show.o
OBJ_BR = board_reset.o

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<


compile: $(OBJ_IR) $(OBJ_TALS) $(OBJ_BR)
	$(CC) -o input_reader $(LIB) $(OBJ_IR)
	$(CC) -o the_amazing_led_show $(LIB) $(OBJ_TALS)
	$(CC) -o board_reset $(LIB) $(OBJ_BR)

clean:
	rm *.o
