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
reset_v: jmp   main			;
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		ldpv	pF,stack	;
			ldpv	p1,temp1	;
			ldpv	p2,temp2	;
			ldpv	p3,temp3	;
			ldpv	p4,temp4	;
				
			// Arithmetic and Logic group
main1:		ldrv	r2,'h1234	;
			ldpagv	'ha011		;
  			addrp	r2,p1		;
  			jsr		subr11		;
			ldpagv	'ha012		;
  			subrp	r1,p2		;
  			jsr		subr12		;
			ldpagv	'ha013		;
  			cmprp	r1,p2		;
  			bra		ne,main2	;
  			jmp		endbad1		; 		
main2:		jsr		subr13		;

			// Move Group with JSR, add NOP before JSR
  			mvrp	r3,p4		;
  			jsr		subr14		;
			ldpv	p5,'h55aa	;
			ldrv	r4,'h1234	;
			ldpagv	'ha015		;
  			mvpr	p5,r4		;
  			jsr		subr15		;
			ldpv	p4,'h33cc	;
			ldrv	p3,'h0c0b	;
			ldpagv	'ha016		;
  			mvpp	p3,p4		;
  			jsr		subr16		;
  			swapp	r1,p2		;
  			jsr		subr17		;
  			
			// Move Group with BRA
b1a:		ldpagv	'h1a1b		;
  			mvrp	r3,p4		;
  			bra		b1b			;
b2a:		ldpagv	'h2a2b		;
  			mvpr	p5,r4		;
  			bra		b2b			;
b3a:		ldpagv	'h3a3b		;
  			mvpp	p3,p4		;
  			bra		b3b			;
b4a:		ldpagv	'h4a4b		;
  			swapp	r1,p2		;
  			bra		b4b			;
b5a:		ldpv	p1,temp1	;
			ldpv	p2,temp2	;
			ldpv	p3,temp3	;
			ldpv	p4,temp4	;	
		
			// Move Group with LDRPI add NOP after LDRPI
			ldpagv	'h1111		;
  			mvrp	r3,p4		;
  			ldrpi	r1,p1		;
			ldpagv	'h2222		;
  			mvpr	p5,r4		;
  			ldrpi	r1,p1		;
			ldpagv	'h3333		;
  			mvpp	p3,p4		;
  			ldrpi	r1,p1		;
			ldpagv	'h4444		;
  			swapp	r1,p2		;
  			ldrpi	r1,p1		;
  			
			// Move Group with LDRPD
			ldpagv	'h5555		;
  			mvrp	r3,p4		;
  			ldrpd	r1,p1		;
			ldpagv	'h6666		;
  			mvpr	p5,r4		;
  			ldrpd	r1,p1		;
			ldpagv	'h7777		;
  			mvpp	p3,p4		;
  			ldrpd	r1,p1		;
			ldpagv	'h8888		;
  			swapp	r1,p2		;
  			ldrpd	r1,p1		;
  			
			// Move Group with LDRP
			ldpagv	'h9999		;
  			mvrp	r3,p4		;
  			ldrp	r1,p1		;
			ldpagv	'haaaa		;
  			mvpr	p5,r4		;
  			ldrp	r2,p1		;
			ldpagv	'hbbbb		;
  			mvpp	p3,p4		;
  			ldrp	r3,p1		;
			ldpagv	'hcccc		;
  			swapp	r1,p2		;
  			ldrp	r4,p1		;
  			
			// Move Group with STRPI add NOP after STRPI
			ldpagv	'hffff		;
  			mvrp	r3,p4		;
  			strpi	r1,p1		;
			ldpagv	'heeee		;
  			mvpr	p5,r4		;
  			strpi	r1,p1		;
			ldpagv	'hdddd		;
  			mvpp	p3,p4		;
  			strpi	r1,p1		;
			ldpagv	'hcccc		;
  			swapp	r1,p2		;
  			strpi	r1,p1		;
  			
			// Move Group with STRPD
			ldpagv	'hbbbb		;
  			mvrp	r3,p4		;
  			strpd	r1,p1		;
			ldpagv	'haaaa		;
  			mvpr	p5,r4		;
  			strpd	r1,p1		;
			ldpagv	'h9999		;
  			mvpp	p3,p4		;
  			strpd	r1,p1		;
			ldpagv	'h8888		;
  			swapp	r1,p2		;
  			strpd	r1,p1		;
  			
			// Move Group with STRP
			ldpagv	'h7777		;
  			mvrp	r3,p4		; // bad
  			strp	r1,p1		;
			ldpagv	'h6666		;
  			mvpr	p5,r4		;
  			strp	r2,p1		;
			ldpagv	'h5555		;
  			mvpp	p3,p4		; // bad
  			strp	r3,p1		;
			ldpagv	'h4444		;
  			swapp	r1,p2		; // bad
  			strp	r4,p1		;
  			
  			
			// first initialize temp0 to temp7
			ldpagv	'h0011		;
			ldcv	c1,7		;
			ldrv	r8,'hdea1	;
			ldpv	p8,temp0	;
loop1:		strpi	r8,p8		;
			inc		r8			;
			dcjnz	c1,loop1	;
			
			// again initialize temp0 to temp7
			ldpagv	'h0022		;
			ldcv	c1,7		;
			ldrv	r8,'hdea0	;
			ldpv	p8,temp0	;
loop2:		inc		r8			;
			strpi	r8,p8		;
			dcjnz	c1,loop2	;
			
			// and again initialize temp0 to temp7
			ldpagv	'h0033		;
			ldcv	c1,7		;
			ldrv	r8,'hdea0	;
			ldpv	p8,temp0	;
loop3:		inc		r8			;
			strp	r8,p8		;
			incp	p8			;
			dcjnz	c1,loop3	;
			
			// and again initialize temp0 to temp7
			ldpagv	'h0044		;
			ldcv	c1,7		;
			ldrv	r8,'hdea1	;
			ldpv	p8,temp7	;
loop4:		strpd	r8,p8		;
			inc		r8			;
			dcjnz	c1,loop4	;
			
			// Move Group with LDRX
			ldpagv	'h3311		;
  			mvrp	r7,p7		;
  			ldpv	p1,temp0	;
  			ldrx	r1,p1,0		;
			ldpagv	'h3322		;
  			mvpr	p8,r8		;
  			ldrx	r2,p1,1		;
			ldpagv	'h3333		;
  			mvpp	p9,pA		;
  			ldrx	r3,p1,2		;
			ldpagv	'h3344		;
  			swapp	rA,pA		;
  			ldrx	r4,p1,3		;
  			
  			
			// Move Group with STRX
			ldpagv	'h4411		;
  			mvrp	r1,p4		;
  			ldpv	p1,ptable	;
  			strx	r1,p1,4		;
			ldpagv	'h4422		;
  			mvpr	p5,r5		;
  			strx	r2,p1,3		;
			ldpagv	'h4433		;
  			mvpp	p3,p4		;
  			strx	r3,p1,2		;
			ldpagv	'h4444		;
  			swapp	r8,p2		;
  			strx	r4,p1,1		;
  			
			// check btable
			ldpv	p1,btable	;
			ldrx	r1,p1,1		;
			ldmam	m2			;
			str		r1,xtemp1	;
			ldmam	m0			;
			ldrx	r1,p1,2		;
			ldmam	m2			;
			str		r1,xtemp1	;
			ldmam	m0			;
			ldrx	r1,p1,3		;
			ldmam	m2			;
			str		r1,xtemp1	;
			ldmam	m0			;
			ldrx	r1,p1,4		;
			ldmam	m2			;
			str		r1,xtemp1	;
			ldmam	m0			;
		
			// Move Group with LDPY and JMPP
//			addrp	r1,p1		;// replace LDPY
//			mvrp	r1,p1		;//
//			ldrp	r1,p1		;//
//			mvrp	r1,p1		;//

jmpp0:		ldpagv	'h7711		;
  			ldpv	p1,btable	;
  			ldrv	r1,1		;
 			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp1:		ldpagv	'h7722		;
  			ldpv	p1,btable	;
  			ldrv	r1,2		;
  			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp2:		ldpagv	'h7733		;
  			ldpv	p1,btable	;
  			ldrv	r1,3		;
  			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp3:		ldpagv	'h7744		;
  			ldpv	p1,btable	;
  			ldrv	r1,4		;
  			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp4:		ldpagv	'h7755		;
  			
			// first initialize temp0 to temp7
			ldpagv	'hbebe		;
			ldcv	c1,7		;
			ldrv	r8,'h0000	;
			ldpv	p8,temp0	;
loop5:		strpi	r8,p8		;
			ldpag	r8			;
			addv	r8,'h1111	;
			dcjnz	c1,loop5	;
			
  			// Load Group
			ldpv	p2,temp2	;
			xor		r7,r7		;
			ldrx	r5,p2,3		;
			ldrpd	r7,p2		;
			jsr		beback1		;
			ldpag	r7			;
			ldpv	p2,temp3	;
			ldrpi	r6,p2		;
			jsr		beback1		;
			ldpag	r6			;
			jmp		skip1		;
beback1:	rts					;
skip1:
  			// I/O Group
  			ldrv	ra,'haba	;
  			outp	ra,'h900	;
			jsr		beback2		;
			ldpagv	'haba		;
  			inp		r5,'h900	;
			jsr		beback2		;
			ldpag	r5			;
			ldpv	p2,temp3	;
			outpp	r5,p2		;
			jsr		beback1		;
			ldpagv	temp3		;
			inpp	r6,p2		;
			jsr		beback2		;
			ldpagv	'hbeba		;
			jmp		skip2		;
beback2:	rts					;
skip2:
  			jmp		endprog		;
			
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
subr11:		ldpagv 	'hb011		; // address page = 1111
  			addrp	r3,r2		; // good
  			rts					;
subr12:		ldpagv 	'hb012		; // address page = 1111
  			subrp	r3,p4		; // good
  			rts					;
subr13:		ldpagv 	'hb013		; // address page = 1111
  			cmprp	r3,p1		; // good
  			rts					;
subr14:		ldpagv 	'hb014		; // address page = 1111
  			mvrp	r2,p5		; // good
  			rts					;
subr15:		ldpagv 	'hb015		; // address page = 1111
  			mvpr	p1,r1		; // good
  			rts					;
subr16:		ldpag 	r1			; // address page = 1111
   			mvpp	p3,p7		; // good
  			rts					;
subr17:		ldpag 	r3			; // address page = 1111
   			swapp	r3,p4		; // good
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
  			
b1b:		bra		b2a;
b2b:		bra		b3a;
b3b:		bra		b4a;
b4b:		bra		b5a;
		
// Internal RAM
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
		
btable:	dw	jmpp0;
		dw	jmpp1;
		dw	jmpp2;
		dw	jmpp3;
		dw	jmpp4;
				
// External RAM
xtemp1:	ds RAM_SIZE	;	 
xtemp2:	ds RAM_SIZE	;	 
xtemp3:	ds RAM_SIZE	;	 
xtemp4:	ds RAM_SIZE	;	 
		
stack:	ds STACK_SIZE;
stack_size: dw stack_size;
 
