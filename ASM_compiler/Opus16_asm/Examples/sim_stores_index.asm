   // PROG_STORES_INDEX.ASM :  Test program load group.
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

@'h0000
reset_v: jmp   main             ;
   
@'h0050	 // main starts at 0x050 to check the RESET Vector
main:	ldpv  pF,stack		; // Initialize stack pointer.

		ldpv	p1,temp1 	;
		ldrv	r1,0		;
		ldrv	r2,0		;
		ldcv 	c0,7		;
loop1:	inc		r1			;
		ldpag	r1			;
     	dec		r2			;
		ldpag	r2			;
     	incp	p1			;
     	incp	p1			;
     	strx	r1,p1,0     ;
     	jsr		sub1		;
     	dcjnz	c0,loop1	;
     	
		ldpv	p1,temp1 	;
		ldpv	p2,xtemp1 	;
		ldcv 	c0,7		;
loop2:	incp	p1			;
     	incp	p2			;
     	ldrx	r1,p1,0		;
     	jsr		sub2		;
		ldpag	r1			;
     	dcjnz	c0,loop2	;
     	
      	nop			; 
end:	stop			; 
	 	jmp   end		; 

	 	// subroutines
sub1:	strx	r2,p1,1     ;
     	rts					;
     		 	
sub2:	strx	r1,p2,4		;
		ldrx	r3,p2,4		;
     	rts					;
     		 	
// Internal RAM
temp1:	ds 32	;	 
temp2:	ds 32	;	 
temp3:	ds 32	;	 
temp4:	ds 32	;	 

   
// External RAM
xtemp1:	ds 32	;	 
xtemp2:	ds 32	;	 
xtemp3:	ds 32	;	 
xtemp4:	ds 32	;	 

stack:   ds    1                ; 
