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
swi_a:		jmp		swia			;// vector a default
   
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		cli					; // disable interrupts
			ldpv	pF,stack	; // Initialize stack pointer.
			ldpv	p1,temp1	;
			ldpv	p2,temp2	;
			sei;
			ldcv	c0,80		;
main1:		ldrv	r1,'h101	;
			ldpag	r1			;
			cmprv	r1,'h101	;
			bra		z,main11	;
			jmp		endprog		;
main11:		inc		r1			;
			cmprv	r1,'h102	;
			bra		z,main12	;
			jmp		endprog		;
main12:		inc		r1			;
			cmprv	r1,'h103	;
			bra		z,main13	;
			jmp		endprog		;
main13:		inc		r1			;
			cmprv	r1,'h104	;
			bra		z,main14	;
			jmp		endprog		;
main14:		inc		r1			;
			bra		nz,main2	;
			jmp		endprog		;
main2:		dcjnz	c0,main1	;
			
			cli					;			
			nop;
			
			ldmam	m2			;
			ldr		r1,int1cnt	;
			str		r1,xtemp1	;
			ldr		r1,int2cnt	;
			str		r1,xtemp2	;
			ldr		r1,int3cnt	;
			str		r1,xtemp3	;
			ldr		r1,int4cnt	;
			str		r1,xtemp4	;
			ldr		r1,swiacnt	;
			str		r1,xtemp0	;
			ldmam	m0			;
			
endprog:	nop					; 
			nop					; 
			stop				;
			nop					; 
			nop					; 
			jmp		endprog		; // test again.
         
         
@'h0200
sub1:		ldpagv	'h5501		; // address page = 1111
			rts					;
sub2:		ldpagv	'h5502		; // address page = 1111
			rts					;
sub3:		ldpagv	'h5503		; // address page = 1111
			rts					;
sub4:		ldpagv	'h5504		; // address page = 1111
			rts					;
		
irq1:		ldpagv	'h1111		; // address page = 1111
			ldr		rc,int1cnt	;
			inc		rc			;
			ldpag	rc			;
			str		rc,int1cnt	;
			rti;
			
irq2:		ldpagv	'h2222		; // address page = 1111
			ldr		rc,int2cnt	;
			inc		rc			;
			ldpag	rc			;
			str		rc,int2cnt	;
			rti;
			
irq3:		ldpagv	'h3333		; // address page = 1111
			ldr		rc,int3cnt	;
			inc		rc			;
			ldpag	rc			;
			str		rc,int3cnt	;
			rti;
			
irq4:		ldpagv	'h4444		;
			ldr		rc,int4cnt	;
			inc		rc			;
			ldpag	rc			;
			str		rc,int4cnt	;
			rti;
			
swia:		ldpagv	'haaaa		;
			ldr		rc,swiacnt	;
			inc		rc			;
			str		rc,swiacnt	;
			ldcv	c1,10		;
			ldrv	r3,'h100	;
swia_1:		ldpag	r3			;
			inc		r3			;
			dcjnz	c1,swia_1	;			
			rti;
			
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

ptable:	dw temp0;
   		dw temp1;
   		dw temp2;
		dw temp3;
		dw temp4;
		
// External RAM
xtemp0:	dw 0       	;	 
xtemp1:	dw 0       	;	 
xtemp2:	dw 0       	;	 
xtemp3:	dw 0       	;	 
xtemp4:	dw 0       	;	 
stemp0:	ds RAM_SIZE	;	 
stemp1:	ds RAM_SIZE	;	 

stack:	ds STACK_SIZE; 
