#
# Makefile for the Atari ST - gcc Compiler
#

CFLAGS = -O2
CC = m68k-atari-mint-gcc
STRIP = m68k-atari-mint-strip

%.c: 
	$(CC) $(CFLAGS) $@

MACH=	tos.o

OBJ=	main.o edit.o linefunc.o normal.o cmdline.o hexchars.o \
	misccmds.o help.o ptrfunc.o search.o alloc.o \
	mark.o screen.o fileio.o param.o $(MACH)

all : stevie.ttp
#	No idea why there has to be some command here, but I don't really care.
#	$(STRIP) stevie.ttp
	
stevie.ttp : $(OBJ)
#	$(CC) $(OBJ) -o stevie.ttp
	m68k-atari-mint-ld.exe -o stevie.ttp /opt/cross-mint/lib/gcc/m68k-atari-mint/4.6.4/../../../../m68k-atari-mint/lib/crt0.o -L/opt/cross-mint/lib/gcc/m68k-atari-mint/4.6.4 -L/opt/cross-mint/lib/gcc/m68k-atari-mint/4.6.4/../../../../m68k-atari-mint/lib main.o edit.o linefunc.o normal.o cmdline.o hexchars.o misccmds.o help.o ptrfunc.o search.o alloc.o mark.o screen.o fileio.o param.o tos.o -lgcc -lc -lgcc --traditional-format

clean :
	$(RM) $(OBJ) 

