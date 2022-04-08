   // PROG_LOADS.ASM :  Test program load group.
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
		ldpv	p2,temp2 	;
		ldrv	r1,0		;
		ldrv	r2,'h7fff	;
		ldcv 	c0,7		; // 8 loops
loop1:	inc		r1			;
     	inc		r2			;
     	strpi	r1,p1       ;
     	strpi	r2,p2		;
     	dcjnz	c0,loop1	;
     	
		ldpv	p1,temp1 	;
		ldpv	p2,temp2 	;
		ldpv	p3,temp3 	;
		ldpv	p4,temp4 	;
		ldcv 	c0,7		; // 8 loops
loop2:	ldrpi	r1,p1		;
     	ldrpi	r2,p2		;
     	strpi	r1,p3       ;
     	strpi	r2,p4       ;
     	dcjnz	c0,loop2	;
     	
// test on external memory LDMAM=2 (m2)    	
		ldpv	p1,temp1 	;
		ldpv	p2,temp2 	;
		ldpv	p3,temp3 	;
		ldpv	p4,temp4 	;
		ldmam	m2			; // store external, load internal
		ldcv 	c0,7		; // 8 loops
loop3:	ldrpi	r1,p1		;
     	ldrpi	r2,p2		;
     	strpi	r1,p3       ;
     	strpi	r2,p4       ;
     	dcjnz	c0,loop3	;
		ldmam	m0			; // store internal, load internal
     	

      	nop			; 
end:	stop			; 
	 	jmp   end		; 

temp1:	ds 32	;	 
temp2:	ds 32	;	 
temp3:	ds 32	;	 
temp4:	ds 32	;	 
  
stack:   ds    1                ; 
