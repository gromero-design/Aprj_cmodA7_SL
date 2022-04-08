   // PROG_INOUT.ASM :  Test program I/O group.
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification =
   //
   // Register and Pointer definitions
   // P0 pointer 0  -> program counter 'PC' not accesible
   // P1 pointer 1  -> user pointer    'P1'
   // P2 pointer 2  -> user pointer    'P2'
   // -------------------------------------
   // PF pointer 15 -> stack pointer   'SP' can be used in some conditions
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user limited   'R3'
   // -----------------------------------
   // RF register 15 -> user limited   'RF'
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
			
			// Initialize external RAM
            ldmam	m2			;
			ldrv	r1,'he000	;
			str		r1,xtemp0	;
			ldrv	r1,'he001	;
			str		r1,xtemp1	;
			ldrv	r1,'he002	;
			str		r1,xtemp2	;
			ldrv	r1,'he003	;
			str		r1,xtemp3	;
			ldrv	r1,'he004	;
			str		r1,xtemp4	;
			
			// Initialize external PORT
            ldmam	m2			;
			ldrv	r2,'hf000	;
			str		r2,port0 	;
			ldrv	r2,'hf001	;
			str		r2,port1	;
			ldrv	r2,'hf002	;
			str		r2,port2	;
			ldrv	r2,'hf003	;
			str		r2,port3	;
			ldrv	r2,'hf004	;
			str		r2,port4	;
			
			
test_ldmam: ldmam	m2			; // start fresh
			ldrv	r1,'h33cc	;
			str		r1,port0	;
			ldr		r3,temp0	;
			ldmam	m1			;
			ldr     r2,port0	;
			str		r2,temp0	;
			
			nop;nop;nop;
			
			ldmam	m2;
			ldr		r1,temp1;
			str		r1,port1;
			ldmam	m1;
			ldr		r1,xtemp2;
			str		r1,temp2;
			ldmam	m2;
			ldr		r1,temp3;
			str		r1,port3;
			ldmam	m3;
			ldr		r1,xtemp4;
			str		r1,port4;
			
			ldmam	m0;
			ldp		p1,temp1;
			stp		p1,temp4;
			ldmam	m1;
			ldp		p1,xtemp2;
			stp		p1,temp3;
			ldmam	m2;
			ldp		p1,temp3;
			stp		p1,xtemp0;
			ldmam	m3;
			ldp		p1,xtemp4;
			stp		p1,port3;
			ldmam	m0;
			
here:		stop					; 
			bra		here			; 

   // Temporary storage Internal
@'hD00
temp0:	 dw    'hd000           ; 
temp1:   dw    'hd001           ; 
temp2:   dw    'hd002           ; 
temp3:   dw    'hd003           ; 
temp4:   dw    'hd004           ;

   // Temporary storage External
@'hE00
xtemp0:	 dw    0           ; 
xtemp1:  dw    0           ; 
xtemp2:  dw    0           ; 
xtemp3:  dw    0           ; 
xtemp4:  dw    0           ;

   // IO ports external
@'hF00
port0:	 dw    0    		;
port1:	 dw    0    		;
port2:	 dw    0     		; 
port3:	 dw    0    		; 
port4:	 dw    0    		; 
   
   // Stack memory
@'hFF0
stack:   ds    1                ; // Stack from 0xFF0

