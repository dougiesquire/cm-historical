CC = gcc
CFLAGS = -g -pedantic -Wall -std=c99 -D_GNU_SOURCE

PROGRAMS =\
dn2date\
date2dn

SRC =\
scaldate.c

HDR =\
scaldate.h\
version.h

all: $(PROGRAMS)

dn2date: dn2date.c $(SRC) $(HDR) Makefile
	$(CC) $(CFLAGS) -DPROGRAM_NAME=\"dn2date\" -o dn2date dn2date.c $(SRC)
date2dn: date2dn.c $(SRC) $(HDR) Makefile
	$(CC) $(CFLAGS) -DPROGRAM_NAME=\"date2dn\" -o date2dn date2dn.c $(SRC)
clean:
	rm -f $(PROGRAMS)
indent:
	indent -T size_t *.[ch]; rm -f *.[ch]~
