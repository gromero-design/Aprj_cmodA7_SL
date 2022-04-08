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
define   IRW 0 // internal read , internal write. m0  
define   XRD 1 // external read , internal write. m1 
define   XWR 2 // internal read , external write. m2 
define   XRW 3 // external read , external write. m3 
   
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
			ldpv	p1,colorseg		;
			ldrv	r2,50			; 
			ldrv	rc,'hffff		;// counter 
			str		r2,numpixels	; 
			ldrv	r1,1			; 
loop1:		str		r1,colorcnt		; 
			jsr		computeseg		;
			inc		r1				;
			cmpr	r1,r2			; // cmpr
			bra		nz,loop1		; // nz ok
			
continue:	nop						;			
			ldpv	p1,colorseg		;
			ldrv	r1,0			; 
loop2:		ldpag	r1				;
			ldrpi	r2,p1			;
			str		r2,temp0		;
			ldpag	r2				;
			inc		r1				;
			cmprv	r1,50			; // cmprv
			bra		nz,loop2		; // nz OK

stop:		stop					; 
			bra		stop			;
		 
// subroutine under test
computeseg:	ldr		r4,colorcnt		;
			ldr		r5,numpixels	;
			xor		r6,r6			; // number of segments
compute1:	sub		r5,r4			;
			bra		s,computend		;
			inc		r6				;
			bra		compute1		;
			
computend:	inc		rc				;
			ldpag	rc				;
			mvrr	rc,rb			;
			andv	rb,'h7			;
			cmprv	rb,0			;
			bra		z,computend0	;
			cmprv	rb,1			;
			bra		z,computend1	;
			cmprv	rb,2			;
			bra		z,computend2	;
			cmprv	rb,3			;
			bra		z,computend3	;
			cmprv	rb,4			;
			bra		z,computend4	;
			cmprv	rb,5			;
			bra		z,computend5	;
			cmprv	rb,6			;
			bra		z,computend6	;
			cmprv	rb,7			;
			bra		z,computend7	;
			
computend0:	ldrp 	r7,p1			;
			rts						;									
computend1:	ldrpi	r7,p1			;
			rts						;									
computend2:	ldrpd	r7,p1			;
			rts						;									
computend3:	strp 	r6,p1			;
			rts						;									
computend4:	strpi	r6,p1			;
			rts						;									
computend5:	strpd	r6,p1			;
			rts						;									
computend6:	strx	r6,p1,1			;
			rts						;									
computend7:	ldrx	r7,p1,2			;
			rts						;									
									
   // Temporary storage
@'ha00
colorcnt:	dw 0					;
numpixels:	dw 0					;
temp0:		dw	0					; 
			ds RAM_SIZE				; 
colorseg:	ds RAM_SIZE				; 

   // Stack memory
stack:		ds STACK_SIZE	;
