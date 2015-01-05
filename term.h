/*
 * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
 *
 * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
 *
 */

/*
 * This file contains the machine dependent escape sequences that
 * the editor needs to perform various operations. Some of the sequences
 * here are optional. Anything not available should be indicated by
 * a null string. In the case of insert/delete line sequences, the
 * editor checks the capability and works around the deficiency, if
 * necessary.
 *
 * Currently, insert/delete line sequences are used for screen scrolling.
 * There are lots of terminals that have 'index' and 'reverse index'
 * capabilities, but no line insert/delete. For this reason, the editor
 * routines s_ins() and s_del() should be modified to use 'index'
 * sequences when the line to be inserted or deleted line zero.
 */

/*
 * The macro names here correspond (more or less) to the actual ANSI names
 */

#ifdef	ATARI
#define	T_EL	"\033l"		/* erase the entire current line */
#define	T_IL	"\033L"		/* insert one line */
#define	T_DL	"\033M"		/* delete one line */
#define	T_SC	"\033j"		/* save the cursor position */
#define	T_ED	"\033E"		/* erase display (may optionally home cursor) */
#define	T_RC	"\033k"		/* restore the cursor position */
#define	T_CI	"\033f"		/* invisible cursor (very optional) */
#define	T_CV	"\033e"		/* visible cursor (very optional) */
#endif

