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
define	RAM_SIZE	16
define	VALUE1	'h0055
define	VALUE2	'h1234

@RESET_ENTRY
reset_v:	jmp		main			;// vector 0
irq_1:		jmp		irq1			;// vector 2
irq_2:		jmp		irq2			;// vector 4
irq_3:		jmp		irq3			;// vector 6
irq_4:		jmp		irq4			;// vector 8
   
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		cli					; // disable interrupts
			ldpv	pF,stack	; // Initialize stack pointer.
			xor		r1			;
			xor		r2			;
			xor		r3			;
			xor		r4 			;
			xor		r7			;
			xor		r8			;
			xor		r9			;
			ldcv	c0,100		;
			uflag	t1			;
			sei;
main1:		
			ldpv	p1,jmp2		;
			mvpr	p1,r5		;
			ldpag	r5			;
			jmpp	p1			; // ok
			bra		enddead		;
main2:		ldpv	p1,jmp3		;
			mvpr	p1,r5		;
			ldpag	r5			;
			jmp		jmp3		; // ok
			bra		enddead		;
main3:		ldpv	p1,jmp4		;
			mvpr	p1,r5		;
			ldpag	r5			;
			jmp		t1,jmp4		;
			bra		enddead		;
main4:		ldpv	p1,jmp5		;
			mvpr	p1,r5		;
			ldpag	r5			;
			bra		jmp5		;
			jmp		enddead		;
main5:		inc		r7			;

			ldpv	p3,ptable	;
			addrp	r9,p3		;
			str		r9,pjump	;
			ldp		p3,pjump	;
			ldrp	r9,p3		;
			str		r9,pjump	;
			inc		r9			;
			andv	r9,3		;
			
			ldp		p3,pjump	;
			jmpp	p3			;
main6:		dcjnz	c0,main1	;
			
			cli					;			
			
endprog:	ldpagv	'hb0b0		; // address page = 1111
			stop				;
			jmp		endprog		; // test again.
         
enddead:	ldpagv	'hdead		; // address page = 1111
			stop				;
			jmp		enddead		; // test again.
         
jmp2:		bra		main2		;
			jmp		enddead		;
jmp3:		bra		main3		;
			jmp		enddead		;
jmp4:		bra		main4		;
			jmp		enddead		;
jmp5:		jmp		main5		;
			bra		enddead		;
			
         
         
@'h0200
sub1:		ldpagv	'h5501		; // address page = 1111
			nop					;
			jmp		main6		;
sub2:		ldpagv	'h5502		; // address page = 1111
			nop					;
			nop					;
			jmp		main6		;
sub3:		ldpagv	'h5503		; // address page = 1111
			nop					;
			nop					;
			nop					;
			jmp		main6		;
sub4:		ldpagv	'h5504		; // address page = 1111
			nop					;
			nop					;
			nop					;
			nop					;
			jmp		main6		;
		
irq1:		inc		r1			;
//			jsr		sub1i		;
			rti;
			
irq2:		inc		r2			;
//			jsr		sub2i		;
			rti;
			
irq3:		inc		r3			;
//			jsr		sub3i		;
			rti;
			
irq4:		inc		r4			;
//			jsr		sub4i		;
			rti;
			
sub1i:		ldpagv	'h1111		; // address page = 1111
			rts					;
			
sub2i:		ldpagv	'h2222		; // address page = 1111
			rts					;
			
sub3i:		ldpagv	'h3333		; // address page = 1111
			rts					;
			
sub4i:		ldpagv	'h4444		;
			rts					;
		
swia:		inc		r8			;
			ldpagv	'haaaa		;
			rti;
			
ptable:	dw sub1;
   		dw sub2;
   		dw sub3;
   		dw sub4;
   		
// Internal RAM
@'h0300
temp0:	dw 'h1234;
temp1:	dw 'h1111;
temp2:	dw 'h2222;
temp3:	dw 'h3333;	 
temp4:	dw 'h4444;

swiacnt:	dw	0	;
int1cnt:	dw	0	;
int2cnt:	dw	0	;
int3cnt:	dw	0	;
int4cnt:	dw	0	;

pjump:	dw	0;

// External RAM
xtemp0:	dw 0       	;	 
xtemp1:	dw 0       	;	 
xtemp2:	dw 0       	;	 
xtemp3:	dw 0       	;	 
xtemp4:	dw 0       	;	 
stemp0:	ds RAM_SIZE	;	 
stemp1:	ds RAM_SIZE	;	 

stack:	ds STACK_SIZE; 
