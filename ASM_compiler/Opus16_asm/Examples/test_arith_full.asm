   //////////////////////////////////////////////////////////////////////
   // PROGRAM :		Template Full
   //////////////////////////////////////////////////////////////////////
   // Application:
   // Any with UART interface and SESMA state machine
   // Bluetooth serial interface
   //////////////////////////////////////////////////////////////////////
   // check comments with //g or //g# , #=1 to 99
   //////////////////////////////////////////////////////////////////////
   // Registers, Pointers and flags usage:
   //
   // Pointers
   // p0 : Program counter don't touch
   // p1 : temp, write/read SESMA
   // p2 : temp, 
   // p3 : temp,
   // p4 : temp
   // p5 : temp
   // p6 : temp
   // p7 : pointer to debug variables don't touch, or save/restore
   // p8 : temp, Display registers
   // pA : contains the address of the UART Data register don't touch
   // pB : contains the address of the UART Status register don't touch
   // pC : used by tx_line, tx_page, tx_prmt routines don't touch
   // pD : pointer to debug registers don't touch, or save/restore
   // pE : 
   // pF : Stack pointer
   //
   // Registers
   // r0 : auxilary reg, temp, modified by arith/logic operations
   // r1 : chkstat, rdchar, any routine
   //	   tohex2,asc2hex input value
   // r2 : hex2asc, input value tohex2,asc2hex
   //      output value dishexs
   // r3 : tx_page, tx_line, dishexs
   // r4 : tx_page, tx_line
   // r5 : 
   // rA : boot loader, available
   // rC : boot loader, available
   // rE :
   //
   // uflag(0-4) available
   // uflag(5) used by memory dump
   // uflag(6) used by asc2hex routine
   // uflag(7) used by boot loader 
   //          used by echo ON/OFF in normal operation
   // uflag(8) irq, flag
   // uflag(9) irq, flag
   // uflag(A-F) available

   // uport(0) main loop trigger/signal
   // uport(1-3) available 
   // uport(4) IRQ enable
   // uport(7) echo ON/OFF
   // uport(8) INT1
   // uport(9) INT2
   // uport(A-F) available
   //
   // Register and Pointer definitions
   //=====================================
   //
   // POINTER REGISTERS
   //=====================================
   // P0 pointer 0 -> program counter 'p0' don't touch
   // P1 pointer 1 -> user pointer    'p1'
   // P2 pointer 2 -> user pointer    'p2'
   // P3 pointer 3 -> user pointer    'p3'
   // P4 pointer 4 -> user pointer    'p4'
   // P5 pointer 5 -> user pointer    'p5'
   // P6 pointer 6 -> user pointer    'p6'
   // P7 pointer 7 -> user pointer    'p7' debug pointers don't touch
   // P8 pointer 8 -> user pointer    'p8'
   // P9 pointer 9 -> user pointer    'p9'
   // PA pointer 10-> user pointer    'pA' UART Data register don't touch
   // PB pointer 11-> user pointer    'pB' UART Status register don't touch
   // PC pointer 12-> user pointer    'pC'
   // PD pointer 13-> user pointer    'pD' pointer to debug registers don't touch
   // PE pointer 14-> user pointer    'pE'
   // PF pointer 15-> stack pointer   'pF' don't touch
   //
   //
   // REGISTERS
   //=====================================
   // R0 register 0 -> temporary ACC  'r0' modified by arith/logic instructions
   // R1 register 1 -> user register  'r1' any routine
   // R2 register 2 -> user register  'r2' asc2hex, hex2asc,tohex2
   // R3 register 3 -> user register  'r3' asc2hex, tx_page, tx_line, dishexs
   // R4 register 4 -> user register  'r4' tx_page, tx_line, application
   // R5 register 5 -> user register  'r5' any routine
   // R6 register 6 -> user register  'r6' any routine
   // R7 register 7 -> user register  'r7' any routine
   // R8 register 8 -> user register  'r8' any routine
   // R9 register 9 -> user register  'r9' any routine
   // RA register 10-> user register  'rA' Boot Loader,  any routine
   // RB register 11-> user register  'rB' any routine
   // RC register 12-> user register  'rC' Boot Loader
   // RD register 13-> user register  'rD' any routine
   // RE register 14-> user register  'rE' any routine
   // RF register 15-> status/control 'rF' any routine
   //
   // R0 can be used in Input and Output I/O access
   // R0 is modified by arithemtic and logic instructions, temp reg
   //=====================================
   //////////////////////////////////////////////////////////////////////
   // Register and memory map for uC16
   //////////////////////////////////////////////////////////////////////
   // 'h0000 - 'h00FF uC16 I/O map internal
   //		Internal Register I/O map 'h0000 to 'h000F
   //		UART I/O map 'h0010-'h0011
   //		Available for future use 'h0012 to 'h00FF
   //
   //		Registers I/O map
   // 'h0100 - 'hFFFF user I/O map external
   //
   //		buff/BRAM memory map
   // 'h0000 - 'hFFFF user mem map external
   //
   // GPREG_xx  address 'h0000-'h000F General purpose registers
   // UART      address 'h0010-'h0011
   // Available address 'h0012 to 'h00FF
   // APPREG_xx address 'h0100-'hFFFF Application registers
   // REGxx_IO  address 'hxxxx + BAR (Base Address Register)
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

   //////////////////////////////////////////////////////////////////////
   // REAL TIME CLOCK
   //////////////////////////////////////////////////////////////////////
   //            decimal  hexadecimal
define YEAR      2022; // 07E6 Year
define MONTH       01; //    1 Month January
define DATE      0001; // 0001 day/Date (Monday/01)
define HOUR        00; //    0 hours
define MINUTE      00; //   00 minutes
define SECONDS     00; //    0 seconds
   
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // System defines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // To be used with LDMAM instruction (Load Memory Access Mode)	
   // ldmam mo ; // internal read , internal write. IRW 
   // ldmam m1 ; // external read , internal write. XRD
   // ldmam m2 ; // internal read , external write. XWR
   // ldmam m3 ; // external read , external write. XRW

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

define   NUMFILL 	'h5  // number of filling charaters in message
define   CHARFILL	'h2d // character to fill in this case is "-"

   //////////////////////////////////////////////////////////////////////
   // UART Data Reg
   //////////////////////////////////////////////////////////////////////
define   UARTDAT  'h0010 // UART Output Register
define   UARTSTA  'h0011

   // status lines
define   RXDVLD   'h0080 // valid or present input data
define   TXFULL   'h0040 // TX fifo full 
define   TXEMPT   'h0020 // TX fifo EMPTY 
define   TP2      'h0010 // test point 2
define   RXERR    'h0008 // RX error
define   RXFULL   'h0004 // RX fifo full
define   RXEMPT   'h0002 // RX fifo empty
define   TP1      'h0001 // test point 1
define   TP1_2    'h0011 // test point 1 and 2

   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // User defines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
define	SIGNED      'h8000 // Signed bit

// Defines for the index of pointer P7
// strx rn,p7,SR_IX ; // example
define SR_IX	0 // external RAM page address
define IR_IX_LN	1 // internal RAM length
define IR_IX	2 // internal RAM address
define ER_IX	3 // external RAM address
define IRL_IX	4 // internal RAM address last
define ERL_IX	5 // external RAM address last
//				6
//				7

   /////////////////////////////////////////////////////////////////////
define   BASEREGIO  'h0000 // Base register address port

   // Application Registers 
   // 'h0000 - 'h000f register map
   // Registers - OUTPUTs
define   GPREG_00  'h0000 // holds the address of the tempvar storage
define   GPREG_01  'h0001 //
define   GPREG_02  'h0002 // ECODE 
define   GPREG_03  'h0003 // BCODE 
define   GPREG_04  'h0004 //
define   GPREG_05  'h0005 //
define   GPREG_06  'h0006 //
define   GPREG_07  'h0007 // triger src, scope src, PCODE
define   GPREG_08  'h0008 // low  word for 1Sec counter 
define   GPREG_09  'h0009 // high word for 1Sec counter

   // Registers - INPUTs
define   GPREG_0a  'h000a // 
define   GPREG_0b  'h000b //
define   GPREG_0c  'h000c // Boot address
define   GPREG_0d  'h000d //
define   GPREG_0e  'h000e // TEST_DATE : top_fpga date  
define   GPREG_0f  'h000f // TEST_VERSION : opus ip core date

	// GPREG_07 = System Register - OUTPUT
define   TARGET_MSK 'h0001 // Target reset mask
define   TARGET_NSK 'hFFFE //
define   PCODE_MSK  'h0002 // Pcode mask
define   PCODE_NSK  'hFFFD //
define   SCOPE_MSK  'h3000 // Scope source
define   SCOPE_NSK  'hCFFF //
define   TRIGS_MSK  'hC000 // Trigger source
define   TRIGS_NSK  'h3FFF //
   //  0  'h0001 target reset pulse and clear registers
   //  1  'h0002 pcode 0=unprotected code, 1=protected code
   // 12  'hF000 bit 12,Scope   source, bit 0
   // 13         bit 13,Scope   source, bit 1
   // 14         bit 14,Trigger source, bit 0
   // 15         bit 15,Trigger source, bit 1
   
   // User registers - INOUTs
   // 'h0100 - 'h011f register map
   // Read-Write Base address of application registers 
   // 'h0100 - 'h010F 16 application registers
   // 'h0110 - 'h011F 16 application registers
define   APPREG_00  'h0100 // description here
define   APPREG_10  'h0120 // description here

   // User switches
define   USRSW_MSK  'h0000	// and logic
define   USRSW_NSK  'hFFFF	// or  logic

   //////////////////////////////////////////////////////////////////////
   //
   // Code Area Protected
   //
   // All labels lower case
   //////////////////////////////////////////////////////////////////////

@RESET_ADDR // Reset vector
reset_v:	jmp   setup      ; // @'h000 reset vector
irq1_v:		jmp   hw_irq1    ; // @'h002 hardware irq vector
irq2_v:		jmp   hw_irq2    ; // @'h004 hardware irq vector
irq3_v:		jmp   hw_irq3    ; // @'h006 hardware irq vector
irq4_v:		jmp   hw_irq4    ; // @'h008 hardware irq vector

// Free from h000A to MAIN_ADDR
   
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Program Section, Protected area
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
@MAIN_ADDR
setup:		cli						;
			ldpv  pA,UARTDAT       ; // initialize UART
	        ldpv  pB,UARTSTA       ;
         	ldpv  pF,stack         ; // initialize stack pointer
         	ldpv  p7,dbugptr       ; // debug initialize debug pointer
         	ldpv  pD,tempvar1      ; // temp/results pointer
         	ldpv  pE,tempvar2      ; // temp/results pointer
         	ldrv  r1,kpst00        ; // Initialize SESMA variables
         	str   r1,ssm_pst       ; // present state
         	str   r1,ssm_lst       ; // last state.

			// Insert User Initialization
			// Initialize local registers

			ldrv	r1,0			; // non used regs
			outp	r1,GPREG_01		; //  	        
			outp	r1,GPREG_04		; //  	        
			outp	r1,GPREG_05		; //  	        
			outp	r1,GPREG_06		; // 
			
			ldrv	r1,tempvar1		; // save the tempvar address in register
			outp	r1,GPREG_00		; //  	        
			ldrv	r1,zend_code   	; // end of program protected RAM
	        outp    r1,GPREG_02     ; //
			ldrv	r1,zend_ram  	; // start of protected RAM, BOOT section
	        outp    r1,GPREG_03     ; //
			ldrv	r1,'h0002 		; // trigger = 00,source  = 00
	        outp    r1,GPREG_07     ; // protected mode
			ldrv	r1,'h7840 		; // low word for 1Sec counter
	        outp    r1,GPREG_08     ; // 15:0
			ldrv	r1,'h017d 		; // high word for 1Sec counter
	        outp    r1,GPREG_09     ; // 31:16 1Sec based on 40nS clock
	        
	        uflag 	t2				; // enable ClearScreen
	 		uflag	f3				; // disable pjump execution routine
	        uflag 	f5				; // memory pointer
	        uflag 	f6				; // asc2hex
	        uflag 	t7				; // echo ON
	        uflag 	fE				; // 1 mSec flag, clear by routine
	        uflag 	fA				; // 1 Hour flag, clear by routine

	        uport	f0				; // Main loop
			uport	f4				; // hw interrupt enable flag 
			uport	f8				; // hw IRQ1 test
			uport	f9				; // hw IRQ2 test 
									 
	        jsr		d_target		; // reset top fpga
	        jsr		irq_enb			; // enable Interrupts
	        
    //////////////////////////////////////////////////////////////////////
	// Main Loop
    //////////////////////////////////////////////////////////////////////
    // use a command in application menu to enable pjump routine execution
    // for example : a command that ask for routine address and 
    // another command to enable/disable uflag(3)

main:		uport	t0				; // scope signal for trigger
			inpp  	r1,pB	     	; // read status reg
			uport	f0				; // to measure the main loop time
         	bitv  	r1,RXDVLD   	; // test data valid RX
         	bra   	z,main2		  	; //
			jsr   	rdchar          ; // read command and call SESMA
			jsr   	sesma           ; // uses pointer 1 (p1), action routine has RTS
main2:		jmp		f3,main			; // check if a routine should be executed                    
			uflag	f3				; // disable pjump execution later
			ldrv	r1,main			; // return address
			push	r1,pF			; // save it in stack
			ldp		p3,pjump		; // load address routine
			jmpp	p3				; // task routine returns back to main:

	//////////////////////////////////////////////////////////////
	// Display Menus : start
	//////////////////////////////////////////////////////////////
   
   			// Echo ON/OFF   
echo_on:	uflag	t7				;
			ldrv	r1,1			;
			bra		echo_save		;
echo_off:	uflag	f7				;
			xor		r1,r1			;
echo_save:	str		r1,echomode		;
			rts						;
						         	         
         	// Version number always on        	
d_prgver:	uflag	t7				;
			ldpv	pC,version_m	;
			jsr		tx_line 		;
			jsr		tx_prmtlf		;
			ldr		r1,echomode		;
			or		r1,r1			;
			bra		nz,d_prgver2	;
			uflag	f7				;
d_prgver2:	rts						;  
         	
			// display real time clock always on
d_rtcval:	uflag	t7				;
			ldpv	p1,tmr1year		;
		 	ldcv	c1,5			; // columns
rtcdump: 	ldrpi	r2,p1			;
         	jsr		dishex4    		; // display signed
		 	dcjnz	c1,rtcdump		;
			ldpv  	pC,promptlf     ; // 
         	jsr   	tx_line         ; // output LF
         	ldr		r1,echomode		;
			or		r1,r1			;
			bra		nz,d_rtcval2	;
			uflag	f7				;
d_rtcval2:	rts                		;
         	
   // Clear Screen and send cursor to home
enbscreen:	uflag	t2				;
			rts						;
disscreen:	uflag	f2				;
			rts						;
			   
clscreen:	jmp		f2,clscreen2	;
			ldpv	pC,cls_m      	; // display message
         	jsr 	tx_line         ; // clear screen
         	jsr 	tx_prmtx2       ; 
         	ldpv	pC,chome_m      ; // display message
         	jsr 	tx_line         ; // message out.
         	jsr 	tx_prmtx2       ; 
clscreen2:	rts						;
			// remove start
d_menu:  	jsr	  clscreen      	; // clear screen
		 	ldpv  pC,menu           ; // display menu 
         	jmp   d_txpage          ;
         
d_appset:	jsr	  clscreen      	; // clear screen
		 	ldpv  pC,appset_m       ; // display menu 
         	jmp   d_txpage          ;
         	
d_sysset:	jsr	  clscreen      	; // clear screen
		 	ldpv  pC,sysset_m       ; // display menu 
         	jmp   d_txpage          ;

d_debug:  	uflag	t7				; // echo ON
			jsr	  clscreen      	; // clear screen
		 	ldpv  pC,debug_m        ; // display menu 
         	jmp   d_txpage          ;
         	
d_help:  	jsr	  clscreen      	; // clear screen
		 	ldpv  pC,help_m         ; // display menu 
         	jmp   d_txpage          ;
         	
d_helpa:  	jsr	  clscreen      	; // clear screen
		 	ldpv  pC,help_a         ; // display menu 
         	jmp   d_txpage          ;

	// Display Menus : ends
	//////////////////////////////////////////////////////////////

   			// Read REGS
d_aregs: 	jsr	  clscreen      	; // clear screen
		 	jsr   tx_prmt           ; // prompt out.
	 		ldr   r1,regptr			;
	 		mvrp  r1,p8				;
         	ldcv c1,15              ; 
d_areg1: 	inpp  r2,p8             ;
         	jsr   dishex4           ;
         	jsr   tx_prmt           ; 
         	incp  p8                ;
         	dcjnz c1,d_areg1        ;
         	jsr   tx_prmt           ; 
         	rts                     ;

         	// Memory Access = Internal/External (0/1)
d_mema:	 	ldr   r1,memacc	    	;
         	xorv  r1,1   			;
         	bra   nz,d_memon      	;
	 		xor   r2,r2	       		;
	 		str   r2,memop			;
         	ldpv  pC,memof_m      	; // display menu
         	bra   d_memof         	;
d_memon: 	ldrv  r2,3 	       		;
	 		str   r2,memop			;
	 		ldpv  pC,memon_m      	; 
d_memof: 	str   r1,memacc      	;
         	jsr   tx_line         	;
	 		jsr   tx_prmt         	; 
	 		rts		       			;
         	// Memory Access = Word/Byte (0/1)
d_memb:	 	ldr   	r1,memode  		;
         	xorv	r1,1		   	;
         	bra		nz,d_membyte     	;
         	ldpv	pC,memword_m      	; // display menu
         	bra		d_memword        	;
d_membyte: 	ldpv	pC,membyte_m      	; 
d_memword:	str		r1,memode      	;
         	jsr		tx_line         	;
	 		jsr		tx_prmt         	; 
	 		rts	
	 			       			;
d_base:	 	ldpv  pC,hexval4_m    	; // Register Base Address
	 		jsr   tx_line	       	;
	 		jsr   asc2hex	       	;
	 		str   r2,regptr  		;
	 		jsr   tx_prmtx2        	;
	 		rts						;

			//////////////////////////////
			// Common routines
d_txpage:	jsr   tx_page          	;
         	jsr   tx_prmtcr        	; 
d_nothing: 	rts                    	;

         	// Debug mode
         	// bit operation in bitop
s_bitop: 	ldr   r1,inpchar       	; // write command
         	jmp		f7,s_bitop1		;
			outpp r1,pA            	; //x//
s_bitop1:	str   r1,bitop			;
clrval:	 	ldrv  r1,'h3030        	; // "00" in ASCII
         	str   r1,cvalue1       	; 
         	str   r1,cvalue2       	;
         	rts                    	;
			// get address in cvalue1/2
a_getadr:	ldr   r1,inpchar       	;
         	jmp		f7,a_geta1		 ;
			outpp r1,pA            	; //x//
a_geta1:   	ldr   r2,cvalue1       	;
         	ldr   r3,cvalue2       	;
         	ldcv  c1,7		     	;
a_geta2: 	shl   l,r2             	;
         	shl   k,r3             	;
         	dcjnz c1,a_geta2       	;
         	str   r3,cvalue2       	; 
         	or    r2,r1            	;
         	str   r2,cvalue1       	;
         	rts                    	; 
			// get value
a_getval:	jsr   a_setadd		;
         	jsr   tx_prmt       ; 
		 	ldp   p1,inpaddr	;
		 	ldr   r1,bitop		;
		 	cmprv r1,"m"		;// here check for M or IO
		 	bra   z,a_getmem	;
	 		inpp  r2,p1 		;// register
	 		bra   a_getend		;
a_getmem:	stp   p1,memptr		;
			stp   p1,memptrlast	;
			ldr	  r4,memop		;
			andv  r4,3			;
			bra	  nz,a_getex	;	
	 		ldrp  r2,p1			;
	 		bra	  a_getend		;
a_getex:	ldmam m1			; // external read , internal write.  XRD
	 		ldrp  r2,p1			;
a_getend:	ldmam m0			; // internal read , internal write.  IRW  	
			jsr   dishex4       ;
	 		jsr   tx_prmt       ; 
         	rts					;
         
a_setadd:	ldr   r1,cvalue1    ;
         	jsr   tohex2        ;
			mvrr  r2,r3			;
			ldr   r1,cvalue2    ;
        	jsr   tohex2        ;
        	shl4  r2	 		;
			shl4  r2			;
			or    r2,r3			;
			str   r2,inpaddr	;
        	ldrv  r1,'h3030     ;
        	str   r1,cvalue1    ; 
        	str   r1,cvalue2    ;
        	ldr   r1,inpchar    ; // delimiter
	 		str   r1,delimeter	;
        	jmp		f7,a_setadd2;
			outpp r1,pA         ;
a_setadd2: 	rts                 ; 

a_regdat:	jsr   a_getadr      ; 
         	rts                 ; 

a_wrval1:	jsr   a_wrval		;
	 		jsr   a_wrout		;
e_wrval1:	rts					;
	
a_wrval2:	jsr   a_wrval       ;
        	ldr   r2,outdata	;
			not   r2			;
			ldr   r3,delimeter	;
			cmprv r3,"-"		;
			bra   ne,a_ones		;
			addv  r2,1			;
a_ones:		str   r2,outdata    ;
	 		jsr   a_wrout		;
e_wrval2:	rts					;
	
a_wrval:	ldr   r1,cvalue1    ;
        	jsr   tohex2        ;
        	mvrr  r2,r3         ; //save it and
        	ldr   r1,cvalue2    ;
        	jsr   tohex2        ;
	 		shl4  r2			;
	 		shl4  r2			;
        	or    r2,r3         ; // combine
        	str   r2,outdata    ;
	 		rts					;
	
         // write data into address
a_wrout:	ldr   r1,outdata       	;
        	ldr   r2,inpaddr       	;
        	ldr   r3,bitop			;
        	ldr   r4,memop			;
			cmprv r3,"w" 			; // write register
			bra   ne,a_w1			;
			mvrp  r2,p1				;
        	outpp r1,p1            	;
	 		bra   a_wend			;
a_w1:		cmprv r3,"s"			; // set bit
	 		bra   ne,a_w2			;
			mvrp  r2,p1				;
			ldpv  p3,h2btab			;
			ldr   r1,outdata		;// bit #
			addrp r1,p3				;
			mvrp  r1,p3				;
			ldrp  r1,p3				; // bit set
			inpp  r2,p1				; //x//
			or    r2,r1				;
			outpp r2,p1  			;
			bra   a_wend			;
a_w2:		cmprv r3,"c"			; // clear bit
	 		bra   ne,a_w3			;
	 		mvrp  r2,p1				;
	 		ldpv  p3,h2btab			;
	 		ldr   r1,outdata		;// bit #
	 		addrp r1,p3				;
	 		mvrp  r1,p3				;
	 		ldrp  r1,p3				; // bit set
	 		not   r1,r1				; // bit clear
	 		inpp  r2,p1				; //x//
	 		and   r2,r1				;
	 		outpp r2,p1  			;
	 		bra   a_wend			;
a_w3:		cmprv r3,"t"			; // toggle bit
	 		bra   ne,a_w4			;
	 		mvrp  r2,p1				;
	 		ldpv  p3,h2btab			;
	 		ldr   r1,outdata		;// bit #
	 		addrp r1,p3				;
	 		mvrp  r1,p3				;
	 		ldrp  r1,p3				; // bit set
	 		inpp  r2,p1				; //x//
	 		xor   r2,r1				;
	 		outpp r2,p1  			;
	 		bra   a_wend			;
a_w4:		cmprv r3,"i"			; // pulse bit
	 		bra   ne,a_w5			;
	 		mvrp  r2,p1				;
	 		ldpv  p3,h2btab			;
	 		ldr   r1,outdata		;// bit #
	 		addrp r1,p3				;
	 		mvrp  r1,p3				;
	 		ldrp  r1,p3				; // bit set
	 		inpp  r2,p1				; //x//
	 		xor   r2,r1				;
	 		outpp r2,p1  			; //x//
	 		xor   r2,r1				;
	 		outpp r2,p1  			;
	 		bra   a_wend			;
a_w5:		cmprv r3,"a"			; // AND with MEMORY or PORT 16bits
	 		bra   ne,a_w6			;
	 		mvrp  r2,p1				;
	 		inpp  r3,p1				; //x//
	 		and   r1,r3				;
	 		outpp r1,p1  			;
	 		bra   a_wend			;
a_w6:		cmprv r3,"o"			; // AND with MEMORY or PORT 16bits
	 		bra   ne,a_w7			;
	 		mvrp  r2,p1				;   	
	 		inpp  r3,p1				; //x//
	 		or    r1,r3				;   	
	 		outpp r1,p1  			;
	 		bra   a_wend			;
a_w7:		cmprv r3,"e"			; // XOR with MEMORY or PORT 16bits
	 		bra   ne,a_w8			;
	 		mvrp  r2,p1				;   	
	 		inpp  r3,p1				; //x//
	 		xor   r1,r3				;   	
	 		outpp r1,p1  			;
	 		bra   a_wend			;
a_w8:		cmprv r3,"m"			; // memory access
			bra   ne,a_wend			;
			ldp   p1,inpaddr		;
			ldr   r3,memop			;
			andv  r3,3				;
			bra   z,a_w9			;
			ldmam m2				; // internal read , external write.  XWR
a_w9:		strp  r1,p1				;
a_wend:		ldmam m0				; // internal read , internal write.  IRW 
			jsr   tx_prmt   		;
			jsr   tx_prmt   		;
			rts             		;
                            
a_quit:		nop                		;
			jsr   tx_prmt      		;
			rts                		;

			// use user flag 5
memnext:	uflag 	t5				; // use memory pointer here
			ldp   	p1,memptr		;
			stp	  	p1,memptrlast	;
			jmp   	memdump0		;
memdump:	ldp   	p1,memptrlast	;
memdump0:	mvpr  	p1,r2			; // show current address
			jsr	  	dishex4			; // r2 contains the message pointer
			jsr	  	tx_prmt			; // CR-LF
			ldmam 	m0           	 ; // access internal memory for write/read
        	ldcv	c2,15			; // rows
        	ldr		r1,memode		;
			or		r1,r1			;// check for byte/word access
			bra		nz,memdumb1		;// nz byte, z word
        	// memory dump word
memdumw1: 	ldcv	c1,7			; // columns
memdumw2: 	ldr   	r1,memop		;
			andv  	r1,3			;
			bra   	z,rdmemw		;
			ldmam 	m1				; // external read , internal write.  XRD
rdmemw:		ldrpi 	r2,p1			;
        	ldmam 	m0            	; // internal read , internal write.  IRW
        	jsr   	dishex4      	; // display signed
			dcjnz 	c1,memdumw2		;
        	jsr   	tx_prmt      	; 
        	dcjnz 	c2,memdumw1  	;
        	jmp	  	f5,memdum4		;
        	stp   	p1,memptr    	;
        	uflag 	f5				;
        	jmp		memdum4			;
			// end
        	// memory dump byte
memdumb1: 	ldcv	c1,7			; // columns
memdumb2: 	ldr   	r1,memop		;
			andv  	r1,3			;
			bra   	z,rdmemb		;
			ldmam 	m1				; // external read , internal write.  XRD
rdmemb:		xor		r3,r3			;
			ldrpi	r2,p1			; // read buffer
			or		r3,r2			;
			ldrpi	r2,p1			;
			shl4	r2				;
			shl4	r2				;
			or		r3,r2			;
			swap	r3,r2			;
        	ldmam 	m0            	; // internal read , internal write.  IRW
        	jsr   	dishex4      	; // display signed
			dcjnz 	c1,memdumb2		;
        	jsr   	tx_prmt      	; 
        	dcjnz 	c2,memdumb1  	;
        	jmp	  	f5,memdum4		;
        	stp   	p1,memptr    	;
        	uflag 	f5				;
        	jmp		memdum4			;
			// end
memdum4:   	jsr   	tx_prmt      	;
         	rts                		;
         	
vardump: 	ldpv	p1,varchk	;
vardump0:	mvpr	p1,r2		; // show current address
			jsr		dishex4		; // r2 contains the message pointer
			jsr		tx_prmt		; // CR-LF
		 	ldmam	m0         	; // internal read , internal write.  IRW
         	ldcv	c2,7		; // rows
vardum1: 	ldcv	c1,7		; // columns
vardum2: 	ldrpi	r2,p1		;
         	jsr		dishex4    	; // display signed
		 	dcjnz	c1,vardum2	;
         	jsr		tx_prmt    	; 
         	dcjnz	c2,vardum1 	;
         	stp		p1,memptr  	;
			jsr		tx_prmt    	;
         	rts                	;
         	
			//################################
			// buffer length and address
			// length=r3, default 0
			// buff_addr = r2
setpar1:	ldpv	pC,hexval4_m    ; //
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r3,r2
			str		r3,buff_len 	; // buff_len  = r3
         	strx	r3,p7,IR_IX_LN	; //
			str		r2,buff_addr 	; // buff_addr = r2
         	strx	r3,p7,IR_IX		; //
			jsr		tx_prmt			; 
			rts		                ;

			//################################
			// buffer page and buff_addrx
			// page = r3, default 0
			// buff_addrx = r2
setpar2:	ldpv	pC,hexval4_m    ; //
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r3,r2
			andv	r3,'h0007		; // limit to 8 pages for testing
         	strx	r3,p7,SR_IX		; //
         	ldpag	r3				; // set address page reg = R3
			str		r2,buff_addrx 	; // destination address external RAM = 2
         	strx	r3,p7,ER_IX		; //
			jsr		tx_prmt			; 
			rts		                ;

			//################################
			// buffer dump
bufdump: 	ldp		p1,buff_addr	;
bufdump0:	mvpr	p1,r2			; // show current address
			jsr		dishex4			; // r2 contains the message pointer
			jsr		tx_prmt			; // CR-LF
		 	ldmam	m0         		; // internal read , internal write.  IRW
		 	ldr		r5,buff_len		;
		 	ldc		c2,r5			;
bufdum1: 	ldcv	c1,7			; // columns (this could be programmable too)
bufdum2: 	ldrpi	r2,p1			;
         	jsr		dishex4    		; // display signed
		 	dcjnz	c1,bufdum2		;
         	jsr		tx_prmt    		; 
         	dcjnz	c2,bufdum1 		;
         	stp		p1,memptr  		;
			jsr		tx_prmt    		;
         	rts                		;
         	
         	//################################
			// Memory fill parameters
			// example of fill memory address 34 with value 1
			// enter 0034 0001 or 0034,0001
			// example of fill memory address 1234 with value 5ac3
			// enter 1234 5ac3 or 1234,5ac3
			// address and value MUST BE 4 digits each
			// external memory support only 8 bits (1 byte)
			//################################
			// buffer length, increment
memlen:		ldpv	pC,hexval4_m    ; // RED/GREEN/BLUE
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r3,r2
			str		r3,buff_len 	; // 
			str		r2,buff_inc 	; // 
			jsr		tx_prmt			; 
			rts		                ;

			// Memory fill
			// buffer address,value (r2,r3)
memfill:	ldpv	pC,hexval4_m    ; // RED/GREEN/BLUE
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r3,r2
			str		r3,buff_addr 	; //
			str		r2,buff_value	; 
			mvrp	r3,p1			; // address   REG00
			ldr		r5,buff_inc		; // increment REG02
			ldr		r4,buff_len		; // length    REG03
			ldr   	r6,memop		;
			andv  	r6,3			;
			bra   	z,memfill2		;
			ldr		r1,memode		; // save memode before 
			ldmam 	m2				; // internal read , external write.  XWR
			or		r1,r1			; // check for byte/word access
			bra		nz,memfill3		;
memfill2:	strpi	r2,p1			; // word mode
			add  	r2,r5			;
			dec		r4				;
			bra		nz,memfill2		;
			bra		memfill4		;
			// big/little endian setup needed?
memfill3:	strpi	r2,p1			; // byte mode
			mvrr	r2,r3			;
			shr4	r3				; // Big Endian
			shr4	r3				;
			strpi	r3,p1			;
			add  	r2,r5			;
			dec		r4				;
			bra		nz,memfill3		;
memfill4:	ldmam 	m0				; // internal read , internal write.  IRW 
			jsr		tx_prmt			; 
			rts						;

   /////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////
   // System Subroutines
   /////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////
   // SESMA:   
   // Sequential State Machine
   // Search for k-value, return pointer to subroutine.
   // key in r1, pointer to table in p1.
   // all registers are save in stack.
sesma:   	strpi 	r2,pF            ;// push r2 and r3
         	strpi 	r3,pF            ;
         	ldp   	p1,ssm_pst       ; 
ssm_1:   	ldrp  	r2,p1            ;
         	or    	r2,r2            ;
         	bra   	e,ssm_2          ; 
         	cmpr  	r1,r2            ;
         	bra   	e,ssm_2          ;
         	mvpr  	p1,r3            ; // point to next state.
         	addv  	r3,4             ;
         	mvrp  	r3,p1            ; 
         	bra   	ssm_1            ;
ssm_2:   	ldrx  	r2,p1,1          ; // check code
         	cmprv 	r2,"R"           ; // "R" : restore last state ?
         	bra   	e,p_rest         ;
         	cmprv 	r2,"J"           ; // "J" : save state ?
         	bra   	e,p_jump         ;
         	cmprv 	r2,"S"           ; // "S" : jump to next state ?
         	bra   	ne,ssm_end       ;
p_save:  	ldr   	r2,ssm_pst       ; // read next state
         	str   	r2,ssm_lst       ; // save it 
p_jump:  	ldrx  	r2,p1,3          ; // read next state
         	str   	r2,ssm_pst       ; // 
         	bra   	ssm_end          ;
p_rest:  	ldr   	r2,ssm_lst       ;
         	str   	r2,ssm_pst       ;
ssm_end: 	ldrx  	r2,p1,2          ;// action
         	mvrp  	r2,p1            ;
         	ldrpd 	r3,pF            ;// pop r3 and r2
         	ldrpd 	r2,pF            ;
ssm_exec:	jmpp  	p1               ; // the called address must have a RTS.

			// Transmit ASCII text
   			// Transmit a single line
tx_line: 	jmp		f7,tx_ends		 ;
tx_line2:	inpp  	r3,pB	         ; // read status //x//
         	andv  	r3,TXEMPT        ; // transmit empty?
         	bra   	 z,tx_line2      ; // no , wait
tx_char: 	ldrpi 	r4,pC            ; // read character
         	cmprv 	r4,NULL          ; // Check end of line
         	bra   	z,tx_ends        ; //
			cmprv 	r4,"|"			 ;
			bra   	nz,tx_nxt		 ;
			ldcv 	c0,NUMFILL		 ; // number of user defined chars
tx_fill: 	inpp  	r3,pB	         ; // read status //x//
         	andv  	r3,TXFULL        ; // transmit full ?
         	bra   	nz,tx_fill       ; // yes, wait
         	ldrv  	r4,CHARFILL		 ; // the user char
			outpp 	r4,pA  			 ;
			dcjnz 	c0,tx_fill		 ;
         	bra   	tx_line2         ; // next one
tx_nxt:	 	outpp 	r4,pA            ; // output char //x//
         	inpp  	r3,pB	         ; //*read status //x//
         	andv  	r3,TXFULL        ; //*transmit full ?
         	bra   	nz,tx_line2      ; //*yes, wait
         	bra   	tx_char          ; // next character
tx_ends: 	rts						 ; // finished
   
   			// transmit a full page
tx_page: 	jmp		f7,tx_ends		 ;
tx_page2:	jsr   	tx_line          ; // read a line
         	mvpr  	pC,r1            ;
         	str   	r1,temp0         ; 
         	jsr   	tx_prmt          ; // output prompt
         	ldr   	r1,temp0         ;
         	mvrp  	r1,pC            ; 
         	ldrp  	r3,pC            ; // read current character
         	cmprv 	r3,ETX           ; // check for end of page
         	bra   	nz,tx_page2      ; // next line
         	rts                    	 ;

   			// Transmit prompt character
tx_prmtcr: 	jmp		f7,tx_ends		;
			ldpv  	pC,promptcr     ; // 
         	jsr   	tx_line         ; // output CR
         	rts                		; //

tx_prmtlf: 	jmp		f7,tx_ends		;
			ldpv  	pC,promptlf     ; // 
         	jsr   	tx_line         ; // output LF
         	rts                		; //

tx_prmt: 	jmp		f7,tx_ends		;
			ldpv  	pC,prompt       ; // 
         	jsr   	tx_line         ; // output CR-LF
         	rts                    	; //

tx_prmtx2:	jmp		f7,tx_ends		;
			ldpv  	pC,promptx2     ; // 
         	jsr   	tx_line         ; // output CR-LF-CR-LF
         	rts                    	; //

   			// Check for Transmitt ready
chkstat: 	inpp  	r1,pB	         ; // read status //x//
         	andv  	r1,TXFULL        ; // transmit full ?
         	bra   	nz,chkstat       ; // yes, wait
         	rts                    ;
   
   			// Convert HEX value to ASCII
   			// register usage:
   			// Inputs:  R2
   			// Outputs:  hex1val, hex2val
hex2asc: 	strpi 	r2,pF            ; // push
         	andv  	r2,'h00F         ;
         	cmprv 	r2,'h00A         ;
         	bra   	lt,hex1          ;
         	addv  	r2,'h007         ;
hex1:    	addv  	r2,'h030         ;
         	str   	r2,hex1val         ;
         	ldrpd 	r2,pF            ; // pop
         	shr4  	r2               ; // shift right 4 logical
         	andv  	r2,'h00F         ;
         	cmprv 	r2,'h00A         ;
         	bra   	lt,hex2          ;
         	addv  	r2,'h007         ;
hex2:    	addv  	r2,'h030         ;
         	str   	r2,hex2val         ; 
         	rts                    ;

   			// Convert ASCII to HEX used by USB
   			// register usage:
   			// Inputs:  R1
   			// Outputs: R2
tohex2:  	mvrr  	r1,r2            ; // save it
         	andv  	r1,'h00ff        ; 
         	subv  	r1,'h030         ; // remove any unwanted char
         	cmprv 	r1,9             ;
         	bra   	ls,tohex21       ;
         	andv  	r1,'h000f        ; 
         	addv  	r1,9             ;
tohex21: 	shr4  	r2               ;
         	shr4  	r2               ;
         	andv  	r2,'h00ff        ; 
         	subv  	r2,'h030         ; // remove any unwanted char
         	cmprv 	r2,9             ;
         	bra   	ls,tohex22       ;
         	andv  	r2,'h000f        ; 
         	addv  	r2,9             ;
tohex22: 	shl4  	r2               ;
         	andv  	r2,'h00f0        ; 
         	or    	r2,r1            ;
         	rts                    	; 

   			// Convert ASCII to HEX used by UART
   			// register usage:
   			// Used Flags: uflag 6
   			// Used Reg: R1
   			// Outputs:  R2,R3
asc2hex: 	xor   	r2,r2           ; // clear result register
		 	xor   	r3,r3           ; // clear result register
		 	uflag 	f6				;
rd_hex1: 	jsr   	rdchar          ;
         	jmp		f7,no_out_ch	;
			outpp 	r1,pA           ; //x// output char
no_out_ch: 	cmprv 	r1,CR           ;
         	bra   	z,rd_hex9       ;
         	cmprv 	r1,LF           ;
         	bra   	z,rd_hex9       ;
		 	cmprv 	r1,"-"			;
		 	bra   	ne,noneg		;
		 	uflag 	t6				;
noneg:	 	subv  	r1,'h030  		; // remove any unwanted char
         	bra   	s,rd_hex1 		; // reset counters.
         	shl  	l,r2      		; 
         	shl  	k,r3      		; 
         	shl  	l,r2      		; 
         	shl  	k,r3      		; 
         	shl  	l,r2      		; 
         	shl  	k,r3      		; 
         	shl  	l,r2      		; 
         	shl  	k,r3      		; 
         	cmprv 	r1,9      		;
         	bra   	ls,rd_hex2		;
         	andv  	r1,'h00F  		; // must be a-f
         	addv  	r1,9      		;
rd_hex2: 	or    	r2,r1     		;
         	bra   	rd_hex1   		;
rd_hex9: 	jmp   	f6,rd_hexa		;
		 	not   	r2,r2			;
		 	not   	r3,r3			;
		 	addv  	r2,1			;
rd_hexa: 	rts                    	; 

			// display single digit from 0 to 9
			// digit in R2
disdigit:	addv	r2,'h30			; // convert to ASCII
			outpp	r2,pA           ; // display value
			ldrv	r2,CR			;
			outpp	r2,pA           ; // carriage return
			rts		                ;

   			// Display 2 or 4 hex values.
dishexs: 	mvrr  	r2,r3	       	;
		 	andv  	r3,SIGNED       ;
		 	bra   	z,dishex4       ;
		 	not   	r2	       		;
		 	addv  	r2,1			;
		 	ldrv  	r3,"-"			;
		 	outpp 	r3,pA  			; //x//
dishex4: 	mvrr  	r2,r3   		;
         	shr4  	r2      		;
         	shr4  	r2      		; 
         	jsr   	hex2asc 		; 
         	ldr   	r1,hex2val		;
         	outpp 	r1,pA   		;
         	jsr   	chkstat 		; 
         	ldr   	r1,hex1val		;
         	outpp 	r1,pA  			;
         	mvrr  	r3,r2   		;
dishex2: 	jsr   	hex2asc 		; 
         	ldr   	r1,hex2val		;
         	outpp 	r1,pA   		;
         	jsr   	chkstat 		; 
         	ldr   	r1,hex1val		;
         	outpp 	r1,pA   		;
         	jsr   	chkstat 		; 
         	ldrv  	r1,SPC  		;
         	outpp 	r1,pA   		;
         	rts             		; 
      
rdchar:  	inpp  	r1,pB			; // read status reg
         	bitv  	r1,RXDVLD		; // mask data valid bit
         	bra   	z,rdchar 		; // read again
         	inpp  	r1,pA	 		; // read data reg
         	andv  	r1,'hFF  		; // mask data
         	str   	r1,inpchar		; // save it
			rts						; // return in R1
   
			// Setup real time clock
setyear: 	ldpv  	pC,hexval4_m	; // RTC setup
         	jsr   	tx_line			;
         	jsr   	asc2hex			; // return in r2
		 	str		r2,tmr1year		;
         	jsr   	tx_prmt			; 
         	rts						;
	     	      	
setmonth: 	ldpv  	pC,hexval4_m	; // RTC setup
         	jsr   	tx_line			;
         	jsr   	asc2hex			; // return in r2
		 	str		r2,tmr1month	;
         	jsr   	tx_prmt			; 
         	rts						;
	     	      	
setdate: 	ldpv  	pC,hexval4_m	; // RTC setup
         	jsr   	tx_line			;
         	jsr   	asc2hex			; // return in r2
		 	str		r2,tmr1date		;
         	jsr   	tx_prmt			; 
         	rts						;

sethour: 	ldpv  	pC,hexval4_m	; // RTC setup
         	jsr   	tx_line			;
         	jsr   	asc2hex			; // return in r2
		 	str		r2,tmr1hour		;
		 	xor		r2,r2			;
		 	str		r2,tmr1min		;
		 	str		r2,tmr1sec		;
         	jsr   	tx_prmt			; 
         	rts						;
	     	      	
setmin: 	ldpv  	pC,hexval4_m	; // RTC setup
         	jsr   	tx_line			;
         	jsr   	asc2hex			; // return in r2
		 	str		r2,tmr1min		;
		 	xor		r2,r2			;
		 	str		r2,tmr1sec		;
         	jsr   	tx_prmt			; 
         	rts						;
	     	      	
setsec: 	ldpv  	pC,hexval4_m	; // RTC setup
         	jsr   	tx_line			;
         	jsr   	asc2hex			; // return in r2
		 	str		r2,tmr1sec		;
         	jsr   	tx_prmt			; 
         	rts						;
	     	      	
         	// Setup scope and trigger sources      	
d_scpsrc:	ldpv  	pC,hexval4_m     ; // scope source
         	jsr   	tx_line          ;
         	jsr   	asc2hex          ; // return in r2
         	andv  	r2,'h0003        ; // limit to 3
		 	shl4  	r2				;
		 	shl4  	r2				;
		 	shl4  	r2				;
		 	inp   	r1,GPREG_07     	;
         	andv  	r1,SCOPE_NSK    	;
         	or    	r1,r2	       	;
         	outp  	r1,GPREG_07     	;
         	jsr   	tx_prmt          ; 
         	rts   	                 ;
	     	      	
d_trgsrc:	ldpv  	pC,hexval4_m     ; // trigger source
         	jsr   	tx_line          ;
         	jsr   	asc2hex          ; // return in r2
         	andv  	r2,'h0003        ; // limit to 0 to 3
		 	shl4  	r2		;
		 	shl4  	r2		;
		 	shl4  	r2		;
		 	shl   	r2		;
		 	shl   	r2		;
		 	inp   	r1,GPREG_07     	;
         	andv  	r1,TRIGS_NSK     ;
         	or    	r1,r2	        ;
         	outp  	r1,GPREG_07     	;
         	jsr   	tx_prmt          ; 
         	rts                    ;

			// target reset pulse
d_target:	inp		r1,GPREG_07     ; // reset target
         	andv  	r1,TARGET_NSK   ;
		 	orv   	r1,TARGET_MSK	;
         	outp  	r1,GPREG_07     ;
			ldcv	c0,10  			; //
d_target2:	nop						;
			nop						;
			dcjnz	c0,d_target2	;
			nop;
         	andv  	r1,TARGET_NSK   ;
         	outp  	r1,GPREG_07     ; 
         	ldpv  	pC,treset_m     ; // display message
         	jsr   	tx_line         ; // message out.
         	jsr   	tx_prmtx2       ; 
         	rts                    	;
	
d_pcode:	ldpv  	pC,hexval4_m     ; // pcode value must be equal to PCODE_MSK
         	jsr   	tx_line          ;
         	jsr   	asc2hex          ; // return in r2
         	andv  	r2,PCODE_MSK     ; // r2 = PCODE_MSK to set to 1
		 	inp   	r1,GPREG_07    	 ;
         	andv  	r1,PCODE_NSK   	 ;
         	or    	r1,r2	       	 ;
         	outp  	r1,GPREG_07      ;
         	jsr   	tx_prmt          ; 
         	rts   	                 ;
	     	      	
  
			// Enable interrupts
irq_set:	ldpv	pC,hexval4_m    ;
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r2
			str		r2,irqmask    	; //
			or		r2,r2			; // temporary
			bra		z,irq_dis		;
irq_enb:	sei						;
			uport	t4				; // IRQ ON
			rts						; 
irq_dis:	cli						;
			uport	f4				; // IRQ OFF
			rts		                ;

			// page number selects external SRAM block 
d_pagenum:	ldpv	pC,hexval4_m    ; // 
         	jsr   	tx_line         ;
d_pagenum2:jsr   	asc2hex         ; // return in r2,r3
			andv	r2,'h0007		; // limit to 8 pages for testing
         	strx	r2,p7,SR_IX		; // SRAM page setup
         	ldpag	r2				; // set address page reg = R2
			jsr		tx_prmt			; 
d_pagenum3:	rts						;

			// Save buffer into external SRAM
savebuf:	ldp		p1,buff_addr	; // Intrernal RAM address
			ldp		p2,buff_addrx	; // External SRAM address
			ldr		r4,buff_len		; // buffer length
			ldmam	m2				; // internal read , external write.  XWR
savebuf1:	ldcv	c0,1			; // 2 bytes
			ldrpi	r2,p1			; // read buffer
savebuf2:	strpi	r2,p2			; // write to SRAM
			shr4	r2				;
			shr4	r2				;
			dcjnz	c0,savebuf2		;
			dec		r4				;
			bra		nz,savebuf1		;
			ldmam	m0				; // internal read , internal write.  IRW 
			mvpr	p1,r1			;
			strx	r1,p7,IRL_IX	; // internal RAM pointer last
			mvpr	p2,r1			;
			strx	r1,p7,ERL_IX	; // external SRAM pointer last
			jsr		tx_prmt			; 
			rts		                ;
			
			// Restore buffer into internal SRAM
restorebuf:	ldp		p1,buff_addr	;
			ldp		p2,buff_addrx	; // SRAM address
			ldr		r4,buff_len		; // number of pixels
			ldmam	m1				; // external read , internal write.  XRD
restorebuf1:xor		r3,r3			;
			ldrpi	r2,p2			; // read buffer
			or		r3,r2			;
			ldrpi	r2,p2			;
			shl4	r2				;
			shl4	r2				;
			or		r3,r2			;
			strpi	r3,p1			;
			dec		r4				;
			bra		nz,restorebuf1	;
			ldmam	m0				; // internal read , internal write.  IRW
			mvpr	p1,r1			;
			strx	r1,p7,IRL_IX	; // internal RAM pointer last
			mvpr	p2,r1			;
			strx	r1,p7,ERL_IX	; // external SRAM pointer last
			jsr		tx_prmt			; 
			rts		                ;
			
	////////////////////////////////////////////////////////////
	// Basic Functions
	////////////////////////////////////////////////////////////
	// DIVISION
	//		R6 = result  
	//		R5 = numerator
	//		R4 = denominator
	//		R3 = residual
division:	xor		r6,r6			; // clear result
divstart:	sub		r5,r4			;
			bra		s,divend	   	;
			mvrr	r5,r3      		; // residual = numpixels/colorseg
			inc		r6				;
			bra		divstart  		;
divend:		rts						;		

	////////////////////////////////////////////////////////////
	// Interrupt vectors
	////////////////////////////////////////////////////////////
	// ~30uSec pulsepixel counter
hw_irq1:	uport	t8				;
			uport	f8				;
			rti						;
                                	
	// ~3mSec pulse Strip counter, reset strip
hw_irq2:	uport	t9				;
hw_irq2_1:	uport	f9				;
			rti						;
			
	// 1 mSec pulse timer
hw_irq3:	ldr		r1,tmr1msec		;
			or		r1,r1			;
			bra		z,hw_irq3_1		;
			dec		r1				;
			str		r1,tmr1msec		;
			bra		hw_irq3_2		;
hw_irq3_1:	uflag	tE				; // tmr1msec  = 0, flag clear by routine
hw_irq3_2:	rti						;
			  
	// 1 sec pulse for calendar
hw_irq4:	ldr		r2,tmr1min		; // current minutes
			ldr		r3,tmr1hour		; // current hours
			ldr		r4,tmr1date		; // current days
			mvrr	r4,r7			; // save day/date		
			ldr		r5,tmr1month	; // current months
			ldr		r6,tmr1year		; // current year
			ldr		r1,tmr1sec		; // current seconds
			inc		r1				;
			cmprv	r1,60			; // 1 minute
			bra		lt,hw_irq4_1	;
			xor		r1,r1			;
			inc		r2				;
			cmprv	r2,60			; // 1 hour
			bra		lt,hw_irq4_2	;
			xor		r2,r2			;
			uflag	tA				; // one hour flag
			inc		r3				;
			cmprv	r3,24			; // 1 day
			bra		lt,hw_irq4_3	;
			xor		r3,r3			;
			andv	r4,'h00ff		;
			andv	r7,'hff00		;
			shr4	r7				;
			shr4	r7				;
			inc		r7				;
			cmprv	r7,6			; // check for SUN
			bra		lt,hw_irq4_6	;
			xor		r7,r7			; // back to MON
hw_irq4_6:	shl4	r7				;
		 	shl4	r7				;
		 	inc		r4				;
			cmprv	r4,31			; // 1 month
			bra		lt,hw_irq4_7	;
			ldrv	r4,1			;
hw_irq4_7:	or		r4,r7			;			
			inc		r5				;
			cmprv	r5,12			; // 1 year
			bra		lt,hw_irq4_5	;
			xor		r5,r5			;
			inc		r6				;
			str		r6,tmr1year	; 
hw_irq4_5:	str		r5,tmr1month	; 
hw_irq4_4:	str		r4,tmr1date		; 
hw_irq4_3:	str		r3,tmr1hour		; 
hw_irq4_2:	str		r2,tmr1min		; 
hw_irq4_1:	str		r1,tmr1sec		; 
			rti						;

	// SWI #1
sw_irq1:	rti						;  

   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Application routines
   //////////////////////////////////////////////////////////////////////
   // Don't overwrite dedicated pointers like:
   // p0,p7,pA,pB,pD,pF
   //////////////////////////////////////////////////////////////////////
   
   // Here your test/application routine
   // remember to load pjump variable with myapp address
   // or initialize pjump with test_name
   // pjump: dw test_name; // default myapp
   //
myapp:		jsr		test_arith		;
         	ldpv	pD,tempvar1		; // restore pointer
			rts						; // uses the push return address
			
			// Application code   
test_arith:	// ADD two negative numbers
			ldrv	rA,'h8000		;
			ldrv	rB,'h8000		;
			add		rA,rB			; // rA=0000, carry=1
			strpi	rA,pD			;
   
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
			// ends Application code

			// enable application/ test routine to run once 
runapp:		uflag	t3				;
			rts						;

   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Data Section
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////

version_m:	dt "SW:030922-03 test_arith_full";
				//SoftWare version-revision
				//    - version     mmddyy
				//    - revision        nn
				
   //////////////////////////////////////////////////////////////////////
   // System Constants and Menu Messages
   //////////////////////////////////////////////////////////////////////

memof_m:	dt  " Internal Memory Access"; 
memon_m:	dt  " External Memory Access";
   
membyte_m:	dt  " Byte Memory Access"; 
memword_m:	dt  " Word Memory Access";
   
hexval4_m:	dt  " Enter value [RET] = ";
         
treset_m:	dt  " Target Reset done";

promptx2:	dw  CR; // 0x0D
         	dw  LF; // 0x0A
prompt:		dw  CR; // 0x0D
promptlf:	dw  LF; // 0x0A
			dw  NULL; // terminator
promptcr:	dw  CR; // 0x0D
			dw  NULL; // terminator
			
// hex to binary for bit manipulation
h2btab:		dw  'h0001,'h0002,'h0004,'h0008 ;
	 		dw  'h0010,'h0020,'h0040,'h0080 ;
	 		dw  'h0100,'h0200,'h0400,'h0800 ;
	 		dw  'h1000,'h2000,'h4000,'h8000 ;
	 		
// Clear Screen
cls_m:		dw	ESC				; // VT100 escape sequence
			dt	"[2J"			; // Clear screen
			dw  NULL			; // terminator
// Cursor Home
chome_m:	dw	ESC				; // VT100 escape sequence
			dt	"[H"			; // Home
			dw  NULL			; // terminator
			
	
   //////////////////////////////////////////////////////////////////////
   // Menu Tables   
   //////////////////////////////////////////////////////////////////////
   // Field definitions:   

   // VALUE  :  input key or single value.
   // JCODE  :  "J" -> jump to next state.
   //           "S" -> save present state and jump to next state
   //           "R" -> restore last state to present state and jump into it.
   // ARADD  :  Action routine address
   // NXST   :  Next state address

   ///////////////////////////////
   // SESMA for UART state machine
   ///////////////////////////////
         //    VALUE PCODE  ARADD    NXST
		 // Main Menu
kpst00:  dw    "d"  ,"J" , d_debug,  kpst10; //memory/register access
         dw    "s"  ,"J" , d_sysset, kpst30; //system setup
         dw    "a"  ,"J" , d_appset, kpst40; //application setup
         dw    "v"  ,"J" , d_prgver, kpst00; //program version
         dw    "L"  ,"J" , BOOT_ADDR,kpst00; //load program
         dw    "E"  ,"J" , echo_on,  kpst00; //set echoflag
         dw    "e"  ,"J" , echo_off, kpst00; //clear echoflag (default)
         dw    "C"  ,"J" , enbscreen,kpst00; //enable clearscreen
         dw    "c"  ,"J" , disscreen,kpst00; //disable clearscreen
         dw    "I"  ,"J" , irq_set,  kpst00; //enable interrupts
         dw    "k"  ,"J" , d_rtcval, kpst00; //display RTC
         dw    NULL ,"J" , d_menu,   kpst00; //d_menu
   
         // Debug Menu
kpst10:  dw    "A"  ,"J" , d_mema,   kpst10; //memory access mode
         dw    "B"  ,"J" , d_memb,   kpst10; //memory byte mode
         dw    "P"	,"J",  d_pagenum,kpst10; // set page SRAM
         dw    "d"  ,"J" , memdump,  kpst10; // memory display
         dw    "n"  ,"J" , memnext,  kpst10; // memory display
         dw    "f"  ,"J" , memfill,  kpst10; // memory fill
         dw    "l"  ,"J" , memlen,	 kpst10; // memory fill
         dw    "m"  ,"S" , s_bitop,  wpst01; //memory
         dw    "w"  ,"S" , s_bitop,  wpst01; //write register
         dw    "s"  ,"S" , s_bitop   wpst01; // set bit
         dw    "c"  ,"S" , s_bitop,  wpst01; // clear bit
         dw    "t"  ,"S" , s_bitop,  wpst01; // toggle bit
         dw    "i"  ,"S" , s_bitop,  wpst01; // pulse bit
         dw    "a"  ,"S" , s_bitop,  wpst01; // and reg with value
         dw    "o"  ,"S" , s_bitop,  wpst01; // or reg with value
         dw    "e"  ,"S" , s_bitop,  wpst01; // and reg with value
         dw    "b"  ,"J" , d_base,   kpst10; // base reg address 
         dw    "r"  ,"J" , d_aregs,  kpst10; //display all regs
         dw    "v"  ,"J" , vardump,  kpst10; // memory display
         dw    "h"  ,"J" , d_help,   kpst10; //display the help notes
         dw    "x"  ,"J" , d_menu,   kpst00; // return
         dw    " "  ,"J" , d_debug,  kpst10;
         dw    NULL ,"J" , d_nothing,kpst10;
   
         // Available
kpst20:  dw    "h"  ,"J" , d_help,   kpst20; //display the help notes
         dw    "x"  ,"J" , d_menu,   kpst00; //return to main
         dw    NULL ,"J" , d_help,   kpst20; //
   
         // System Menu
kpst30:  dw    	"s" ,"J", d_scpsrc, kpst30; // scope source
         dw    	"t" ,"J", d_trgsrc, kpst30; // scope source
         dw    	"b" ,"J", d_base,   kpst30; // base reg address 
         dw    	"r" ,"J", d_aregs,  kpst30; // display all regs
         dw    	"w" ,"S", s_bitop,  wpst01; // write register
         dw     "R" ,"J", d_target, kpst30; // target reset.
         dw     "W" ,"J", d_pcode,  kpst30; // pcode set, make program RAM writable or not
         dw     "Y" ,"J", setyear,  kpst30; // set RTC
         dw     "M" ,"J", setmonth, kpst30; // set RTC
         dw     "D" ,"J", setdate,  kpst30; // set RTC
         dw     "H" ,"J", sethour,  kpst30; // set RTC
         dw     "U" ,"J", setmin,   kpst30; // set RTC
         dw     "S" ,"J", setsec,   kpst30; // set RTC
         dw     "k" ,"J", d_rtcval, kpst30; // display RTC
         dw		"v" ,"J", vardump, 	kpst30; // memory dump z variables
         dw    	"x" ,"J", d_menu,   kpst00; //return to main
         dw     NULL,"J", d_sysset, kpst30; //
   
         // Application Menu
kpst40:  dw     "a" ,"J",  runapp,		kpst40; // run app once
         dw     "1" ,"J",  setpar1,		kpst40; // buffer source, length
         dw     "2" ,"J",  setpar2,		kpst40; // page number, buffer destination
         dw     "d" ,"J" , bufdump,     kpst40; // memory dump buffer address/length
		 dw		"S"	,"J",  savebuf, 	kpst40; // save buffer to Ext SRAM
         dw		"R"	,"J",  restorebuf, 	kpst40; // restore buffer from Ext SRAM
         dw     "k" ,"J",  d_rtcval,    kpst40; // display RTC
         dw    	"r" ,"J",  d_aregs,     kpst40; // display all regs
         dw     "v" ,"J",  vardump,     kpst40; // varcheck display
         dw     "h" ,"J",  d_helpa,     kpst40; // display the help notes
         dw     "x" ,"J",  d_menu,   	kpst00; // return to main
         dw     NULL,"J",  d_appset, 	kpst40; //
   
   ///////////////////////////////
   // Table for Write registers
   ///////////////////////////////
   //    VALUE PCODE  ARADD    NXST
wpst00:  dw    CR   ,"R" , a_quit,   kpst00; //do nothing
         dw    "q"  ,"R" , a_quit,   kpst00; //do nothing
         dw    NULL ,"J" , a_regdat, wpst00; //display menu
   
wpst01:  dw    ","  ,"J" , a_setadd, wpst02; //set addr and wait for data
         dw    " "  ,"J" , a_setadd, wpst02; //set addr and wait for data
         dw    "-"  ,"J" , a_setadd, wpst03; //set addr and wait for -data
         dw    "n"  ,"J" , a_setadd, wpst03; //set addr and wait for -data
         dw    CR   ,"R" , a_getval, kpst00; //get current value
         dw    "q"  ,"R" , a_quit,   kpst00; //do nothing
         dw    NULL ,"J" , a_getadr, wpst01; //get 4 characters
   
wpst02:  dw    CR   ,"R" , a_wrval1, kpst00; //write reg and return
         dw    "q"  ,"R" , a_quit,   kpst00; //do nothing
         dw    NULL ,"J" , a_regdat, wpst02; //display menu
   
wpst03:  dw    CR   ,"R" , a_wrval2, kpst00; //write reg and return
         dw    "q"  ,"R" , a_quit,   kpst00; //do nothing
         dw    NULL ,"J" , a_regdat, wpst03; //display menu
   
   //////////////////////////////////////////////////////////////////////
   // Menu Messages
   // '|' character start a sequence of user define chars like '-'
   // Defined in tx_line subroutine
   //////////////////////////////////////////////////////////////////////
menu:    dt    "|Main Menu|"; 
         dt    " a = application";
         dt    " s = system setup";
         dt    " d = debug"; 
         dt    " v = version"; 
         dt    " E = Echo ON"; 
         dt    " e = echo OFF"; 
         dt    " C = Clear screen/Home ON"; 
         dt    " c = Clear screen/Home OFF"; 
         dt    " I = IRQ mask"; 
         dt    " k = display clock ";
         dt    " L = Load Program *.mem"; 
         dt    "|||"; 
         dw    ETX;// end of page 
   
debug_m: dt    "|Memory/Register/IO Menu|"; 
         dt    " A = memory Access mode"; 
         dt    " B = memory Byte   mode"; 
         dt    " P = external memory Page"; 
         dt    " m = Memory write/read"; 
         dt    " d = Memory dump"; 
         dt    " n = Next dump";
         dt    " f = fill memory address/value (AAAA,vvvv)"; 
         dt    " l = set length/increment (LLLL,iiii)"; 
         dt    ""; 
         dt    " w = Write/read port/register"; 
         dt    " s = Set reg bit"; 
         dt    " c = Clear reg bit"; 
         dt    " t = Toggle reg bit"; 
         dt    " i = Pulse reg bit"; 
         dt    " a = and"; 
         dt    " o = or"; 
         dt    " e = xor"; 
         dt    ""; 
         dt    " b = set Base I/O/Registers address"; 
         dt    " r = Read all Input ports/registers"; 
         dt    " v = display variables";
         dt    ""; 
         dt    " h = HELP"; 
         dt    " x = exit";
         dt    "||||";	
         dw    ETX;// end of page
	
sysset_m:dt    "|System Setup|"; 
         dt    " t = trigger source ( 0 to 3)"; 
         dt    " s = scope Source ( 0 to 3)"; 
		 dt    "";
         dt    " b = set Base reg address"; 
         dt    " r = Read all registers"; 
         dt    " w = Write/read port/register"; 
         dt    ""; 
         dt    " Y = Year";
         dt    " M = Month";
         dt    " D = day/DATE";
         dt    " H = Hour";
         dt    " U = minUte";
         dt    " S = Sec";
         dt    " k = display clock ";
         dt    ""; 
         dt    " R = target Reset";
         dt    " W = Write protect (2 or 0)";
         dt    " v = display variables";
         dt    " x = exit";
         dt    "|||"; 
         dw    ETX;// end of page
   
appset_m:dt    "|Application|";
         dt    " a = run myapp once"; 
         dt    ""; 
         dt    " 1 = set int RAM buff_length,buff_addr"; 
         dt    " 2 = set ext RAM page and address"; 
         dt    " S = Save buffer"; 
         dt    " R = Restore buffer"; 
         dt    ""; 
         dt    " d = dump buff_addr"; 
         dt    " r = Read all registers"; 
         dt    " v = display variables";
         dt    ""; 
         dt    " k = display clock ";
         dt    " h = HELP"; 
         dt    " x = exit";
         dt    "|||"; 
         dw    ETX;// end of page
   
help_a:  dt    "| H E L P |"; 
         dt    " Space key will refresh the screen"; 
         dt    " Enter x to exit (previous menu)"; 
         dt    " Enter values in HEXADECIMAL (0-9, a-f)"; 
         dt    ""; 
         dt    "| Commands |"; 
         dw    ETX;// end of page 
         
help_m:  dt    "| H E L P |"; 
         dt    " Space key will refresh the screen"; 
         dt    " Enter x to exit (previous menu)"; 
         dt    " Enter values in HEXADECIMAL"; 
         dt    ""; 
         dt    "| Memory Commands |"; 
         dt    " A = Memory access (toggle)";
         dt    " B = Memory byte mode (toggle)";
         dt    " m = Memory read/write: (MEM ADDR)";
		 dt    " ___ [m]addr[RET] read and set address"  ;
		 dt    " ___ [m]addr,val[RET] write value"  ;
         dt    " d = dump memory from address 0";
         dt    " n = next 256 memory from last address";
         dt    " f = fill memory with value + increment";
         dt    " ___ addr,value = aaaa,vvvv (comma or space)";
         dt    " l = memory length and increment";
         dt    " ___ length,increment = llll,iiii (comma or space)";
         dt    " ___ aaaa,vvvv,llll,iiii mandatory 4 digits";
         dt    ""; 
         dt    "| Register Commands |"; 
         dt    " w = Write Output Port/Register: (full address)"; 
         dt    " ___ [w]addr[RET] read port"; 
         dt    " ___ [w]addr,val[RET] delimeter comma"; 
         dt    " ___ [w]addr val[RET] delimiter space"; 
         dt    " ___ [w]addr'n'val[RET] one's complement"; 
         dt    " ___ [w]addr'-'val[RET] two's complement"; 
         dt    ""; 
         dt    "[s/c/t/i]regaddr,bit[RET] (bit=0 to F)"; 
         dt    "[a/o/e]  regaddr,mask[RET]"; 
         dt    ""; 
         dt    " b = set register Base address";
         dt    " r = Read 16 Registers(BASE ADDR + 0 to F)";
         dt    "|||"; 
         dw    ETX;// end of page 
         
   //////////////////////////////////////////////////////////////////////
   // Application Constants
   //////////////////////////////////////////////////////////////////////
         
zend_code: // mark the end of code
         dw	zend_code;
         
   //////////////////////////////////////////////////////////////////////
   //
   // Work Area, Stack Area, Writable RAM
   //
   //////////////////////////////////////////////////////////////////////

memptr:	 	dw 0			; // holds the pointer memory address
memptrlast:	dw 0			; // holds previous pointer address

hex1val:   	dw 0   			; // hex value
hex2val:   	dw 0   			; // hex value
cvalue1: 	dw 0           ; // character value
cvalue2: 	dw 0           ; // character value

inpchar: 	dw 0           ; // usb/uart input character.
inpaddr: 	dw 0           ; // address
outdata: 	dw 0           ; // data
uartstat:	dw 0			; // UART status
	
bitop:	 	dw "w"   		;
delimeter:	dw 0 			;
temp0:   	dw 0			; // temporary scratch pad.
regptr:  	dw BASEREGIO	; // Base register address pointer

echomode:	dw 1			; // default is on
	
   //////////////////////////////////////////////////////////////////////
   // Application Variables
   //////////////////////////////////////////////////////////////////////
varchk:
buff_addr:	dw	tempvar1		; // default this address
buff_len:	dw	15				; // default 16
buff_addrx:	dw	0				;
buff_value:	dw	0				;
buff_inc:	dw	0				;
memode:		dw	0				; // word/byte = 0/1, default word
memacc:		dw	0				; // internal/external = 0/1, default internal
			dw	0				; // gap
			
tmr1msec:	dw	0				; // timer 1mS
tmr1value:	dw	100				; // timer recurrent value
irqmask:	dw	1				; // default irq 1
ssm_pst: 	dw	kpst00			; // present state
ssm_lst: 	dw	kpst00			; // last state (return state)
pjump:		dw	myapp			; // table jump
			dw	0				; // gap
memop:	 	dw  0     			; // IRW,XRD,XWR,XRW (0,1,2,3) 

tmr1year:	dw	YEAR			; // yyyy : timer 12 M = 1Y
tmr1month:	dw	MONTH			; // 00mm : timer 28/29/30/31 D = 1M
tmr1date:	dw	DATE			; // ddDD : timer 24 H = 1D, dd = 0 to 6 (MON to SUN)
tmr1hour:	dw	HOUR			; // 00hh : timer 60 m = 1H
tmr1min:	dw	MINUTE			; // 00mm : timer 60 s = 1m
tmr1sec:	dw	SECONDS			; // 00ss : timer 1S
			dw	0				; // gap			
			dw	0				; // gap
			
dbugptr:	ds	8				; // p7 = dbugptr,variables for debugging

   //////////////////////////////////////////////////////////////////////
   // Stack area
   //////////////////////////////////////////////////////////////////////
stack:	ds STACK_LENGTH    	; // stack area

   //////////////////////////////////////////////////////////////////////
   // Temporary space for results of any operations
   //////////////////////////////////////////////////////////////////////
tempvar1:	ds	64				; // pD = tempvar1,
tempvar2:	ds	64				; // pE = tempvar2,

zend_ram:  // mark the end of writable RAM area

			
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // BOOT LOADER
   // Loads a program file into memory.
   // The program file is ASCII hex with extension .mem
   // The first value is the length of the program.
   // If the first character received is the ESC key
   // the boot loader aborts the download
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Write program memory.
@BOOT_ADDR
zboot_addr:
         cli                    ; // clear interrupts
         nop					; // allow to clear any pending interrupts
         uport f4				; // IRQ OFF
boot_p:  uport f7               ; // clear port.
         ldrv  r1,"<"           ; // Load program memory from
         outpp r1,pA,0          ; // external text file.
boot_ch: inpp  r1,pB	        ; // read status reg
         andv  r1,RXDVLD        ; // mask data valid bit
         bra   z,boot_ch        ; // read again
         inpp  r1,pA	        ; // read data reg
         andv  r1,'h0FF         ; // mask upper bits.
         cmprv r1,"#"           ; // check for header :  #4000
         bra   e,boot_fh        ; // found header
         cmprv r1,ESC           ; // abort ?
         bra   ne,boot_ch       ; // no, keep reading
         jmp   end_boot         ; // exit requiered by user
boot_fh: uflag f7               ; // clear user flag.
         uport t7               ; // indicates found header
         // Start with program memory, the first 16 bit word is the
         // program length.
boot_p0: ldpv  p1,0             ;
boot_p1: ldcv c2,3              ; 
         xor   r2,r2            ; // clear result
boot_p2: shl4  r2               ; 
boot_p3: inpp  r1,pB	        ; // read status reg
         andv  r1,RXDVLD        ; // mask data valid bit
         bra   z,boot_p3        ; // read again
         inpp  r1,pA	        ; // read data reg
         andv  r1,'h0FF         ; // mask upper bits.
         subv  r1,'h030         ; // remove any unwanted char
         bra   s,boot_p3        ; // reset counters.
         cmprv r1,9             ;
         bra   ls,boot_p4       ;
         andv  r1,'h00F         ; // must be a-f
         addv  r1,9             ;
boot_p4: or    r2,r1            ;
         dcjnz c2,boot_p2       ;
	 	 nop					;
         jmp   t7,boot_p4b      ; // test flag
         mvrr  r2,ra            ; // program length.
         str   ra,prog_lng      ; // store program length.
         uflag t7               ; // start of program
         bra   boot_p0          ; 
   
boot_p4b:mvpr  p1,r1            ; // start taking data
         cmprv r1,boot_p        ;
         bra   hs,boot_p5       ; 
         strpi r2,p1            ; // store in program memory
         bra   boot_p6          ; 
boot_p5: ldrv  r0,"*"           ;
         bra   boot_p7          ;
boot_p6: ldrv  r0,"."           ; 
boot_p7: outpp r0,pA,0          ;
         dec   ra               ;
         bra   nz,boot_p1       ;
end_boot:stp   p1,prog_cnt      ; 
         ldrv  r0,"#"           ; 
         outpp r0,pA,0          ;
end_loop:ldrv  r1,0				; // Clear register value
	 	 uport f7               ; // clear port.
         jmp   reset_v          ;
   
         // Read program memory
boot_r:  ldr   rc,prog_lng      ;// read program length
         ldpv  p1,0             ;
boot_r1: ldcv c2,3              ; 
         ldrpi r2,p1            ;
boot_r2: shl   r,r2             ; 
         shl   r,r2             ; 
         shl   r,r2             ; 
         shl   r,r2             ; 
         mvrr  r2,r1            ; 
         andv  r1,'h00F         ;
         addv  r1,'h030         ;
         cmprv r1,'h039         ;
         bra   ls,boot_r3       ;
         addv  r1,'h027         ; 
boot_r3: inpp  r3,pB	        ; // read status
         andv  r3,TXFULL       	; // transmit full ?
         bra   nz,boot_r3       ; // yes, wait
         outpp r1,pA,0          ;
         dcjnz c2,boot_r2       ;
	 	 nop					;
boot_r4: inpp  r3,pB	        ; // read status
         andv  r3,TXFULL       ; // transmit full ?
         bra   nz,boot_r4       ; // yes, wait
         ldrv  r3,'h00A         ;
         outpp r3,pA,0          ; 
         dec   rc               ; // decrement counter
         bra   nz,boot_r1       ; 
         jmp   end_loop         ;
   
prog_lng:dw    0                ; // program length
prog_cnt:dw    0                ; // program counter

   
/////////////////// End of File //////////////////////////
