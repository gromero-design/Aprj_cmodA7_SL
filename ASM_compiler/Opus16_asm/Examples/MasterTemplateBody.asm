   //////////////////////////////////////////////////////////////////////
   // PROGRAM :		Template Body
   //////////////////////////////////////////////////////////////////////
   // Application: test_name.asm
   //
   // save MasterTemplateBody.asm to test_name.asm or any name.asm
   // insert your code in Application area and make a call inside main loop
   // compile test_name.asm (asm test_name)  no extension
   // save the results      (save test_name) no extension
   // the coe file is in ../../Opus16_cores_xil under prog_ram_example.coe
   // the test_name.lst in the current directory 
   // also check ./temp directory for more files for Xilinx and Altera
   //
   //////////////////////////////////////////////////////////////////////
   // check comments with //g// or //g#// , #=1 to 99
   //////////////////////////////////////////////////////////////////////
   // Registers, Pointers and flags usage:
   //
   // Pointers
   // p0 : program counter
   // p1 : temp
   // p2 : temp, 
   // p3 : temp
   // p4 : temp
   // p5 : temp
   // p6 : temp
   // p7 : temp
   // p8 : temp
   // pA : temp
   // pB : temp
   // pC : temp
   // pD : temp
   // pE : temp
   // pF : stack pointer
   //
   // Registers
   // r0 : auxilary reg, don't use it
   // r1 : temp
   // r2 : temp
   // r3 : temp
   // r4 : temp
   // r5 : temp
   // r6 : temp
   // r7 : temp
   // r8 : temp
   // r9 : temp
   // rA : temp
   // rB : temp
   // rC : temp
   // rD : temp
   // rE : temp
   // rF : temp
   //
   // uflag(0)
   // uflag(1)
   // uflag(2)
   // uflag(3)
   // uflag(4)
   // uflag(5)
   // uflag(6)
   // uflag(7)
   // uflag(8)
   // uflag(9)
   // uflag(A-F) available

   // uport(0)
   // uport(1)
   // uport(2)
   // uport(3)
   // uport(4)
   // uport(5)
   // uport(6)
   // uport(7)
   // uport(8)
   // uport(9)
   // uport(A-F) available
   //
   // Register and Pointer definitions
   //=====================================
   //
   // POINTER REGISTERS
   //=====================================
   // P0 pointer 0 -> program counter 'p0'
   // P1 pointer 1 -> user pointer    'p1'
   // P2 pointer 2 -> user pointer    'p2'
   // P3 pointer 3 -> user pointer    'p3'
   // P4 pointer 4 -> user pointer    'p4'
   // P5 pointer 5 -> user pointer    'p5'
   // P6 pointer 6 -> user pointer    'p6'
   // P7 pointer 7 -> user pointer    'p7'
   // P8 pointer 8 -> user pointer    'p8'
   // P9 pointer 9 -> user pointer    'p9'
   // PA pointer 10-> user pointer    'pA'
   // PB pointer 11-> user pointer    'pB'
   // PC pointer 12-> user pointer    'pC'
   // PD pointer 13-> user pointer    'pD'
   // PE pointer 14-> user pointer    'pE'
   // PF pointer 15-> stack pointer   'pF' Stack routines
   //
   //
   // REGISTERS
   //=====================================
   // R0 register 0 -> temporary ACC  'r0' modified by arith/logic instructions
   // R1 register 1 -> user register  'r1' any routine
   // R2 register 2 -> user register  'r2' 
   // R3 register 3 -> user register  'r3' 
   // R4 register 4 -> user register  'r4' 
   // R5 register 5 -> user register  'r5' 
   // R6 register 6 -> user register  'r6' 
   // R7 register 7 -> user register  'r7' 
   // R8 register 8 -> user register  'r8' 
   // R9 register 9 -> user register  'r9' 
   // RA register 10-> user register  'rA' 
   // RB register 11-> user register  'rB' 
   // RC register 12-> user register  'rC' 
   // RD register 13-> user register  'rD' 
   // RE register 14-> user register  'rE' 
   // RF register 15-> status/control 'rF' 
   //
   // R0 is modified by arithemtic and logic instructions, temp reg
   //=====================================
   //////////////////////////////////////////////////////////////////////
   // To be used with LDMAM instruction (Load Memory Access Mode)	
   // ldmam mo ; // internal read , internal write. IRW  
   // ldmam m1 ; // external read , internal write. XRD 
   // ldmam m2 ; // internal read , external write. XWR 
   // ldmam m3 ; // external read , external write. XRW 

   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Main Address Defines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // The boot loader must always be in the last program memory positions.
   // 4K  -> 'h0F00
   // 8K  -> 'h1F00
   // 16K -> 'h3F00 <---- 16384
   // 32K -> 'h7F00
   // 64K -> 'hFF00

define	RESET_ADDR		'h0000 // Reset vector address
define	MAIN_ADDR		'h0050 // Main entry address
define	BOOT_ADDR		'h3F00 // Boot loader address
define	STACK_LENGTH		64 //

   
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // System defines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   
   // Key defines, add as many as you need
define   CTLX 'h03 // ^C
define   ETX  'h03 // ^C
define   CTLD 'h04 // ^D
define   CTLE 'h05 // ^E
define   CTLI 'h09 // ^I
define   CR   'h0D // ^M
define   LF   'h0A // ^J
define   FF   'h0C // ^L
define   CTLL 'h0C // ^L
define   CTLP 'h10 // ^P
define   CTLR 'h12 // ^R
define   CTLZ 'h1A // ^Z
define   ESC  'h1B // ^[
define   NULL 'h00 // ^@
define   CTLS 'h13 // ^S
define   CTL_ 'h1F // ^S
define   SPC  'h20 // Space

define   NUMFILL 	'h5  // number of filling charaters in message
define   CHARFILL	'h2d // character to fill in this case is "-"


   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // User defines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
define	SIGNED		'h8000 // Signed bit
define	BASEREGIO	'h0000 // Base register address port

   //////////////////////////////////////////////////////////////////////
   //
   // Code Area Protected
   //
   // All labels lower case
   //////////////////////////////////////////////////////////////////////

@RESET_ADDR // Reset vector
reset_v:	jmp		main		; // @'h000 reset vector
irq1_v:		jmp		hw_irq1		; // @'h002 hardware irq vector
irq2_v:		jmp		hw_irq2		; // @'h004 hardware irq vector
irq3_v:		jmp		hw_irq3		; // @'h006 hardware irq vector
irq4_v:		jmp		hw_irq4		; // @'h008 hardware irq vector

// Available from 'h000A to MAIN_ADDR


   
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Program Section, Protected area
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
@MAIN_ADDR
main:		cli						; // disable interrutps
			ldmam	m0				; // internal read , internal write
			ldpv	pF,stack		; // initialize stack pointer
			// Initialize local registers and pointers
			ldpv	p0,temp			; // p0 = &temp
			ldpv	p1,temp3		; // p1 = &temp3
			ldrv	r1,zend_code	; // end of code
			ldpag	r2				; // page port = end of code
			ldrv	r2,zend_ram		; // end of ram
			ldpag	r1				; // page port = end of code+ram
			ldpagv	'h0000			; // page port = 0, here used for debugging/results
			
			// Insert User Initialization user flags
			uflag	f0				; // 
			uflag	f1				; //
			uflag	f2				; //
			uflag	f3				; //
			// here more uflag from 4 to B
			uflag	fC				; //
			uflag	fD				; //
			uflag	fE				; //
			uflag	fF				; //
			// Insert User Initialization user port bits
			uport	f0				; //
			uport	f1				; //
			uport	f2				; //
			uport	f3				; //
			// here more uport from 4 to B
			uport	fC				; //
			uport	fD				; //
			uport	fE				; //
			uport	fF				; //
									 
    //////////////////////////////////////////////////////////////////////
	// Main Loop
    //////////////////////////////////////////////////////////////////////

main_loop:	uport	t0				; // trigger signal for scope
			uport	f0				; // clears port bit 0
			
			jsr		test_name		;
			
			nop						; 
			stop					; 
			jmp   main_loop			; 
			 			
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Application routines
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	
test_name:  rts						;

	////////////////////////////////////////////////////////////
	// Interrupt vectors
	////////////////////////////////////////////////////////////
hw_irq1:	uport	t8				; // used to trigger scope
			uport	f8				;
			rti						;
                                	
hw_irq2:	uport	t9				; // used to trigger scope
			uport	f9				;
			rti						;
			
hw_irq3:	rti						;
			  
hw_irq4:	rti						;

	// SWI #1
sw_irq1:	rti						;  

   //////////////////////////////////////////////////////////////////////
   // Data Section
   //////////////////////////////////////////////////////////////////////
   
				
   //////////////////////////////////////////////////////////////////////
   // System Constants and Menu Messages
   //////////////////////////////////////////////////////////////////////
			
         
   //////////////////////////////////////////////////////////////////////
   // Application Constants
   //////////////////////////////////////////////////////////////////////
         
zend_code:	// mark the end of code
			dw	zend_code;
         
   //////////////////////////////////////////////////////////////////////
   // Work Area, Stack Area, Writable RAM
   //////////////////////////////////////////////////////////////////////

   //////////////////////////////////////////////////////////////////////
   // Application Variables
   //////////////////////////////////////////////////////////////////////
   
   // Temporary storage
temp:	ds	10		; // reserve 10 word places, temporary scratch pad.
temp1:	dw	1		; // Decimal constants 
temp2:	dw	2		; 
temp3:	dw	'0'		; // ASCII constant 
temp4:	dw	'1'		; 
temp5:	dw	'2'		; 
temp6:	dw	'3'		; 
temp7:	dw	'4'		; 
temp8:	dw	'h000d	; // Hexadecimal constants

   //////////////////////////////////////////////////////////////////////
   // Stack area
   //////////////////////////////////////////////////////////////////////
stack:	ds	STACK_LENGTH    	; // stack area

zend_ram:	// mark the end of writable RAM area
   
/////////////////// End of File //////////////////////////
