CFLAGS = -DTCAP		# or UNIXPC or ATARI

OBJ = main.o edit.o linefunc.o normal.o \
	cmdline.o hexchars.o misccmds.o help.o

default : stevie

stevie : $(OBJ) tcapwind.o
	cc $(OBJ) tcapwind.o -lcurses -ltermcap -o stevie

s4vi : $(OBJ) unixpcwind.o
	cc $(OBJ) unixpcwind.o -ltam -ltermcap -o s4vi

tcapwind.o : window.c
	cc -c $(CFLAGS) window.c
	mv window.o tcapwind.o

unixpcwind.o : window.c
	cc -c $(CFLAGS) window.c
	mv window.o unixpcwind.o

clean :
	rm -f *.o stevie s4vi
