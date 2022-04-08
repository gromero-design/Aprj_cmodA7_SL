// check ldpy (load pointer indexed with register)
// same as the sequence in here



   // PROG_POINTERS.ASM :  Test program jump group.
   //
   // Behavioral Simulation = ?
   // Gate Level Simulation = ?
   // Hardware Verification =
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
define	RAM_SIZE	16


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
main0:		ldrv	r1,'h0000		; // Clear all
			mvrr	r1,r2			;
			uport	t2				;
main1:		uport	t3				;
			ldpv	p3,ptable		; // patterns table
			addrp 	r1,p3			;
			mvrp	r1,p3			;
			ldpag	r1				;
			ldrp	r1,p3			;
			mvrp	r1,p3			;
			inc		r2				;
			mvrr	r2,r1			;
			jmpp	p3				; // go to task #

main2:		ldrv	r1,'h0000		; // Clear all
			mvrr	r1,r2			;
main3:		uport	t3				;
			ldpv	p3,ptable2		; // patterns table
			ldpy	p3,r1			;
			mvpr	p3,r3			;
			ldpag	r3				;
			inc		r2				;
			mvrr	r2,r1			;
			jmpp	p3				; // go to task #

pattern0:	ldpagv	'h8800			;// trap
			stp 	p3,temp0 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern1:	ldpagv	'h8801			;// trap
			stp 	p3,temp1 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern2:	ldpagv	'h8802			;// trap
			stp 	p3,temp2 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern3:	ldpagv	'h8803			;// trap
			stp 	p3,temp3 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern4:	ldpagv	'h8804			;// trap
			stp 	p3,temp4 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern5:	ldpagv	'h8805			;// trap
			stp 	p3,temp5 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern6:	ldpagv	'h8806			;// trap
			stp 	p3,temp6 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern7:	ldpagv	'h8807			;// trap
			stp 	p3,temp7 		; // store pointer in temp
			uport	f3				; 
			jmp		main1			;
pattern8:	ldpagv	'h8888			;// trap
//			jmp		stop			;
			jmp		main2			; // use ldpy	
			
pattern9:	ldpagv	'h9900			;// trap
			stp 	p3,temp0 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern10:	ldpagv	'h9901			;// trap
			stp 	p3,temp1 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern11:	ldpagv	'h9902			;// trap
			stp 	p3,temp2 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern12:	ldpagv	'h9903			;// trap
			stp 	p3,temp3 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern13:	ldpagv	'h9904			;// trap
			stp 	p3,temp4 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern14:	ldpagv	'h9905			;// trap
			stp 	p3,temp5 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern15:	ldpagv	'h9906			;// trap
			stp 	p3,temp6 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern16:	ldpagv	'h9907			;// trap
			stp 	p3,temp7 		; // store pointer in temp
			uport	f3				; 
			jmp		main3			;
pattern17:	ldpagv	'h9999			;// trap
			uport	f2				;
			jmp		stop			;
				
			// stop running
stop:	 	stop			; 
	 		bra   stop		; // end of program
   
irq1:		ldpagv	'h1111		; // address page = 1111
			rti;
			
irq2:		ldpagv	'h2222		; // address page = 1111
			rti;
			
irq3:		ldpagv	'h3333		; // address page = 1111
			rti;
			
irq4:		ldpagv	'h4444		;
			rti;
			
swia:		ldpagv	'hf001		;// trap
			stop				;
			rti					;// default swi
			
			// Temporary storage
@'h0800
temp0:		dw 0			; 
temp1:		dw 0			; 
temp2:		dw 0			; 
temp3:		dw 0			; 
temp4:		dw 0			;
temp5:		dw 0			; 
temp6:		dw 0			; 
temp7:		dw 0			; 

tempa:		ds RAM_SIZE 	;
tempb:		ds RAM_SIZE     ;
tempc:		dw tempa        ; 

pjump:		dw pattern0				; // pattern table offset
ptable:		dw pattern0		;
			dw pattern1		;
			dw pattern2		;
			dw pattern3		;
			dw pattern4		;
			dw pattern5		;
			dw pattern6		;
			dw pattern7		;
			dw pattern8		;
ptable2:	dw pattern9		;
			dw pattern10	;
			dw pattern11	;
			dw pattern12	;
			dw pattern13	;
			dw pattern14	;
			dw pattern15	;
			dw pattern16	;
			dw pattern17	;
               
stack:		ds STACK_SIZE	;
