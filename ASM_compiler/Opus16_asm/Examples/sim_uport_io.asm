   // PROG_BRANCH.ASM :  Test program jump group.
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification = PASSED
   //
   // Register and Pointer definitions
   // P0 pointer 0  -> program counter 'PC' not accesible
   // P1 pointer 1  -> user pointer    'P1'
   // P2 pointer 2  -> user pointer    'P2'
   // Pn pointer n -> user pointer    'Pn' n=0...F
   // PF pointer F -> stack pointer   'SP' can be used in some conditions
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user limited   'R3'
   // Rn register n -> user register  'Rn' n=0...F
   //

define RESET_ENTRY	'h0000
define MAIN_ENTRY	'h0050

	// To be used with LDMAM instruction (Load Memory Access Mode)	
define   IRW 0 // internal read , internal write.  m0 
define   XRD 1 // external read , internal write.  m1
define   XWR 2 // internal read , external write.  m2
define   XRW 3 // external read , external write.  m3
   
// User defines
define	STACK_SIZE	10
define	RAM_SIZE	100


@RESET_ENTRY
reset_v:	jmp		main			;// vector 0
irq_1:		jmp		irq_1			;// vector 2
irq_2:		jmp		irq_2			;// vector 4
irq_3:		jmp		irq_3			;// vector 6
irq_4:		jmp		irq_4			;// vector 8
swi_a:		jmp		swi_a			;// vector a default
   
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		cli					; // disable interrupts
			ldpv	pF,stack	; // Initialize stack pointer.  
			ldrv  r0,0          ; // initialize registers
			str   r0,error		;
init:		ldrv  r1,'h1234		; // initialize ports
			outp  r1,port0		; 
			ldrv  r1,'h5678		; // initialize ports
			outp  r1,port1		; 
			ldrv  r1,'h9abc		; // initialize ports
			outp  r1,port2		; 
			ldrv  r1,'hb0b0		; // initialize ports
			outp  r1,port3		; 
			
			ldpv  pA,port0		;
			ldpv  pB,port1		;
rdchar:		inpp  r1,pB         ; // read status reg
			andv  r1,'h5678     ; // mask data valid bit
			bra   z,rdchar      ; // read again
			inpp  r1,pA         ; // read data reg
			andv  r1,'hFF       ; // mask data
			str   r1,temp0      ; // save it
			ldr   r4,temp0		;
			cmpr  r4,r1			;
			bra   e,keepg1		;
			ldrv  r0,'h1001		;
			str   r0,error		;
			uport t1			;
			bra   stop			;
	
keepg1:		ldpv  p1,temp0		;
			ldpv  p3,port3		;
			ldrv  r2,7			;
			outpp r2,p3			;
wrnext:		inpp  r1,p3         ; // read status reg
			strpi r1,p1         ; // mask data valid bit
			dec   r1            ; // read again
			outpp r1,p3         ; // read data reg
			or    r1,r1			;
			bra   nz,wrnext		;
			strpi r1,p1         ; // mask data valid bit
	
			ldcv	c1,7			;
			ldrv  r4,0			;
			ldpv  p5,temp8		;
rdnext:		ldrpd r1,p5			;
			xor   r1,r4			;
			bra   nz,e02		;
			inc   r4			;
			dcjnz c1,rdnext		;
			bra   stop			;
e02:		ldrv  r0,'h1002		;
			str   r0,error		;
			uport t2 			;
			bra   stop			;
	
stop:		stop                ;
			uport f1			;
			uport f2			;
			bra   stop			;	 

   // IO ports driven by opus1_tb.vhd
@'hE00
port0:	 dw    0 ;
port1:	 dw    1 ;
port2:	 dw    2 ; 
port3:	 dw    3 ; 
port4:	 dw    4 ; 
port5:	 dw    5 ; 
port6:	 dw    6 ; 
port7:	 dw    6 ;
	
   // Temporary storage
@'hF00
temp0:   dw    1                ;
temp1:   dw    'h1234           ; 
temp2:   dw    1                ; 
temp3:   dw    1                ; 
temp4:   dw    1                ;
temp5:   dw    1                ;
temp6:   dw    1                ;
temp7:   dw    1                ;
temp8:	 dw    0				;
error:   dw    0                ; 

   // Stack memory
stack:   ds    STACK_SIZE       ; // Stack from 0xFF0

