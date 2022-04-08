   // PROG_BIT_TEST.ASM :  Test program 
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification =
   //
   // Register and Pointer definitions
   // P0 pointer 0  -> program counter 'PC' not accesible
   // P1 pointer 1  -> user pointer    'P1'
   // P2 pointer 2  -> user pointer    'P2'
   // Pn pointer n -> user pointer    'Pn' n=0...F
   // PF pointer 15 -> stack pointer   'SP' can be used in some conditions
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user limited   'R3'
   // Rn register n -> user register  'Rn' n=0...F
   // RF register 15 -> user limited  'RF'
   //
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
define	RAM_SIZE	32
define	VALUE1	'h0055
define	VALUE2	'h1234

@RESET_ENTRY
reset_v: jmp   main			;
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:	ldpv	pF,stack	; // Initialize stack pointer.

		xor		r2,r2		;
		ldpv	p4,ptable	;
		ldpy	p4,r2		; // works
		ldrp	r3,p4		;
		ldpag	r3			;
		
		inc		r2			;
		ldpv	p4,ptable	;
		ldpy	p4,r2		; // works
		ldrp	r3,p4		;
		ldpag	r3			;
		
		inc		r2			;
		ldpv	p4,ptable	;
		ldpy	p4,r2		; // works
		ldrp	r3,p4		;
		ldpag	r3			;
		
		inc		r2			;
		ldpv	p4,ptable	;
		ldpy	p4,r2		; // works
		ldrp	r3,p4		;
		ldpag	r3			;
		
		xor		r2,r2		;
		ldcv	c0,3		;
loop1:	ldpv	p4,ptable	;
		ldpy	p4,r2		;
		ldrp	r3,p4		;
		ldpag	r3			;
		inc		r2			;
		dcjnz	c0,loop1	;
		
		ldpv	p1,temp0	;
		ldpv	p2,xtemp2	;
		ldpv	p3,xtemp1	;
		ldrv	r2,'habcd	;
		ldrv	r7,'h3cc3	;
l1:		ldrpi	r1,p1		; // good
//		bra		l2			; // good
		jsr		sub2		; // good
l2:		strpi	r2,p3		; // good
//		bra		l3			; // good
		jsr		sub3		; // good
l3:		ldrpd	r3,p1		; // good
//		bra		l4			; // good
		jsr		sub2		; // good
l4:		strpd	r3,p3		; // good
//		bra		l5			; // good
		jsr		sub3		; // good
l5:		outpp	r2,p2		; // good
		bra		l6			; // good
l6:		inpp	r4,p2		; // good
		bra		l7			; // good
l7:		swapp	r4,p2		; // good
		bra		l8			; // good
l8:		mvpp	p2,p4		; // good
		bra		l9			; // good
l9:		incp	p2			; // good
		bra		l10			; // good
l10:	decp	p4			; // good
		bra		l11			; // good
l11:	ldrv	r2,3		;
		ldpv	p5,temp0	;
		ldpy	p5,r2		; // good
		bra		next		; // good
		
here:	bra		here		;
next:	ldpag	r1			;
		ldpag	r2			;
		ldpag	r3			;
		ldpag	r4			;
		
		 // end of test
         nop				;
endprog: stop               ; 
         jmp   endprog		; // test again.
         
         
sub1:	ldpag	r7			; // address page = 1111
		ldrpi	r0,p1		; // good
		rts					;
sub2:	ldpagv	'h55aa		; // address page = 1111
		ldrpi	r0,p1		; // good
		rts					;
sub3:	ldpagv	'haa55		; // address page = 1111
		ldrpi	r0,p1		; // good
		rts					;
		

// Internal RAM
@'h0200
temp0:	dw 'h1234;
temp1:	dw 'h1111;
temp2:	dw 'h2222;
temp3:	dw 'h3333;	 
temp4:	dw 'h4444;

@'h0300	 
ptable:	dw temp0;
   		dw temp1;
   		dw temp2;
		dw temp3;
		dw temp4;
		
// External RAM
xtemp1:	ds RAM_SIZE	;	 
xtemp2:	ds RAM_SIZE	;	 
xtemp3:	ds RAM_SIZE	;	 
xtemp4:	ds RAM_SIZE	;	 

stack:	ds STACK_SIZE; 
		