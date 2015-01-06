/*
 * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
 *
 * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
 *
 * Savaged to compile under modern gcc and improved (haha) by: George Nakos  ggn@atari.org
 *
 */

/*
 * System-dependent routines for the Atari ST.
 */

#include "stevie.h"

#include <osbind.h>
void beep();

/*
 * Physical screen address
 */

ULONG *phys;

/*
 * The following buffer is used to work around a bug in TOS. It appears that
 * unread console input can cause a crash, but only if console output is
 * going on. The solution is to always grab any unread input before putting
 * out a character. The following buffer holds any characters read in this
 * fashion. The problem can be easily produced because STEVIE can't yet keep
 * up with the normal auto-repeat rate in insert mode.
 */
#define	IBUFSZ	128

static long inbuf[IBUFSZ];	/* buffer for unread input */
static long *inptr = inbuf;	/* where to put next character */

/*
 * inchar() - get a character from the keyboard
 *
 * Certain special keys are mapped to values above 0x80. These
 * mappings are defined in keymap.h. If the key has a non-zero
 * ascii value, it is simply returned. Otherwise it may be a
 * special key we want to map.
 *
 * The ST has a bug involving keyboard input that seems to occur
 * when typing quickly, especially typing capital letters. Sometimes
 * a value of 0x02540000 is read. This doesn't correspond to anything
 * on the keyboard, according to my documentation. My solution is to
 * loop when any unknown key is seen. Normally, the bell is rung to
 * indicate the error. If the "bug" value is seen, we ignore it completely.
 */
int
inchar()
{
	for (;;) {
		long c, *p;

		/*
		 * Get the next input character, either from the input
		 * buffer or directly from TOS.
		 */
		if (inptr != inbuf) {	/* input in the buffer, use it */
			c = inbuf[0];
			/*
			 * Shift everything else in the buffer down. This
			 * would be cleaner if we used a circular buffer,
			 * but it really isn't worth it.
			 */
			inptr--;
			for (p = inbuf; p < inptr ;p++)
				*p = *(p+1);
		} else
			c = Crawcin();
	
		if ((c & 0xff) != 0)
			return ((int) c&0xff);
	
		switch ((int) (c >> 16) & 0xff) {
	
		case 0x62: return K_HELP;
		case 0x61: return K_UNDO;
		case 0x52: return K_INSERT;
		case 0x47: return K_HOME;
		case 0x48: return K_UARROW;
		case 0x50: return K_DARROW;
		case 0x4b: return K_LARROW;
		case 0x4d: return K_RARROW;
		case 0x29: return K_CGRAVE;	/* control grave accent */
		
		/*
		 * Occurs due to a bug in TOS.
		 */
		case 0x54:
			break;
		/*
		 * Add the function keys here later if we put in support
		 * for macros.
		 */
	
		default:
			beep();
			break;
	
		}
	}
}

/*
 * get_inchars - snarf away any pending console input
 *
 * If the buffer overflows, we discard what's left and ring the bell.
 */
static void
get_inchars()
{
	while (Cconis()) {
		if (inptr >= &inbuf[IBUFSZ]) {	/* no room in buffer? */
			Crawcin();		/* discard the input */
			beep();			/* and sound the alarm */
		} else
			*inptr++ = Crawcin();
	}
}

void
outchar(c)
char	c;
{
	get_inchars();
	Cconout(c);
}

void
outstr(s)
register char	*s;
{
	get_inchars();
	Cconws(s);
}

#define	BGND	0
#define	TEXT	3

/*
 * vbeep() - visual bell
 */
static void
vbeep()
{
	int	text, bgnd;		/* text and background colors */
	long	l;

	text = Setcolor(TEXT, -1);
	bgnd = Setcolor(BGND, -1);

   	Vsync();                    /* short pause */

	Setcolor(TEXT, bgnd);		/* swap colors */
	Setcolor(BGND, text);

	Vsync();                    /* short pause */

	Setcolor(TEXT, text);		/* restore colors */
	Setcolor(BGND, bgnd);
}

void
beep()
{
	if (P(P_VB))
		vbeep();
	else
		outchar('\007');
}

void
windinit()
{
    /*
     * TODO: Yeah, this is ugly and will only work with ST resolutions
     *       (TT at best). It will get replaced with something cleaner
     *       at some point. But that point isn't now!
     *       I think the best course of action is to use the cookie
     *       jar to detect machine and set resolution depending on the
     *       result. No cookie jar = st medium or st high.
     */
    switch (Getrez())
    {
        case 0:             /* When we run it from low resolution, set medium instead */
        {
            Setscreen(-1L,-1L,1);
            Columns=80;
            P(P_LI) = Rows = 25;
        }
        break;
        case 1:
        {
            Columns=80;
            P(P_LI) = Rows = 25;
        }
        break;
        case 2:
        {
            Columns=80;
            P(P_LI) = Rows = 50;
        }
        break;
    }
    
    phys=Physbase();

	Cursconf((short)1,(short)0);
}

void
windexit(r)
int r;
{
    /*
     * TODO: restore resolution here
     */
	exit(r);
}

void
windgoto(r, c)
int	r, c;
{
	outstr("\033Y");
	outchar(r + 040);
	outchar(c + 040);
}

/*
 * System calls or library routines missing in TOS.
 */

void
sleep(n)
int n;
{
	int k;

	k = Tgettime();
	while ( Tgettime() <= k+n )
		;
}

void
delay()
{
	long	n;

	for (n = 0; n < 8000 ;n++)
		;
}

FILE *
fopenb(fname, mode)
char	*fname;
char	*mode;
{
	char	modestr[10];

	sprintf(modestr, "b%s", mode);

	return fopen(fname, modestr);
}

