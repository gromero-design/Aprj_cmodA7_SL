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
			ldcv	c0,80		;
			xor		r1			;
			xor		r2			;
			xor		r3			;
			xor		r4			;
			xor		r5,r5		;
			xor		r6,r6		;
			xor		r7,r7		;
			xor		r8,r8		;
			sei;
main1:		uflag	t0			;
			uflag	f0			;
			ldrv	r5,'h101	;
			ldpag	r5			;
			cmprv	r5,'h101	;
			bra		z,main11	;
			jmp		enddead		;
main11:		jsr		sub1		;
			inc		r5			;
			cmprv	r5,'h102	;
			bra		z,main12	;
			jmp		enddead		;
main12:		jsr		sub2		;
			inc		r5			;
			cmprv	r5,'h103	;
			bra		z,main13	;
			jmp		enddead		;
main13:		jsr		sub3		;
			inc		r5			;
			cmprv	r5,'h104	;
			bra		z,main14	;
			jmp		enddead		;
main14:		jsr		sub4		;
			inc		r5			;
			bra		nz,main2	;
			jmp		enddead		;
main2:		ldmam	m2			;
			ldr		r6,int1cnt	;
			str		r6,xtemp1	;
			ldr		r6,int2cnt	;
			str		r6,xtemp2	;
			ldr		r6,int3cnt	;
			str		r6,xtemp3	;
			ldr		r6,int4cnt	;
			str		r6,xtemp4	;
			ldr		r6,swiacnt	;
			str		r6,xtemp0	;
			ldmam	m0			;
			inc		r7			;
			uflag	t1			;
			uflag	t1			;
			dcjnz	c0,main1	;
			
			cli					;			
			nop;
			ldmam	m2			;
			ldr		r6,int1cnt	;
			str		r6,xtemp1	;
			ldr		r6,int2cnt	;
			str		r6,xtemp2	;
			ldr		r6,int3cnt	;
			str		r6,xtemp3	;
			ldr		r6,int4cnt	;
			str		r6,xtemp4	;
			ldr		r6,swiacnt	;
			str		r6,xtemp0	;
			ldmam	m0			;
			
			
endprog:	ldpagv	'hb0b0		; // address page = 1111
			stop				;
			jmp		endprog		; // test again.
         
enddead:	ldpagv	'hdead		; // address page = 1111
			stop				;
			jmp		enddead		; // test again.
         
         
         
@'h0200
sub1:		ldpagv	'h5501		; // address page = 1111
			rts					;
sub2:		ldpagv	'h5502		; // address page = 1111
			rts					;
sub3:		ldpagv	'h5503		; // address page = 1111
			rts					;
sub4:		ldpagv	'h5504		; // address page = 1111
			rts					;
		
subi1:		ldpagv	'ha101		; // address page = 1111
			jsr		sub1		;
			rts					;
subi2:		ldpagv	'hb102		; // address page = 1111
			jsr		sub2		;
			rts					;
subi3:		ldpagv	'hc103		; // address page = 1111
			jsr		sub3		;
			rts					;
subi4:		ldpagv	'hd104		; // address page = 1111
			jsr		sub4		;
			rts					;
subi_i:		ldpagv	'haba0		; // address page = 1111
			jsr		sub1		;
			rts					;
		
irq1:		inc		r1			;
			ldr		rc,int1cnt	;
			inc		rc			;
			str		rc,int1cnt	;
			add		rb,rc		;
			ldpagv	'h1111		; // address page = 1111
			ldpag	rc			;
			jsr		subi1		;
			rti;
			
irq2:		inc		r2			;
			ldr		rc,int2cnt	;
			inc		rc			;
			str		rc,int2cnt	;
			sub		rb,rc		;
			ldpagv	'h2222		; // address page = 1111
			ldpag	rc			;
			jsr		subi2		;
			rti;
			
irq3:		inc		r3			;
			ldr		rc,int3cnt	;
			inc		rc			;
			str		rc,int3cnt	;
			ldrv	rb,0		;
			dec		rb			;
			ldpagv	'h3333		; // address page = 1111
			ldpag	rc			;
			jsr		subi3		;
			rti;
			
irq4:		inc		r4			;
			ldr		rc,int4cnt	;
			inc		rc			;
			str		rc,int4cnt	;
			ldrv	rb,'hffff	;
			inc		rb			;
			ldpagv	'h4444		;
			ldpag	rc			;
			jsr		subi4		;
			rti;
			
swia:		inc		r8			;
			ldr		rc,swiacnt	;
			inc		rc			;
			str		rc,swiacnt	;
			ldpagv	'hfe00	;
			jsr		subi_i		;
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
