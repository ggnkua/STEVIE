/*
 * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
 */

/* One (and only 1) of the following 3 defines should be uncommented. */
/* Most of the code is machine-independent.  Most of the machine- */
/* dependent stuff is in window.c */

#define ATARI		1	/* For the Atari 520 ST */
/*#define UNIXPC	1	/* The AT&T UNIX PC (console) */
/*#define TCAP		1	/* For termcap-based terminals */

#define FILELENG 64000
#define NORMAL 0
#define CMDLINE 1
#define INSERT 2
#define APPEND 3
#define FORWARD 4
#define BACKWARD 5
#define WORDSEP " \t\n()[]{},;:'\"-="
#define SLOP 512

typedef char bool_t;
#define TRUE 1
#define FALSE 0
#define LINEINC 1

#define CHANGED Changed=1
#define UNCHANGED Changed=0

#ifndef NULL
#define NULL 0
#endif

#include "param.h"
#include "ascii.h"
#include "term.h"
#include "keymap.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>

struct charinfo {
	char ch_size;
	char *ch_str;
};

struct	line {
	struct	line	*prev, *next;	/* previous and next lines */
	char	*s;			/* text for this line */
	int	size;			/* actual size of space at 's' */
	unsigned int	num;		/* line "number" */
}; 

struct	lptr {
	struct	line	*linep;		/* line we're referencing */
	int	index;			/* position within that line */
}; 

typedef	struct line	LINE;
typedef	struct lptr	LPTR; 

#define LINEOF(x) x->linep->num

extern struct charinfo chars[];

extern int State;
extern int Rows;
extern int Columns;
extern char *Realscreen;
extern char *Nextscreen;
extern char *Filename;
extern LPTR *Filemem;;
//extern char *Filemax;
extern LPTR *Fileend;
extern LPTR *Topchar;
extern LPTR *Botchar;
extern LPTR *Curschar;
extern LPTR *Insstart;
extern int Cursrow, Curscol, Cursvcol;
extern int Prenum;
extern bool_t Debug;
extern bool_t Changed;
//extern int Binary;
extern char Redobuff[], Undobuff[], Insbuff[];
extern LPTR *Uncurschar;
extern char *Insptr;
extern int Ninsert, Undelchars;
extern bool_t set_want_col;
extern int Curswant;
extern bool_t did_ai;

//char *strchr(), *strsave(), *alloc(), *strcpy();

extern char *strsave(char *string);
extern char *alloc(unsigned size); 
extern LPTR *nextline(LPTR *curr);
extern LPTR *prevline(LPTR *curr); 
extern LPTR *coladvance(LPTR *p, int col); 
static LPTR *ssearch(int dir, char *str);
//extern LPTR *bcksearch(char *str);
//extern LPTR *fwdsearch(char *str);
extern LPTR *getmark(char c); 
extern LPTR *gotoline(int n); 
extern LINE *newline(int nchars);
extern LPTR *showmatch();
extern LPTR *fwd_word(LPTR *p, int type);
extern LPTR *bck_word(LPTR *p, int type);
extern LPTR *end_word(LPTR *p, int type);

//#define	Cursconf(a,b)	(int)xbios(21,a,b)

