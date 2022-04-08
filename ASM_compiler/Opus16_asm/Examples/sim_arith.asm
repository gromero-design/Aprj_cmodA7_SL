   // PROG_ARITH.ASM :  Test program arithmetic group.
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
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Main Address Defines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // The boot loader must always be in the last program memory positions.
   // 4K  -> 'h0F00
   // 8K  -> 'h1F00
   // 16K -> 'h3F00 <---- 16384
   // 32K -> 'h7F00
   // 64K -> 'hFF00

define	RESET_ADDR		'h0000 // Reset vector address
define	MAIN_ADDR		'h0010 // Main entry address
define	BOOT_ADDR		'h3F00 // Boot loader address
define	STACK_LENGTH		64 //
   

@RESET_ADDR
reset_v: jmp   main             ;
   
@MAIN_ADDR
main:		nop                    ;
			ldrv  rA,'h8000        ;
			ldrv  rB,'h8000        ;
			or    rC,rB            ; 
			add   rA,rB            ;
			str   rA,temp1         ;
			str   rB,temp2         ;
   
			// ADD,ADDV,NOT
			ldrv  r0,'h1111	;
			ldrv  r1,'h2222	;
			mvrr  r0,r2		;
			mvrr  r1,r3		; 
			add   r2,r1		;
			addv  r3,'h5555	; 
			str   r0,temp		; //100=555
			str   r1,temp		; //100=222
			str   r2,temp		; //100=333
			str   r3,temp		; //100=777
			not   r2,r3		;
			str   r3,temp		; //100=ccc
			add   r3,r2		;
			str   r3,temp		; //100=fff
			// SUB,SUBV,NOT
			ldrv  r1,'h7777	;
			ldrv  r2,'h8888	;
			mvrr  r1,r0		; 
			sub   r2,r1		;
			subv  r3,'h5555	; 
			str   r0,temp		; //100=555
			str   r1,temp		; //100=777
			str   r2,temp		; //100=111
			str   r3,temp		; //100=aaa
			not   r2,r3		;
			str   r3,temp		; //100=eee
			// ADDC
			ldrv  r0,'hff00	;
			ldrv  r1,'h0100	;
			mvrr  r0,r2		;
			mvrr  r1,r3		; 
			add   r0,r1		;
			adc   r3,r2   		; 
			str   r0,temp1		; //f00=000
			str   r1,temp2		; //f01=010
			str   r2,temp3		; //f02=ff0
			str   r3,temp4		; //f03=001
			// SUBB
			ldrv  r0,'h7777	;
			ldrv  r1,'h8888	;
			mvrr  r0,r2		; 
			mvrr  r1,r3		;
			sub   r0,r1		; 
			sbb   r3,r2		; 
			str   r0,temp1		; //f00=eef
			str   r1,temp2		; //f01=888
			str   r2,temp3		; //f02=777
			str   r3,temp4		; //f03=111
			
			// ADDRP
			ldrv  r4,'h1234        ;
			ldpv  pB,'h1111        ;
			addrp r4,pB            ;
			str   r4,temp3         ;
			
			// SUBRP
			ldrv  r9,'h55aa        ;
			ldpv  pF,'h2277        ;
			subrp r9,pF            ;
			str   r4,temp4         ;
   

end:		nop			; 
			stop			; 
			jmp   end		; 

zend_pcode: // mark the end of code
       
   // Temporary storage
temp:	 ds    10		; 
temp1:	 dw    1		; 
temp2:	 dw    1		; 
temp3:	 dw    1		; 
temp4:	 ds    1 		;

stack:	ds STACK_LENGTH    	; // stack area
zend_pmem: // mark the end of memory program 
