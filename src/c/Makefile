Scheme = ../../out/scheme

SRCS = $(shell ls *.c)

HEADERS = $(shell ls *.h) \
		  ./zlib/zconf.h\
		  ./zlib/zlib.h

CFLAGS = -m64 -msse2 -Wpointer-arith -Wall -Wextra -Werror -O2 -D_REENTRANT -pthread

LIBS = ./zlib/libz.a\
	   -lm -ldl -lpthread -lrt

$(Scheme): $(SRCS) $(HEADERS) ./zlib/libz.a
	cc $(CFLAGS) -DX86_64 -I./zlib -c *.c
	cc $(CFLAGS) -rdynamic -o $(Scheme) *.o $(LIBS)

./zlib/libz.a:
	(cd ./zlib; ${MAKE})

clean:
	rm -f *.o 
	(cd ./zlib; ${MAKE} clean)

