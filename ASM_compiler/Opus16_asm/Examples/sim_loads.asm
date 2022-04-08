   // PROG_LOADS.ASM :  Test program load group.
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification =
   //
   // Register and Pointer definitions
   // P0 pointer 0 -> program counter 'PC' not accesible
   // P1 pointer 1 -> user pointer    'P1'
   // P2 pointer 2 -> user pointer    'P2'
   // Pn pointer n -> user pointer    'Pn' n=0...F
   // PF pointer F -> stack pointer   'SP' can be used in some conditions
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user register  'R3'
   // Rn register n -> user register  'Rn' n=0...F
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
main:	ldpv  pF,stack		; // Initialize stack pointer.

		ldrv  r0,'hFFFF	;
		ldrv  r1,'h1234	;
		ldrv  r2,'h5678	;
		ldrv  r3,'h9ABC ;
		ldrv  r4,'h55AA	;
		ldrv  r5,'h33CC	;
		ldrv  r6,'h1122	;
		ldrv  r7,'h3344	;
		ldrv  r8,'h5566	;
		ldrv  r9,'h7788	;
		ldrv  rA,'h99AA	;
		ldrv  rB,'hBBCC	;
		ldrv  rC,'hDDEE	;
		ldrv  rD,'hFF00	;
		ldrv  rE,'h00FF	;
		ldrv  rF,'h1324	;
		
		ldpv  p0,'hFFFF	;
		ldpv  p1,'h1234	;
		ldpv  p2,'h5678	;
		ldpv  p3,'h9ABC ;
		ldpv  p4,'h55AA	;
		ldpv  p5,'h33CC	;
		ldpv  p6,'h1122	;
		ldpv  p7,'h3344	;
		ldpv  p8,'h5566	;
		ldpv  p9,'h7788	;
		ldpv  pA,'h99AA	;
		ldpv  pB,'hBBCC	;
		ldpv  pC,'hDDEE	;
		ldpv  pD,'hFF00	;
		ldpv  pE,'h00FF	;
		ldpv  pF,'h1324	;
		
		ldrv  r5,'hFFFF	;
		ldrv  r7,'h1234	;
		ldrv  rA,'h5678	;
		ldrv  rF,'h9ABC ;
		ldrv  r0,'h55AA	;
		ldrv  r4,'h33CC	;
		ldrv  r6,'h1122	;
		ldrv  r8,'h3344	;
		ldrv  rB,'h5566	;
		ldrv  r3,'h7788	;
		ldrv  rD,'h99AA	;
		ldrv  r1,'hBBCC	;
		ldrv  rE,'hDDEE	;
		ldrv  r9,'hFF00	;
		ldrv  rC,'h00FF	;
		ldrv  r2,'h1324	;
		
		ldpv  p5,'hFFFF	;
		ldpv  p7,'h1234	;
		ldpv  pA,'h5678	;
		ldpv  pF,'h9ABC ;
		ldpv  p0,'h55AA	;
		ldpv  p4,'h33CC	;
		ldpv  p6,'h1122	;
		ldpv  p8,'h3344	;
		ldpv  pB,'h5566	;
		ldpv  p3,'h7788	;
		ldpv  pD,'h99AA	;
		ldpv  p1,'hBBCC	;
		ldpv  pE,'hDDEE	;
		ldpv  p9,'hFF00	;
		ldpv  pC,'h00FF	;
		ldpv  p2,'h1324	;
    	
    	ldr   r1,temp1  ;
    	ldr   r2,temp2  ;
    	ldr   r3,temp3  ;
    	ldr   r4,temp4  ;
    	ldr   r5,temp1  ;
    	ldr   r6,temp2  ;
    	ldr   r7,temp3  ;
    	ldr   r8,temp4  ;
    	ldr   r9,temp1  ;
    	ldr   rA,temp2  ;
    	ldr   rB,temp3  ;
    	ldr   rC,temp4  ;
    	ldr   rD,temp1  ;
    	ldr   rE,temp2  ;
    	ldr   rF,temp3  ;
    	ldr   r0,temp4  ;
    	
    	ldp   p1,temp1  ;
    	ldp   p2,temp2  ;
    	ldp   p3,temp3  ;
    	ldp   p4,temp4  ;
    	ldp   p5,temp1  ;
    	ldp   p6,temp2  ;
    	ldp   p7,temp3  ;
    	ldp   p8,temp4  ;
    	ldp   p9,temp1  ;
    	ldp   pA,temp2  ;
    	ldp   pB,temp3  ;
    	ldp   pC,temp4  ;
    	ldp   pD,temp1  ;
    	ldp   pE,temp2  ;
    	ldp   pF,temp3  ;
    	ldp   p0,temp4  ;
   
		ldpv  pE,temp5	;
		ldpv  p9,temp6	;
		ldpv  pC,temp7	;
		ldpv  p2,temp8	;
		
		ldrp  r1,pE     ;
		ldrp  r2,p9     ;
		ldrp  r3,pC     ;
		ldrp  r4,p2     ;
		ldrp  r5,pE     ;
		ldrp  r6,p9     ;
		ldrp  r7,pC     ;
		ldrp  r8,p2     ;
		ldrp  r9,pE     ;
		ldrp  rA,p9     ;
		ldrp  rB,pC     ;
		ldrp  rC,p2     ;
		ldrp  rD,pE     ;
		ldrp  rE,p9     ;
		ldrp  rF,pC     ;
		ldrp  r0,p2     ;
   
		ldpv  p1,temp1 	;
		ldpv  p5,temp2 	;
		ldpv  pA,temp3 	;
		ldpv  pF,temp4 	;

		ldrpi r1,p1     ;
		ldrpi r2,p5     ;
		ldrpi r3,pA     ;
		ldrpi r4,pF     ;
		ldrpi r1,p1     ;
		ldrpi r2,p5     ;
		ldrpi r3,pA     ;
		ldrpi r4,pF     ;
		ldrpi r1,p1     ;
		ldrpi r2,p5     ;
		ldrpi r3,pA     ;
		ldrpi r4,pF     ;
		
		ldrpd r5,p1     ;
		ldrpd r6,p5     ;
		ldrpd r7,pA     ;
		ldrpd r8,pF     ;
		ldrpd r5,p1     ;
		ldrpd r6,p5     ;
		ldrpd r7,pA     ;
		ldrpd r8,pF     ;
		ldrpd r5,p1     ;
		ldrpd r6,p5     ;
		ldrpd r7,pA     ;
		ldrpd r8,pF     ;
		
		ldpv  p3,temp8  ;
		ldrx  r9,p3,2   ;
		ldpv  p7,temp1  ;
		ldrx  rA,p7,6   ;
		ldpv  p9,temp5  ;
		ldrx  r3,p9,3   ;
		ldpv  pB,temp7  ;
		ldrx  r9,pB,0   ;
		
		ldcv  c0,'h1029 ;
		ldcv  c1,'h2468 ;
		ldcv  c2,'h55aa ;
		ldcv  c3,'h7866 ;
   
		nop				; 
end:	stop			; 
		jmp		end		; 


temp1:	dw 'h4321,'h5678,'h1122; 
temp2:	dw 'h8765,'h3344,'h5566; 
temp3:	dw 'hCBA9,'h7788,'h9900; 
temp4:	dw 'h0FED,'hab55,'hcd33; 
temp5:	dw 'h5555,'h1234,'habcd; 
temp6:	dw 'h6666,'h4123,'hdabc; 
temp7:	dw 'h7777,'h3412,'hcdab; 
temp8:	dw 'h8888,'h2341,'hbcda; 
   
stack:	ds STACK_SIZE; 
