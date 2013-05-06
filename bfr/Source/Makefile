
srcdir = .
#LDFLAGS =
#LIBS =  
#CFLAGS := -O2 -fomit-frame-pointer -fno-builtin -fpic
#LIBS="-L$(STAGING_DIR)/lib -fno-builtin -nostdinc++ -nodefaultlibs -luClibc++ -lc -lm -lgcc_s -lgcc -largp -lpthsem" \
#CPPFLAGS="-I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/uClibc++"

# Change these if necessary

#CC := g++

all:	BFR

BFR:
	$(CC) -o $@ $(CPPFLAGS) $(LDFLAGS) $(LIBS) *.cpp

clean:
	rm -f $(OBJS) BFR *.gdb   
