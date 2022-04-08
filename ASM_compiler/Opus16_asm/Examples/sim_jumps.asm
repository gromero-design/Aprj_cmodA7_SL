   // PROG_JUMPS.ASM :  Test program jump group.
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
   // PF pointer F -> stack pointer   'SP' can be used in some conditions
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user limited   'R3'
   // Rn register n -> user register  'Rn' n=0...F
   //

@'h0000
			ldpv  pF,stack         ; 
			jmp   main             ;

@'h0010   
main:		ldr		r1,temp1		;
			str		r1,temp2		;
			ldpag	r1;
			ldp		p3,temp1         ;
			jmpp	p3               ;
@'h0020   
main2:		nop                    ;
			ldcv	c0,31            ;
			xor		rA,rA            ; 
main3:		inc   	rA               ;
			dcjnz 	c0,main3         ;
			str   	rA,temp2         ;
			
			xor   	r3,r3            ; 
			uflag 	f5               ;
			uflag 	t7               ;
			uflag 	t5               ;
			uflag 	f7               ;
			jmp   	t5,flag_t0       ;
bad_flg:	ldrv  	r3,'hdead        ;
			str   	r3,temp1         ;
			jmp   	stop             ;
flag_t0:	jmp   	t7,bad_flg       ;
			str   	r3,temp1         ;
			      	
			ldrv  	r5,'h5555        ;
			jsr   	subr1            ;
			str   	r5,temp2         ;
			mvrp  	r5,p7; 
			      	
			jmp   	stop             ; 

jmp_lb1:	jmp		main2              ;
subr1:		jsr		subr2            ;
			rts		                 ;
subr2:		jsr		subr3            ;
			rts		                 ;
subr3:		jsr		subr4            ;
			rts                    ;
subr4:		ldrv	r5,'haaaa        ;
			rts                    ;
   

   
   // stop running
stop:		stop			; 
			bra   stop		; // end of program
   
   // Temporary storage
@'h0F00
temp1:	 dw    jmp_lb1		; 
temp2:	 dw    1		; 
temp3:	 dw    1		; 
temp4:	 ds    1 		;

@'h1000
tempa:	 ds    16 		;
tempb:   ds    16               ;
tempc:   dw    tempa            ; 

stack:   ds    100              ; 
