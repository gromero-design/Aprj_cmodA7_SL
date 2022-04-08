   // PROG_BRANCH.ASM :  Test program loads/stores pointer group.
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
reset_v:	jmp		main             ; // to verify RESTART VECTOR.

@'h010   // main
main:		ldpv	pF,stack		; // initialize stack pointer
			ldpv	p1,temp1		;
			ldrv	rc,'h0000		;// counter 
main2:		jsr		computend		;
			inc		rc				;
			cmprv	rc,8			;
			bra		nz,main2 		;
			ldpagv	'hd0de			;
stop:		stop					; 
			bra		stop			;
		 
// subroutine under test
computend:	cmprv	rc,0			;
			bra		z,computend0	;
			cmprv	rc,1			;
			bra		z,computend1	;
			cmprv	rc,2			;
			bra		z,computend2	;
			cmprv	rc,3			;
			bra		z,computend3	;
			cmprv	rc,4			;
			bra		z,computend4	;
			cmprv	rc,5			;
			bra		z,computend5	;
			cmprv	rc,6			;
			bra		z,computend6	;
			cmprv	rc,7			;
			bra		z,computend7	;
			ldpagv	'hbeef			;
			rts						;

computend0:	ldpag	rc				;
			ldrpi	r7,p1			;
			rts						;									
computend1:	ldpag	rc				;
			ldrp 	r7,p1			;
			rts						;									
computend2:	ldpag	rc				;
			ldrpd	r7,p1			;
			rts						;									
computend3:	ldpag	rc				;
			strp 	rc,p1  			;
			rts						;									
computend4:	ldpag	rc				;
			strpi	rc,p1			;
			rts						;									
computend5:	ldpag	rc				;
			strpd	rc,p1			;
			rts						;									
computend6:	ldpag	rc				;
			ldrx	r4,p1,6			;
			rts						;									
computend7:	ldpag	rc				;
			strx	r4,p1,7			;
			rts						;									
									
   // Temporary storage
@'ha00
temp0:		dw	'h8007				;
			dw	'h8006				;
			dw	'h8005				;
			dw	'h8004				;
			dw	'h8003				;
			dw	'h8002				;
			dw	'h8001				;
			dw	'h8000				;
temp1:		dw	'h1000				; // r7=1000 @rc=0 p1=temp1
			dw	'h1001				; // r7=1001 @rc=1 p1=temp1+1
			dw	'h1002				; // r7=1000 @rc=2 p1=temp1
			dw	'h1003				; // temp1=rc
			dw	'h1004				;
			dw	'h1005				;
			dw	'h1006				;
			dw	'h1007				;
			
   // Stack memory
@'hF00
stack:		ds 10					; // Stack from 0xF00
