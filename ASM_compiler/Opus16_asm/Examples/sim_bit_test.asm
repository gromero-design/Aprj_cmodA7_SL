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
define STACK_SIZE	10
define RAM_SIZE	32

@RESET_ENTRY
reset_v: jmp   main			;
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:	ldpv  pF,stack		; // Initialize stack pointer.

		ldpv	p1,temp1 	;
		ldrv	r1,'h3c5a	;
		mvrr	r1,r7		; // save it
		ldrv	r2,1		;
		ldrv	r3,0		;
		ldrv	r4,1		;
		ldcv	c0,15		; // loop 16-1
     	ldpag	r1			;
		
loop1:	bit		r1,r2		;
     	bra		nz,true		;
     	ldpagv	0			;
     	strpi	r3,p1		;
     	bra		again		;
true:  	ldpagv	1			;
		strpi	r4,p1		;
again:	shl		r2			;
     	dcjnz	c0,loop1	;
     	
     	
///////////////////////////////////     	
// test on external memory LDMAM=2     	
		ldpv	p1,temp1 	;
		ldpv	p2,xtemp1 	;
		ldmam	m2			; // store external, load internal
		ldcv	c0,15		;
		ldpagv	'h3c5a		;
loop2:	ldrx	r1,p1,0		;
		ldpag	r1			;
     	strx	r1,p2,0		;
     	incp	p1			;
     	incp	p2			;
     	dcjnz	c0,loop2	;
		ldmam	m0			; // store internal, load internal
     	
      	nop			; 
end:	stop			; 
	 	jmp   end		; 

// Internal RAM
temp1:	ds RAM_SIZE	;	 
temp2:	ds RAM_SIZE	;	 
temp3:	ds RAM_SIZE	;	 
temp4:	ds RAM_SIZE	;	 

   
// External RAM
xtemp1:	ds RAM_SIZE	;	 
xtemp2:	ds RAM_SIZE	;	 
xtemp3:	ds RAM_SIZE	;	 
xtemp4:	ds RAM_SIZE	;	 

stack:	ds STACK_SIZE; 

		