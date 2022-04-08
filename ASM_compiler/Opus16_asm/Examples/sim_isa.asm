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
   
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		cli					; // disable interrupts
			ldpv	pF,stack	; // Initialize stack pointer.
			xor		r1			;
			xor		r2			;
			xor		r3			;
			xor		r4 			;
			xor		r7			;
			xor		r8			;
			xor		r9			;
			ldpv	p1,temp0	;
			ldpv	p2,temp5	;
			ldpv	p3,0		;
			ldpv	p4,temp0	;
			ldpv	p5,temp5	;
			ldpv	p6,0		;
			ldpv	p7,temp0	;
			ldpv	p8,temp5	;
			ldpv	p9,0		;
			ldpv	pa,0		;
			ldpv	pb,0		;
			ldpv	pc,xtemp0	;
			ldpv	pd,xtemp1	;
			ldpv	pe,jmpp_pb	;
			outp	r5,xtemp0	;
			outp	r5,xtemp1	;
			ldcv	c3,80		;
			sei;
main1:		nop					;
			// arithmetic and logic group
			add		r1,r2		;
			adc		r1,r2		;
			addv	r1,'h1234	;
			addrp	r1,p3		;
			sub		r3,r4		;
			sbb		r3,r4		;
			subv	r3,'h0001	;
			subrp	r3,p3		;
			not					;
			and		r1,r2		;
			andv	r1,'hffff	;
			or		r2,r1		;
			orv		r3,'h1010	;
			xor		r2,r1		;
			xorv	r3,'h1010	;
			inc		r1			;
			dec		r2			;
			cmpr	r1,r2		;
			cmprv	r3,'h0000	;
			cmprp	r1,p1		;
			shl		r1			;
			shl		l,r1		;
			shl		k,r2		;
			shl		r,r3		;
			shl		a,r4		;
			shr		ra			;
			shr		l,rb		;
			shr		k,rc		;
			shr		a,rd		;
			shr		r,re		;
			shl4	r3			;
			shr4	r3			;
			// move group
			mvrr	r1,r4		;
			mvrp	r2,p4		;
			mvpr	p4,r7		;
			mvpp	p4,p5		;
			swap	r3,r4		;
			swapp	r4,p3		;
			// load group
			ldcv	c0,3		;
			ldc		c1,r9		;
			ldr		r1,temp0	;
			ldrv	r2,'h0003	;
			ldrp	r3,p1		;
			ldrx	r4,p1,2		;
			ldrpi	r5,p1		;
			ldrpd	r6,p1		;
			ldmam	m0			;
			ldpagv	'haba		;
			ldpag	r6			;
			// store group
			str		r6,temp0	;
			strp	r1,p4		;
			strx	r2,p4,2		;
			strpi	r3,p5		;
			strpd	r2,p5		;
			// pointer group
			ldp		pa,tempa	;
			ldpv	pb,temp0	;
			ldrv	rb,2		;
			ldpy	pb,rb		;
			stp		pb,tempa	;
			incp	pa			;
			decp	pb			;
			// I/O group
			inp		r1,xtemp0	;
			inpp	r2,pc		;
			outp	r3,xtemp1	;
			outpp	r4,pd		;
			// control transfer
			bra		main21		;
main2:		dcjz	c0,main2	;
main3:		dcjnz	c1,main3	;
			jmp		main41		;
main4:		jmp		f1,main51	;						
main5:		jmpp	pe			;
main6:		jsr		subr1		;
			uflag	t2			;
			uport	t3			;
			bit		r1,r2		;
			bitv	r3,'h0011	;
			swi		swia		;
			dcjnz	c3,main1	;
endmain:	cli					;			
			
endprog:	ldpagv	'hb0b0		; // address page = 1111
			stop				;
			jmp		endprog		; // test again.
         
enddead:	ldpagv	'hdead		; // address page = 1111
			stop				;
			jmp		enddead		; // test again.
         
main21:		jmp		main2		;
main41:		bra		main4		;
main51:		bra		main5		;
jmpp_pb:	jmp		main6		;

subr1:		rts					;
		
irq1:		inc		rc			;
			rti;
			
irq2:		inc		rd			;
			rti;
			
irq3:		inc		re			;
			rti;
			
irq4:		inc		rf			;
			rti;
			
swia:		rti;


// Internal RAM
@'h0300
temp0:	dw 'h1234;
temp1:	dw 'h1111;
temp2:	dw 'h2222;
temp3:	dw 'h3333;	 
temp4:	dw 'h4444;
temp5:	dw 'h5555;
temp6:	dw 'h6666;
temp7:	dw 'h7777;
temp8:	dw 'h8888;	 
temp9:	dw 'h9999;
tempa:	dw temp0;

swiacnt:	dw	0	;
int1cnt:	dw	0	;
int2cnt:	dw	0	;
int3cnt:	dw	0	;
int4cnt:	dw	0	;

// External RAM
xtemp0:	dw 0       	;	 
xtemp1:	dw 0       	;	 
xtemp2:	dw 0       	;	 
xtemp3:	dw 0       	;	 
xtemp4:	dw 0       	;	 
stemp0:	ds RAM_SIZE	;	 
stemp1:	ds RAM_SIZE	;	 

stack:	ds STACK_SIZE; 
