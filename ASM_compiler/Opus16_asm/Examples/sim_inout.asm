   // PROG_INOUT.ASM :  Test program I/O group.
   // Updated 05/27/2021
   // Behavioral Simulation = PASSED
   // Gate Level Simulation = PASSED
   // Hardware Verification = PASSED
   //
   // Register and Pointer definitions
   // P0 pointer 0  -> program counter 'PC' not accesible
   // P1 pointer 1  -> user pointer    'P1'
   // P2 pointer 2  -> user pointer    'P2'
   // -------------------------------------
   // PF pointer 15 -> stack pointer   'SP' can be used in some conditions
   //
   // R0 register 0 -> temporary ACC  'R0' modified by some instructions
   // R1 register 1 -> user register  'R1'
   // R2 register 2 -> user register  'R2'
   // R3 register 3 -> user limited   'R3'
   // -----------------------------------
   // RF register 15 -> user limited   'RF'
   //


define   valid 'h8000
define   count  8
   
@'h0
reset_v:	jmp   main             ;
   
@'h050		//start
main:		// initialize registers
	 		ldpv	pF,stack		; // init stack pointer
init:		ldrv	r1,'h3950		; // initialize ports

wr_port:	outp	r1,port1		;
			jsr		beback1			;
			ldpag	r1				;
			ldrv	r2,'h2440		; // initialize ports
			outp	r2,port2		; 
			jsr		beback1			;
			ldpag	r2				;
			ldrv	r3,'h1760		; // initialize ports
			outp	r3,port3		; 
			jsr		beback1			;
			ldpag	r3				;
			ldrv	r4,'h4360		; // initialize ports
			outp	r4,port4		; 
			jsr		beback1			;
			ldpag	r4				;
			ldrv	r5,'hcff0		; // initialize ports
			outp	r5,port5		; 
			jsr		beback1			;
			ldpag	r5				;
			ldrv	r6,'h4000		; // initialize ports
			outp	r6,port6		;
			jsr		beback1			;
			ldpag	r6				;
			ldrv	r7,'hdea0		; // initialize ports
			outp	r7,'h0e07		; // port7
			jsr		beback1			;
			ldpag	r7				;
			    	
rd_back:	inp 	r7,port1		;
			jsr		beback1			;
			ldpag	r7				;
			str 	r7,temp1		;
			inp 	r6,port2		;
			jsr		beback1			;
			ldpag	r6				;
			str 	r6,temp2		; 
			inp 	r5,port3		;
			jsr		beback1			;
			ldpag	r5				;
			str 	r5,temp3		; 
			inp 	r4,port4		;
			jsr		beback1			;
			ldpag	r4				;
			str 	r4,temp4		; 
			inp 	r3,port5		;
			jsr		beback1			;
			ldpag	r3				;
			str 	r3,temp5		; 
			inp 	r2,port6		;
			jsr		beback1			;
			ldpag	r2				;
			str 	r2,temp6		; 
			inp 	r1,port7		;
			jsr		beback1			;
			ldpag	r1				;
			str 	r1,temp7		; 
			
			// use indirect addressing			    	
			xor 	r1,r1   		; // clear reg
			ldrv 	r2,7			; // clear reg
			ldpv	p1,port1		;
loop1:		inpp	r1,p1			;
			jsr		beback2			;
			ldpag	r1				;
			incp 	p1				; // point next i/o
			dec		r2				;
			bra  	nz,loop1		;
   
			// use indirect addressing			    	
			ldrv 	r1,'hab00		; // clear reg
			ldrv 	r2,7			; // clear reg
			ldpv	p1,port1		;
loop2:		outpp	r1,p1			;
			jsr		beback3			;
			ldpag	r1				;
			incp 	p1				; // point next i/o
			inc		r1				;
			dec		r2				;
			bra  	nz,loop2		;

			ldpv	p1,port1		;
			ldpv	p2,port1		;
skip0:		ldpagv	'habba			;								   
			inpp	r4,p1			;
			bra		skip1			; // bad
			bra		endbad			;
skip1:		ldpagv	'habbb			;								   
			outpp	r4,p1			;
			bra		skip2			; // bad
			bra		endbad			;
skip2:		ldpagv	'habbc			;
			incp	p1				;								   
			inpp	r5,p1			;
			incp	p2				;
			bra		skip3			;
			bra		endbad			;
skip3:		ldpagv	'habbd			;								   
			outpp	r5,p1			;
			incp	p2				;
			bra		skip4			;
			bra		endbad			;
skip4:		ldpagv	'habbe			;

			bra		endprog			;								   

endbad:		ldpagv	'hbadd			;
			bra		here			;
			   
endprog:	ldpagv	'heedd			;								   
here:		stop				; 
			bra   here			; 


   // IO ports driven by opus1_tb.vhd
@'hE00
port:	 dw    'h10    			;
port1:	 dw    'h11    			;
port2:	 dw    'h12     		; 
port3:	 dw    'h13    			; 
port4:	 dw    'h14    			; 
port5:	 dw    'h15    			; 
port6:	 dw    'h16    			; 
port7:	 dw    'h17    			; 
   
   // Temporary storage
@'hF00
temp:	 dw    0                ; 
temp1:   dw    1                ; 
temp2:   dw    2                ; 
temp3:   dw    3                ; 
temp4:   dw    4                ;
temp5:   dw    5                ;
temp6:   dw    6                ;
temp7:   dw    7                ;

store:   ds    8                ;

beback1:	rts					;
beback2:	inpp	r3,p1			;
			rts					;
beback3:	outpp	r2,p1			;
			rts					;

   // Stack memory
@'hFF0
stack:   ds    1                ; // Stack from 0xFF0

