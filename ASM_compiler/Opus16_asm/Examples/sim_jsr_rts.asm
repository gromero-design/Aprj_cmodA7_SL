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
define	RAM_SIZE	32
define	VALUE1	'h0055
define	VALUE2	'h1234

@RESET_ENTRY
reset_v:	jmp		main			;// vector 0
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		cli					; // disable interrupts
			ldpv	pF,stack	; // Initialize stack pointer.
		
main2:		nop					;
			jsr		sub1   		;
			nop					;
			ldpagv	'hefff		; // address page = 1111
			
endprog:	stop				; 
			jmp		endprog		; // test again.
         
         
sub1:		ldpagv	'h5501		; // address page = 1111
			rts					;
sub2:		rts					;
sub3:		rts					;
sub4:		rts					;
		
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
