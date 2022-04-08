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

define RESET_ENTRY	'h0000
define MAIN_ENTRY	'h0050

	// To be used with LDMAM instruction (Load Memory Access Mode)	
define   IRW 0 // internal read , internal write. m0  
define   XRD 1 // external read , internal write. m1 
define   XWR 2 // internal read , external write. m2 
define   XRW 3 // external read , external write. m3 
   
// User defines
define	STACK_SIZE	10
define	RAM_SIZE	16


@RESET_ENTRY
reset_v:	jmp		main			;// vector 0
   
   
@MAIN_ENTRY	 // main starts at 0x050 to check the RESET Vector
main:		cli						; // disable interrupts
			ldpv	pF,stack		; // Initialize stack pointer.  
			// verify timing with simple logic
			xor		r7,r7			; // z = 1
			orv		r1,'hffff		; // z = 0, s = 1 
			xor		r1,r1			; // z = 1
			orv		r1,'h0555		; // z = 0, s = 0
main1:		uflag	t8				; // check for true
			jmp		f8,test_fail	;
			inc		r7          	; //1
			ldpag	r7				; 
			uflag	f8				; // check for false
			jmp		t8,test_fail	;
			inc		r7          	; //2
			ldpag	r7				; 
			bra		chk_bra     	;
			                    	
chk_bra:	inc		r7				; //3
			ldpag	r7				;
			bra   	chk_z       	; // check branch
			bra		total_fail		; // branch not executed!, badddddd
			                    	
// Check for ZERO			    	
chk_z:		ldrv	r1,'h0000   	; // r1=0
			or		r1,r1       	; // r1=0
			bra		nz,test_fail	; // z = 1
			str		r1,temp0		; 
			dec		r1          	; // r1=ffff
			bra		z,test_fail 	; // z = 0
			inc		r7          	; //4
			ldpag	r7				; 
			str   	r1,temp0		; 
			addv  	r1,'h0005		; // r1=4
			bra   	z,test_fail		; // z = 0
			inc   	r7          	; //5
			ldpag	r7				; 
			str   	r1,temp0		; 
			subv  	r1,4			; // r1=0
			bra   	nz,test_fail	; // z = 1
			inc   	r7          	; //6
			ldpag	r7				; 
			str   	r1,temp0		; 
			inc   	r1				; // r1=1
			cmprv 	r1,1			;
			bra   	ne,test_fail	; // z=1
			inc   	r7          	; //7
			ldpag	r7				; 
end_z:		bra   	chk_s       	; 
                                	
                                	
// Check for SIGN               	
chk_sb:		bra   	chk_sf      	; // check negative offset
chk_s:		orv   	r1,'hffff   	; // r1=ffff (-1)
			bra   	s,chk_sb    	; // s=1
			bra   	test_fail   	; 
chk_sf:		inc   	r7          	; //8
			ldpag	r7				; 
			str   	r1,temp0		; 
			inc   	r1          	; // r1=0
			bra   	s,test_fail 	; // s=0
			inc   	r7          	; //9
			ldpag	r7				; 
			str   	r1,temp0		; 
			ldrv  	r1,'hfff0		; // r1=fff0
			ldrv  	r2,'h000f		;
			add   	r1,r2			; // r1=ffff
			bra   	ns,test_fail	; // s=1
			inc   	r7          	; //10
			ldpag	r7				; 
			str   	r1,temp0		; 
			sub   	r2,r1			; // r2=0
			bra   	s,test_fail		; // s=0
			inc   	r7          	; //11
			ldpag	r7				; 
			str   	r2,temp0		; 
end_s:		bra   chk_c         	;
                                	
// Check for CARRY              	
chk_cb:		bra   	chk_cf      	; // check negative offset
chk_c:		ldrv  	r1,'h1000   	; // r1=1000
			addv  	r1,'hf000   	; // r1=0000
			bra   	c,chk_cb    	; // c=1, o=1
			bra   	test_fail   	;
chk_cf:  	inc   	r7          	; //12
			ldpag	r7				; 
			str   	r1,temp0		; 
			ldrv  	r2,'h0003   	; // r2=3
			addv  	r2,'hfffc   	; // r2=ffff
			bra   	c,test_fail 	; // c=0
			inc   	r7          	; //13
			ldpag	r7				; 
			str   	r2,temp0		; 
			ldrv  	r1,'hffff		; // r1=ffff
			addv  	r1,1			; // r1=0
			bra   	nc,test_fail	; // c=1, o=1
			inc   	r7          	; //14
			ldpag	r7				; 
			str   	r1,temp0		; 
			addv  	r1,1			; // r1=1
			bra   	c,test_fail		; // c=0
			inc   	r7          	; //15
			ldpag	r7				; 
			str   	r1,temp0		; 
			addv  	r1,1			; // r1=2
			bra   	c,test_fail		; // c=0
			inc   	r7          	; //16
			ldpag	r7				; 
			str   	r1,temp0		; 
			subv  	r1,1			; // r1=1
			bra   	c,test_fail		; // c=0
			inc   	r7          	; //17
			ldpag	r7				; 
			str   	r1,temp0		; 
			subv  	r1,1			; // r=0
			bra   	c,test_fail		; // c=0
			inc   	r7          	; //18
			ldpag	r7				; 
			str   	r1,temp0		; 
			subv  	r1,1			; // r1=ffff
			bra   	nc,test_fail	; // c=1
			inc   	r7          	; //19
			ldpag	r7				; 
			str   	r1,temp0		; 
end_c:		bra   	chk_o       	;
                                	
// Check for OVERFLOW           	
chk_o:		ldrv  	r1,'h7777   	; //
			addv  	r1,'h7777   	; // r1=eeee
			bra   	no,test_fail	; // o=1
			inc   	r7          	; //20
			ldpag	r7				; 
			str   	r1,temp0		; 
			ldrv  	r2,'h7777   	;
			addv  	r2,'h9999   	; // r2=1110
			bra   	o,test_fail 	; // o=0
			inc   	r7          	; //21
			ldpag	r7				; 
			str   	r2,temp0		; 
end_o:		bra   	chk_ge      	;
                                	
                                	
// Check for GREATER THAN OR EQUAL
chk_ge:		ldrv  	r1,'h0777   	;
			subv  	r1,'h0999   	; // r1=fdde
			bra   	ge,test_fail	; // c=1,o=0,s=1,z=1
			inc   	r7          	; //22
			ldpag	r7				; 
			str   	r1,temp0		; 
			ldrv  	r1,'h0065   	;
			cmprv 	r1,'h0156   	; // r1=ff0f
			bra   	ge,test_fail	; // 
			inc   	r7          	; //23
			ldpag	r7				; 
			str   	r1,temp0		; 
			ldrv  	r1,'h0037   	;
			ldrv  	r2,'h0045   	;
			sub   	r1,r2			; // r1=fff2
			bra   	ge,test_fail	;
			inc   	r7          	; //24
			ldpag	r7				; 
			str   	r1,temp0		; 
			ldrv  	r1,'h0054   	;
			ldrv  	r2,'h0055   	;
			cmpr  	r1,r2			; 
			bra   	ge,test_fail	;
			inc   	r7          	; //25
			ldpag	r7				; 
			str   	r1,temp0		; 
chk_ge0:	ldrv  	r1,'h0057   	;
			subv  	r1,'h0056   	;
			bra   	ge,chk_ge1  	;
			jmp   	test_fail		; 
chk_ge1:	str   	r1,temp0		; 
			inc   	r7          	; //26
			ldpag	r7				; 
			ldrv  	r1,'h0045   	;
			subv  	r1,'h0045   	;
			bra   	ge,chk_ge2  	;
			jmp   	test_fail		; 
chk_ge2:	str   	r1,temp0		; 
			inc   	r7          	; //27
			ldpag	r7				; 
			ldrv  	r1,'h0057   	;
			ldrv  	r2,'h0056   	;
			cmpr  	r1,r2       	;
			bra   	ge,chk_ge3  	;
			jmp   	test_fail		; 
chk_ge3:	str   	r1,temp0		; 
			inc   	r7          	; //28
			ldpag	r7				; 
			ldrv  	r1,'h0045   	;
			ldrv  	r2,'h0045   	;
			cmpr  	r1,r2       	;
			bra   	ge,chk_ge4  	;
			jmp   	test_fail		; 
chk_ge4:	str   	r1,temp0		; 
			inc   	r7          	; //29
			ldpag	r7				; 
			ldrv  	r1,'h0e45   	;
			ldrv  	r2,'h0e46   	;
			cmpr  	r1,r2       	;
			bra   	ge,test_fail	;
chk_ge5:	str   	r1,temp0		; 
			inc   	r7          	; //30
			ldpag	r7				; 
			ldrv  	r1,'h0001   	;
			ldrv  	r2,'hffff   	;
			cmpr  	r1,r2       	;
			bra   	ge,chk_ge6  	;
			jmp   	test_fail		; 
chk_ge6:	str   	r1,temp0		; 
			inc   	r7          	; //31
			ldpag	r7				; 
			ldrv  	r1,'hf001   	;
			ldrv  	r2,'hf000   	;
			cmpr  	r1,r2       	;
			bra   	ge,chk_ge7  	;
			bra   	test_fail		; 
chk_ge7:	str   	r1,temp0		; 
			inc   	r7          	; //32
			ldpag	r7				; 
			ldrv  	r1,'h0e45   	;
			ldrv  	r2,'h0e45   	;
			cmpr  	r1,r2       	;
			bra   	ge,chk_ge8  	;
			jmp   	test_fail		; 
chk_ge8:	str   	r1,temp0		; 
			inc   	r7          	; //33
			ldpag	r7				; 
end_ge:		bra		chk_lt			;
                                	
// Check for LESS THAN          	
chk_lt:		ldrv  	r1,'h000a   	;
			cmprv 	r1,'h0009   	;
			bra   	lt,test_fail	;
			inc   	r7          	; //34
			ldpag	r7				; 
			str   	r1,temp0		; 
			ldrv  	r2,'h0009   	;
			cmprv 	r2,'h000a   	;
			bra   	lt,chk_lt1  	;
			bra   	test_fail		; 
chk_lt1:	str   	r2,temp0		; 
			inc   	r7          	; //35
			ldpag	r7				; 
end_lt:		bra   	chk_inc     	; 
                                	
// Check whatever               	
chk_inc:	ldrv  	r3,'hffff   	;
			inc   	r3          	; // r3=0
			bra   	c,chk_ig1   	; // c=1
			bra   	test_fail   	; 
chk_ig1:	inc   	r7          	; //36
			ldpag	r7				; 
			ldrv  	r3,'hffff   	;
			inc   	r3          	; // r3=0
			bra   	z,chk_ig2   	; // z=1
			bra   	test_fail   	;
chk_ig2:	inc   	r7          	; //37
			ldpag	r7				; 
			inc   	r3          	; // r3=1
			bra   	z,test_fail 	; // z=0
			inc   	r7          	; //38
			ldpag	r7				; 
			dec   	r3          	; // r3=0
			bra   	nz,test_fail	; // z=1
			inc   	r7          	; //39
			ldpag	r7				; 
			dec   	r3          	; // r3=ffff
			bra   	nc,test_fail	; // c=1
			inc   	r7          	; //40
			ldpag	r7				; 
			ldrv  	r9,'h8000   	;
			add   	r9,r9       	;
			bra   	nc,stop     	; // c=1, o=1
			inc   	r7          	; //41
			ldpag	r7				; 
			ldrv  	r4,'h0f00   	;
			add   	r4,r4       	;
			bra   	c,test_fail 	; // c=0
			inc   	r7          	; //42
			ldpag	r7				; 
end_inc:	bra   	chk_shift   	; 
                                	
chk_shift:	ldrv	r4,'h7fff		;
			shl		l,r4			;
			bra		ns,test_fail	;
			inc   	r7          	; //43
			ldpag	r7				; 
			shl		l,r4			;
			bra		s,chk_shift1	;
			bra		test_fail		;
chk_shift1:	inc   	r7          	; //44
			ldpag	r7				;
			ldrv	r4,'h8000		;
			shl		l,r4			;
			bra		nz,test_fail	;
			inc   	r7          	; //45
			ldpag	r7				; 
			ldrv	r4,'h8000		;
			shl		l,r4			;
			bra		c,chk_shift2	;
			bra		test_fail		;
chk_shift2:	inc   	r7          	; //46
			ldpag	r7				;
			                    	
end_shift:	bra		end_test		;
                                	


			
// End of Test
test_fail:	ldrv  	rd,'he000		;
			add		rd,r7			; 
			ldpag	rd				; 
			ldrv  	rd,'hdead		; 
			ldpag	rd				; 
			bra		stop2			;
			                    	
total_fail:	ldrv  	rd,'heeee		; 
			ldpag	rd				; 
			ldrv  	rd,'hdead		; 
			ldpag	rd				; 
			bra		stop2			;
			                    	
end_test:	mvrp  	r7,pA			;
			ldrv  	rC,46         	; // update this value 
			cmprp 	rC,pA         	;
			bra   	ne,total_fail 	;
stop:		ldpagv	'h1234			;
			ldr		r8,temp0		;
			ldpag	r8				;
			nop                 	;
			nop                 	;
stop2:		nop                 	;
			nop                 	;
			nop                 	;
			nop                 	;
			nop                 	;
			nop                 	;
stoploop:	nop                 	;
			stop					; 
			bra   stoploop			;
			                    	
                                	
   // Temporary storage
@'hF00
temp0:   dw    1                ;
temp1:   dw    1                ; 
temp2:   dw    1                ; 
temp3:   dw    1                ; 
temp4:   dw    1                ;

   // Stack memory
stack:	ds STACK_SIZE	;
