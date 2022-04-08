   // PROG_LOGIC.ASM :  Test program logical group.
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
main:		// AND,ANDV,NOT
			ldrv  r1,'hfffc	;
			ldrv  r2,'hfffd	;
			ldrv  r3,'hfffe	;
			ldrv  r4,'hffff	;
			ldrv  r5,'h0003	;
			ldrv  r6,'h0002	;
			ldrv  r7,'h0001	;
			ldrv  r8,'h0000	;
			ldrv  r9,'h9900	;
			ldrv  ra,'haa00	;
			ldrv  rb,'hbb00	;
			ldrv  rc,'hcc00	;
			ldrv  rd,'hdd00	;
			ldrv  re,'hee00	;
			ldrv  rf,'hff00	;
			ldrv  r0,'h0000	;
			
			// INC
			inc   r1               ; 
			inc   r1               ; 
			inc   r1               ; 
			inc   r1               ; 
			inc   r2               ; 
			inc   r2               ; 
			inc   r2               ; 
			inc   r2               ; 
			inc   r3               ; 
			inc   r3               ; 
			inc   r3               ; 
			inc   r3               ; 
			inc   r4               ; 
			inc   r4               ; 
			inc   r4               ; 
			inc   r4               ; 
			inc   r9               ; 
			inc   r9               ; 
			inc   r9               ; 
			inc   r9               ; 
			inc   ra               ; 
			inc   ra               ; 
			inc   ra               ; 
			inc   ra               ; 
			inc   rb               ; 
			inc   rb               ; 
			inc   rb               ; 
			inc   rb               ; 
			inc   rc               ; 
			inc   rc               ; 
			inc   rc               ; 
			inc   rc               ; 
			
			// DEC
			dec   r1               ; 
			dec   r1               ; 
			dec   r1               ; 
			dec   r1               ; 
			dec   r2               ; 
			dec   r2               ; 
			dec   r2               ; 
			dec   r2               ; 
			dec   r3               ; 
			dec   r3               ; 
			dec   r3               ; 
			dec   r3               ; 
			dec   r4               ; 
			dec   r4               ; 
			dec   r4               ; 
			dec   r4               ; 
			dec   r5               ; 
			dec   r5               ; 
			dec   r5               ; 
			dec   r5               ; 
			dec   r6               ; 
			dec   r6               ; 
			dec   r6               ; 
			dec   r6               ; 
			dec   r7               ; 
			dec   r7               ; 
			dec   r7               ; 
			dec   r7               ; 
			dec   r8               ; 
			dec   r8               ; 
			dec   r8               ; 
			dec   r8               ; 
			
			ldpv  p1,'h1100	;
			ldpv  p2,'h2200	;
			ldpv  p3,'h3300	;
			ldpv  p4,'h4400	;
			ldpv  p5,'h5500	;
			ldpv  p6,'h6600	;
			ldpv  p7,'h7700	;
			ldpv  p8,'h8800	;
			ldpv  p9,'h9900	;
			ldpv  pa,'haa00	;
			ldpv  pb,'hbb00	;
			ldpv  pc,'hcc00	;
			ldpv  pd,'hdd00	;
			ldpv  pe,'hee00	;
			ldpv  pf,'hff00	;
			
			    // INCP
			incp  p1               ; 
			incp  p1               ; 
			incp  p1               ; 
			incp  p1               ; 
			incp  p2               ; 
			incp  p2               ; 
			incp  p2               ; 
			incp  p2               ; 
			incp  p3               ; 
			incp  p3               ; 
			incp  p3               ; 
			incp  p3               ; 
			incp  p3               ; 
			incp  p4               ; 
			incp  p4               ; 
			incp  p4               ; 
			incp  p4               ; 
			incp  p9               ; 
			incp  p9               ; 
			incp  p9               ; 
			incp  p9               ; 
			incp  pa               ; 
			incp  pa               ; 
			incp  pa               ; 
			incp  pa               ; 
			incp  pb               ; 
			incp  pb               ; 
			incp  pb               ; 
			incp  pb               ; 
			incp  pc               ; 
			incp  pc               ; 
			incp  pc               ; 
			incp  pc               ; 
			
			// DECP
			decp  p5               ; 
			decp  p5               ; 
			decp  p5               ; 
			decp  p5               ; 
			decp  p6               ; 
			decp  p6               ; 
			decp  p6               ; 
			decp  p6               ; 
			decp  p7               ; 
			decp  p7               ; 
			decp  p7               ; 
			decp  p7               ; 
			decp  p7               ; 
			decp  p8               ; 
			decp  p8               ; 
			decp  p8               ; 
			decp  p8               ; 
			decp  pd               ; 
			decp  pd               ; 
			decp  pd               ; 
			decp  pd               ; 
			decp  pe               ; 
			decp  pe               ; 
			decp  pe               ; 
			decp  pe               ; 
			decp  pf               ; 
			decp  pf               ; 
			decp  pf               ; 
			decp  pf               ; 
			decp  p1               ; 
			decp  p1               ; 
			decp  p1               ; 
			decp  p1               ; 
   
end:		nop			; 
			stop			; 
			jmp   end		; 

       
   // Temporary storage
@'h100
temp:	 ds    10		; 

@'hF00
temp1:	 dw    1		; 
temp2:	 dw    1		; 
temp3:	 dw    1		; 
temp4:	 ds    1 		;
