// Insert this code into:
// a copy of MasterTemplateBody.asm or
// a copy of MasterTemplateFull.asm

@'h0000		// start at address 0
main:		ldpv	pD,temp			; // initialize pointer to temp

//----------   application code ----------//
			// ADD two negative numbers
test_arith:	ldrv	rA,'h8000		;
			ldrv	rB,'h8000		;
			add		rA,rB			;
			strpi	rA,pD			; // rA=0000, carry=1
   
			// ADD,ADDV,NOT
			ldrv	r1,'h1111		;
			ldrv	r2,'h2222		;
			mvrr	r1,r3			; 
			add 	r2,r1			;
			strpi	r2,pD			; // r2=3333
			addv	r3,'h5555		; 
			strpi	r3,pD			; // r3=6666
			not		r2,r3			; // r3 = ~r2
			strpi	r3,pD			; // r3=cccc
			strpi	r2,pD			; // r2-3333
			add		r3,r2			;
			strpi	r3,pD			; // r3=ffff
			                    	
			// SUB,SUBV,NOT     	
			ldrv  	r1,'h7777		;
			ldrv  	r2,'h8888		;
			mvrr	r2,r3			;
			sub   	r2,r1			;
			strpi	r2,pD			; // r2=1111
			subv  	r3,'h5555		;  
			strpi	r3,pD			; // r3=3333
			not   	r2,r3			; // r3=~r2
			strpi	r2,pD			; // r2=1111
			strpi	r3,pD			; // r3=eeee
			                    	
			// ADDC             	
			ldrv  	r0,'hff00		;
			ldrv  	r1,'h0100		;
			mvrr  	r0,r2			;
			mvrr  	r1,r3			; 
			add   	r0,r1			;
			adc   	r3,r2   		; 
			strpi	r0,pD			; // r0=0000
			strpi	r3,pD			; // r3=0001
                                	
			// SUBB             	
			ldrv  	r0,'h7777		;
			ldrv  	r1,'h8888		;
			mvrr  	r0,r2			; 
			mvrr  	r1,r3			;
			sub   	r0,r1			; 
			sbb   	r3,r2			;
			strpi	r0,pD			; // r0=eeef
			strpi	r3,pD			; // r3=1111
			// SUBB 			                    	
			ldrv  	r0,'h7777		;
			ldrv  	r1,'h8888		;
			mvrr  	r0,r2			; 
			mvrr  	r1,r3			;
			sub   	r1,r0			; 
			sbb   	r2,r3			;
			strpi	r1,pD			; // r1=1111
			strpi	r2,pD			; // r2=eeee
			                    	
			// ADDRP            	
			ldrv  	r4,'h1234   	;
			ldpv  	p9,'h1111   	;
			addrp 	r4,p9       	;
			strpi	r4,pD			; // r4=2345
			                    	
			// SUBRP            	
			ldrv  	r9,'h55aa   	;
			ldpv  	p9,'h2277   	;
			subrp 	r9,p9       	;
			strpi	r9,pD			; // r9=3333

			rts						;
//--------- ends application code ----------//


// Define a temporary storage to save the results
temp:	ds		100		; // define a storage in data section
