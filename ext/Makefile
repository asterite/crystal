CC		= gcc
LFLAGS	= -fPIC

all: libcrystal.dylib

libcrystal.dylib: crystal.c
	$(CC) $(LFLAGS) -c -o crystal.o $<
	$(CC) -dynamiclib -Wl,-dylib_install_name,libcrystal.dylib -o libcrystal.dylib crystal.o

.PHONY: clean
clean:
	rm -f crystal.o libcrystal.so
