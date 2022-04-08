   //////////////////////////////////////////////////////////////////////
   // PROGRAM :		WS281x LED controller
   //////////////////////////////////////////////////////////////////////
   // Application:
   // WS2811     = RBG , sequence = R7..0-B7..0-G7..0 (GBR)
   // WS2815     = RBG , sequence = R7..0-B7..0-G7..0 (GBR)
   //
   // WS2812/12B = GRB , sequence = G7..0-R7..0-B7..0
   // WS2813     = GRB , sequence = G7..0-R7..0-B7..0 
   // SK6812     = GRB , sequence = G7..0-R7..0-B7..0
   // SK9822
   //
   // RGB is formatted as two 16 bits = 4 Chars
   // asc2hex return low 16 bits in R2 and higher 16 bits in R3
   // WBGR = R2=GR, R3=WB, W is not used, B is Blue, G is Green and R is Red
   //
   //////////////////////////////////////////////////////////////////////
   // check comments with //g// or //g#// , #=1 to 99
   //////////////////////////////////////////////////////////////////////
   // Registers, Pointers and flags usage:
   //
   // Pointers
   // p1 : temp, write/read SESMA
   // p2 : temp, 
   // p3 : temp, write/read, pjump, themes/patterns 
   // p4,p5,p6 : NU
   // p7 : pointer to debug variables don't touch, or save/restore
   // p8 : temp, Display registers
   // pA : contains the address of the UART Data register don't touch
   // pB : contains the address of the UART Status register don't touch
   // pC : used by tx_line, tx_page, tx_prmt routines don't touch
   // pD : pointer to debug registers
   // pE : Timer don't touch
   // pF : SESMA don't touch
   //
   // Registers
   // r0 : auxilary reg, don't use it
   // r1 : chkstat, rdchar, any routine
   //	   tohex2,asc2hex input value
   // r2 : hex2asc, input value tohex2,asc2hex
   //      output value dishexs
   // r3 : tx_page, tx_line, dishexs
   // r4 : tx_page, tx_line
   // r5 : temporary, used local
   // rA : boot loader, available
   // rC : boot loader, available
   // rE : Init timer don't touch
   //
   // uflag(0)
   // uflag(1) switch fg and bg in patterns
   // uflag(2) tp2 detected, clear by routine if needed
   // uflag(3) t3=special effects enabled
   // uflag(4) f4=foreground, t4=background
   // uflag(5) used by memory dump
   // uflag(6) used by asc2hex routine
   // uflag(7) used by boot loader 
   //          used by echo ON/OFF in normal operation
   // uflag(8) irq, pixel counter flag
   // uflag(9) irq, strip counter flag
   // uflag(A-F) available

   // uport(0) global hw signal
   // uport(1) f1=disable strip   / t1=enable strip
   // uport(2) f2=foreground      / t2=background
   // uport(3) main loop trigger/signal
   // uport(4) hw interrupt enable flag
   // uport(5) not used
   // uport(6) reset int4 counters in hw
   // uport(7) used by boot loader and echo ON/OFF
   // uport(8) irq, pixel counter signal for hw
   // uport(9) irq, strip counter signal for hw
   // uport(A-F) available
   //
   // Register and Pointer definitions
   //=====================================
   //
   // POINTER REGISTERS
   //=====================================
   // P0 pointer 0 -> program counter 'p0' not accesible
   // P1 pointer 1 -> user pointer    'p1' write/read routines, SESMA
   // P2 pointer 2 -> user pointer    'p2' write/read routines
   // P3 pointer 3 -> user pointer    'p3' write/read routines
   // P4 pointer 4 -> user pointer    'p4'
   // P5 pointer 5 -> user pointer    'p5'
   // P6 pointer 6 -> user pointer    'p6'
   // P7 pointer 7 -> user pointer    'p7' pointer to debug pointers 
   // P8 pointer 8 -> user pointer    'p8' Display Registers
   // P9 pointer 9 -> user pointer    'p9'
   // PA pointer 10-> user pointer    'pA' UART Data register  
   // PB pointer 11-> user pointer    'pB' UART Status register
   // PC pointer 12-> user pointer    'pC' Tx routines, buffer ptr
   // PD pointer 13-> user pointer    'pD' pointer to debug registers
   // PE pointer 14-> user pointer    'pE' Timer
   // PF pointer 15-> stack pointer   'pF' Stack routines/ SESMA
   //
   //
   // REGISTERS
   //=====================================
   // R0 register 0 -> temporary ACC  'r0' modified by instructions
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
   // RD register 13-> user register  'rD'  any routine
   // RE register 14-> user register  'rE' Init Timer
   // RF register 15-> status/control 'rF' any routine
   //
   // R0 can be used in Input and Output I/O access
   // R0 is modified by arithemtic and logic instructions
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
define YEAR      2022; // 07E6 year		2022
define MONTH       04; //    4 month	April (January=1 to December=12)
define DATE      0105; // 0105 day/date	Tuesday (Mon=0 to Sun=6)
define HOUR        10; //    A hours
define MINUTE      25; //   19 minutes
define SECONDS     00; //    0 seconds
   
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // System defines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
	// To be used with LDMAM instruction (Load Memory Access Mode)	
define   IRW 0 // internal read , internal write. ldmam mo  
define   XRD 1 // external read , internal write. ldmam m1 
define   XWR 2 // internal read , external write. ldmam m2 
define   XRW 3 // external read , external write. ldmam m3 
   
   // Key defines
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
define	VIRTUAL_CHA 'h80FF // 256 CHANNELS, negative means default real channel

define	MAXCHAN       15   // maximum number of channels (16=0..15)
define	STRIPLENGTH  100   // max number of pixels
// Buffer length is always STRIPLENGTH * 2
//define	BUFFERLENGTH   100 //  50 pixels = RG-BW 2 words 16ft
  define	BUFFERLENGTH   200 // 100 pixels = RG-BW 2 words 32ft
//define	BUFFERLENGTH   300 // 150 pixels = RG-BW 2 words 48ft
//define	BUFFERLENGTH   600 // 300 pixels = RG-BW 2 words 64ft

define	THEMELENGTH  'h000F // max 16, this is a mask
define	PATLENGTH    'h000F // max 16, this is a mask

// Defines for the index of pointer P7
// strx rn,p7,DEFINE;
define SR_IX	0 // SRAM page address
define FG_IX	1 // 0=fg, 1=bg (foreground/background)
define IR_IX	2 // internal RAM pointer
define ER_IX	3 // external RAM pointer
define IRL_IX	4 // internal RAM pointer last
define ERL_IX	5 // external RAM pointer last
//              6
//              7


   /////////////////////////////////////////////////////////////////////
define   BASEREGIO  'h0000 // Base register address port

   // Application Registers 
   // 'h0000 - 'h000f register map
   // Registers - OUTPUTs
define   GPREG_00  'h0000 // number of Pixels
define   GPREG_01  'h0001 // LED load/reset reg
define   GPREG_02  'h0002 // ECODE 
define   GPREG_03  'h0003 // BCODE 
define   GPREG_04  'h0004 // SOC Cycle               
define   GPREG_05  'h0005 // SOC Pulse width for NRZ '0' 
define   GPREG_06  'h0006 // SOC Pulse width for NRZ '1' 
define   GPREG_07  'h0007 // triger src, scope src, pcode

   // Registers - INPUTs
define   GPREG_08  'h0008 // 
define   GPREG_09  'h0009 // 
define   GPREG_0a  'h000a // 
define   GPREG_0b  'h000b //
define   GPREG_0c  'h000c // Boot address
define   GPREG_0d  'h000d // TEST_CFG : channels/irq/proto   
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
   // 'h0100 - 'h010F RGB values
   // 'h0110 - 'h011F RGB values background
define   APPREG_00  'h0100 // RED/GRN channel #1-16
define   APPREG_10  'h0120 // RED/GRN channel #1-16 background

// RGB tables length
define   RGBLENGTHH 'h0F //   16 channels RGBW = 16 words x 2 values
define   RGBLENGTH  'h1F //   16 channels RGBW = 16 words x 1 value
define   RGBLENGTHF	'h3F // 2x16 channels RGBW, RGBW_bg = 32 words

define	RED 'h00FF // red   00FF-0000
define	GRN 'h00FF // green 0000-00FF
define	BLU 'hFF00 // blue  FF00-0000
define	BLK 'h0000 // black 0000-0000
define	WHT 'hFFFF // white FFFF-00FF

   // User switches
define   USRSW_MSK  'h0000	// NO User switches
define   USBMD_MSK  'h0000	// UART Mode only
define   PWM_RESET  'h1E00  // SOC reset >300uS depends of the number of pixels
define   PWM_PERIOD 'h001F  // SOC period 1F Fast, 3E slow
define   PWM_LOW    'h0008  // WS2811 low  bit
define   PWM_HIGH   'h0016  // WS2811 high bit

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

// Free from @'h000A to @MAIN_ADDR


   
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
         	ldpv  p7,dbugptr       ; //debug initialize debug pointer
         	ldpv  pD,zregdbug      ; //debug initialize debug pointer
         	ldrv  r1,kpst00        ; // Initialize SESMA variables
         	str   r1,ssm_pst       ; // present state
         	str   r1,ssm_lst       ; // last state.

			// Insert User Initialization
			// Initialize local registers
	        
	        ldr 	r1,numpixels	;// 50
	        outp    r1,GPREG_00     ;// Pixels = 50 
			ldrv	r1,PWM_RESET	;// 1E00hex=7680x40nS=307uS
	        outp    r1,GPREG_01     ;// Load/Reset LED pulse > 300uS
			ldrv	r1,zend_code   	;// end of program protected RAM
	        outp    r1,GPREG_02     ;//
			ldrv	r1,zend_ram  	;// start of protected RAM, BOOT section
	        outp    r1,GPREG_03     ;//
			ldrv	r1,PWM_PERIOD	;// PWM period/cycle, 3C slow, 1E fast
	        outp    r1,GPREG_04     ;//
			ldrv	r1,PWM_LOW		;// PWM width 0C slow, 06 fast
	        outp    r1,GPREG_05     ;//  '0' NRZ
			ldrv	r1,PWM_HIGH		;// PWM width 0=1E slow, 0F fast
	        outp    r1,GPREG_06     ;//  '1' NRZ
			ldrv	r1,'h0002 		;// trigger = 00,source  = 00
	        outp    r1,GPREG_07     ;// protected mode
			ldrv	r1,'h7840 		;// trigger = 00,source  = 00
	        outp    r1,GPREG_08     ;// protected mode
			ldrv	r1,'h017d 		;// trigger = 00,source  = 00
	        outp    r1,GPREG_09     ;// protected mode
	        
	        // initialize colors
	        ldcv	c0,RGBLENGTHF	; // 8 channels = 8 x 4 words
	        ldpv	p1,rgbtab		; // 0 to f = 16 loops
	        ldpv	p2,APPREG_00	; // from 00 to 0f
initloop:	ldrpi	r1,p1			;
			outpp	r1,p2  			;
			incp	p2				;
			dcjnz	c0,initloop		;
	        
	        uflag 	f0				; // 
	        uflag 	f1				; // pattern behavior
	        uflag 	f2				; // enable ClearScreen
	        uflag 	f3				; // special effects disabled
	        uflag 	f4				; // fg=f4, bg=t4 
	        uflag 	f5				; // memory pointer
	        uflag 	f6				; // asc2hex
	        uflag 	f7				; // echo OFF
	        uflag 	f8				; // pixel irq flag
	        uflag 	f9				; // strip irq flag
	        uflag 	fA				; // one hour flag
	        uflag 	fE				; // timer 1mS flag, timer = 0

	        uport	f0				; // 
			uport	t1				; // enable  Strip
			uport	f2				; // foreground
			uport	f3				; // Main loop
			uport	f4				; // hw interrupt enable flag 
			uport	f5				; // 
			uport	f6				; // 
			uport	f7				; // echo OFF
			uport	f8				; // hw test
			uport	f9				; // hw test 
									 
			xor		r6,r6			; // clear variables
			str		r6,colorcnt		;
			mvrp	r6,pE			; // strip timer/counter
			ldrv	rE,20			; // strip timer/counter value
						
	        jsr   	tx_prmt         ; // prompt out.
	        jsr		d_target		; // reset top fpga
	        jsr		irq_enb			;
	        
    //////////////////////////////////////////////////////////////////////
	// Main Loop
	// main loop is approximately 50 times faster than new pixel count
    //////////////////////////////////////////////////////////////////////

main:		uport	t3				; // scope signal for trigger
			inpp  	r1,pB	     	; // read status reg
			uport	f3				;
         	bitv  	r1,RXDVLD   	; // test data valid RX
         	bra   	z,main2		  	; //
			jsr   	rdchar          ;
			jsr   	sesma           ; // uses pointer 1 (p1), action routine has RTS
main2:		jmp		f8,main3		; // check pixel counter
			uflag	f8				; // new pixel 
			jmp		f3,main			; // special effects
			ldrv	r1,main			; // return address for jmpp
			push	r1,pF			; // into stack                    
			ldp		p3,pjump		; // load address routine
			jmpp	p3				; // execute Theme or Pattern, task routine jumps back to main:
main3:		jmp		f9,main			; // check strip counter
			uflag	f9				; // strip start, reset
         	incp	pE				; // timer/counter 
			jmp		fA,main			;
			uflag	fA				; // clear one hour flag
			// check calendar based on uflag A
			jmp		main			;
			 			
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
	 		uflag	t7				;
			ldr   r1,regptr			;
	 		mvrp  r1,p8				;
         	ldcv c1,15              ; 
d_areg1: 	inpp  r2,p8             ;
         	jsr   dishex4           ;
         	jsr   tx_prmt           ; 
         	incp  p8                ;
         	dcjnz c1,d_areg1        ;
         	ldr		r1,echomode		;
			or		r1,r1			;
			bra		nz,d_areg2		;
			uflag	f7				;
d_areg2:	jsr   tx_prmt           ; 
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
	 		ldrp  r2,p1			;// internal memory
	 		bra	  a_getend		;
a_getex:	ldmam m1			;// external memory
	 		ldrp  r2,p1			;
a_getend:	ldmam m0			;	 	
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
			ldmam m2				; // access external memory
a_w9:		strp  r1,p1				;
a_wend:		ldmam m0				; // restore memory access
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
			ldmam 	m1				;
rdmemw:		ldrpi 	r2,p1			;
        	ldmam 	m0            	; // access internal memory for write/read
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
			ldmam 	m1				;
rdmemb:		xor		r3,r3			;
			ldrpi	r2,p1			; // read buffer
			or		r3,r2			;
			ldrpi	r2,p1			;
			shl4	r2				;
			shl4	r2				;
			or		r3,r2			;
			swap	r3,r2			;
        	ldmam 	m0            	; // access internal memory for write/read
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
		 	ldmam	m0         	; // access internal memory for write/read
         	ldcv	c2,16		; // rows
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
			ldmam 	m2				; // access external memory
			or		r1,r1			;// check for byte/word access
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
memfill4:	ldmam 	m0				; // restore memory access
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

setarst: 	ldpv  	pC,hexval4_m     ; // SOC reset
         	jsr   	tx_line          ;
         	jsr   	asc2hex          ; // return in r2
		 	outp  	r2,GPREG_01 		;
         	jsr   	tx_prmt          ; 
         	rts   	                 ;
	     	      	
setaper: 	ldpv  	pC,hexval4_m     ; // SOC cycle / period
         	jsr   	tx_line          ;
         	jsr   	asc2hex          ; // return in r2
		 	outp  	r2,GPREG_04 		;
         	jsr   	tx_prmt          ; 
         	rts   	                 ;
	     	      	
setapul0:	ldpv  	pC,hexval4_m     ; // SOC pulse width
         	jsr   	tx_line          ;
         	jsr   	asc2hex          ; // return in r2
		 	outp  	r2,GPREG_05		; // code 0
         	jsr   	tx_prmt          ; 
         	rts   	                 ;
         	      	
setapul1:	ldpv  	pC,hexval4_m     ; // SOC pulse width
         	jsr   	tx_line          ;
         	jsr   	asc2hex          ; // return in r2
		 	outp  	r2,GPREG_06		; // code 1
         	jsr   	tx_prmt          ; 
         	rts                    ;

d_fastpwm:	uport	f1				;// disable strip
         	ldrv	r1,PWM_PERIOD	;// PWM period/cycle, 3E slow, 1F fast
	        outp    r1,GPREG_04     ;//
			ldrv	r1,PWM_LOW		;// PWM width 0C slow, 06 fast
	        outp    r1,GPREG_05     ;//  '0' NRZ
			ldrv	r1,PWM_HIGH		;// PWM width 0=1E slow, 0F fast
	        outp    r1,GPREG_06     ;//  '1' NRZ
			uport	t1				;// enable strip
         	rts                    ;

d_slowpwm:	uport	f1				;// disable strip
         	ldrv	r1,PWM_PERIOD	;// PWM period/cycle, 3E slow, 1F fast
         	shl		l,r1			;// slow
	        outp    r1,GPREG_04     ;//
			ldrv	r1,PWM_LOW		;// PWM width 0C slow, 06 fast
			shl		l,r1			;// slow
	        outp    r1,GPREG_05     ;//  '0' NRZ
			ldrv	r1,PWM_HIGH		;// PWM width 0=1E slow, 0F fast
			shl		l,r1			;// slow
	        outp    r1,GPREG_06     ;//  '1' NRZ
			uport	t1				;// enable strip
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
	     	      	
  //////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  // Application routines
  //////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  // WS2811 = BRG
  
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

			// Number of pixels on strip
d_pixels:  	uport	f2				; // select foreground RGB
			jsr		setcolor0		; // clear strips
			uport	f1				; // disable and reset strip
			ldpv	pC,hexval4_m    ;
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r2
			outp	r2,GPREG_00   	; //
			str		r2,numpixels	;
			jsr		tx_prmt			; 
			uport	t1				; // enable strip
			rts		                ;

			// pixels on walking colors a cmd
d_pixelson:	ldpv	pC,hexval4_m    ;
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r2
			str		r2,pixelson   	; // 
//g			jsr		tx_prmtlf		; 
			rts		                ;

			// buffer read mode, 0/1/2 r cmd
d_readmode:	ldpv	pC,hexval4_m    ;
         	jsr   	tx_line         ;
         	jsr   	asc2hex         ; // return in r2
         	andv	r2,3			; // limit to 4 modes
			str		r2,read_mode   	; //
			xor		r0,r0			; // clear walk counter 
			str		r0,walk_cnt		;
//g			jsr		tx_prmtlf		; 
			rts		                ;

			// select fore/background RGB
d_enbfg:	uport	f2				; // select foreground RGB
			uflag	f4				;
			xor		r1,r1			;
			jmp		d_enbfgbg		;
d_enbbg:	uport	t2				; // Select background RGB
			uflag	t4				;
			ldrv	r1,1			;
d_enbfgbg:	strx	r1,p7,FG_IX		; // (p7+3) = fg
//g			jsr		tx_prmtlf		; 
			rts		                ;

			// Timer 1
d_timer1:	ldpv	pC,hexval4_m    ; // timer
         	jsr   	tx_line         ;
			jsr   	asc2hex         ; // return in r2
         	str		r2,tmr1msec		;
         	str		r2,tmr1value	;
         	uflag	fE				; // clear flag
         	mvrr	r2,rE			;
			ldpv	pE,0			; 
//g			jsr		tx_prmtlf		;
			rts		                ;

			// Dimm steps
d_dimstep:	ldpv	pC,hexval4_m    ; // timer
         	jsr   	tx_line         ;
d_dimstep2:	jsr   	asc2hex         ; // return in r2
			andv	r2,'h000F		;
			str		r2,dimsteps		;
//g			jsr		tx_prmtlf		;
d_dimstep3:	rts		                ;

			// Create Masks
create_msk:	mvrr	r2,r5			; // rg
			xor		r6,r6			; // mask
			xor		r7,r7			; // mask
			andv	r5,'h00ff		;
			bra		z,c_msk_1		; // no color
			ldrv	r6,'h00ff		; // some color
c_msk_1:	andv	r2,'hff00		;
			bra		z,c_msk_2		; // no color
			orv		r6,'hff00		; // some color
c_msk_2:	andv	r3,'h00ff		; // wb
			bra		z,c_msk_3		; // no color
			ldrv	r7,'h00ff		; // some color
c_msk_3:	str		r6,colormskrg	;
			str		r7,colormskwb	;
			rts						;
			
									
			//#############################
			// Set colors foreground and background
d_colors:	ldpv	pC,hexval4_m    ; // 
         	jsr   	tx_line         ;
d_colors2: 	jsr   	asc2hex         ; // return in r2,r3 (rg,bw)
         	push	r2,pF			;
         	push	r3,pF			;
         	nop						; // an extra NOP is needed
         	// before call subroutine
         	jsr		create_msk		; // destroy r2/r3
         	pop		r3,pF			;
         	pop		r2,pF			;
         	jmp		t4,d_colorsb	;
			// set colors foreground // uflag f4
			ldpv	p1,rgbtab		;
			bra		d_colorall		;
d_colorsb:	// set colors background // uflag t4
			ldpv	p1,rgbtab_bg	;
d_colorall:	ldr		r1,channel		;
			shl		l,r1			;
			addrp	r1,p1			;
			mvrp	r1,p1			;
			strpi	r2,p1			;
			strp	r3,p1			;
			str		r2,colorsetrg	;
			str		r3,colorsetwb	;
			jsr		refresh			;
//g			jsr		tx_prmtlf		; 
			rts		                ;
			
			// refresh colors
refresh:    ldcv	c0,RGBLENGTHF	; // 8 channels = 2 x 4 words
	        ldpv	p1,rgbtab		; // 0 to F = 16 loops
	        ldpv	p2,APPREG_00	; // from 00 to 0F
d_enbloop1:	ldrpi	r1,p1			;
			outpp	r1,p2  			;
			incp	p2				;
			dcjnz	c0,d_enbloop1	;
			rts						;
			
			
			//################################
			// Set channel
d_channel:	ldpv	pC,hexval4_m    ; // 
         	jsr   	tx_line         ;
d_channel2:	jsr   	asc2hex         ; // return in r2
			andv	r2,MAXCHAN		; // limit to 16
			str		r2,channel		;
//g			jsr		tx_prmtlf		; 
d_channel3:	rts		                ;
			
			//################################
			// Set intensity
d_colorin:	ldpv	pC,hexval4_m    ; // 
         	jsr   	tx_line         ;
d_colorin2:	jsr   	asc2hex         ; // R2 = yyxx R3 = ??!!
  			andv	r2,7			; // limit to 8 values
  			ldpv	p1,intensity_tab;
  			addrp	r2,p1			;
  			mvrp	r2,p1			;
  			ldrp	r2,p1			;
			str		r2,intensity	;
//g			jsr		tx_prmtlf		; 
d_colorin3:	rts		                ;
			
			//################################
			// NEW themes call routine
d_enbthe:	uport	f2				; // select foreground RGB
			ldpv	pC,hexval4_m    ;
         	jsr   	tx_line         ;
d_enbthe2: 	jsr   	asc2hex         ; // return in r2,r3
         	andv	r2,THEMELENGTH	; // limit table's length
			str		r2,poffset		;
			ldpv	p3,the_table	; // themes table
			ldpy	p3,r2			;
			stp		p3,tjump		;
			jmpp   	p3				;
			
			//################################
			// patterns call routine
d_runthem0:	uport	f2				; // select foreground RGB
			xor		r2,r2			; // do not change register R2
			str		r2,walk_cnt		;
			str		r2,walk_on		;
			str		r2,read_mode	;
			uflag	f1				; // foregroung set
			jmp		d_enbpat0		; // it is used to set poffset
			
d_enbpat:	uport	f2				; // select foreground RGB
			ldpv	pC,hexval4_m    ;
         	jsr   	tx_line         ;
d_enbpat2: 	jsr   	asc2hex         ; // return in r2,r3
         	str		r2,poffset		;
			andv	r2,PATLENGTH	; // limit table'slength to 16
         	bra		nz,d_enbpat1	;
         	ldrv	r1,1			;
         	str		r1,walk_on		;
         	bra		d_enbpat0		;
d_enbpat1:	xor		r1,r1			;
			str		r1,walk_on		;         	
d_enbpat0: 	ldpv	p3,pat_table	; // patterns table
			ldpy	p3,r2			;
			stp		p3,pjump		;
			ldpv	pE,'h0000		; // timer pE
			uflag	t3				; // enable especial effects
			rts						;
			
			//################################
			// Set defined color
setcolor0:	xor		r2,r2	 		; // Set BLK
			xor		r3,r3	 		; // Set BLK
			xor 	r4,r4	  		; // Set  
			xor 	r5,r5	  		; // Set
			str		r4,colormskrg	;
			str		r5,colormskwb	;
			jmp		setdefcolor		;
setcolor1:	ldr 	r2,intensity	; //
			andv 	r2,RED  		; // Set RED
			ldrv 	r3,'h0000  		; // Set  
			ldrv 	r4,RED  		; // Set  
			ldrv 	r5,'h0000  		; // Set  
			jmp		setdefcolor		; //
setcolor2:	ldrv 	r2,'h0000  		; //
			ldr 	r3,intensity	; //
			andv 	r3,GRN  		; // Set GRN
			ldrv 	r4,'h0000  		; // Set  
			ldrv 	r5,GRN  		; // Set  
			jmp		setdefcolor		; //
setcolor3:	ldr 	r2,intensity	; //
			andv 	r2,RED  		; // Set RED
			ldr 	r3,intensity	; //
			andv 	r3,GRN  		; // Set GRN
			ldrv 	r4,RED  		; // Set  
			ldrv 	r5,GRN  		; // Set  
			jmp		setdefcolor		; //
setcolor4:	ldr 	r2,intensity	; //
			andv 	r2,BLU  		; // Set BLU
			ldrv 	r3,'h0000  		; //
			ldrv 	r4,BLU  		; // Set  
			ldrv 	r5,'h0000  		; // Set  
			jmp		setdefcolor		; //
setcolor5:	ldr 	r2,intensity	; //
			andv 	r2,'hFFFF  		; // Set BLU/RED
			ldrv 	r3,'h0000  		; //
			ldrv 	r4,'hFFFF  		; // Set  
			ldrv 	r5,'h0000  		; // Set  
			jmp		setdefcolor		; //
setcolor6:	ldr 	r2,intensity	; //
			andv 	r2,BLU  		; // Set BLU
			ldr 	r3,intensity	; //
			andv 	r3,GRN  		; // Set GRN
			ldrv 	r4,BLU  		; // Set  
			ldrv 	r5,GRN  		; // Set  
			jmp		setdefcolor		; //
setcolor7:	ldr 	r2,intensity	; //
			andv 	r2,WHT  		; // Set RED
			ldr 	r3,intensity	; //
			andv 	r3,GRN  		; // Set GRN
			ldrv 	r4,WHT  		; // Set  
			ldrv 	r5,GRN  		; // Set  
setdefcolor:str		r2,colorsetrg	;
			str		r3,colorsetwb	;
			str		r4,colormskrg	;
			str		r5,colormskwb	;
			jmp		t4,setcolorbg	;
         	ldpv	p1,rgbtab		;
	        ldpv	p2,APPREG_00	;
         	bra		setcolor		;
setcolorbg:	ldpv	p1,rgbtab_bg		;
	        ldpv	p2,APPREG_10	;
setcolor:	ldcv	c0,RGBLENGTHH	; // 16 channels = 2 x 8 words
setloop1:	strpi	r2,p1			;
			strpi	r3,p1			;
			outpp	r2,p2  			;
			incp	p2				;
			outpp	r3,p2  			;
			incp	p2				;
			dcjnz	c0,setloop1		; // 0 to 15 = 16 loops
			uflag	f3				; // disable especial effects
			rts						;
			
			//################################
			// save colors into colorset buffer
savecolor:	uflag	f3				; // disable especial effects
			ldr		r2,colorsetrg	; // restore color RG
			ldr		r3,colorsetwb	; // restore color WB
			ldpv	p3,colorset		;
			ldr		r5,colorcnt		;
			mvrr	r5,r6			;
scolor1:	shl		r5				;			
			addrp	r5,p3			;
			mvrp	r5,p3			;
			strpi	r2,p3			; // 
			strpi	r3,p3			;
			inc		r6				;
			cmprv	r6,50			; //// compare with maximum now just 50
			bra		ge,scolor3		;
scolor2:	str		r6,colorcnt		;
scolor3:	rts						;
			
			// clear color counter, segment and flag
resetcolor:	uflag	f3				; // disable especial effects
	        uflag 	f4				; // foreground (fg=f4, bg=t4)
			uport	f2				; // select foreground RGB
			xor		r1,r1			;
			str		r1,ready2go		; // clear flag
			str		r1,colorcnt		; // clear counter
			str		r1,colorseg		; // clear segment
			str		r1,residual		; // clear residual
			str		r1,walk_cnt		;
			str		r1,walk_on		;
			jsr		refresh			; // refresh HW color
			ldcv	c0,7			;
			ldpv	p1,dbugptr		;
resetcolor2:
			strpi	r1,p1			;
			dcjnz	c0,resetcolor2	;
			rts						;
				
			// buffer mode=0 stretch, mode=1 repeat		
d_bufmode:	ldpv	pC,hexval4_m    ; // 
         	jsr   	tx_line         ;
d_bufmode2: jsr   	asc2hex         ; // return in r2,r3
			andv	r2,3			; // limit to 4 modes
         	str		r2,buff_mode	;
			rts						;

			// page number selects external SRAM block 
d_pagenum:	ldpv	pC,hexval4_m    ; // 
         	jsr   	tx_line         ;
d_pagenum2:jsr   	asc2hex         ; // return in r2,r3
			andv	r2,'h0007		; // limit to 8 pages for testing
         	strx	r2,p7,SR_IX		; // SRAM page setup
         	ldpag	r2				; // set address page reg = R2
			jsr		tx_prmt			; 
d_pagenum3:	rts						;

			// id number selects external SRAM block 
			// Virtual channel
d_buff_idx:	ldpv	pC,hexval4_m    ; // 
         	jsr   	tx_line         ;
d_buff_idx2:jsr   	asc2hex         ; // return in r2,r3
			andv	r2,VIRTUAL_CHA	; // limit to 256 virtual channels
         	str		r2,buff_idx		; // SRAM virtual channel
			jsr		tx_prmt			; 
d_buff_idx3:rts						;

			// compute number of segments based on colorcnt
computeseg:	ldr		r4,colorcnt		;
			or		r4,r4			; // check for zero
			bra		nz,computseg0	;
			xor		r1,r1			; // ready2go flag
			bra		computseg2		;
computseg0:	ldrv	r1,1			;
			ldr		r5,numpixels	;
			jsr		division		;
			str		r3,residual		; // residual = numpixels/colorseg
computseg2:	str		r6,colorseg		;
			str		r1,ready2go		;
			rts						;		

			// Compute src and dst address pointers
			// If buff_idx is equal to 8xxx, default 8000
			// then (S)ave command will save channel #
			// to same Virtual channel #
			// example V=8000, C=5, S will save the C5 into
			// virtual channel 5 in external memory by default
			// V=5 and c=1, channel 1 save it on virtual channel 5
computeptr:	ldpv	p1,buf_table	;
			ldr		r1,channel		;															
			addrp	r1,p1			;
			mvrp	r1,p1			;
			ldrp	r1,p1			;
			strx	r1,p7,IR_IX		; // internal RAM pointer
			str		r1,buff_addr	; // source address
			ldr		r4,numpixels	; //
			shl		r4,r4			; // numpixels*2 (RG,WB)
			str		r4,buff_len		; // length
			shl		r4				; // byte mode
			xor		r2,r2			; // 
			ldr		r5,buff_idx		;
			mvrr	r5,r3			; // save the idx
			andv	r5,SIGNED		; // check if idx = ch
			bra		nz,computprt0	;
			bra		computptr1		;
computprt0:	ldr		r3,channel		; // yes, idx = ch
computptr1:	or		r3,r3			;
			bra		z,computptr3	; 
computptr2:	add		r2,r4			;
			dec		r3				;
			bra		nz,computptr2	;				
computptr3:	str		r2,buff_addrx	;
			strx	r2,p7,ER_IX		; // external SRAM pointer
			rts		                ;
			
			// Save buffer into external SRAM
savebuf:	jsr		computeptr		;
			ldp		p1,buff_addr	; // Intrernal RAM address
			ldp		p2,buff_addrx	; // External SRAM address
			ldr		r4,buff_len		; // buffer length
			ldmam	m2				; // 
savebuf1:	ldcv	c0,1			; // 2 bytes
			ldrpi	r2,p1			; // read buffer
savebuf2:	strpi	r2,p2			; // write to SRAM
			shr4	r2				;
			shr4	r2				;
			dcjnz	c0,savebuf2		;
			dec		r4				;
			bra		nz,savebuf1		;
			ldmam	m0				; // restore mem access
			mvpr	p1,r1			;
			strx	r1,p7,IRL_IX	; // internal RAM pointer last
			mvpr	p2,r1			;
			strx	r1,p7,ERL_IX	; // external SRAM pointer last
			jsr		tx_prmt			; 
			rts		                ;
			
			// Restore buffer into internal SRAM
restorebuf:	jsr		computeptr		;
			ldp		p1,buff_addr	;
			ldp		p2,buff_addrx	; // SRAM address
			ldr		r4,buff_len		; // number of pixels
			ldmam	m1				; // 
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
			ldmam	m0				; // restore mem access
			mvpr	p1,r1			;
			strx	r1,p7,IRL_IX	; // internal RAM pointer last
			mvpr	p2,r1			;
			strx	r1,p7,ERL_IX	; // external SRAM pointer last
			jsr		tx_prmt			; 
			rts		                ;
			

			//################################
			// Themes 
			//################################
			
			//################################
			// Fill buffer with Custom or Flags pattern
			// to run a custom pattern fill colorset with s cmd
			// colorset = ff00,0000,00ff,0000,0000,00ff,...
			// or single number commands 0 to 7
theme0:		uflag	f3				; // disable especial effects
			jsr		computeseg		; // numpixels/colorcnt=segments
			ldr		r1,ready2go		;
			or		r1,r1			; // check if ready 
			bra		z,theme0_4		; // no colors to display
			// calculate buffer pointer
theme0_0:	ldpv	p1,buf_table   	; // table address
			ldr		r1,channel		; // channel #
			ldpy	p1,r1			; // address buffer
			mvpr	p1,r5			; // R5 holds the buffer address 

			// setup register values
			ldpv	p2,colorset		; // address
			ldr		r4,numpixels	; // R4 number of pixels
			mvrr	r4,r7			; // R7 numpixels-segments
			ldr		r6,colorseg		; // R6 segment size
			ldr		r8,colorcnt		; // R8 number of colors
			ldr 	r9,intensity	; //Intensity
			// Check Mode			
			ldr		r1,buff_mode	; // 0:stretch, 1:repeat
			or		r1,r1			;
			bra		nz,theme0_3		; // 
			// Mode = 0, segmented colorset
			ldrpi	r2,p2			; //? value
			and 	r2,r9			;
			ldrpi	r3,p2			; //? value
			and 	r3,r9			;
theme0_1:	strpi	r2,p1			; //? segmented colorset
			strpi	r3,p1			; //?
			dec		r4				; // numpixels--
			bra		nz,theme0_1	 	;
			mvrp	r5,p1			; // restore address pointer
			ldrpi	r2,p2			; //? value
			and 	r2,r9			;
			ldrpi	r3,p2			; //? value
			and 	r3,r9			;
			sub		r7,r6			; // numpixels-segment
			dec		r8				; // colorcnt--
			bra		z,theme0_4		; // done
			mvrr	r7,r4			; // hold last value
			bra		theme0_1		;
			// Mode=1, repeat colorset
theme0_3:	dec		r7				; // pixels left
			or 		r7,r7			; // pixels
			bra		s,theme0_4		; // done
			ldrpi	r2,p2			; //? value
			and 	r2,r9			;
			ldrpi	r3,p2			; //? value
			and 	r3,r9			;
			strpi	r2,p1			; //? segmented colorset
			strpi	r3,p1			; //?
			dec		r8				; // colorcnt--
			bra		nz,theme0_3	 	;
			ldr		r8,colorcnt		; // R8 number of colors
			ldpv	p2,colorset		; // address
			dec		r6				; // colorseg--
			bra		theme0_3		; // next
theme0_4:	rts						;
			
			//################################
			// Fill buffer with XMas/RGB
t_xmas:		uflag	f3				; // disable especial effects
			ldpv	p1,buf_table   	; // table address
			ldr		r1,channel		; // channel #
			ldpy	p1,r1			; // address buffer
			ldr		r4,numpixels	; // length
			ldr 	r9,intensity	; //Intensity
			ldrv	r2,'h00FF		; // RED
			and		r2,r9			; // set intensity
			ldrv	r3,'h0000		;
			mvrr	r2,r7			;
			mvrr	r3,r8			;
tloop1_1:	strpi	r2,p1			;
			strpi	r3,p1			;
			ldcv	c0,7			;
tloop1_2:	shl		l,r2			;// insert repeat value according w
			shl		k,r3			;
			dcjnz	c0,tloop1_2		;
			andv	r3,'h00FF		;
			mvrr	r2,r5			;
			mvrr	r3,r6			;
			or		r5,r6			;
			bra		ne,theme1_1		;
			mvrr	r7,r2			;
			mvrr	r8,r3			;
theme1_1:	dec		r4				;
			bra		nz,tloop1_1		;
			jmp   	tx_prmt			;
			
			//################################
			// Fill buffer with increasing RGB
t_xmas2:	uflag	f3				; // disable especial effects
			ldpv	p1,buf_table   		; // address
			ldr		r1,channel		;
			ldpy	p1,r1			; // address buffer
			xor		r2,r2			;
			mvrr	r2,r3			; // value
			ldr		r4,numpixels	; // length
tloop1:		or		r2,r2			;
			bra		nz,theme2_1	;
			andv	r3,'h00FF		;
			bra		nz,theme2_1	;	
			ldrv	r2,'h0001		;
			xor 	r3,r3     		;
theme2_1:	strpi	r2,p1			;
			strpi	r3,p1			;
			shl		l,r2			;
			shl		k,r3			;
			dec		r4				;
			bra		nz,tloop1		;
			jmp   	tx_prmt			;

			//################################
			// USA Flag
t_usaflag:	jsr		resetcolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jsr		setcolor7		;
			jsr		savecolor		;
			jsr		setcolor4		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// Ireland Flag
t_ireflag:	jsr		resetcolor		;
			ldpv	p1,colorset		;
			ldrv	r2,'h00FF		;
			ldrv	r3,'h0030		;
			strpi	r2,p1			;
			strpi	r3,p1			;
			ldrv	r2,'hFFFF		;
			ldrv	r3,'h00FF		;
			strpi	r2,p1			;
			strpi	r3,p1			;
			ldrv	r2,'h0000		;
			ldrv	r3,'h00FF		;
			strpi	r2,p1			;
			strpi	r3,p1			;
  			ldrv	r1,3 			;
			str		r1,colorcnt		;
			jmp		theme0			;
			
			//################################
			// Argentina Flag
t_argflag:	jsr		resetcolor		;
			jsr		setcolor4		;
			jsr		savecolor		;
			jsr		setcolor7		;
			jsr		savecolor		;
			jsr		setcolor4		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// England Flag
t_engflag:	jsr		resetcolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jsr		setcolor7		;
			jsr		savecolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// Italian Flag
t_itaflag:	jsr		resetcolor		;
			jsr		setcolor2		;
			jsr		savecolor		;
			jsr		setcolor7		;
			jsr		savecolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// Halloween Flag
t_halloween:
			jsr		resetcolor		;
			ldpv	p1,colorset		;
			ldrv	r2,'h00FF		;
			ldrv	r3,'h0022		;
			strpi	r2,p1			;
			strpi	r3,p1			;
  			ldrv	r1,1 			;
			str		r1,colorcnt		;
			jmp		theme0			;
			
			//################################
			// Colorful 1
t_colorful1:
			jsr		resetcolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jsr		setcolor2		;
			jsr		savecolor		;
			jsr		setcolor4		;
			jsr		savecolor		;
			jsr		setcolor3		;
			jsr		savecolor		;
			jsr		setcolor5		;
			jsr		savecolor		;
			jsr		setcolor6		;
			jsr		savecolor		;
			jsr		setcolor7		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// Colorful 2
t_colorful2:
			jsr		resetcolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jsr		setcolor2		;
			jsr		savecolor		;
			jsr		setcolor3		;
			jsr		savecolor		;
			jsr		setcolor4		;
			jsr		savecolor		;
			jsr		setcolor5		;
			jsr		savecolor		;
			jsr		setcolor6		;
			jsr		savecolor		;
			jsr		setcolor7		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// Colorful 3
t_colorful3:
			jsr		resetcolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jsr		setcolor7		;
			jsr		savecolor		;
			jsr		setcolor2		;
			jsr		savecolor		;
			jsr		setcolor6		;
			jsr		savecolor		;
			jsr		setcolor3		;
			jsr		savecolor		;
			jsr		setcolor5		;
			jsr		savecolor		;
			jsr		setcolor4		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// Saint Patricks DATE March 17th
t_saintpatrick:
			jsr		resetcolor		;
			ldpv	p1,colorset		;
			ldrv	r2,'h0000		;
			ldrv	r3,'h0011		;
			strpi	r2,p1			;
			strpi	r3,p1			;
			ldrv	r2,'h0000		;
			ldrv	r3,'h00ff		;
			strpi	r2,p1			;
			strpi	r3,p1			;
			ldrv	r2,'h0000		;
			ldrv	r3,'h00ff		;
			strpi	r2,p1			;
			strpi	r3,p1			;
			ldrv	r2,'h0000		;
			ldrv	r3,'h0011		;
			strpi	r2,p1			;
			strpi	r3,p1			;
  			ldrv	r1,4 			;
			str		r1,colorcnt		;
			jmp		theme0			;
			
			//################################
			// Liverpool
t_liverpool:
			jsr		resetcolor		;
			jsr		setcolor1		;
			jsr		savecolor		;
			jmp		theme0			;
			
			//################################
			// New York City FC
t_nycfc:	jsr		resetcolor		;
			ldpv	p1,colorset		;

			ldrv	r2,'h6200		;// Light Blue
			ldrv	r3,'h0000		;
			strpi	r2,p1			;
			strpi	r3,p1			;
			ldrv	r2,'hFFFF		;// White
			ldrv	r3,'h00FF		;
			strpi	r2,p1			;
			strpi	r3,p1			;
			ldrv	r2,'h00FF		;// Orange
			ldrv	r3,'h0022		;
			strpi	r2,p1			;
			strpi	r3,p1			;		
			ldrv	r2,'hFF00		;// Blue
			ldrv	r3,'h0000		;
			strpi	r2,p1			;
			strpi	r3,p1			;
  			ldrv	r1,4 			;
			str		r1,colorcnt		;
			jmp		theme0			;
			
themef:		nop						;
			rts						;
			
			
			//################################
			// Patterns
			//################################
			
			//################################
			// Execute buffer
pattern0:	ldr		r1,numpixels	;
			jmp		rd_buffer		;
			
			//################################
			// Blinking RGB and rgb
p_blink:	jmp		fE,pattern1_2	;
			ldr		r1,tmr1value	;
			str		r1,tmr1msec		;
			uflag	fE				;
	        jmp		t1,pattern1_1	;
			uflag	t1				;
			uport	t2				;
pattern1_2:	jmp   	pattern1_3     	; // 
pattern1_1:	uflag	f1				;
			uport	f2				;
pattern1_3:	rts						;
			
			//################################
			// walking led
p_walk:		jmp		fE,pattern2_1	;
			ldr		r1,tmr1value	;
			str		r1,tmr1msec		;
			uflag	fE				;
			jmp		t1,pattern2_2	;
			uflag	t1				; // switch fg/bg
			uport	f2				; // enable hw-fg
			ldr		r2,numpixels  	;
			ldr		r3,pselect1		;
			ldr		r4,pixelson		;
			inc		r3				;
			str		r3,pselect1		;
			add		r3,r4			;
			str		r3,pselect1e	;
			ldr		r3,pselect1		;
			cmpr 	r3,r2			;
			bra		le,pattern2_1	;
			ldrv	r3,1			;
			str		r3,pselect1		;
pattern2_0:	add		r3,r4			;
			str		r3,pselect1e	;
pattern2_1: jmp		wpattern		;
pattern2_2:	uflag	f1				; // fg/bg
			jmp		wpattern		;

			//################################
			// Dimm all channels
			// rtegister usage:
			// r1,r2,r3,--,r5,r6,--
p_dimm:		jmp		fE,pattern3_2	;
			ldr		r1,tmr1value	;
			str		r1,tmr1msec		;
			uflag	fE				;
			jsr		dimcounter		; // return flag in r4
pattern3_2:	ldcv	c0,RGBLENGTHH 	; // 8 channels = 2 x 8 words
			ldpv	p2,APPREG_00	; // from 00 to 07
			ldr		r2,colormskrg	; // mask
			ldr		r3,colormskwb	;
ploop3:		ldr		r1,dimcnt		; // r1=00xx
			mvrr	r1,r5			;
 			shl4	r5				;
 			shl4	r5				; // r5=xx00
			or		r1,r5			; // r1=xxxx
			mvrr	r1,r6			; // r6=xxxx
			// RG @ MASK
			and		r1,r2			; // mask
			outpp	r1,p2  			; //,0 optimize
			incp	p2				;
			// WB @ mask
			mvrr	r6,r1			;
			and		r1,r3			; // mask
			outpp	r1,p2  			; //,0 optimize
			incp	p2				;
			dcjnz	c0,ploop3		;
			rts						;
			
			//################################
			//
pattern4:	
pattern5:	
pattern6:	
pattern7:	
pattern8:	
pattern9:	
patterna:	
patternb:	
patternc:	
patternd:	
patterne:	
patternf:	nop						;
			rts						;
			
			
			////////////////////////////////////////////////
			//  Read buffers	
			// read from buffer write to port
			// Register usage:
			// r1,r2,--,r4,r5,r6,r7,--,ra,--,re
rd_buffer:	ldr		r1,pcounter1	;
			ldr		r5,numpixels	;
rd_buffer0:	ldr		r6,walk_cnt		;
			add		r1,r6			;
			mvrr	r1,r4			;
			sub		r1,r5			;
			bra		s,rd_buffer2	;
			bra		rd_buffer3		;
rd_buffer2:	mvrr	r4,r1			;
rd_buffer3:	shl		r1				;
			mvrr	r1,r2			; // save it
			ldpv	p9,APPREG_00	; // APPREG_00 CH0
			ldpv	p2,buf_table	; // point to all buffers
			ldcv	c0,RGBLENGTHH	; // 8 channels = 8 x 4 words
			// check walk on, Themes don't walk, Pattern walks
			ldr		ra,walk_on		; // walk_on=0 -> Themes
			or		ra,ra			; // walk_on=1 -> Patterns
			bra		z,rd_bufferx	;
			
			// timer to increment pointer
	        cmprp	rE,pE			; // old timer sync with tp2 thru uflag 2
			bra		ge,rd_bufferx	;
			ldpv	pE,'h0000		;
			
			ldr		ra,read_mode	;
			cmprv	ra,0			; // Up shift
			bra		z,rd_buffup		;
			cmprv	ra,1			; // Down shift
			bra		z,rd_buffdn		;
			cmprv	ra,2			; // Up/Down shift
			bra		z,rd_buffud		;
			cmprv	ra,3			; // blink
			bra		z,rd_buffbnk	;
			
			// Pixel 0 to numpixels
rd_buffup:	or		r6,r6			; // Up Shift default
			bra		nz,rd_buffup1	;
			ldr		r6,numpixels	;
rd_buffup1:	dec		r6				;
			bra		rd_buffwc1		;
			// Pixel numpixels to 0
rd_buffdn:	cmpr	r6,r5			; // Down shift
			bra		ge,rd_buffdn1	;
			inc		r6				;
			bra		rd_buffwc1		;
rd_buffdn1:	xor		r6,r6			;
			bra		rd_buffwc1		;
			// Pixel 0 to numpixels to 0
rd_buffud:	jmp		t1,rd_buffud0	; // Up Shift default
			or		r6,r6			; // Up Shift default
			bra		nz,rd_buffud1	;
			uflag	t1				;
			bra		rd_buffwc1		;
rd_buffud1:	dec		r6				;
			bra		rd_buffwc1		;						
rd_buffud0:	cmpr	r6,r5			; // Down shift
			bra		ge,rd_buffud2	;
			inc		r6				;
			bra		rd_buffwc1		;
rd_buffud2:	uflag	f1				;
			bra		rd_buffwc1		;
rd_buffbnk: jmp		t1,rd_buffbnk3	;
			uflag	t1				;
			uport	t2				; // background
			bra		rd_buffend		; // 
rd_buffbnk3:uflag	f1				;
			uport	f2				; // foreground
			bra		rd_buffend		; // 
			// looping for all channels
rd_buffwc1:	str		r6,walk_cnt		;
rd_bufferx:	ldrp	r7,p2			; // load the buffer
			mvrp	r7,p1			; // update p1
			incp	p2				; // point to next buffer
			addrp	r1,p1			;
			mvrp	r1,p1			;
			ldrpi	r1,p1			;
			outpp	r1,p9  			; // nop needed
			incp	p9				;
			ldrp	r1,p1			;
			outpp	r1,p9  			; // nop needed
			incp	p9				; // next APPREG_0x channel
			mvrr	r2,r1			; // restore pixel number
			dcjnz	c0,rd_bufferx	; // next buffer
rd_buffend:	rts						;
			
			
			////////////////////////////////////////////////
			//  Write patterns	
			// walking led 
wpattern:	ldr		r2,pselect1 	;
	        ldr		r3,pselect1e 	;
	        ldr		r4,pcounter1	;
	        ldr		r5,numpixels	;
	        mvrr	r3,r6			; // temporary 
	        sub		r6,r5			; // r6 = numpixels-pselect1e
	        bra		s,wpattern_chk	; // no pixels in carry out
	        cmpr	r4,r6			;
	        bra		le,wpattern_0	; // turn on pixels
wpattern_chk:
	        cmpr	r4,r5			;
	        bra		gt,wpattern_0	; //
			cmpr	r4,r2    		; // r4,r2
			bra		lt,wpattern_3	; // lt
			cmpr	r4,r3			; // r4,r3
			bra		ge,wpattern_3	; // ge
			// channel 1-16 with bg=BLK
wpattern_0: ldcv	c0,RGBLENGTHF	; // 16 channels
	        ldpv	p1,rgbtab		; // 0 to F = 16 loops
	        ldpv	p2,APPREG_00	; // from 00 to 07
wloop:		ldrpi	r1,p1			; //
			outpp	r1,p2  			; //,0
			incp	p2				;
			dcjnz	c0,wloop		;
			jmp		wpattern_2		;
wpattern_3: jmp		t4,wpattern4	;	
			xor		r1,r1	 		; // background zero/black
	        ldcv	c0,RGBLENGTHF	; // 16 channels
	        ldpv	p2,APPREG_00	;
wloop1:		outpp	r1,p2  			; //,0
			incp	p2				;
			dcjnz	c0,wloop1		; // 0 to F = 16 loops
	        jmp		wpattern_2		;
wpattern4:	// channel 1-16 with bg=RGB
	        ldcv	c0,RGBLENGTH	; // foreground
	        ldpv	p1,rgbtab_bg	;
	        ldpv	p2,APPREG_00	;
wloop2f:	ldrpi	r1,p1			; //
  			outpp	r1,p2  			; //,0
  			incp	p2				;
  			dcjnz	c0,wloop2f		; // 0 to 7 = 8 loops
	        ldcv	c0,RGBLENGTH	;
	        ldpv	p1,rgbtab_bg	; // backgound color
	        ldpv	p2,APPREG_10	;
wloop2b:	ldrpi	r1,p1			; //
  			outpp	r1,p2  			; //,0
  			incp	p2				;
  			dcjnz	c0,wloop2b		; // 0 to 7 = 8 loops
wpattern_2: rts						;

			//################################
			// Dim Counters
dimcounter:	ldr		r1,dimcnt		;
			ldr		r2,dimflg		;
			ldr		r3,dimsteps		;
			ldr		r4,intensity	;
			andv	r4,'h00FF		;
			cmprv	r2,0			;
			bra		z,addvalue		;// dimflg=0 Add steps
subvalue:	sub		r1,r3			;// dimflg=1 Sub steps
			bra		ns,keepit		;
			xor		r1,r1			;
			xor		r2,r2			;
  			bra		keepit			;
addvalue:	add		r1,r3			;
			cmpr	r1,r4	 		;
			bra		lt,keepit		;
			mvrr	r4,r1			;
			ldrv	r2,1			;
keepit:		str		r1,dimcnt		;
			str		r2,dimflg		;
			rts						;
			
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
	// Month check 28/29/30/31
	// January = 1 to December = 12
	// Monday  = 0 to Sunday = 6
	// Date    = 1 to 31

	// Initialize:
	// month  = 1;
	// Monday = 0;
	// date   = 1;

	// algorithm:
	//	if month = 2
	//		if leap_year
	//			monthcheck = 29
	//		else
	//			monthcheck = 28
	//	goto end
    //	else
	//		if month 1xxx (bit 3 high)
	//			goto August
	//		else
	//			if 0xx0 (bit 3 low and bit 0 low) 
	//				monthcheck = 30
	//			if 0xx1 (bit 3 low and bit 0 high)
	//				monthcheck = 31
	//			goto end
	//	endif
	//
	// august:
	//	if month 1xx0 (bit 3 high and bit 0 low)
	//		monthcheck = 31
	//	if month 1xx1 (bit 3 high and bit 0 high)
	//		monthcheck = 30
	//
	//	end:
	
	//		R5 input  = current month
	//		R6 input  = current year
	//		R8 output = max days for the month
monthchk:	cmprv	r5,2			; // current month
			bra		ne,monthchk0	; // is not February
			mvrr	r6,r9			;
			andv	r9,'h00ff		;
			bra		z,month28		; // not leap year, 2100/2200/2300 for example
			andv	r9,'h0003		; // every 4 years
			bra		nz,month28		; // not leap year
month29:	ldrv	r8,29			;
			bra		monthchkend		; // leap year
month28:	ldrv	r8,28			;			
			bra		monthchkend		;
monthchk0:	bitv	r5,8			; //
			bra		nz,monthchk1	;
			bitv	r5,1			; // January to July
			bra		z,month30		;
month31:	ldrv	r8,31			;
			bra		monthchkend		;
month30:	ldrv	r8,30			;
			bra		monthchkend		;
monthchk1:	bitv	r5,1			; // August to December
			bra		z,month31		;
			bra		month30			;
monthchkend:
			rts						;
			
	////////////////////////////////////////////////////////////
	// Interrupt vectors
	////////////////////////////////////////////////////////////
	// ~30uSec pulsepixel counter
hw_irq1:	uport	t8				;
			ldr		r1,pcounter1	; // pcounter1
			inc		r1;
			str		r1,pcounter1	; // pcounter1
			uflag	t8				;
			uport	f8				;
			rti						;
                                	
	// ~3mSec pulse Strip counter, reset strip
hw_irq2:	uport	t9				;
			xor		r1,r1	  		; //
			str		r1,pcounter1	; // clear pixel counter 1
			uflag	t9				;
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
			uflag	tA				; // one hour flag, clear by someone, not used right now
			inc		r3				;
			cmprv	r3,24			; // 1 day
			bra		lt,hw_irq4_3	;
			xor		r3,r3			;
			andv	r4,'h00ff		;
			andv	r7,'hff00		;
			shr4	r7				;
			shr4	r7				;
			inc		r7				;
			cmprv	r7,7			; // check for SUN
			bra		lt,hw_irq4_6	;
			xor		r7,r7			; // back to MON
hw_irq4_6:	shl4	r7				;
		 	shl4	r7				;
		 	inc		r4				; // current month
		 	jsr		monthchk		; // 1 month, check 28/29/30/31
			cmpr	r4,r8			; // return in r8 the max day of the month
			bra		le,hw_irq4_4	;
			ldrv	r4,1			;
			inc		r5				;
			cmprv	r5,12			; // 1 year 1 to 12
			bra		le,hw_irq4_5	;
			ldrv	r5,1			; // initialize to January
			inc		r6				;
			str		r6,tmr1year	; 
hw_irq4_5:	str		r5,tmr1month	; 
hw_irq4_4:	or		r4,r7			;			
			str		r4,tmr1date		; 
hw_irq4_3:	str		r3,tmr1hour		; 
hw_irq4_2:	str		r2,tmr1min		; 
hw_irq4_1:	str		r1,tmr1sec		;
			rti						;


	// SWI #1
sw_irq1:	rti						;  

   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Data Section
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   
monthtab:	dw	31,28,31,30,31,30,31,31,30,31,30,31;

version_m:	dt "SW:040522-01-16Ch-100Pix-1c3b-2a69(3f00)";
				//Software version: MMDDYY-rev-channels-pixels-codeLength-progrLength(max progrLength)
				//    - version                 mmddyy
				//    - revision                    nn
				//    - number of channels        nnCh
				//    - number of pixels        nnnPix
				//    - code length               LLLL
				//    - RAM  length               LLLL  (code+RAM+stack)
				//    - (Boot Address)                  Maximum RAM length
				
   //////////////////////////////////////////////////////////////////////
   // System Constants and Menu Messages
   //////////////////////////////////////////////////////////////////////
return_m:	dt	" Return to caller, press any key to display menu"; 

memof_m:	dt  " Internal Memory Access"; 
memon_m:	dt  " External Memory Access";
   
membyte_m:	dt  " Byte Memory Access"; 
memword_m:	dt  " Word Memory Access";
   
hexval4_m:	dt  " Enter value [RET] = ";
         
treset_m:	dt  " Target Reset done";
clearr_m:	dt  " Control Register Cleared";

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
   // PCODE  :  "J" -> jump to next state.
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
kpst30:  dw		"n"	,"J", d_pixels,	kpst30; // number of Pixels
         dw    	"l" ,"J", setarst,  kpst30; //set SOC reset, ws2811 load bits
         dw    	"p" ,"J", setaper,  kpst30; //set SOC coversion period
         dw    	"0" ,"J", setapul0, kpst30; //set SOC pulse width     
         dw    	"1" ,"J", setapul1, kpst30; //set SOC pulse width     
         dw		"8"	,"J", d_fastpwm,kpst30; // 800KHz
         dw		"4"	,"J", d_slowpwm,kpst30; // 400Khz
         dw    	"s" ,"J", d_scpsrc, kpst30; // scope source
         dw    	"t" ,"J", d_trgsrc, kpst30; // scope source
         dw    	"b" ,"J", d_base,   kpst30; // base reg address 
         dw    	"r" ,"J", d_aregs,  kpst30; //display all regs
         dw    	"w" ,"S", s_bitop,  wpst01; //write register
         dw     "R" ,"J", d_target, kpst30; //target reset.
         dw     "W" ,"J", d_pcode,  kpst30; //pcode set, make program RAM writable or not
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
kpst40:  dw		"a"	,"J",  d_pixelson,	kpst40; // active/walking Pixels
         dw		"s"	,"J",  d_colors,	kpst40; // set colors
         dw		"c"	,"J",  d_channel,	kpst40; // channel #
         dw		"i"	,"J",  d_colorin,	kpst40; // set intensity
         dw		"e" ,"J",  d_enbthe,	kpst40; // set themes
         dw		"p" ,"J",  d_enbpat,	kpst40; // run patterns
         dw		"d" ,"J",  d_runthem0,	kpst40; // run pattern/theme #0
         dw		"f" ,"J",  d_enbfg,		kpst40; // enable foreground
         dw		"m" ,"J",  d_bufmode,	kpst40; // fill buffer mode
         dw		"b" ,"J",  d_enbbg, 	kpst40; // enable background
         dw		"0" ,"J",  setcolor0,	kpst40; // set color blk
         dw		"1" ,"J",  setcolor1,	kpst40; // set color red
         dw		"2" ,"J",  setcolor2,	kpst40; // set color grn
         dw		"3" ,"J",  setcolor3,	kpst40; // set color red/grn
         dw		"4" ,"J",  setcolor4,	kpst40; // set color blu
         dw		"5" ,"J",  setcolor5,	kpst40; // set color red/blu
         dw		"6" ,"J",  setcolor6,	kpst40; // set color grn/blu
         dw		"7" ,"J",  setcolor7,	kpst40; // set color wht
         dw		"8" ,"J",  savecolor,	kpst40; // update colorset counters
         dw		"9" ,"J",  resetcolor,	kpst40; // reset colorset counters/flags
         dw		"r"	,"J",  d_readmode,	kpst40; // read buffer mode
         dw		"t" ,"J",  d_timer1,	kpst40; // set timer 1
         dw		"j"	,"J",  d_dimstep,	kpst40; // increase dimsteps
         dw		"n"	,"J",  d_pixels,	kpst40; // Pixels
         dw		"S"	,"J",  savebuf, 	kpst40; // save buffer to SRAM
         dw		"R"	,"J",  restorebuf, 	kpst40; // restore buffer from SRAM
         dw		"P"	,"J",  d_pagenum,	kpst40; // set page SRAM
         dw		"V"	,"J",  d_buff_idx, 	kpst40; // set virtual channel
         dw     "k" ,"J",  d_rtcval,    kpst40; // display RTC
         dw     "v" ,"J" , d_prgver,    kpst40; //program version
         dw     "h" ,"J",  d_helpa,     kpst40; //display the help notes
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
         dt    " L = Load Program *.mem"; 
         dt    " E = Echo ON"; 
         dt    " e = echo OFF"; 
         dt    " C = CLS ON"; 
         dt    " c = CLS OFF"; 
         dt    " I = IRQ mask"; 
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
         dt    " l = PWM reset"; 
         dt    " p = PWM period"; 
         dt    " 0 = PWM pulse width code 0";
         dt    " 1 = PWM pulse width code 1";
         dt    " 8 = 800Khz PWM"; 
         dt    " 4 = 400Khz PWM"; 
		 dt    "";
         dt    " b = set Base reg address"; 
         dt    " r = Read all registers"; 
         dt    " w = Write/read port/register"; 
         dt    " n = Number of Pixels"; 
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
         dt    " c = set Channel (0 to f)"; 
         dt    " f = select Foreground"; 
         dt    " b = select Background"; 
         dt    " s = Set color value per channel"; 
         dt    ""; 
         dt    " p = Pattern";
         dt    " e = thEme";
         dt    " d = Display theme"; 
         dt    " m = theme Mode"; 
         dt		""; 
         dt    " i = Intensity (0-7)";
         dt    " 0 = blk"; 
         dt    " 1 = red"; 
         dt    " 2 = grn"; 
         dt    " 3 = yel"; 
         dt    " 4 = blu"; 
         dt    " 5 = mag"; 
         dt    " 6 = cya"; 
         dt    " 7 = wht"; 
         dt    " 8 = update colorset queue"; 
         dt    " 9 = reset  colorset queue"; 
         dt    ""; 
         dt    " a = active pixels"; 
         dt    " r = read buffer mode"; 
         dt    " t = timer (blink/dim/walk)"; 
         dt    " j = dimm steps"; 
         dt    " n = Number of Pixels"; 
         dt    ""; 
         dt    " S = Save channel to virtual channel"; 
         dt    " R = Restore virtual channel to channel"; 
         dt    " P = external memory Page"; 
         dt    " V = set Virtual channel, V=-1 then V=c"; 
         dt    ""; 
         dt    " k = display clock ";
         dt    " v = version";
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
		 dt    " b = background color";
         dt    " c = channel strip (0 to f)";
         dt    " d = display buffer";
         dt    " f = foreground color";
         dt    "";
		 dt    " a = active walking/length pixels";
         dt    " r = read buffer mode, DN(0),UP(1),UD(2)";
         dt    " t = timer for blink/dim/walk";
         dt    " j = dimm steps"; 
         dt    "";
		 dt    " p = selects a pattern";
         dt    " p = 0 Walking Custom theme"; 
         dt    " p = 1 Blinking LED"; 
         dt    " p = 2 Walking LED"; 
         dt    " p = 3 Dimm LED"; 
         dt    "";
		 dt    " e = selects a theme";
         dt    " e = 0 Custom Theme";
         dt    " e = 1,2 XMas";
         dt    " e = 3,4,5,6 colorful1";
         dt    " e = 7,8,9,a,b  Flags";
         dt    " ....7:USA,8:IRE,9:ARG,a:ENG,b:ITA,";
         dt    "";
         dt    " s = selects color, enter GGBBRR in Hex";
         dt    " i = color intensity for solid colors <0-7>";
         dt    " m = Fill channel buffer mode"; 
         dt    " ....0:stretch, 1:repeat"; 
         dt    " 8-9 = Update-Reset colorset counter/queue"; 
         dt    " 0-7 = selects predefined colors";
         dt    "..... 0:BLK 1:R 2:G 3:RG 4:B 5:RB 6:GB 7:WHT";
         dt    "|||"; 
         dw    ETX;// end of page 
         
help_m:  dt    "| H E L P |"; 
         dt    "| WG2811/12.asm (16K)|"; 
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
			// Theme Table
the_table:	dw	theme0			; //0 custom
			dw	t_xmas			; //1 fill buffer with RGB
			dw	t_xmas2			; //2 fill buffer with gradient
			dw	t_colorful1		; //3 
			dw	t_colorful2		; //4 
			dw	t_colorful3		; //5 
			dw	t_halloween 	; //6
			dw	t_liverpool		; //7 
			dw	t_nycfc    		; //8 
			dw	t_saintpatrick	; //9 
			dw	t_usaflag		; //a 
			dw	t_ireflag		; //b 
			dw	t_argflag		; //c
			dw	t_engflag 		; //d
			dw	t_itaflag 		; //e
			dw	themef 			;

			// Pattern Table
pat_table:	dw	pattern0		; // custom walk up/down
			dw	p_blink			; // Blinking pixels 
			dw	p_walk			; // Walking pixels     
			dw	p_dimm			; // Dim and blink 
			dw	pattern4		;
			dw	pattern5		;
			dw	pattern6		; // 
			dw	pattern7		; // 
			dw	pattern8		;
			dw	pattern9 		;
			dw	patterna 		;
			dw	patternb 		;
			dw	patternc 		;
			dw	patternd 		;
			dw	patterne 		;
			dw	patternf 		;
			
intensity_tab:
			dw	'h0101			;
			dw	'h0303			;
			dw	'h0707			;
			dw	'h0F0F			;
			dw	'h1F1F			;
			dw	'h3F3F			;
			dw	'h7F7F			;
			dw	'hFFFF			;
         
         
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

echomode:	dw 0			; // default is off
	
   //////////////////////////////////////////////////////////////////////
   // Application Variables
   //////////////////////////////////////////////////////////////////////
tmr1msec:	dw	0			; // timer 1mS
tmr1value:	dw	100			; // timer recurrent value
walk_cnt:	dw	0			;
walk_on:	dw	0			; // enable walking pixels
   		
pcounter1:	dw	0 			; // pixel counter
pselect1:	dw	0 			; // pixel selected
pselect1e:	dw	1 			; // pixel end
irqmask:	dw	1			; // default irq 1
//
dimcnt:		dw	0			;
dimflg:		dw	0			;
//							  // SESMA local variables.
ssm_pst: 	dw	kpst00		; // present state
ssm_lst: 	dw	kpst00		; // last state (return state)


			////////////////////////////////////////////////////////
			// RGB Tables
rgbtab:		dw	'h0005,'h0000,'h0000,'h0005; // channel 1-2
			dw	'h0500,'h0000,'h0500,'h0505; // channel 3-4
			dw	'h0005,'h0000,'h0000,'h0005; // channel 5-6
			dw	'h0500,'h0000,'h0500,'h0505; // channel 7-8
rgbtab8:	dw	'h0001,'h0000,'h0000,'h0002; // channel 9-10
			dw	'h0000,'h0000,'h0000,'h0000; // channel 11-12
			dw	'h0000,'h0000,'h0000,'h0000; // channel 13-14
			dw	'h0000,'h0000,'h0000,'h0000; // channel 15-16
rgbtab_bg:	dw	'h0100,'h0000,'h0100,'h0000; // channel 1-2
			dw	'h0100,'h0101,'h0100,'h0101; // channel 3-4
			dw	'h0100,'h0000,'h0100,'h0000; // channel 5-6
			dw	'h0100,'h0101,'h0100,'h0101; // channel 7-8
rgbtab_bg8:	dw	'h0100,'h0000,'h0200,'h0000; // channel 9-10
			dw	'h0000,'h0000,'h0000,'h0000; // channel 11-12
			dw	'h0000,'h0000,'h0000,'h0000; // channel 13-14
			dw	'h0000,'h0000,'h0000,'h0000; // channel 15-16
			
			
zbugtab:		// for visualization and debugging
				// L1			
varchk:		dw	the_table	; // theme table
			dw	pat_table	; // pattern table
			dw	rgbtab		; // foreground
			dw	rgbtab_bg	; // background
			dw	buf_table	; // buffer table
			dw	tmr1msec	; // timer 1 mSec
			dw	colorset	; // 
numpixels:	dw	STRIPLENGTH	;

				// L2
buf_table:	dw	pbuffer1;
			dw	pbuffer2;
			dw	pbuffer3;
			dw	pbuffer4;
			dw	pbuffer5;
			dw	pbuffer6;
			dw	pbuffer7;
			dw	pbuffer8;
				// L3
			dw	pbuffer9;
			dw	pbuffer10;
			dw	pbuffer11;
			dw	pbuffer12;
			dw	pbuffer13;
			dw	pbuffer14;
			dw	pbuffer15;
			dw	pbuffer16;
				// L4
dbugptr:	ds 8				; //p7=dbugptr,variables for debugging
				// L5			  	  
colorcnt:	dw	0				; // number of colors
colorseg:	dw	0				; // number of segments
residual:	dw	0				; // p7+10
ready2go:	dw	0				; // colorcnt > 0	
channel:	dw	0				; // channel
intensity:	dw	'hFFFF			; // intensity
colorsetrg:	dw	0				;			
colorsetwb:	dw	0				;	
				// L6
buff_addr:	dw	0				;
buff_addrx:	dw	0				;
buff_value:	dw	0				;
buff_len:	dw	0				;
buff_inc:	dw	0				;
buff_idx:	dw	SIGNED			; // virtual Channel number
pixelson:	dw	1 				; // pixel always ON
dimsteps:	dw	1				;
				// L7
colormskrg:	dw	'hFFFF			;			
colormskwb:	dw	'h00FF			;			
memode:		dw	0				; // word/byte = 0/1
memacc:		dw	0				; // internal/external = 0/1
memop:	 	dw  0     			; // IRW,XRD,XWR,XRW (0,1,2,3) 
poffset:	dw	0				; // pattern/theme table offset
buff_mode:	dw  0				; // theme mode
tjump:		dw	the_table		; // theme table jump
				// L8
tmr1year:	dw	YEAR			; // timer 12 M = 1Y
tmr1month:	dw	MONTH			; // timer 28/29/30/31 D = 1M
tmr1date:	dw	DATE			; // timer 24 H = 1D
tmr1hour:	dw	HOUR			; // timer 60 m = 1H
tmr1min:	dw	MINUTE			; // timer 60 s = 1m
tmr1sec:	dw	SECONDS			; // timer 1S
read_mode:	dw 0				; // pattern mode
pjump:		dw	pat_table		; // pattern table jump
				// L9
zregdbug:	ds 8				; //pD=dbugptr,register for debugging
			
colorset:	ds	BUFFERLENGTH	; // BR,WG -> 2 words per pixel
			//			
pbuffer1:	ds	BUFFERLENGTH	; // BUFFERLENGTH = numpixels*2
pbuffer2:	ds	BUFFERLENGTH	; // BR,WG -> 2 words per pixel
pbuffer3:	ds	BUFFERLENGTH	;
pbuffer4:	ds	BUFFERLENGTH	;
pbuffer5:	ds	BUFFERLENGTH	;
pbuffer6:	ds	BUFFERLENGTH	;
pbuffer7:	ds	BUFFERLENGTH	;
pbuffer8:	ds	BUFFERLENGTH	;
pbuffer9:	ds	BUFFERLENGTH	; // BUFFERLENGTH = numpixels*2
pbuffer10:	ds	BUFFERLENGTH	; // BR,WG -> 2 words per pixel
pbuffer11:	ds	BUFFERLENGTH	;
pbuffer12:	ds	BUFFERLENGTH	;
pbuffer13:	ds	BUFFERLENGTH	;
pbuffer14:	ds	BUFFERLENGTH	;
pbuffer15:	ds	BUFFERLENGTH	;
pbuffer16:	ds	BUFFERLENGTH	;

   //////////////////////////////////////////////////////////////////////
   // Stack area
   //////////////////////////////////////////////////////////////////////
zstack:
stack:	ds STACK_LENGTH    	; // stack area

   //////////////////////////////////////////////////////////////////////
   // How to use exe_v as an intermediate call
   //			jsr		setexe			;
   //	
   //setexe:	ldrv	r1,my_routine	; // routine address to be execute by callexe
   //	 		ldpv	p1,exe_v		; // address destination
   //	 		strx	r1,p1,1			; // save it after jmp instruction
   //    		rts                 	;
   //
   //callexe: 	jsr   exe_v				; // this call executes any routine
   //         	rts						;
   //
   // my_routine:
   //			nop						;
   //			rts						; 
   //////////////////////////////////////////////////////////////////////
exe_v:	jmp	exe_v	; // exe_v will be replaced by my_routine

zend_ram:  // mark the end of writable RAM area

			
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // BOOT LOADER
   // ^P loads a program file into memory.
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
