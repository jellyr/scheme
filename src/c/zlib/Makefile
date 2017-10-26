SRCS = $(shell ls *.c)
HEADERS = $(shell ls *.h)
CFLAGS= -m64 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN

libz.a: $(SRCS) $(HEADERS)
	cc $(CFLAGS) -c *.c
	ar rc libz.a *.o

clean:
	@rm -f *.o *.a

