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
define RAM_SIZE		 8
define LOOP_CNT		12

@RESET_ENTRY
reset_v: jmp   main			;
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:	ldpv	pF,stack	; // Initialize stack pointer.
		ldpv	p1,temp1 	;
		ldpv	p2,temp2 	;
		ldpv	p6,temp 	;
		ldpv	p7,xtemp 	;
		ldmam	m0			; // read internal, read internal
		ldpagv	'h55		; // reference point
		ldpagv	0			; 
		// start
		// check NOP first
		nop					;		
		nop					;		
		// Load group
		ldcv 	c1,'h5678	;
		ldcv 	c3,'h1234	;
		ldr		r2,temp1	;
		ldr		r7,temp2	;
		ldrv	r1,'h3c5a	;
		ldrv	r5,'hc3a5	;
		// stop
		nop					;		
		ldpagv	'haa		; // reference point
		ldpagv	0			; 
     	
     	
///////////////////////////////////     	
// test on external memory LDMAM=2     	
		ldpv	p8,temp1 	;
		ldpv	p9,xtemp1 	;
		ldmam	m2			; // write external, read internal
		ldcv 	c0,RAM_SIZE	;
loop2:	ldrpi	r1,p8		;
     	strpi	r1,p9  		;
     	dcjnz	c0,loop2	;
		ldmam	m0			; // read internal, read internal
      	nop					; 
end:	stop				; 
	 	jmp   end			; 

// Internal RAM
temp1:	dw 'h1111			;	 
temp2:	dw 'h2222			;	 
temp3:	dw 'h3333	;	 
temp4:	dw 'h4444	;	 
temp:	ds RAM_SIZE	;	 
		dw 0;
		
// External RAM
xtemp1:	dw 0	;	 
xtemp2:	dw 0	;	 
xtemp3:	dw 0	;	 
xtemp4:	dw 0	;	 
xtemp:	ds RAM_SIZE	;	 
		dw 0;
		
		
stack:	ds STACK_SIZE; 

		