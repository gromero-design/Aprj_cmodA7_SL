   // SIM_TEST.ASM :  Test program
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification = PASSED
   //
   // POINTER REGISTERS
   // P0 pointer 0 -> program counter 'PC' not accesible
   // P1 pointer 1 -> user pointer    'P1'
   // P2 pointer 2 -> user pointer    'P2'
   //------------------------------------
   // PE pointer 14-> user pointer    'PE'
   // PF pointer 15-> stack pointer   'PF' , can be used
   //
   // REGISTERS
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   //------------------------------------
   // Rn register n -> user register  'Rn'
   //------------------------------------
   // RF register 15-> status/control 'RF'
   //

   // Key defines
define   NULL 'h00 // ^@
define   CTLX 'h03 // ^C
define   LF   'h0a // ^J
define   CR   'h0d // ^M
define   FF   'h0c // ^L
define   CTLP 'h10 // ^P
define   CTLR 'h12 // ^R
define   CTLS 'h13 // ^S
define   ESC  'h1b // ^[


define BOOT_LOADER	'h03ff
define RESET_ENTRY	'h0000
define MAIN_ENTRY	'h0050

	// To be used with LDMAM instruction (Load Memory Access Mode)	
define   IRW 0 // internal read , internal write. m0  
define   XRD 1 // external read , internal write. m1 
define   XWR 2 // internal read , external write. m2 
define   XRW 3 // external read , external write. m3 
   
// User defines
define	STACK_SIZE	10
define	RAM_SIZE	8
define	VALUE1	'h0055
define	VALUE2	'h1234

@RESET_ENTRY
reset_v: jmp   main				;
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		ldpv	pF,stack	;
			ldrv	r1,'h1111	;
			ldrv	r2,'h2222	;
			ldrv	r3,'h3333	;
			ldrv	r4,'h4444	;
			// Arithmetic and Logic group
  			add		r1,r2		; // good
  			jsr		subr11		;
  			adc		r1,r2		; // good
  			jsr		subr12		;
  			addv	r1,'h2222	; // good
  			jsr		subr13		;
  			sub		r1,r2		; // good
  			jsr		subr14		;
  			sbb		r1,r2		; // good
  			jsr		subr15		;
  			subv	r1,'h2222	; // good
  			jsr		subr16		;
  			not		r1			; // good
  			jsr		subr17		;
  			not		r1,r2		; // good
  			jsr		subr18		;
  			and		r1,r2		; // good
  			jsr		subr19		;
  			andv	r1,'h2222	; // good
  			jsr		subr110		;
  			or		r1,r2		; // good
  			jsr		subr111		;
  			orv 	r1,'h2222	; // good
  			jsr		subr112		;
  			xor		r1,r2		; // good
  			jsr		subr113		;
   			xorv 	r1,'h2222	; // good
  			jsr		subr114		;
  			inc		r1			; // good
  			jsr		subr115		;
  			dec		r1			; // good
  			jsr		subr116		;
  			cmpr	r1,r2		; // good
  			bra		ne,main2	;
  			jmp		endbad1		; 		
main2:		jsr		subr117		;
   			cmprv 	r1,'h2222	; // good
   			bra		z,endbad2	;
  			jsr		subr118		;
  			shl		r1			; // good
  			jsr		subr119		;
  			shr		r1			; // good
  			jsr		subr120		;
  			shl4	r1			; // good
  			jsr		subr121		;
  			shr4	r1			; // good
  			jsr		subr122		;
  			mvrr	r1,r2		; // good
  			jsr		subr123		;
  			swap	r1,r2		; // good
  			jsr		subr124		;
  			ldr		r1,temp2	; // good
  			jsr		subr125		;
  			ldrv	r1,'h2222	; // good
  			jsr		subr126		;
  			str		r1,xtemp1	; // good
  			jsr		subr127		;
  			bit		r1,r2		; // good
  			jsr		subr128		;
  			bitv	r1,'h2222	; // good
  			jsr		subr129		;
  			ldmam	m0			; // good
  			jsr		subr130		;
  			ldcv	c0,'h1234	; // good
  			jsr		subr131		;
  			ldc 	c1,r2		; // good
  			jsr		subr132		;
			uflag	t2			; // good
  			jsr		subr133		;
			
			 // end of test
endprog:	ldpagv	'habcd		; // address page = 1111
			stop               	; 
        	jmp   	endprog		; // test again.
        	
endbad1:	ldpagv	'hdead		; // address page = 1111
			stop				; 
			jmp		endbad1		; // test again.
			
endbad2:	ldpagv 	'hbeef		; // address page = 1111
			stop				; 
			jmp   	endbad2		; // test again.
         
// Support subrroutines
@'h0250	 
subr11:		ldpag 	r1			; // address page = 1111
  			add		r3,r4		; // good
  			rts					;
subr12:		ldpag 	r1			; // address page = 1111
  			adc		r3,r4		; // good
  			rts					;
subr13:		ldpag 	r1			; // address page = 1111
  			addv	r3,'h1111	; // good
  			rts					;
subr14:		ldpag 	r1			; // address page = 1111
  			sub		r4,r3		; // good
  			rts					;
subr15:		ldpag 	r1			; // address page = 1111
  			sbb		r4,r3		; // good
  			rts					;
subr16:		ldpag 	r1			; // address page = 1111
   			subv	r3,'h1111	; // good
  			rts					;
subr17:		ldpag 	r1			; // address page = 1111
   			not		r4			; // good
  			rts					;
subr18:		ldpag 	r1			; // address page = 1111
   			not		r3,r4		; // good
  			rts					;
subr19:		ldpag 	r1			; // address page = 1111
  			and		r3,r4		; // good
  			rts					;
subr110:	ldpag 	r1			; // address page = 1111
  			andv	r3,'h1111	; // good
  			rts					;
subr111:	ldpag 	r1			; // address page = 1111
  			or 		r3,r4		; // good
  			rts					;
subr112:	ldpag 	r1			; // address page = 1111
   			orv 	r3,'h1111	; // good
  			rts					;
subr113:	ldpag 	r1			; // address page = 1111
  			xor		r3,r4		; // good
  			rts					;
subr114:	ldpag 	r1			; // address page = 1111
   			xorv 	r4,'h1111	; // good
  			rts					;
subr115:	ldpag 	r1			; // address page = 1111
  			inc		r3			; // good
  			rts					;
subr116:	ldpag 	r1			; // address page = 1111
  			dec		r4			; // good
  			rts					;
subr117:	ldpag 	r1			; // address page = 1111
  			cmpr	r3,r4		; // good
  			rts					;
subr118:	ldpag 	r1			; // address page = 1111
   			cmprv 	r3,'h1111	; // good
  			rts					;
subr119:	ldpag 	r1			; // address page = 1111
   			shl		r3			; // good
  			rts					;
subr120:	ldpag 	r1			; // address page = 1111
   			shr		r4			; // good
  			rts					;
subr121:	ldpag 	r1			; // address page = 1111
   			shl4	r3			; // good
  			rts					;
subr122:	ldpag 	r1			; // address page = 1111
   			shr4	r4			; // good
  			rts					;
subr123:	ldpag 	r1			; // address page = 1111
   			mvrr	r3,r4		; // good
  			rts					;
subr124:	ldpag 	r1			; // address page = 1111
   			swap	r3,r1		; // good
  			rts					;
subr125:	ldpag 	r1			; // address page = 1111
  			ldr		r3,temp3	; // good
  			rts					;
subr126:	ldpag 	r1			; // address page = 1111
  			ldrv	r4,'h1111	; // good
  			rts					;
subr127:	ldpag 	r1			; // address page = 1111
  			str		r3,xtemp3	; // good
  			rts					;
subr128:	ldpag 	r1			; // address page = 1111
  			bit		r3,r4		; // good
  			rts					;
subr129:	ldpag 	r1			; // address page = 1111
			bitv	r3,'h1111	; // good
  			rts					;
subr130:	ldpagv	'h5a5a		; // address page = 1111
			ldmam	m0			; // good
  			rts					;
subr131:	ldpagv 	'haa55		; // address page = 1111
			ldcv	c0,'h1234	; // good
  			rts					;
subr132:	ldpagv	'h55aa		; // address page = 1111
			ldc		c1,r3		; // good
  			rts					;
subr133:	ldpagv	'h3c3c		; // address page = 1111
			uflag	f2			; // good
  			rts					;
  			

// Internal RAM
@'h0380
temp0:	dw 'h1234;
temp1:	dw 'h1111;
temp2:	dw 'h2222;
temp3:	dw 'h3333;	 
temp4:	dw 'h4444;
temp5:	dw 'h5555;
temp6:	dw 'h6666;
temp7:	dw 'h7777;

ptable:	dw temp0;
   		dw temp1;
   		dw temp2;
		dw temp3;
		dw temp4;
   		dw temp5;
		dw temp6;
		dw temp7;
		
// External RAM
xtemp1:	ds RAM_SIZE	;	 
xtemp2:	ds RAM_SIZE	;	 
xtemp3:	ds RAM_SIZE	;	 
xtemp4:	ds RAM_SIZE	;	 
		
stack:	ds STACK_SIZE; 
