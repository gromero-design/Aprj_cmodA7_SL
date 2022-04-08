   // PROG_SHIFTS.ASM :  Test program shift group.
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

   

define   shifts 4
define   count  8
   
@'h0
reset_v: jmp   main             ; 

@'h50    // main starts at 0x050 to check the RESET Vector
main:		ldrv  r1,1             ;
shiftl_1:	shl   l,r1             ;//2
			str   r1,temp1          ; 
			shl   l,r1             ;//4
			str   r1,temp1          ; 
			shl   l,r1             ;//8
			str   r1,temp1          ; 
			shl   l,r1             ;//10
			str   r1,temp1          ; 
			shl   l,r1             ;//20
			str   r1,temp1          ; 
			shl   l,r1             ;//40
			str   r1,temp1          ; 
			shl   l,r1             ;//80
			str   r1,temp1          ; 
			shl   l,r1             ;//100
			str   r1,temp1          ; 
			shl   l,r1             ;//200
			str   r1,temp1          ; 
			shl   l,r1             ;//400
			str   r1,temp1          ; 
			shl   l,r1             ;//800
			str   r1,temp1          ; 
			shl   l,r1             ;//1000
			str   r1,temp1          ; 
			shl   l,r1             ;//2000
			str   r1,temp1          ; 
			shl   l,r1             ;//4000
			str   r1,temp1          ; 
			shl   l,r1             ;//8000
			str   r1,temp1          ; 
			shl   l,r1             ;//0000
			str   r1,temp1          ; 
			
			ldrv  rB,'h8000        ; 
shiftr_2:	shr   l,rB             ;//2
			str   rB,temp2          ; 
			shr   l,rB             ;//4
			str   rB,temp2          ; 
			shr   l,rB             ;//8
			str   rB,temp2          ; 
			shr   l,rB             ;//10
			str   rB,temp2          ; 
			shr   l,rB             ;//20
			str   rB,temp2          ; 
			shr   l,rB             ;//40
			str   rB,temp2          ; 
			shr   l,rB             ;//80
			str   rB,temp2          ; 
			shr   l,rB             ;//100
			str   rB,temp2          ; 
			shr   l,rB             ;//200
			str   rB,temp2          ; 
			shr   l,rB             ;//400
			str   rB,temp2          ; 
			shr   l,rB             ;//800
			str   rB,temp2          ; 
			shr   l,rB             ;//1000
			str   rB,temp2          ; 
			shr   l,rB             ;//2000
			str   rB,temp2          ; 
			shr   l,rB             ;//4000
			str   rB,temp2          ; 
			shr   l,rB             ;//8000
			str   rB,temp2          ; 
			shr   l,rB             ;//0000
			str   rB,temp2          ; 
			
			ldrv  r9,'h8000        ; 
shift4r_3:	shr4  r9             ;//2
			str   r9,temp3          ; 
			shr4  r9             ;//4
			str   r9,temp3          ; 
			shr4  r9             ;//8
			str   r9,temp3          ; 
			shr4  r9             ;//10
			str   r9,temp3          ; 
			shr4  r9             ;//20
			str   r9,temp3          ; 
			
			ldrv  rD,'h0008        ; 
shift4l_4:	shl4  rD             ;//2
			str   rD,temp4          ; 
			shl4  rD             ;//4
			str   rD,temp4          ; 
			shl4  rD             ;//8
			str   rD,temp4          ; 
			shl4  rD             ;//10
			str   rD,temp4          ; 
			shl4  rD             ;//20
			str   rD,temp4          ; 
			
			xor   rA,rA            ; 
			ldrv  r7,'ha5c3        ; 
shiftk_5:	shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			shl   l,r7             ;
			shr   k,rA             ; 
			str   r7,temp1          ; 
			str   rA,temp2          ; 
			
			ldrv  r5,'h8000        ; 
			ldrv  rC,'ha5c3        ; 
shiftr_6:	shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
			shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
			shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
			shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
			shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
			shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
			shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
			shl   r,rC             ;
			shr   a,r5             ; 
			str   rC,temp1          ; 
			str   r5,temp2          ; 
         
   
    
here:		stop; // mark the end of simulation
			bra   here             ;

   // Temporary storage
@'hF00
temp1:   dw    1                ; 
temp2:   dw    1                ; 
temp3:   dw    1                ; 
temp4:   ds    1                ;

