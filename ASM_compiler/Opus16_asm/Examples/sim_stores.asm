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
   // RF register 15 -> user limited   'RF'
   //

@'h0000
reset_v: jmp   main             ;
   
@'h0050	 // main starts at 0x050 to check the RESET Vector
main:	ldpv	pF,stack		; // Initialize stack pointer.

		ldrv	r0,'hFFFF	;
		ldrv	r1,'h1234	;
		ldrv	r2,'h5678	;
		ldrv	r3,'h9ABC 	;
		ldrv	r4,'h55AA	;
		ldrv	r5,'h33CC	;
		ldrv	r6,'h1122	;
		ldrv	r7,'h3344	;
		ldrv	r8,'h5566	;
		ldrv	r9,'h7788	;
		ldrv	rA,'h99AA	;
		ldrv	rB,'hBBCC	;
		ldrv	rC,'hDDEE	;
		ldrv	rD,'hFF00	;
		ldrv	rE,'h00FF	;
		ldrv	rF,'h1324	;
		
		str		r0,temp1         ;
		str		r1,temp2         ;
		str		r2,temp3         ;
		str		r3,temp4         ;
		str		r4,temp5         ;
		str		r5,temp6         ;
		str		r6,temp7         ;
		str		r7,temp8         ;
		str		r8,temp1         ;
		str		r9,temp2         ;
		str		rA,temp3         ;
		str		rB,temp4         ;
		str		rC,temp5         ;
		str		rD,temp6         ;
		str		rE,temp7         ;
		str		rF,temp8         ;
		
		ldpv	p1,'h1234	;
		ldpv	p2,'h5678	;
		ldpv	p3,'h9ABC 	;
		ldpv	p4,'h55AA	;
		ldpv	p5,'h33CC	;
		ldpv	p6,'h1122	;
		ldpv	p7,'h3344	;
		ldpv	p8,'h5566	;
		ldpv	p9,'h7788	;
		ldpv	pA,'h99AA	;
		ldpv	pB,'hBBCC	;
		ldpv	pC,'hDDEE	;
		ldpv	pD,'hFF00	;
		ldpv	pE,'h00FF	;
		ldpv	pF,'h1324	;
		
		stp		p1,temp82        ;
		stp		p2,temp83        ;
		stp		p3,temp84        ;
		stp		p4,temp85        ;
		stp		p5,temp86        ;
		stp		p6,temp87        ;
		stp		p7,temp88        ;
		stp		p8,temp91        ;
		stp		p9,temp92        ;
		stp		pA,temp93        ;
		stp		pB,temp94        ;
		stp		pC,temp95        ;
		stp		pD,temp96        ;
		stp		pE,temp97        ;
		stp		pF,temp98        ;
		
		ldpv	p1,temp80	;
		ldpv	p3,temp84	;
		ldpv	p6,temp90	;
		ldpv	p8,temp94	;
		    	
		strp	r1,p1            ;
		strp	r2,p3            ;
		strp	r3,p6            ;
		strp	r4,p8            ;
		strp	r5,p1            ;
		strp	r6,p3            ;
		strp	r7,p6            ;
		strp	r8,p8            ;
		strp	r9,p1            ;
		strp	rA,p3            ;
		strp	rB,p6            ;
		strp	rC,p8            ;
		strp	rD,p1            ;
		strp	rE,p3            ;
		strp	rF,p6            ;
		strp	r0,p8            ;
		    	
		ldpv	p1,temp1 	;
		ldpv	p5,temp2 	;
		ldpv	pA,temp3 	;
		ldpv	pF,temp4 	;
		     	
		strpi	r1,p1            ;
		strpi	r2,p5            ;
		strpi	r3,pA            ;
		strpi	r4,pF            ;
		strpi	r1,p1            ;
		strpi	r2,p5            ;
		strpi	r3,pA            ;
		strpi	r4,pF            ;
		strpi	r1,p1            ;
		strpi	r2,p5            ;
		strpi	r3,pA            ;
		strpi	r4,pF            ;
		     	
		strpd	r5,p1            ;
		strpd	r6,p5            ;
		strpd	r7,pA            ;
		strpd	r8,pF            ;
		strpd	r5,p1            ;
		strpd	r6,p5            ;
		strpd	r7,pA            ;
		strpd	r8,pF            ;
		strpd	r5,p1            ;
		strpd	r6,p5            ;
		strpd	r7,pA            ;
		strpd	r8,pF            ;
		
		ldpv	p3,temp8         ;
		strx	r9,p3,2          ;
		ldpv	p7,temp1         ;
		strx	rA,p7,6          ;
		ldpv	p9,temp5         ;
		strx	r3,p9,3          ;
		ldpv	pB,temp7         ;
		strx	r9,pB,0          ;
		
		ldrv	r1,'h1234		;
		str		r1,testpcode	;
		
		nop						; 
end:	stop					; 
		jmp		end				;
		
testpcode:
		dw		0;
				 
z_endcode:
		dw		z_endcode		;

temp1:   dw    'h4321,'h5678,'h1122; 
temp2:   dw    'h8765,'h3344,'h5566; 
temp3:   dw    'hCBA9,'h7788,'h9900; 
temp4:   dw    'h0FED,'hab55,'hcd33; 
temp5:   dw    'h5555,'h1234,'habcd; 
temp6:   dw    'h6666,'h4123,'hdabc; 
temp7:   dw    'h7777,'h3412,'hcdab; 
temp8:   dw    'h8888,'h2341,'hbcda; 

temp80:  dw    1                ;
temp81:  dw    1                ;
temp82:  dw    1                ;
temp83:  dw    1                ;
temp84:  dw    1                ;
temp85:  dw    1                ;
temp86:  dw    1                ;
temp87:  dw    1                ;
temp88:  dw    1                ;
temp89:  dw    1                ;
temp90:  dw    1                ;
temp91:  dw    1                ;
temp92:  dw    1                ;
temp93:  dw    1                ;
temp94:  dw    1                ;
temp95:  dw    1                ;
temp96:  dw    1                ;
temp97:  dw    1                ;
temp98:  dw    1                ;
temp99:  dw    1                ;
   
stack:   ds    10               ;

z_endram:
		dw		z_endram		;
		 
