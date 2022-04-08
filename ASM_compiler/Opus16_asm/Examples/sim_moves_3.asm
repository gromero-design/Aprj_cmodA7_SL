// prog.asm : Opus Test Program memory
define shifts		4
define count		8
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
main:	cli					; // disable interrupts
		ldpv	pF,stack	; // Initialize stack pointer.  

		nop			;
		ldr   r1,mem4		;
		str   r1,'h100		; //100=f80
		ldpag	r1			;
		ldpv  p2,'h123		;
		mvpr  p2,r3		;
		str   r3,'h101		; //101=123
		ldpag	r3			;
		ldrv  r2,'habc		;
		ldpag	r2			;
		mvrp  r2,p1		;
		stp   p1,'h102		; //102=abc
		mvpp  p1,p2		;
		stp   p2,'h103		; //103=abc
		ldp   p1,mem3		;
		stp   p1,'h104		; //104=800
		ldpv  p2,mem1		;
		stp   p2,'h105		; //105=120
		ldrp  r3,p2		;
		str   r3,'h106		; //106=001
		ldpag	r3			;
		ldpv  p2,mem1		;
		stp   p2,temp		; //100=120
		ldrpi r3,p2		;
		str   r3,temp		; //100=001
		ldpag	r3			;
		stp   p2,temp		; //100=121
		ldrpi r3,p2		; 
		ldrpi r3,p2		; 
		ldrpi r3,p2		; 
		stp   p2,temp		; //100=124
		ldrpd r3,p2		;
		ldrpd r3,p2		;
		ldpag	r3			;
		stp   p2,temp		; //100=122
		ldpv  p1,mem1		;
		ldrx  r1,p1,5		;
		str   r1,temp		; //100=020
		ldpv  p1,temp		;
		ldrv  r3,'h123		;
		ldpag	r3			;
		strp  r3,p1   		; //100=123
		strpi r3,p1		; //100=123
		strpi r3,p1		; //101=123
		strpi r3,p1		; //102=123
		strpi r3,p1		; //103=123
		strpi r3,p1		; //104=123
		strpi r3,p1		; //105=123
		stp   p1,temp		; //100=106
		strpd r3,p1		; //105=123
		strpd r3,p1		; //104=123
		strpd r3,p1		; //103=123
		stp   p1,temp		; //100=103
		strx  r3,p1,7		; //10a=123
		ldrv  r1,'h555		; //100=555
		ldpag	r1			;
		str   r1,temp		; 
		ldpv  p1,temp		;
		ldrv  r3,'h123		;
		ldpag	r3			;
		stp   p1,temp 		; //100=100
		str   r3,temp		; //100=123
		incp  p1		; 
		incp  p1		; 
		incp  p1		; 
		stp   p1,temp 		; //100=103
		decp  p1		;
		decp  p1		;
		stp   p1,temp 		; //100=101
		str   r1,temp		; //100 001
		ldpv  p1,mem2		;
		str   r2,temp		; //100 010
		ldpv  p2,temp2		;
		ldrv  r1,'h456		;
		ldpv  p3,stack		;
		jsr   sub1		; //110 501
		jsr   sub4		; //100 504
		jsr   sub2		; //100 502 100 503
		jsr   sub3		; //100 503
		ldrv  r1,'he0f		; 
		ldpag	r1			;
		str   r1,temp		; //100 e0f
		ldpv  p1,'h123		;
		ldrv  r3,3		;
		str   r3,temp		; //100 003
		stp   p1,temp		; //100 123
		swapp r3,p1		;
		ldpag	r3			;
		str   r3,temp		; //100 123
		stp   p1,temp		; //100 003
		swapp r3,p1		;
		ldpag	r3			;
		str   r3,temp		; //100 003
		stp   p1,temp		; //100 123
		swapp r3,p1		;
		ldpag	r3			;
		str   r3,temp		; //100 123
		stp   p1,temp		; //100 003
   
here:	nop			; 
		stop			; // mark the end of simulation
		bra   here		;

   
@'h100   
mem1:	 dw    'h01,'h02,'h04,'h08,'h10,'h20,'h40,'h80; 
mem2:	 dw    'h10,'h20,'h40,'h80,'h100,'h200,'h400,'h800; 
mem3:	 dw    'h800,'h900,'ha00,'hb00,'hc00,'hd00,'he00,'hf00; 
mem4:	 dw    'hf80,'hf90,'hfa0,'hfb0,'hfc0,'hfd0,'hfe0,'hff0;
 
temp:	 ds    RAM_SIZE; 
temp1:	 ds    RAM_SIZE;
temp2:	 ds    RAM_SIZE; 

@'h240   
sub1:	ldrv	r1,'h501		;
		ldpag	r1			;
		str		r1,temp		;
		rts			; 
@'h250
sub2:	ldrv  r1,'h502		;
		ldpag	r1			;
		str   r1,temp		;
		jsr   sub3		; 
		rts			; 
@'h260
sub3:	ldrv  r1,'h503		;
		ldpag	r1			;
		str   r1,temp		;
		rts			; 
@'h270
sub4:	ldrv  r1,'h504		;
		ldpag	r1			;
		str   r1,temp		;
		rts			; 
   
stack:	ds STACK_SIZE	;
   
