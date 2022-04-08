   // PROG_BIT_TEST.ASM :  Test program 
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification =
   //
   // Register and Pointer definitions
   // P0 pointer 0  -> program counter 'PC' not accesible
   // P1 pointer 1  -> user pointer    'P1'
   // P2 pointer 2  -> user pointer    'P2'
   // Pn pointer n -> user pointer    'Pn' n=0...F
   // PF pointer 15 -> stack pointer   'SP' can be used in some conditions
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user limited   'R3'
   // Rn register n -> user register  'Rn' n=0...F
   // RF register 15 -> user limited  'RF'
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
define	STACK_SIZE	10
define	RAM_SIZE	32
define	VALUE1	'h0055
define	VALUE2	'h1234

@RESET_ENTRY
reset_v: jmp   main			;
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		ldpv	pF,stack	; // Initialize stack pointer.
        	
			ldpagv	'h5511		;
			
			xor		r2,r2		;
			ldpv	p4,ptable	;
			ldpy	p4,r2		; // works
			ldrp	r3,p4		;
			ldpag	r3			;
			
			ldpagv	'h5522		;
			inc		r2			;
			ldpv	p4,ptable	;
			ldpy	p4,r2		; // works
			ldrp	r3,p4		;
			ldpag	r3			;
			
			ldpagv	'h5533		;
			inc		r2			;
			ldpv	p4,ptable	;
			ldpy	p4,r2		; // works
			ldrp	r3,p4		;
			ldpag	r3			;
			
			ldpagv	'h5544		;
			inc		r2			;
			ldpv	p4,ptable	;
			ldpy	p4,r2		; // works
			ldrp	r3,p4		;
			ldpag	r3			;
			
			ldpagv	'h5555		;
			xor		r2,r2		;
			ldcv	c0,3		;
loop1:		ldpv	p4,ptable	;
			ldpy	p4,r2		;
			ldrp	r3,p4		;
			ldpag	r3			;
			inc		r2			;
			dcjnz	c0,loop1	;
			
			// check btable
			ldmam	m2			; // load from internal RAM
			ldpv	p1,btable	; // strore to external RAM
			ldrx	r1,p1,1		;
			str		r1,xtemp1	;
			ldrx	r1,p1,2		;
			str		r1,xtemp1	;
			ldrx	r1,p1,3		;
			str		r1,xtemp1	;
			ldrx	r1,p1,4		;
			str		r1,xtemp1	;
			ldmam	m0			;
		
			// Move Group with LDPY and JMPP
jmpp0:		ldpagv	'h7711		;
  			ldpv	p1,btable	;
  			ldrv	r1,1		;
 			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp1:		ldpagv	'h7722		;
  			ldpv	p1,btable	;
  			ldrv	r1,2		;
  			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp2:		ldpagv	'h7733		;
  			ldpv	p1,btable	;
  			ldrv	r1,3		;
  			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp3:		ldpagv	'h7744		;
  			ldpv	p1,btable	;
  			ldrv	r1,4		;
  			ldpy	p1,r1		;
  			jmpp	p1			;
  			ldpagv	'hbeef		;
  			
jmpp4:		ldpagv	'h7755		;

check_ldrpi:
			ldpv	p2,temp2	;
			xor		r7,r7		;
			ldrx	r5,p2,3		;
			ldrpd	r7,p2		;
			jsr		beback1		;
			ldpag	r7			;
			ldpv	p2,temp3	;
			ldrpi	r6,p2		;
			jsr		beback1		;
			ldpag	r6			;
			jmp		check_strpi	;

beback1:	rts					;
		
check_strpi:
			ldpv	p2,temp4	;
			ldrv	r8,'hbaba	;
			strx	r8,p2,4		;
			strpd	r8,p2		;
			jsr		beback2		;
			ldpagv	1			;
			ldpv	p2,temp3	;
			strpi	r8,p2		;
			jsr		beback2		;
			ldpagv	2			;
			jmp		check_moves			;

beback2:	rts					;
		
check_moves:
			// Move Group with JSR, add NOP before JSR
			ldpv	p4,'hcccc	;
			ldrv	r3,'h3333	;
  			mvrp	r3,p4		;
  			jsr		beback3		;
			ldpv	p5,'h55aa	;
			ldrv	r4,'h1234	;
			ldpagv	'ha015		;
  			mvpr	p5,r4		;
  			jsr		beback3		;
			ldpv	p4,'h33cc	;
			ldpv	p3,'h0c0b	;
			ldpagv	'ha016		;
  			mvpp	p3,p4		;
  			jsr		beback3		;
  			ldrv	r1,'h1111	;
  			ldpv	p2,'haaaa	;
  			swapp	r1,p2		;
  			jsr		beback3		;
  			ldpagv	'ha017		;
			jmp		end			;
  			
beback3:	rts					;
		
end:		stop				; 
	 		jmp   end			; 
	 	
		
// Internal RAM
@'h0200
temp1:	dw 'h1111;
temp2:	dw 'h2222;
temp3:	dw 'h3333;	 
temp4:	dw 'h4444;	 
temp5:	dw 'h1111;
temp6:	dw 'h2222;
temp7:	dw 'h3333;	 
temp8:	dw 'h4444;	 

ptable:	dw temp1;
   		dw temp2;
		dw temp3;
		dw temp4;
		
btable:	dw jmpp0;
		dw jmpp1;
		dw jmpp2;
		dw jmpp3;
		dw jmpp4;
				
		
// External RAM
xtemp1:	ds RAM_SIZE	;	 
xtemp2:	ds RAM_SIZE	;	 
xtemp3:	ds RAM_SIZE	;	 
xtemp4:	ds RAM_SIZE	;	 

stack:	ds STACK_SIZE; 
		dw stack;

		