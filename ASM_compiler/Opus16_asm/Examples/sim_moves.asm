   // PROG_MOVES.ASM :  Test program move and load intructions.
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
   // R3 register 3 -> user limited   'R3'
   // Rn register n -> user register  'Rn' n=0...F
   //
@'h0000
         jmp   main             ;
   
@'h0050
main:		ldrv  r0,'hFFFF	;
			ldrv  r1,'h1234	;
			ldrv  r2,'h5678	;
			ldrv  r3,'h9ABC 	;
			ldrv  r4,'h55AA	;
			ldrv  r5,'h33CC	;
			ldrv  r6,'h1122	;
			ldrv  r7,'h3344	;
			ldrv  r8,'h0000	;
			ldrv  r9,'h0000	;
			ldrv  rA,'h0000	;
			ldrv  rB,'h0000	;
			ldrv  rC,'h0000	;
			ldrv  rD,'h0000	;
			ldrv  rE,'h0000	;
			ldrv  rF,'h0000	;
			
			mvrr  r0,r8            ; 
			mvrr  r1,r9            ; 
			mvrr  r2,rA            ; 
			mvrr  r3,rB            ; 
			mvrr  r4,rC            ; 
			mvrr  r5,rD            ; 
			mvrr  r6,rE            ; 
			mvrr  r7,rF            ; 

			ldrv  r1,'h1111	;
			ldrv  r2,'h2222	;
			ldrv  r3,'h3333 	;
			ldrv  r4,'h4444	;
			ldrv  r5,'h5555	;
			ldrv  r6,'h6666	;
			ldrv  r7,'h7777	;
			ldrv  r8,'h8888	;
			ldrv  r9,'h9999	;
			ldrv  rA,'hAAAA	;
			ldrv  rB,'hBBBB	;
			ldrv  rC,'hCCCC	;
			ldrv  rD,'hDDDD	;
			ldrv  rE,'hEEEE	;
			ldrv  rF,'hFFFF	;
			
			mvrp  r1,p1    	;
			mvrp  r2,p2     	;
			mvrp  r3,p3     	;
			mvrp  r4,p4     	;
			mvrp  r5,p5     	;
			mvrp  r6,p6     	;
			mvrp  r7,p7    	;
			
			mvpp  r1,p8    	;
			mvpp  r2,p9     	;
			mvpp  r3,pA    	;
			mvpp  r4,pB     	;
			mvpp  r5,pC    	;
			mvpp  r6,pD     	;
			mvpp  r7,pE     	;
			mvpp  r8,pF     	;
			
			mvpr  p1,r8    	;
			mvpr  p2,r9     	;
			mvpr  p3,rA    	;
			mvpr  p4,rB     	;
			mvpr  p5,rC    	;
			mvpr  p6,rD     	;
			mvpr  p7,rE     	;
			mvpr  p8,rF     	;

			swap  r8,r1            ;
			swap  r9,r2            ;
			swap  rA,r3            ;
			swap  rB,r4            ;
			swap  rC,r5            ;
			swap  rD,r6            ;
			swap  rE,r7            ;
			swap  rF,r8            ;
			
			swapp r1,p8            ;
			swapp r2,p9            ;
			swapp r3,pa            ;
			swapp r4,pb            ;
			swapp r5,pc            ;
			swapp r6,pd            ;
			swapp r7,pe            ;
			swapp r8,pf            ;
   
end:		stop			; 
			jmp   end		; 

temp1:   dw    'h4321,'h5678,'h1122; 
temp2:   dw    'h8765,'h3344,'h5566; 
temp3:   dw    'hCBA9,'h7788,'h9900; 
temp4:   dw    'h0FED,'hab55,'hcd33; 
temp5:   dw    'h5555,'h1234,'habcd; 
temp6:   dw    'h6666,'h4123,'hdabc; 
temp7:   dw    'h7777,'h3412,'hcdab; 
temp8:   dw    'h8888,'h2341,'hbcda; 
   
stack:   ds    1                ; 
