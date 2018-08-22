
; --------------------------------------------------------------
        
        .globl    ___cxa_pure_virtual
	.globl	__ZSt17__throw_bad_allocv

;	.globl	_memcpy
	.globl	_memset

	.globl	_main
	.globl	_exit
	.globl	__exit
	.globl	___cxa_guard_acquire
	.globl	___cxa_guard_release

	.globl	___libc_csu_init

; --------------------------------------------------------------

BASEPAGE_SIZE		=		$100
USPS			=		$100*4

			.if		^^defined AGT_CONFIG_STACK
SSPS			=		(AGT_CONFIG_STACK)
			.else
SSPS			=		$4000
			.endif

.macro	bbreak
	andi		#~2,ccr
	bvc.s		*
	.endm
	
; --------------------------------------------------------------

*-------------------------------------------------------*
__crt_entrypoint:	.globl		__crt_entrypoint
_start:			.globl		_start
*-------------------------------------------------------*
	move.l		4(sp),a5
*-------------------------------------------------------*
*	command info
*-------------------------------------------------------*
;	lea		128(a5),a4
;	move.l		a4,cli
*-------------------------------------------------------*
*	Mshrink
*-------------------------------------------------------*
	move.l		12(a5),d0			; text segment
	add.l		20(a5),d0			; data segment
	add.l		28(a5),d0			; bss segment
	add.l		#BASEPAGE_SIZE+USPS,d0		; base page
*-------------------------------------------------------*
	move.l		a5,d1				; address to basepage
	add.l		d0,d1				; end of program
	and.w		#-16,d1				; align stack
	move.l		sp,d2
	move.l		d1,sp				; temporary USP stackspace
	move.l		d2,-(sp)	
*-------------------------------------------------------*
	move.l		d0,-(sp)
	move.l		a5,-(sp)
	clr.w		-(sp)
	move.w		#$4a,-(sp)
	trap		#1				; Mshrink
	lea		12(sp),sp	
*-------------------------------------------------------*
*	Program
*-------------------------------------------------------*
	bsr		user_start
*-------------------------------------------------------*
*	Begone
*-------------------------------------------------------*
	clr.w		-(sp)				; Pterm0
	trap		#1

user_start:

	; clear bss segment
			
	move.l		$18(a5),a0
	move.l		$1c(a5),d0				;length of bss segment
	move.l		d0,-(sp)
	pea		0.w
	move.l		a0,-(sp)
	jsr		_memset
	lea		12(sp),sp

;	if (REDIRECT_OUTPUT_TO_SERIAL==1)  
;	; redirect to serial
;	
;	move.w		#2,-(sp)
;	move.w		#1,-(sp)
;	move.w		#$46,-(sp)
;	trap		#1
;	addq.l		#6,sp
;
;	endif

	pea		super_start
	move.w		#38,-(sp)
	trap		#14
	addq.l		#6,sp

	rts
		
; --------------------------------------------------------------
super_start:
; --------------------------------------------------------------
	lea		new_ssp,a0
	move.l		a0,d0
	subq.l		#4,d0	
	and.w		#-16,d0
	move.l		d0,a0
	move.l		sp,-(a0)
	move.l		usp,a1
	move.l		a1,-(a0)
	move.l		a0,sp
	
;	__libc_csu_init(int argc, char **argv, char **envp);

	move.l		#0,-(sp)
	pea		dummy_argv
	pea		dummy_envp
	jsr		___libc_csu_init
	lea		12(sp),sp

	move.l		sp,entrypoint_ssp	

	jsr		_main
	
;	link to high level exit(0) function on return
	pea		0.w
	jmp		_exit
	
__exit:

;	level SSP, because exit() is a subroutine

	move.l		entrypoint_ssp,sp

	move.l		(sp)+,a0
	move.l		a0,usp
	move.l		(sp)+,sp
	rts
	
; --------------------------------------------------------------
;_memcpy:	
; --------------------------------------------------------------
;			.abs
;; --------------------------------------------------------------
;.sp_return:		ds.l	1
;.sp_pdst:		ds.l	1
;.sp_psrc:		ds.l	1
;.sp_size:		ds.l	1
;; --------------------------------------------------------------
;			.text
;; --------------------------------------------------------------
;;	move.l		.sp_pdst(sp),a0
;;	move.l		.sp_psrc(sp),a1
;	move.l		.sp_pdst(sp),d0
;	move.l		d0,a0
;	move.l		.sp_psrc(sp),d1
;	move.l		d1,a1
;	or.w		d0,d1
;	btst		#0,d1
;	bne.s		.memcpy_misaligned
;	
;	move.l		.sp_size(sp),d1
;	
;	lsr.l		#4,d1					; num 16-byte blocks total
;	move.l		d1,d0
;	swap		d0					; num 1mb blocks (64k * 16bytes)
;	subq.w		#1,d1					; num 16-byte blocks remaining
;	bcs.s		.ev1mb
;
;.lp1mb:
;.lp16b:	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;	dbra		d1,.lp16b
;
;.ev1mb:	subq.w		#1,d0
;	bpl.s		.lp1mb
;
;	moveq		#16-1,d1
;	and.w		.sp_size+2(sp),d1
;	lsl.b		#4+1,d1
;	bcc.s		.n8
;	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;.n8:	add.b		d1,d1
;	bcc.s		.n4
;	move.l		(a1)+,(a0)+
;.n4:	add.b		d1,d1
;	bcc.s		.n2
;	move.w		(a1)+,(a0)+
;.n2:	add.b		d1,d1
;	bcc.s		.n1
;	move.b		(a1)+,(a0)+
;.n1:
;	move.l		.sp_pdst(sp),d0
;	rts
;
;.memcpy_misaligned:
;	move.w		a1,d1
;	eor.w		d0,d1
;	btst		#0,d1
;	bne		.memcpy_misaligned_sgl
;		
;.memcpy_misaligned_pair:		
;	move.l		.sp_size(sp),d1
;	
;	move.b		(a1)+,(a0)+
;	subq.l		#1,d1
;	beq		.done
;	move.w		d1,.sp_size+2(sp)
;	
;	lsr.l		#4,d1					; num 16-byte blocks total
;	move.l		d1,d0
;	swap		d0					; num 1mb blocks (64k * 16bytes)
;	subq.w		#1,d1					; num 16-byte blocks remaining
;	bcs.s		.ev1mc
;
;.lp1mc:
;.lp16c:	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;	dbra		d1,.lp16c
;
;.ev1mc:	subq.w		#1,d0
;	bpl.s		.lp1mc
;
;	moveq		#16-1,d1
;	and.w		.sp_size+2(sp),d1
;	lsl.b		#4+1,d1
;	bcc.s		.n8c
;	move.l		(a1)+,(a0)+
;	move.l		(a1)+,(a0)+
;.n8c:	add.b		d1,d1
;	bcc.s		.n4c
;	move.l		(a1)+,(a0)+
;.n4c:	add.b		d1,d1
;	bcc.s		.n2c
;	move.w		(a1)+,(a0)+
;.n2c:	add.b		d1,d1
;	bcc.s		.n1c
;	move.b		(a1)+,(a0)+
;.n1c:
;.done:	move.l		.sp_pdst(sp),d0
;	rts
;
;.memcpy_misaligned_sgl:		
;	move.l		.sp_size(sp),d1
;	
;	lsr.l		#4,d1					; num 16-byte blocks total
;	move.l		d1,d0
;	swap		d0					; num 1mb blocks (64k * 16bytes)
;	subq.w		#1,d1					; num 16-byte blocks remaining
;	bcs.s		.ev1md
;
;.lp1md:
;.lp16d:	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	dbra		d1,.lp16d
;
;.ev1md:	subq.w		#1,d0
;	bpl.s		.lp1md
;
;;	copy remaining bytes, if any
;
;	moveq		#16-1,d1
;	and.w		.sp_size+2(sp),d1
;	add.w		d1,d1
;	neg.w		d1
;	jmp		.jtab(pc,d1.w)
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;	move.b		(a1)+,(a0)+
;.jtab:	
;	move.l		.sp_pdst(sp),d0
;	rts
	
; --------------------------------------------------------------
_memset:
; --------------------------------------------------------------	

;	move.l		d2,-(sp)
	move.l		d2,a1
	
	; value
	move.b		0+8+3(sp),d0
	move.b		d0,d1
	lsl.w		#8,d1
	move.b		d0,d1
	move.w		d1,d2
	swap		d2
	move.w		d1,d2

	; size
	move.l		0+12(sp),d1

	; dest
	move.l		0+4(sp),d0
	move.l		d0,a0
	and.w		#1,d0
	beq.s		.aligned
	move.b		d2,(a0)+
	subq.l		#1,d1
	beq		.done
	move.w		d1,0+12+2(sp)
.aligned:	
	
	lsr.l		#4,d1
	move.l		d1,d0
	swap		d0
	subq.w		#1,d1
	bcs.s		.ev1mb

.lp1mb:
.lp16b:	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	dbra		d1,.lp16b

.ev1mb:	subq.w		#1,d0
	bpl.s		.lp1mb

	moveq		#16-1,d1
	and.w		0+12+2(sp),d1
	lsl.b		#4+1,d1
	bcc.s		.n8
	move.l		d2,(a0)+
	move.l		d2,(a0)+
.n8:	add.b		d1,d1
	bcc.s		.n4
	move.l		d2,(a0)+
.n4:	add.b		d1,d1
	bcc.s		.n2
	move.w		d2,(a0)+
.n2:	add.b		d1,d1
	bcc.s		.n1
	move.b		d2,(a0)+
.n1:

.done:	move.l		0+4(sp),d0

	move.l		a1,d2
;	move.l		(sp)+,d2
	rts
		
; --------------------------------------------------------------
	.text
; --------------------------------------------------------------

_rand:		.globl	_rand
___cxa_guard_acquire:
___cxa_guard_release:
	rts
		
; --------------------------------------------------------------
__ZSt17__throw_bad_allocv:
___cxa_pure_virtual:	
; --------------------------------------------------------------
	jmp	_exit

; --------------------------------------------------------------
	.data
; --------------------------------------------------------------
	
dummy_argv:
dummy_envp:
	dc.b		0
	even

; --------------------------------------------------------------
	.bss
; --------------------------------------------------------------
	
	ds.b	SSPS
new_ssp:
	ds.l	1
entrypoint_ssp:
	ds.l	1

; --------------------------------------------------------------

