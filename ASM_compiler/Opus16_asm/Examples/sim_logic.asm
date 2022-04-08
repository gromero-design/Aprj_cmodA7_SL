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
			ldrv  r1,'h0001	;
			ldrv  r2,'h0002	;
			ldrv  r3,'h0004	;
			ldrv  r4,'h0008	;
			ldrv  r5,'h0010	;
			ldrv  r6,'h0020	;
			ldrv  r7,'h0040	;
			ldrv  r8,'h0080	;

			// OR
			orv   r9,'hffff     	;
			or    ra,r9            ;
			or    rb,r9            ;
			or    rc,r9            ;
			or    rd,r9            ;
			or    re,r9            ;
			or    rf,r9            ;
			
			// AND
			and   r9,r1            ;
			and   ra,r2            ;
			and   rb,r3            ;
			and   rc,r4            ;
			and   rd,r5            ;
			and   re,r6            ;
			and   rf,r7            ;
			
			// ORV
			orv   r1,'h1100        ;
			orv   r2,'h2200        ;
			orv   r3,'h3300        ;
			orv   r4,'h4400        ;
			orv   r5,'h5500        ;
			orv   r6,'h6600        ;
			orv   r7,'h7700        ;
			
			// NOT
			not   r9,r1            ;
			not   ra,r2            ;
			not   rb,r3            ;
			not   rc,r4            ;
			not   rd,r5            ;
			not   re,r6            ;
			not   rf,r7            ;
			
			not   r9               ;
			not   ra               ;
			not   rb               ;
			not   rc               ;
			not   rd               ;
			not   re               ;
			not   rf               ;  
			
			// ANDV
			andv   r1,'h110f        ;
			andv   r2,'h220f        ;
			andv   r3,'h330f        ;
			andv   r4,'h440f        ;
			andv   r5,'h550f        ;
			andv   r6,'h660f        ;
			andv   r7,'h770f        ;
			andv   r8,'h110f        ;
			andv   r9,'h220f        ;
			andv   ra,'h330f        ;
			andv   rb,'h440f        ;
			andv   rc,'h550f        ;
			andv   rd,'h660f        ;
			andv   re,'h770f        ;
			andv   rf,'h0ff0        ;
			
			// XORV
			xorv   r1,'hff00        ;
			xorv   r2,'hff00        ;
			xorv   r3,'h00ff        ;
			xorv   r4,'h00ff        ;
			xorv   r5,'h55aa        ;
			xorv   r6,'h55aa        ;
			xorv   r7,'haa55        ;
			xorv   r8,'haa55        ;
			xorv   r9,'h33cc        ;
			xorv   ra,'h33cc        ;
			xorv   rb,'hcc33        ;
			xorv   rc,'hcc33        ;
			xorv   rd,'hf0f0        ;
			xorv   re,'h0f0f        ;
			xorv   rf,'h0ff0        ;
			
			// XOR
			xor    r1,r9        ;
			xor    r2,ra        ;
			xor    r3,rb        ;
			xor    r4,rc        ;
			xor    r5,rd        ;
			xor    r6,re        ;
			xor    r7,rf        ;
			xor    r8,r0        ;
   
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
