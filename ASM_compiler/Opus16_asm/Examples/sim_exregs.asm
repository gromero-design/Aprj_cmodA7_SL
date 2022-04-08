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


define   valid 'h8000
define   count  8
   
@'h0
reset_v: jmp   main             ;
   
@'h10   
main:	 bra start;

@'h050	 //start
start:	 // initialize registers
			ldpv	pF,stack		; // init stack pointer
init:		ldpv	p1,port1 		; // initialize ports
			ldrv	r1,'h3570		; // initialize ports
			outpp	r1,p1  			; 
			ldpv	p1,port2 		; // initialize ports
			ldrv	r1,'h2440		; // initialize ports
			outpp	r1,p1  			; 
			ldpv	p1,port3 		; // initialize ports
			ldrv	r1,'h1760		; // initialize ports
			outpp	r1,p1  			; 
			ldrv	r1,'h4360		; // initialize ports
			outp	r1,port4		; 
			ldrv	r1,'hcff0		; // initialize ports
			outp	r1,port5		; 
			ldrv	r1,'h4000		; // initialize ports
			outp	r1,port6		;
			ldrv	r1,'hdea0		; // initialize ports
			outp	r1,'h0eff		;

rd_back:	inp		r1,port1		;
			inp		r2,port2		;
			inp		r3,port3		;
			ldpv	p1,port4 		; // initialize ports
			inpp	r4,p1  			;
			ldpv	p1,port5 		; // initialize ports
			inpp	r5,p1  			;
			ldpv	p1,port6 		; // initialize ports
			inpp	r6,p1  			;
			
here:		stop					; 
			bra		here			; 


   // IO ports driven by opus1_tb.vhd
@'hE00
port:	 dw    0    		;
port1:	 dw    1    		;
port2:	 dw    2     		; 
port3:	 dw    3    		; 
port4:	 dw    4    		; 
port5:	 dw    5    		; 
port6:	 dw    6    		; 
   
   // Temporary storage
@'hF00
temp:	 dw    0                ; 
temp1:   dw    1                ; 
temp2:   dw    2                ; 
temp3:   dw    3                ; 
temp4:   ds    4                ;
temp5:   ds    5                ;
temp6:   ds    6                ;

   // Stack memory
@'hFF0
stack:   ds    1                ; // Stack from 0xFF0

