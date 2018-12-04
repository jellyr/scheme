Scheme = ../../out/scheme

SRCS = $(shell ls *.c)

HEADERS = $(shell ls *.h) \
		  ./zlib/zconf.h\
		  ./zlib/zlib.h

CFLAGS = -m64 -msse2 -Wpointer-arith -Wall -Wextra -O2 -D_REENTRANT -pthread   

CFLAGS += -Doff64_t=_off64_t  -Dlseek64=lseek -I/mingw64/include 

# -Wimplicit-fallthrough=2

# pacman -S mingw-w64-x86_64-iconv

LIBS = ./zlib/libz.a\
	   -lm -ldl -lpthread -lrt 

LIBS += -L/mingw64/lib -liconv	   

$(Scheme): $(SRCS) $(HEADERS) ./zlib/libz.a
	cc $(CFLAGS) -DX86_64 -I./zlib -c *.c  
	cc $(CFLAGS) -rdynamic -o $(Scheme) *.o $(LIBS)

./zlib/libz.a:
	(cd ./zlib; ${MAKE})

clean:
	rm -f *.o 
	(cd ./zlib; ${MAKE} clean)

