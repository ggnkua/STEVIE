#
# Makefile for the Atari ST - gcc Compiler
#

CFLAGS = 
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
	$(CC) $(OBJ) -o stevie.ttp

clean :
	$(RM) $(OBJ) 

