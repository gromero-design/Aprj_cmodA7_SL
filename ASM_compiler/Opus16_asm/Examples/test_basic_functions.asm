// Insert this code into:
// a copy of MasterTemplateBody.asm or
// a copy of MasterTemplateFull.asm

   // Key defines, add as many as you need
define   CTLX 'h03 // ^C
define   ETX  'h03 // ^C
define   CTLD 'h04 // ^D
define   CTLE 'h05 // ^E
define   CTLI 'h09 // ^I
define   CR   'h0D // ^M
define   LF   'h0A // ^J
define   FF   'h0C // ^L
define   CTLL 'h0C // ^L
define   CTLP 'h10 // ^P
define   CTLR 'h12 // ^R
define   CTLZ 'h1A // ^Z
define   ESC  'h1B // ^[
define   NULL 'h00 // ^@
define   CTLS 'h13 // ^S
define   CTL_ 'h1F // ^S
define   SPC  'h20 // Space


define	STACK_LENGTH		64 //

@'h0000		// start at address 0
main:		ldpv	pF,stack        ; // initialize stack pointer
         	ldpv	pD,temp			; // initialize pointer to temp
			ldpv	p1,tempsrc		; // initialize pointer to tempsrc
			uport	t9				; // trigger signal for scope
			uport	f9				; // clears port bit 0
			jsr		testbasic		;

			stop					; // trigger Vivado or Modelsim
end:		jmp   	main			; 
			 			
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Application routines
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
			// Application code   
testbasic:	nop						; // call three routines
			// Division
			ldrv	r5,17			; // main caller
			ldrv	r4,3			; //
			jsr		mydivision		; // r6=5 r3=2
            strpi	r6,pD			; 
            strpi	r3,pD			;
            // Hex to ASCII
            ldrv	r2,'h12aE		; // a-f is same as A-F 41h to 46h
            jsr		myhex2asc		; // r3=41(A) r4=45(E) 
            strpi	r4,pD			;
            strpi	r3,pD			;
            ldrv	r2,'h0012		; // 
            jsr		myhex2asc		; // r3=31(1) r4=32(2) 
            strpi	r4,pD			;
            strpi	r3,pD			;
            // ASCII to Hex
            ldpv	p1,tempsrc		; // ASCII table
            xor		r2,r2			; // initialize return value
			ldcv	c1,7			; // reads 8 values
mynextchar:	ldrpi	r1,p1			; // reads next value
			jsr		myasc2hex		;
			dcjnz	c1,mynextchar	; // the last 4 values until CR is detected
			strpi	r2,pD			; // r2=1234
			rts						; // ends of myapp			
 
			// DIVISION
			//		R6 = result  
			//		R5 = numerator
			//		R4 = denominator
			//		R3 = residual
mydivision:	xor		r6,r6			; // clear result
mydivstart:	sub		r5,r4			; // r5 = r5-r4
			bra		s,mydivend	   	; // branch on sign
			mvrr	r5,r3      		; // r3 = r5 residual
			inc		r6				; // r6++
			bra		mydivstart  	; // branch always
mydivend:	rts						; // return

			// Convert HEX value to ASCII
			// register usage:
			// Inputs:  R2
			// Outputs: R3,R4
myhex2asc:	push	r2,pF           ; // push r2 
			andv	r2,'h00F        ; // r2 = r2 & 000F(hex)
			cmprv	r2,'h00A        ; // compare r2 with value A(hex)
			bra 	lt,myhex1         ; // branch on less than
			addv	r2,'h007        ; // r2 = r2 + 7
myhex1:		addv	r2,'h030        ; // r2 = r2 + 30(hex)
			mvrr	r2,r3	        ; // r3 = r2
			pull	r2,pF           ; // pull
			shr4	r2              ; // r2 = r2>>4
			andv	r2,'h00F        ; // r2 = r2 & 000F(hex)
			cmprv	r2,'h00A        ; // compare r2 with value A(hex)
			bra		lt,myhex2         ; // branch on less than
			addv	r2,'h007        ; // r2 = r2 + 7
myhex2:		addv	r2,'h030        ; // r2 = r2 + 30(hex)
			mvrr	r2,r4	        ; // r4 = r2
			rts						; // return

			// Convert ASCII to HEX
			// register usage:
			// Inputs:  R1
			// Outputs: R2
			// example : r1=0030, r1=0031, r1=0032, r1=0033, r1=0034, r1=000d
			//           r2=1234
			//
myasc2hex:	cmprv 	r1,CR            ; // compare r1 with 0D(hex)
			bra   	z,myrd_hex9      ; // branch on equal
			cmprv 	r1,LF            ; // compare r1 with 0A(hex)
			bra   	z,myrd_hex9        ; // branch on equal
			subv  	r1,'h030         ; // r1 = r1-30(hex), remove any unwanted char
			bra   	s,myrd_hex9        ; // branch on sign bit
			shl4  	r2               ; // r2 = r2<<4
			cmprv 	r1,9             ; // compare r1 with value
			bra   	ls,myrd_hex2       ; // branch on lower or same unsigned
			andv  	r1,'h00F         ; // must be a-f
			addv  	r1,9             ; // r1 = r1+9
myrd_hex2: 	or		r2,r1            ; // r2 = r2 | r1
myrd_hex9: 	rts		                 ; // return
			// ends Application code

			
   
   // Temporary storage
temp1:		dw	0		; // Decimal constants 
temp2:		dw	1		; 
temp3:		dw	2		; 
temp4:		dw	3		; 
temp5:		dw	4		; 
temp6:		dw	13		; // decimal CR
tempsrc:	dw	'0'		; // ASCII constant 
			dw	'1'		; 
			dw	'2'		; 
			dw	'3'		; 
			dw	'4'		; 
			dw	'h000d	; // Hexadecimal CR
			dw	'h0000	;
			dw	'h0000	;
temp:		ds	16		; // reserve 16 word places, temporary scratch pad.

   //////////////////////////////////////////////////////////////////////
   // Stack area
   //////////////////////////////////////////////////////////////////////
stack:	ds	STACK_LENGTH    	; // stack area
   
/////////////////// End of File //////////////////////////
