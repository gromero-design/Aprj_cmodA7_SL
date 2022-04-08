	//////////////////////////////////////////////////
   // PROG_sim_instructions :  test new instructions 
   //////////////////////////////////////////////////
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification =
   //
   // Register and Pointer definitions
   // P0 pointer 0  -> program counter 'PC' not accesible
   // P1 pointer 1  -> user pointer    'P1'
   // P2 pointer 2  -> user pointer    'P2'
   // Pn pointer n -> user pointer     'Pn' n=0...F
   // PF pointer 15 -> stack pointer   'SP' can be used in PUSH/POP
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user limited   'R3'
   // Rn register n -> user register  'Rn' n=0...F
   // RF register 15 -> user limited  'RF'
   //
define RESET_ENTRY	'h0000
define MAIN_ENTRY	'h0010
define SUBROUTINES	'h0800
define MEM_SIZE		'h0FFF // 4Kx16

	// To be used with LDMAM instruction (Load Memory Access Mode)	
define   IRW 0 // internal read , internal write. m0  
define   XRD 1 // external read , internal write. m1 
define   XWR 2 // internal read , external write. m2 
define   XRW 3 // external read , external write. m3 
   
// User defines
define STACK_SIZE	10
define RAM_SIZE		16
define LOOP_CNT		20

@RESET_ENTRY
reset_v: jmp   main			;
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:	ldpv	pF,stack	; // Initialize stack pointer.
		jsr		init		; // init variables
		ldpagv	'hFFFF		; // fails with 'hffff - pre_opcode=2?
		// Instruction structure: NEMONIC	OPCODE	WORDS	ORDER 
		add		r1,r2		; //	ADD		01		1		1		r1     = r1+r2
		add		r2,r1		; //	ADD		01		1		1		r2     = r2+r1
		ldpag	r2			; //									page   = r2
		outp	r2,7		; //	OUTP	34		2		0		port 7 = r2
		ldc		c2,r1		; // 									cnt    = r1
		
		xor		r3,r3		;
		ldcv	c1,2		; // 3 counts, c=0 is executed			page   = abcd
loop1:	inc		r3			;
		dcjnz	c1,loop1	;
		ldpag	r3			; // page = r3
		
		xor		r5,r5		;
		ldcv	c3,2		; // 2 counts, c=0 is not executed		page   = abcd
loop2:	dcjz	c3,loop3	;
		inc		r5			;
		bra		loop2		;
loop3:	ldpag	r5			; // page = r3
		
end:	stop				; 
	 	jmp   end			; 

	 	// Initialize all
@SUBROUTINES
init:	ldrv	r1,'h1111	;
		ldrv	r2,'h2222	;
		rts					;


		// Internal RAM
temp1:	dw 'h1111			;	 
temp2:	dw 'h2222			;	 
temp3:	dw 'h3333	;	 
temp4:	dw 'h4444	;	 
temp:	ds RAM_SIZE	;	 
etemp:	dw 0;
		
		// External RAM
xtemp1:	dw 0	;	 
xtemp2:	dw 0	;	 
xtemp3:	dw 0	;	 
xtemp4:	dw 0	;	 
xtemp:	ds RAM_SIZE	;	 
xetemp:	dw 0;
		
		
stack:	ds STACK_SIZE; 

		