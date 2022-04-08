   // PROG_BRANCH.ASM :  Test program jump group.
   //
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification = PASSED
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


@'h000
reset_v: bra   main             ; // to verify RESTART VECTOR.
   

@'h010   // main
main:    add   r1,rC            ; // Arithmetic and Logical group.
         adc   r3,rA            ;
         addv  r5,'h1122        ;
         addv  r6,7             ;
         addrp r5,pA            ;
         sub   r6,r6            ;
         sbb   r6,r6            ;
         subv  r1,1             ;
         subv  r4,'h3           ;
         subrp r8,pC            ;
         not   r4               ;
         not   r4,r3            ;
         and   r3,r4            ;
         andv  r3,10            ;
         andv  r3,'h344         ;
         andv  r4,temp0         ;
         or    rA,rF            ;
         orv   rB,1             ;
         orv   rD,'hffff        ;
         xor   rA,rF            ;
         xorv  rB,1             ;
         xorv  rD,'hffff        ;
         inc   r5               ;
         dec   r4               ;
         cmpr  r4,r5            ;
         cmprv r4,1             ;
         cmprv r5,'h444         ;
         shl   l,r4             ;
         shl   k,r8             ;
         shl   r,r3             ;
         shr   l,r5             ;
         shr   k,r9             ;
         shr   r,r2             ;
         shr   a,r1             ;
         shr4  r4               ;
         shl4  r6               ;

         mvrr  r2,r3            ; // Move group
         mvrp  r3,p4            ;
         mvpr  pf,r7            ;
         mvpp  p4,p1            ;
         swap  r3,r5            ;
         swapp p1,r8            ;

         ldcv  c3,8             ; // Load group
         ldc   c2,r2            ;
         ldr   r4,temp0         ;
         ldrv  rE,11            ;
         ldrv  r7,'h777         ;
         ldrv  r4,temp1         ;
         ldrx  r4,pC,5          ;
   
   
             
stop:    stop                   ; 
	 bra   stop		; 

   // Temporary storage
@'hF00
temp0:   dw    1                ;
temp1:   dw    1                ; 
temp2:   dw    1                ; 
temp3:   dw    1                ; 
temp4:   dw    1                ;

   // Stack memory
@'hFF0
stack:   ds    1                ; // Stack from 0xFF0

@'h1000
error1:  ds    1                ; 
