/*
 * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
 *
 * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
 *
 * Savaged to compile under modern gcc and improved (haha) by: George Nakos  ggn@atari.org
 *
 */

#define ATARI		1	/* For the Atari 520 ST */

#define HELP

#define FILELENG 64000
#define NORMAL 0
#define CMDLINE 1
#define INSERT 2
#define APPEND 3
#define FORWARD 4
#define BACKWARD 5
#define WORDSEP " \t\n()[]{},;:'\"-="
#define SLOP 512

#define TRUE 1
#define FALSE 0
#define LINEINC 1

#define CHANGED Changed=1
#define UNCHANGED Changed=0

#define LINEOF(x) x->linep->num

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

typedef int bool_t;
typedef unsigned short UWORD;
typedef short WORD;
typedef unsigned int ULONG;
typedef short LONG;
typedef unsigned char UBYTE;
typedef char BYTE;

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

extern struct charinfo chars[];
extern int State;
extern int Rows;
extern int Columns;
extern char *Realscreen;
extern char *Nextscreen;
extern char *Filename;
extern LPTR *Filemem;;
extern LPTR *Fileend;
extern LPTR *Topchar;
extern LPTR *Botchar;
extern LPTR *Curschar;
extern LPTR *Insstart;
extern int Cursrow, Curscol, Cursvcol;
extern int Prenum;
extern bool_t Debug;
extern bool_t Changed;
extern char Redobuff[], Undobuff[], Insbuff[];
extern LPTR *Uncurschar;
extern char *Insptr;
extern int Ninsert, Undelchars;
extern bool_t set_want_col;
extern int Curswant;
extern bool_t did_ai;
extern void *fontright;
extern void *fontleft;
extern ULONG *phys;

/* Global functions */

extern char *strsave(char *string);
extern char *alloc(unsigned size); 
extern LPTR *nextline(LPTR *curr);
extern LPTR *prevline(LPTR *curr); 
extern LPTR *coladvance(LPTR *p, int col); 
static LPTR *ssearch(int dir, char *str);
extern LPTR *getmark(char c); 
extern LPTR *gotoline(int n); 
extern LINE *newline(int nchars);
extern LPTR *showmatch();
extern LPTR *fwd_word(LPTR *p, int type);
extern LPTR *bck_word(LPTR *p, int type);
extern LPTR *end_word(LPTR *p, int type);
extern void updatetabstoptable();

/* Inlined functions */

/*
 * gchar(lp) - get the character at position "lp"
 */
static inline int
gchar(lp)
register LPTR	*lp;
{
	return (lp->linep->s[lp->index]);
}

/*
 * inc(p)
 *
 * Increment the line pointer 'p' crossing line boundaries as necessary.
 * Return 1 when crossing a line, -1 when at end of file, 0 otherwise.
 */
static inline int
inc(lp)
register LPTR	*lp;
{
	register char *p = &(lp->linep->s[lp->index]);

	if (*p != NUL) {			/* still within line */
		lp->index++;
		return ((p[1] != NUL) ? 0 : 1);
	}

	if (lp->linep->next != Fileend->linep) {  /* there is a next line */
		lp->index = 0;
		lp->linep = lp->linep->next;
		return 1;
	}

	return -1;
}






