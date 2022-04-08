   // MAIN Program : (runs for about 300 uS)
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
   // R3 register 3 -> user register  'R3'
   // Rn register n -> user register  'Rn' n=0...F


   
   // UART Data Reg
define   UARTRX   'hFF0 // Input Register (read only)
define   UARTTX   'hFF0 // Output Register (write only)
   
define   UARTSTA  'hFF1 // status register (read only)
define   UARTCTL  'hFF1 // control register (write only)
   
define   UARTBL   'hFF2 // Baud rate low byte
define   UARTBH   'hFF3 // Baud rate high byte
   
define   TXHALF   'h004 // fifo half full
define   TXFULL   'h400 // fifo full 
define   RXVALID  'h800 // valid input data
   
define BOOT_LOADER	'h3F00
define RESET_ENTRY	'h0000
define MAIN_ENTRY	'h0050

	// To be used with LDMAM instruction (Load Memory Access Mode)	
define   IRW 0 // internal read , internal write. m0   
define   XRD 1 // external read , internal write. m1 
define   XWR 2 // internal read , external write. m2 
define   XRW 3 // external read , external write. m3 
   
// User defines
define	STACK_SIZE	10
define	RAM_SIZE	32
define	VALUE1	'h0055
define	VALUE2	'h1234

   // Key defines
define   CR       'h00d
define   LF       'h00a
define   FF       'h00c
define   DC2      'h012
define   ESC      'h01b
   

define   shifts 4
define   count  8
   
    
@RESET_ENTRY
reset_v: jmp   main             ; // @ 'h000
irq_v:   jmp   hw_irq           ; // @ 'h002
swi_v:   jmp   sw_irq           ; // @ 'h004

   
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Subroutines
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////

   // Check input key.
waitk:   ldr   r1,access        ;
         cmprv r1,"a"           ;
         bra   z,nowait         ;
         str   r1,access        ; 
nowait:  rts                    ; 

   // Transmit a single line
tx_line: ldrpi r3,p1            ; // read character
         or    r3,r3            ; // Check end of line
         bra   z,tx_ends        ; // 
         outp  r3,UARTTX        ; // output char
         bra   tx_line          ; // next one
tx_ends: rts                    ; // finished
   
   // transmit a full page
tx_page: jsr   tx_line          ; // read a line
         mvpr  p1,r0            ;
         str   r0,tx_tmp        ; 
         jsr   tx_prmt          ; // output prompt
         ldr   r3,tx_tmp        ;
         mvrp  r3,p1            ; 
         ldrp  r3,p1            ; // read current character
         cmprv r3,'hfff         ; // check for end of page
         bra   nz,tx_page       ; // next line
         rts                    ;
   
   // Transmit prompt character
tx_prmt: ldpv  p1,prompt        ; // 
         jsr   tx_line          ; // output prompt
         rts                    ; // end of message

   // Convert HEX value to ASCII
hex2asc: strpi r2,p3            ; // push
         andv  r2,'h00F         ;
         cmprv r2,'h00A         ;
         bra   lt,hex1          ;
         addv  r2,'h007         ;
hex1:    addv  r2,'h030         ;
         str   r2,temp1         ;
         ldrpd r2,p3            ; // pop
         shr4  r2               ; // shift right 4 logical
         andv  r2,'h00F         ;
         cmprv r2,'h00A         ;
         bra   lt,hex2          ;
         addv  r2,'h007         ;
hex2:    addv  r2,'h030         ;
         str   r2,temp2         ; 
         rts                    ;

   // Subroutine to display PASSED or FAILED
pass_fail:
p_or_f:  ldr   r1,e_code        ;
         or    r1,r1            ;
         bra   ne,failed        ; 
         ldpagv	'hcece			;
		 ldpv  p1,p_msg         ;
         bra   passed           ; 
failed:  ldpagv	'hfa11			;
		 ldpv  p1,f_msg         ; 
passed:  jsr   tx_line          ;
         jsr   err_out          ; 
         jsr   tx_prmt          ;
         rts                    ;
   
   // Error out
err_cnt: uport t7               ; 
         ldr   r0,e_code        ;
         inc   r0               ;
         str   r0,e_code        ;
         ldpag	r0				;
         uport f7               ;
         rts                    ;
   
   // Error count
err_out: ldr   r2,e_code        ;
         or    r2,r2            ;
         bra   e,no_error       ; 
         jsr   hex2asc          ;
err_w1:  ldr   r2,temp1         ;
         ldr   r2,temp2         ;
         outp  r2,UARTTX        ;
err_w2:  ldr   r2,temp1         ;
         outp  r2,UARTTX        ;
         xor   r0,r0            ;// clear code
         str   r0,e_code        ; 
no_error:rts                    ;
   
   
   // messages
tx_dt1:  ldrv  r0,'h1111        ;
         str   r0,temp1         ; 
         jsr   tx_dt2           ; 
         rts                    ; // finished

tx_dt2:  ldrv  r0,'h2222        ;
         str   r0,temp2         ; 
         jsr   tx_dt3           ; 
         rts                    ; // finished

tx_dt3:  ldrv  r0,'h3333        ;
         str   r0,temp3         ; 
         jsr   tx_dt4           ; 
         rts                    ; // finished

tx_dt4:  ldrv  r0,'h4444        ;
         str   r0,temp4         ; 
         rts                    ; // finished

   // This is not a Sbroutine
save_5:  ldrv  r0,'h1234        ;
         str   r0,temp0         ;
         jmp   check_5          ;
   
   // This is not a Sbroutine
save_6:  ldrv  r0,'h5678        ;
         str   r0,temp0         ;
         ldpv  p2,check_6       ; 
         jmpp  p2               ;
         jsr   err_cnt          ; // 02
         jmp   c_next           ;

   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Data Section
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////

prompt:  dw    'h00D            ;
         dw    'h00A            ;
         dt    "> "             ;
         dt    " ==================================";
version: dt    " prog_test.asm: version 022006_00"; 
tests_m: dt    " Test Groups:";
         dt    " [a] run all, [SPC] single test, [^L] Load file";
         dw    'hfff            ;// end of page
   
m_inout: dt    " In-Out........"; 
m_move:  dt    " Move.........."; 
m_shift: dt    " Shift.........";
m_jump:  dt    " Jump.........."; 
m_branch:dt    " Branch........"; 
m_load:  dt    " Load.........."; 
m_store: dt    " Store........."; 
m_incdec:dt    " Inc-Dec......."; 
m_arith: dt    " Arithmetic...."; 
m_logic: dt    " Logic.........";
m_loopc: dt    " Loops.........";
m_user:  dt    " User flags....";
end_msg: dt    " ";
tst_cnt: dw    'h030            ; 
         dt    "  <- Run Test";
         dt    " ==================================";
         dw    'hfff            ;// end of page

p_msg:   dt    " PASSED"; 
f_msg:   dt    " FAILED, Error => "; 

stk_warn:dw    CR,LF            ; 
         dt    "!!!!!! WARNING:  Stack, low on space. !!!!!!";
         dw    'hfff            ;
stk_err: dw    CR,LF            ; 
         dt    "!!!!!! ERROR: Stack, no space left. !!!!!!";
         dw    'hfff            ;

e_code:  dw    0                ; 

scratch: ds    32               ;
         dw    0                ; // null terminator for formatted text.

   // Used by TX_LINE and TX_PAGE routines
tx_tmp:  dw    0                ; // use by tx_line/tx_page routines.
   
   // constants
tcte0:   dw    'h0000           ;
tcte1:   dw    'h1111           ;
tcte2:   dw    'h2222           ;
tcte3:   dw    'h3333           ;
tcte4:   dw    'h4444           ;
   
   // Temporary storage
access:  dw    1                ;

temp0:   dw    1                ;
temp1:   dw    1                ; 
temp2:   dw    1                ; 
temp3:   dw    1                ; 
temp4:   dw    1                ;

tempa:   dw    0                ;
tempb:   dw    0                ;
tempc:   dw    0                ;

mem1:    dw    'h0001,'h0002,'h0004,'h0008,'h0010,'h0020,'h0040,'h0080; 
mem2:    dw    'h0010,'h0020,'h0040,'h0080,'h0100,'h0200,'h0400,'h0800; 
mem3:    dw    'h8000,'h9000,'ha000,'hb000,'hc000,'hd000,'he000,'hf000; 
mem4:    dw    'hf800,'hf900,'hfa00,'hfb00,'hfc00,'hfd00,'hfe00,'hff00; 
mem5:    dw    'h0008,'h0009,'h000a,'h000b,'h000c,'h000d,'h000e,'h000f;
    
temp:    ds    100              ;
   
error_left:
         dw    'hfff; // 0 = no error, other = number of errors.
error_right:
         dw    'hfff; // 0 = no error, other = number of errors.
error_arith:
         dw    'hfff; // 0 = no error, other = number of errors.
error_rleft:
         dw    'hfff; // 0 = no error, other = number of errors.
error_rright:  
         dw    'hfff; // 0 = no error, other = number of errors.
error_mixed:  
         dw    'hfff; // 0 = no error, other = number of errors.
   

   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // Program Section
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////

         // MAIN entry
main:    xor   r0,r0            ;
         str   r0,e_code        ; 
         ldpv  pF,stack         ; // initialize stack pointer
         ldrv  r1,last_stk      ; // Check boundaries
         cmprv r1,boot          ;
         bra   ls,chk_stk       ;
         ldpv  p1,stk_warn      ; // WARNING :  low stack
         jsr   tx_page          ; // continue
chk_stk: ldrv  r1,boot          ; // verify if SP was loaded.
         cmprp r1,p3            ;
         bra   hi,main1         ;
         ldpv  p1,stk_err       ; // ERROR :  no stack  
         jsr   tx_page          ; // continue
stk_trap:stop                   ;
         bra   stk_trap         ; // stack error

main1:   ldrv  r0,"a"           ; // run all tests by default
         str   r0,access        ; // used by waitk routine
         ldrv  r1,'h030         ; // clear test counter
         str   r1,tst_cnt       ;
   
main2:   // Initialize variables.
         uport f0               ; // turn OFF LED 1
         uport f1               ; // turn OFF LED 2
         xor   r0,r0            ; // clear error code 1st time.
         str   r0,e_code        ;
         ldrv  r0,'h0000        ; // initialize constants.
         str   r0,tcte0         ; 
         ldrv  r1,'h1111        ;
         str   r1,tcte1         ; 
         ldrv  r2,'h2222        ;
         str   r2,tcte2         ; 
         ldrv  r3,'h3333        ;
         str   r3,tcte3         ; 
         ldrv  r0,'h4444        ;
         str   r0,tcte4         ;

         // Display Header
         ldpv  p1,prompt        ; 
         jsr   tx_page          ;
         jsr   tx_prmt          ;

         // Check External Memory Access
         //=============================
         ldmam m3                ; // access external memory.
         ldrv  r1,'h1234        ;
         str   r1,'h0000        ;
         inc   r1               ;
         str   r1,'h0001        ; 
         inc   r1               ;
         str   r1,'h0002        ;
         ldr   r2,'h0000        ; 
         ldr   r3,'h0001        ; 
         ldr   r4,'h0002        ;
         ldmam m0                ; // restore internal access.
   
         // Check Inp-Outp
         //====================
         // if you see the header message, the INP/OUTP
         // are working.
chk_io:  ldpv  p1,m_inout       ; 
         jsr   tx_line          ;
         jsr   pass_fail        ; // pass_fail

         uport t0               ; 
         jsr   waitk            ; // stop @ 
         uport f0               ; 

         // Test test_moves.asm
         //====================
         // Check MVRR 
chk_mvrr:ldpv  p1,m_move        ; 
         jsr   tx_line          ;
         ldrv  r0,'h1234        ;
         mvrr  r0,r1            ;
         mvrr  r1,r2            ;
         mvrr  r2,r3            ;
         cmprv r3,'h1234        ; 
         bra   ne,f_mvrr        ;
         cmprv r2,'h1234        ; 
         bra   ne,f_mvrr        ;
         cmprv r1,'h1234        ; 
         bra   ne,f_mvrr        ;
         bra   chk_mvrp         ; 
f_mvrr:  jsr   err_cnt          ; // 01
         // Check MVRP 
chk_mvrp:ldrv  r0,'h1234        ;
         mvrp  r0,p1            ;
         ldrv  r2,'h5678        ;
         mvrr  r2,r1            ;
         mvrp  r1,p2            ;
         stp   p1,tempa         ;
         stp   p2,tempb         ;
         ldr   r1,tempa         ;
         cmprv r1,'h1234        ; 
         bra   ne,f_mvrp        ;
         ldr   r2,tempb         ; 
         cmprv r2,'h5678        ; 
         bra   ne,f_mvrp        ;
         bra   chk_mvpr         ; 
f_mvrp:  jsr   err_cnt          ; // 02
         // Check MVPR 
chk_mvpr:
         ldpv  p1,'h8888        ;
         mvpr  p1,r2            ;
         ldpv  p2,'h9999        ;
         mvpr  p2,r3            ;
         cmprv r2,'h8888        ; 
         bra   ne,f_mvpr        ;
         cmprv r3,'h9999        ; 
         bra   ne,f_mvpr        ;
         bra   chk_mvpp         ; 
f_mvpr:  jsr   err_cnt          ; // 03
         // Check MVPP 
chk_mvpp:
         ldpv  p1,'h327         ;
         mvpp  p1,p2            ;
         mvpr  p2,r1            ; 
         cmprv r1,'h327         ; 
         bra   ne,f_mvpp        ;
         ldpv  p1,0             ;
         mvpp  p2,p1            ;
         mvpr  p1,r2            ; 
         cmprv r2,'h327         ; 
         bra   ne,f_mvpp        ;
         bra   chk_swap         ; 
f_mvpp:  jsr   err_cnt          ; // 04
         // Check SWAP 
chk_swap:ldrv  r1,'h777         ;
         ldrv  r3,'h555         ;
         swap  r1,r3            ;
         cmprv r1,'h555         ; 
         bra   ne,f_swap        ;
         cmprv r3,'h777         ; 
         bra   ne,f_swap        ;
         bra   chk_swpp         ; 
f_swap:  jsr   err_cnt          ; // 05
         // Check SWAPP
chk_swpp:ldrv  r3,'h168         ;
         ldpv  p1,'h834         ;
         swapp r3,p1            ;
         ldrv  r1,'h794         ;
         ldpv  p2,'hdee         ;
         swapp r1,p2            ;
         cmprv r3,'h834         ; 
         bra   ne,f_swapp       ;
         cmprv r1,'hdee         ; 
         bra   ne,f_swapp       ;
         mvpr  p1,r1            ;
         cmprv r1,'h168         ;
         bra   ne,f_swapp       ; 
         mvpr  p2,r3            ;
         cmprv r3,'h794         ;
         bra   ne,f_swapp       ; 
         ldpv  p1,p_msg         ;
         bra   p_swapp          ; 
f_swapp: jsr   err_cnt          ; // 06
p_swapp: jsr   pass_fail        ;

         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 

   
         // Test test_shifts.asm
         //=====================
         // Check SHL
chk_shl: ldpv  p1,m_shift       ; 
         jsr   tx_line          ;
         ldpv  p1,mem1;
         ldpv  p2,temp;
         ldrv  r0,count         ;
shiftl:  ldrv  r1,shifts        ;
         ldrpi r2,p1            ; 
loopl:   shl   l,r2             ;
         dec   r1               ;
         bra   nz,loopl         ;
         strpi r2,p2            ;//010-800
         dec   r0               ;
         bra   nz,shiftl        ; 
         ldpv  p1,mem2;
         ldpv  p2,temp;
         xor   r3,r3            ; 
         ldrv  r0,count         ;
loopl2:  ldrpi r1,p1            ; 
         ldrpi r2,p2            ;
         cmpr  r1,r2    ;
         bra   z,goodl          ;
         jsr   err_cnt          ; 
         inc   r3               ;
goodl:   dec   r0               ;
         bra   nz,loopl2        ; 
         str   r3,error_left    ;//000
   
         // shift right and compare. -->
test2:   
         ldpv  p1,mem2;
         ldpv  p2,temp;
         ldrv  r0,count         ;
shiftr:  ldrv  r1,shifts        ;
         ldrpi r2,p1            ; 
loopr:   shr   l,r2             ;
         dec   r1               ;
         bra   nz,loopr         ;
         strpi r2,p2            ;//001-0080
         dec   r0               ;
         bra   nz,shiftr        ; 
         ldpv  p1,mem1;
         ldpv  p2,temp;
         xor   r3,r3            ; 
         ldrv  r0,count         ;
loopr2:  ldrpi r1,p1            ; 
         ldrpi r2,p2            ;
         cmpr  r1,r2            ;
         bra   z,goodr          ;
         jsr   err_cnt          ; 
         inc   r3               ;
goodr:   dec   r0               ;
         bra   nz,loopr2        ; 
         str   r3,error_right   ;//000
   
         // shift right arithmetic and compare. -->
test3:   
         ldpv  p1,mem3;
         ldpv  p2,temp;
         ldrv  r0,count         ;
shifta:  ldrv  r1,shifts        ;
         ldrpi r2,p1            ; 
loopa:   shr   a,r2             ;
         dec   r1               ;
         bra   nz,loopa         ;
         strpi r2,p2            ;//f80-ff0
         dec   r0               ;
         bra   nz,shifta        ;
         ldpv  p1,mem4;
         ldpv  p2,temp;
         xor   r3,r3            ; 
         ldrv  r0,count         ;
loopa2:  ldrpi r1,p1            ; 
         ldrpi r2,p2            ;
         cmpr  r1,r2    ;
         bra   z,gooda          ;
         jsr   err_cnt          ; 
         inc   r3               ;
gooda:   dec   r0               ;
         bra   nz,loopa2        ; 
         str   r3,error_arith   ;//000
   
         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 

         // rotate left and compare. <--
test4:   
         ldpv  p1,mem3;
         ldpv  p2,temp;
         ldrv  r0,count         ;
rotl:    ldrv  r1,shifts        ;
         ldrpi r2,p1            ; 
rloopl:  shl   r,r2             ;
         dec   r1               ;
         bra   nz,rloopl        ;
         strpi r2,p2            ;//008-00f 
         dec   r0               ;
         bra   nz,rotl  ; 
         ldpv  p1,mem5;
         ldpv  p2,temp;
         xor   r3,r3            ; 
         ldrv  r0,count         ;
rloopl2: ldrpi r1,p1            ; 
         ldrpi r2,p2            ;
         cmpr  r1,r2    ;
         bra   z,rgoodl         ;
         jsr   err_cnt          ; 
         inc   r3               ;
rgoodl:  dec   r0               ;
         bra   nz,rloopl2       ; 
         str   r3,error_rleft   ;//000
   
         // rotate right and compare. -->
test5:   
         ldpv  p1,mem5          ; 
         ldpv  p2,temp          ; 
         ldrv  r3,count         ;
rotr:    ldrv  r1,4             ;
         ldrpi r2,p1            ; 
rloopr:  shr   r,r2             ;
         dec   r1               ;
         bra   nz,rloopr        ;
         strpi r2,p2            ;//800-f00 
         dec   r3               ;
         bra   nz,rotr          ; 
         ldpv  p1,mem3          ; 
         ldpv  p2,temp          ; 
         xor   r0,r0            ; 
         ldrv  r3,count         ;
rloopr2: ldrpi r1,p1            ; 
         ldrpi r2,p2            ;
         cmpr  r1,r2            ; 
         bra   z,rgoodr         ;
         jsr   err_cnt          ; 
         inc   r0               ;
rgoodr:  dec   r3               ;
         bra   nz,rloopr2       ;
         str   r0,error_rright  ;//000

         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 

   
         // shift right and left regs thru link bit
test6:   ldpv  p1,temp;
         ldrv  r3,'habc0        ;
         xor   r1,r1            ; 
         strpi r3,p1            ;//abc
         ldrv  r2,16            ; 
loopm:   shl   r,r3             ; // rotate left
         shr   k,r1             ; // shift left link bit.
         dec   r2               ;
         bra   nz,loopm         ;
         strpi r3,p1            ;//abc
         strpi r1,p1            ;//3d5
         ldrv  ra,1             ; 
         cmprv r1,'h3d5         ;
         bra   nz,bad1          ;
         bra   z,yeaa           ;
bad1:    jsr   err_cnt          ; 
         jmp   test7            ;
         str   ra,error_mixed   ;//000
         jmp   test7            ; 
yeaa:    xor   r0,r0            ; 
         str   r0,error_mixed   ;//000
   
         // shift right and left regs 8 bits.
test7:   ldrv  r3,'h005         ;
         shl4  r3               ; 
         str   r3,temp1         ;//050
         cmprv r3,'h050         ;
         bra   ne,f_shl4        ; 
         ldrv  r2,'h700         ;
         shr4  r2               ; 
         str   r2,temp2         ;//070
         cmprv r2,'h070         ;
         bra   ne,f_shr4        ; 
         bra   p_shr4           ;
f_shl4:  jsr   err_cnt          ; 
         bra   p_shr4            ; 
f_shr4:  jsr   err_cnt          ; 
p_shr4:  jsr   pass_fail        ;

         
         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 

         // Test test_jumps.asm
         //====================
         // Check JMP
chk_jmp: ldpv  p1,m_jump        ; 
         jsr   tx_line          ;
         jmp   save_5           ;
check_5: ldr   r1,temp0         ;
         cmprv r1,'h1234        ;
         bra   e,chk_jpp        ;
         jsr   err_cnt          ; // 01
chk_jpp: ldpv  p1,save_6        ; 
         jmpp  p1               ;
         jsr   err_cnt          ; // 02
         bra   c_next           ; 
check_6: jsr   c_345            ;
c_next:  jmp   chk_jsr          ; 
c_345:   ldr   r1,temp0         ;
         cmprv r1,'h5678        ;
         bra   e,good_jp        ;
         jsr   err_cnt          ; // 03
good_jp: rts                    ; 
         // Check JSR and RTS
chk_jsr: jsr   tx_dt1           ; // message out
chk_111: ldr   r1,temp1         ;
         cmprv r1,'h1111        ;
         bra   e,chk_222        ;
         jsr   err_cnt          ; // 04
chk_222: ldr   r1,temp2         ;
         cmprv r1,'h2222        ;
         bra   e,chk_333        ;
         jsr   err_cnt          ; // 05
chk_333: ldr   r1,temp3         ;
         cmprv r1,'h3333        ;
         bra   e,chk_444        ;
         jsr   err_cnt          ; // 06
chk_444: ldr   r1,temp4         ;
         cmprv r1,'h4444        ;
         bra   e,end_jsr        ;
         jsr   err_cnt          ; // 07
end_jsr: jsr   pass_fail        ; // pass_fail

   
         uport t0               ; 
         jsr   waitk            ; // stop @ 
         uport f0               ; 
   
   
         // Test test_branchs.asm
         //=====================
         // Check Zero flag
chk_z:   ldpv  p1,m_branch      ; 
         jsr   tx_line          ;
         ldrv  r1,'h000         ;
         or    r1,r1            ;
         bra   nz,fail_z        ;
         dec   r1               ;
         bra   z,fail_z         ;
         addv  r1,'h005         ;
         bra   e,fail_z         ; 
         subv  r1,4             ;
         bra   ne,fail_z        ;
         inc   r1               ;
         cmprv r1,1             ;
         bra   ne,fail_z        ;
         bra   chk_s            ; 
fail_z:  jsr   err_cnt          ; // 01
         // Check Sign bit
chk_s:   orv   r1,'hffff        ;
         bra   ns,fail_s        ;
         inc   r1               ;
         bra   s,fail_s         ;
         ldrv  r1,'hfff0         ;
         ldrv  r2,'h000f         ;
         add   r1,r2            ;
         bra   ns,fail_s        ;
         sub   r2,r1            ;
         bra   s,fail_s         ; 
         bra   chk_c            ; 
fail_s:  jsr   err_cnt          ; // 02
         // Check Carry bit
chk_c:   ldrv  r1,'h1000         ;
         addv  r1,'hf000         ;
         bra   nc,fail_c        ;
         ldrv  r2,'h0003         ;
         addv  r2,'hfffc         ;
         bra   c,fail_c         ;
         ldrv  r1,'hffff         ;
         addv  r1,1             ;//'h000
         bra   nc,fail_c        ;
         addv  r1,1             ;//'h001
         bra   c,fail_c         ;
         addv  r1,1             ;//'h002
         bra   c,fail_c         ;
         subv  r1,1             ;//'h001
         bra   c,fail_c         ; 
         subv  r1,1             ;//'h000
         bra   c,fail_c         ; 
         subv  r1,1             ;//'hfff
         bra   nc,fail_c        ; 
         bra   chk_o            ; 
fail_c:  jsr   err_cnt          ; // 03
         // Check Overflow
chk_o:   ldrv  r1,'h7777         ;
         addv  r1,'h7777         ;
         bra   no,fail_o        ;
         ldrv  r2,'h7777         ;
         addv  r2,'h9999         ;
         bra   o,fail_o         ;
         bra   chk_ge           ; 
fail_o:  jsr   err_cnt          ; // 04
         // Check Greater Than or Equal
chk_ge:  ldrv  r1,'h077         ;
         subv  r1,'h099         ;
         bra   ge,fail_ge       ;
         ldrv  r1,'h065         ;
         cmprv r1,'h156         ;
         bra   ge,fail_ge       ;
         ldrv  r1,'h037         ;
         ldrv  r2,'h045         ;
         sub   r1,r2            ; 
         bra   ge,fail_ge       ;
         ldrv  r1,'h054         ;
         ldrv  r2,'h055         ;
         cmpr  r1,r2            ; 
         bra   ge,fail_ge       ;
chk_ge0: ldrv  r1,'h057         ;
         subv  r1,'h056         ;
         bra   ge,chk_ge1       ;
         jmp   fail_ge          ; 
chk_ge1: ldrv  r1,'h045         ;
         subv  r1,'h045         ;
         bra   ge,chk_ge2       ;
         jmp   fail_ge          ; 
chk_ge2: ldrv  r1,'h057         ;
         ldrv  r2,'h056         ;
         cmpr  r1,r2            ;
         bra   ge,chk_ge3       ;
         jmp   fail_ge          ; 
chk_ge3: ldrv  r1,'h045         ;
         ldrv  r2,'h045         ;
         cmpr  r1,r2            ;
         bra   ge,chk_ge4       ;
         jmp   fail_ge          ; 
chk_ge4: ldrv  r1,'hee45         ;
         ldrv  r2,'hee46         ;
         cmpr  r1,r2            ;
         bra   ge,fail_ge       ;
chk_ge5: ldrv  r1,'h0001         ;
         ldrv  r2,'hffff         ;
         cmpr  r1,r2            ;
         bra   ge,chk_ge6       ;
         jmp   fail_ge          ; 
chk_ge6: ldrv  r1,'hf001         ;
         ldrv  r2,'hf000         ;
         cmpr  r1,r2            ;
         bra   ge,chk_ge7       ;
         bra   fail_ge          ; 
chk_ge7: ldrv  r1,'hee45         ;
         ldrv  r2,'hee45         ;
         cmpr  r1,r2            ;
         bra   ge,chk_ge8       ;
         jmp   fail_ge          ; 
chk_ge8: bra   chk_lt           ; 
fail_ge: jsr   err_cnt          ; // 05
         // Check Less Than
chk_lt:  ldrv  r1,'h00a         ;
         cmprv r1,'h009         ;
         bra   lt,fail_lt       ;
         ldrv  r2,'h009         ;
         cmprv r2,'h00a         ;
         bra   lt,end_lt        ;
fail_lt: jsr   err_cnt          ; // 06
end_lt:  jsr   pass_fail        ;
    
         uport t0               ; 
         jsr   waitk            ; // stop @ 
         uport f0               ; 

         // Test test_loads.asm
         //====================
         // Check LDPV 
chk_ldpv:ldpv  p1,m_load        ; 
         jsr   tx_line          ;
         ldpv  p1,tcte0         ;
         ldrp  r1,p1            ;
         cmprv r1,'h0000        ;
         bra   ne,f_ldpv        ;
         ldpv  p2,tcte1         ;
         ldrp  r1,p2            ;
         cmprv r1,'h1111        ;
         bra   ne,f_ldpv        ;
         ldpv  p1,tcte4         ;
         ldrp  r1,p1            ;
         cmprv r1,'h4444        ;
         bra   ne,f_ldpv        ;
         bra   chk_ldp          ; 
f_ldpv:  jsr   err_cnt          ; // 01
         // Check LDP  
chk_ldp: ldrv  r1,tcte0         ;
         str   r1,tempa         ; 
         ldp   p1,tempa         ;
         ldrp  r1,p1            ;
         cmprv r1,'h0000        ;
         bra   ne,f_ldp         ;
         ldp   p2,tempa         ;
         ldrp  r3,p2            ;
         cmprv r3,'h0000        ;
         bra   ne,f_ldp         ;
         bra   chk_ldr          ; 
f_ldp:   jsr   err_cnt          ; // 02
         // Check LDR
chk_ldr: ldr   r1,tcte1         ;
         cmprv r1,'h1111        ;
         bra   ne,f_ldr         ;
         ldr   r2,tcte2         ;
         cmprv r2,'h2222        ;
         bra   ne,f_ldr         ;
         ldr   r3,tcte3         ;
         cmprv r3,'h3333        ;
         bra   ne,f_ldr         ;
         bra   chk_ldrv         ; 
f_ldr:   jsr   err_cnt          ; // 03
         // Check LDRV
chk_ldrv:ldrv  r1,'h101         ;
         cmprv r1,'h101         ;
         bra   ne,f_ldrv        ;
         ldrv  r2,'h202         ;
         cmprv r2,'h202         ;
         bra   ne,f_ldrv        ;
         ldrv  r3,'h303         ;
         cmprv r3,'h303         ;
         bra   ne,f_ldrv        ;
         bra   chk_ldrx         ; 
f_ldrv:  jsr   err_cnt          ; // 04
         // Check LDRX
chk_ldrx:ldpv  p1,tcte0         ;
         ldrx  r1,p1,1          ;
         cmprv r1,'h1111        ;
         bra   ne,f_ldrx        ;
         ldrx  r2,p1,2          ;
         cmprv r2,'h2222        ;
         bra   ne,f_ldrx        ;
         ldrx  r3,p1,3          ;
         cmprv r3,'h3333        ;
         bra   ne,f_ldrx        ;
         bra   chk_ldrp         ; 
f_ldrx:  jsr   err_cnt          ; // 05
         // Check LDRP
chk_ldrp:ldpv  p1,tcte4         ;
         ldrp  r1,p1            ;
         cmprv r1,'h4444        ;
         bra   ne,f_ldrp        ;
         ldpv  p2,tcte3         ;
         ldrp  r3,p2            ;
         cmprv r3,'h3333        ;
         bra   ne,f_ldrp        ;
         ldpv  p1,tcte1         ;
         ldrp  r2,p1            ;
         cmprv r2,'h1111        ;
         bra   ne,f_ldrp        ;
         bra   chk_ldrpi        ; 
f_ldrp:  jsr   err_cnt          ; // 06
         // Check LDRPI
chk_ldrpi:
         ldpv  p1,tcte0         ;
         ldrpi r1,p1            ; // r1 = *(p1++)
         cmprv r1,'h0000        ;
         bra   ne,f_ldrpi       ;
         ldrpi r3,p1            ;
         cmprv r3,'h1111        ;
         bra   ne,f_ldrpi       ;
         ldrpi r2,p1            ;
         cmprv r2,'h2222        ;
         bra   ne,f_ldrpi       ;
         ldrpi r2,p1            ;
         cmprv r2,'h3333        ;
         bra   ne,f_ldrpi       ;
         ldrpi r2,p1            ;
         cmprv r2,'h4444        ;
         bra   ne,f_ldrpi       ;
         bra   chk_ldrpd        ; 
f_ldrpi: jsr   err_cnt          ; // 07
         // Check LDRPD
chk_ldrpd:
         ldpv  p1,tcte4         ;
         ldrpd r1,p1            ; // r1 = *(--p1)
         cmprv r1,'h3333        ;
         bra   ne,f_ldrpd       ;
         ldrpd r3,p1            ;
         cmprv r3,'h2222        ;
         bra   ne,f_ldrpd       ;
         ldrpd r2,p1            ;
         cmprv r2,'h1111        ;
         bra   ne,f_ldrpd       ;
         ldrpd r2,p1            ;
         cmprv r2,'h0000        ;
         bra   ne,f_ldrpd       ;
         ldpv  p1,p_msg         ;
         bra   p_ldrpd          ;
f_ldrpd: jsr   err_cnt          ;
p_ldrpd: jsr   pass_fail        ;

         uport t0               ; 
         jsr   waitk            ; // stop @ 
         uport f0               ; 
   
         // Test test_stores.asm
         //=====================
         // Check STP  
chk_stp: ldpv  p1,m_store       ; 
         jsr   tx_line          ;
         ldpv  p1,'h123         ;
         stp   p1,tempa         ; 
         ldr   r1,tempa         ;
         cmprv r1,'h123         ; //101
         bra   ne,f_stp         ;
         ldpv  p2,'h567         ;
         stp   p2,tempb         ; 
         ldr   r3,tempb         ;
         cmprv r3,'h567         ; //101
         bra   ne,f_stp         ;
         bra   chk_str          ; 
f_stp:   jsr   err_cnt          ; 
         // Check STR  
chk_str: ldrv  r1,'h123         ;
         str   r1,tempa         ; 
         ldr   r1,tempa         ;
         cmprv r1,'h123         ; //101
         bra   ne,f_str         ;
         ldrv  r2,'h567         ;
         str   p2,tempb         ; 
         ldr   r3,tempb         ;
         cmprv r3,'h567         ; //101
         bra   ne,f_str         ;
         bra   chk_strp         ; 
f_str:   jsr   err_cnt          ; 
         // Check STRP 
chk_strp:ldrv  r1,'h123         ;
         ldpv  p1,tcte0         ;
         strp  r1,p1            ; 
         ldrv  r3,'h456         ;
         ldpv  p2,tcte4         ;
         strp  r3,p2            ; 
         ldr   r1,tcte0         ;
         cmprv r1,'h123         ; //101
         bra   ne,f_strp        ;
         ldr   r3,tcte4         ;
         cmprv r3,'h456         ; //101
         bra   ne,f_strp        ;
         bra   chk_strpi        ; 
f_strp:  jsr   err_cnt          ; 
         // Check STRPI
chk_strpi:  
         ldrv  r1,'h123         ;
         ldpv  p1,tcte0         ;
         strpi r1,p1            ; 
         ldrv  r2,'h456         ;
         strpi r2,p1            ; 
         ldrv  r3,'h789         ;
         strpi r3,p1            ; 
         ldr   r1,tcte0         ;
         cmprv r1,'h123         ; //101
         bra   ne,f_strpi       ;
         ldr   r3,tcte1         ;
         cmprv r3,'h456         ; //101
         bra   ne,f_strpi       ;
         ldr   r2,tcte2         ;
         cmprv r2,'h789         ; //101
         bra   ne,f_strpi       ;
         bra   chk_strpd        ; 
f_strpi: jsr   err_cnt          ; 
         // Check STRPD
chk_strpd:
         ldpv  p2,tcte4         ;
         ldrv  r1,'heef         ;
         strpd r1,p2            ; 
         ldrv  r2,'h48c         ;
         strpd r2,p2            ; 
         ldrv  r3,'h444         ;
         strpd r3,p2            ; 
         ldr   r1,tcte3         ;
         cmprv r1,'heef         ; //101
         bra   ne,f_strpd       ;
         ldr   r3,tcte2         ;
         cmprv r3,'h48c         ; //101
         bra   ne,f_strpd       ;
         ldr   r2,tcte1         ;
         cmprv r2,'h444         ; //101
         bra   ne,f_strpd       ;
         bra   chk_strx         ; 
f_strpd: jsr   err_cnt          ; 
         // Check STRX
chk_strx:ldrv  r1,'h222         ;
         ldpv  p1,tcte0         ;
         strx  r1,p1,1          ; 
         ldrv  r2,'h333         ;
         strx  r2,p1,2          ; 
         ldrv  r3,'h555         ;
         strx  r3,p1,3          ; 
         ldr   r1,tcte1         ;
         cmprv r1,'h222         ; //101
         bra   ne,f_strx        ;
         ldr   r3,tcte2         ;
         cmprv r3,'h333         ; //101
         bra   ne,f_strx        ;
         ldr   r2,tcte3         ;
         cmprv r2,'h555         ; //101
         bra   ne,f_strx        ;
         ldpv  p1,p_msg         ;
         bra   p_strx           ; 
f_strx:  jsr   err_cnt          ; 
p_strx:  jsr   pass_fail        ;

         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 
   
         // Test test_incdec.asm
         //=====================
         // Check INC
chk_inc: ldpv  p1,m_incdec      ; 
         jsr   tx_line          ;
         ldrv  r1,1             ;
         inc   r1               ;
         inc   r1               ; 
         inc   r1               ; 
         inc   r1               ; 
         inc   r1               ; 
         inc   r1               ; 
         inc   r1               ; 
         cmprv r1,8             ; 
         bra   ne,f_inc         ;
         ldrv  r3,'hfffa        ;
         inc   r3               ;
         inc   r3               ; 
         inc   r3               ; 
         inc   r3               ; 
         inc   r3               ; 
         inc   r3               ; 
         inc   r3               ; 
         cmprv r3,1             ; 
         bra   ne,f_inc         ;
         bra   chk_dec          ; 
f_inc:   jsr   err_cnt          ; 
         // Check DEC
chk_dec: ldrv  r2,1             ;
         dec   r2               ;
         dec   r2               ; 
         dec   r2               ; 
         dec   r2               ; 
         dec   r2               ; 
         dec   r2               ; 
         dec   r2               ; 
         cmprv r2,'hfffa        ; 
         bra   ne,f_dec         ;
         ldrv  r1,'hfff8        ;
         dec   r1               ;
         dec   r1               ; 
         dec   r1               ; 
         dec   r1               ; 
         dec   r1               ; 
         dec   r1               ; 
         dec   r1               ; 
         cmprv r1,'hfff1        ; 
         bra   ne,f_dec         ;
         bra   chk_incp         ; 
f_dec:   jsr   err_cnt          ; 
         // Check INCP
chk_incp:ldpv  p1,1             ;
         incp  p1               ;
         incp  p1               ; 
         incp  p1               ; 
         incp  p1               ; 
         incp  p1               ; 
         incp  p1               ; 
         incp  p1               ;
         mvpr  p1,r1            ; 
         cmprv r1,8             ; 
         bra   ne,f_incp        ;
         ldpv  p2,'hfffa        ;
         incp  p2               ;
         incp  p2               ; 
         incp  p2               ; 
         incp  p2               ; 
         incp  p2               ; 
         incp  p2               ; 
         incp  p2               ;
         mvpr  p2,r3            ; 
         cmprv r3,1             ; 
         bra   ne,f_incp        ;
         bra   chk_decp         ; 
f_incp:  jsr   err_cnt          ; 
         // Check DECP
chk_decp:ldpv  p2,1             ;
         decp  p2               ;
         decp  p2               ; 
         decp  p2               ; 
         decp  p2               ; 
         decp  p2               ; 
         decp  p2               ; 
         decp  p2               ;
         mvpr  p2,r2            ; 
         cmprv r2,'hfffa        ; 
         bra   ne,f_decp         ;
         ldpv  p1,'hfff8        ;
         decp  p1               ;
         decp  p1               ; 
         decp  p1               ; 
         decp  p1               ; 
         decp  p1               ; 
         decp  p1               ; 
         decp  p1               ;
         mvpr  p1,r1            ; 
         cmprv r1,'hfff1        ; 
         bra   ne,f_decp         ;
         ldpv  p1,p_msg         ;
         bra   p_decp            ; 
f_decp:  jsr   err_cnt          ; 
p_decp:  jsr   pass_fail        ;


         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 
   
         // Test test_arith.asm
         //=====================
         // Check ADD,ADC,ADDV
chk_add: ldpv  p1,m_arith       ; 
         jsr   tx_line          ;
         ldrv  r1,'h4190        ;
         ldrv  r2,'hff00        ;
         add   r1,r2            ;
         addv  r1,'h5680        ;
         ldrv  r3,'he770        ;
         add   r1,r3            ;
         addv  r1,'hb0a0        ;
         ldrv  r3,'h0000        ; 
         adc   r1,r3            ; 
         cmprv r1,'h2f21        ;
         bra   e,chk_sub        ;
         jsr   err_cnt          ; 
         // Check SUB,SBB,SUBV
chk_sub: ldrv  r1,'h5780        ;
         ldrv  r2,'h3250        ;
         sub   r1,r2            ;
         subv  r1,'hd5a0        ;
         ldrv  r3,'hc440        ;
         sub   r1,r3            ;
         subv  r1,'h7480        ;
         ldrv  r3,'h3000        ; 
         sub   r1,r3            ; 
         ldrv  r3,'h0000        ; 
         sbb   r1,r3            ; 
         cmprv r1,'he6d0        ;
         bra   e,chk_addrp      ; 
         jsr   err_cnt          ; 
chk_addrp:
         ldrv  r2,3             ;
         ldpv  p1,mem3          ;
         addrp r2,p1            ;
         mvrp  r2,p1            ; 
         ldrp  r3,p1            ;
         cmprv r3,'hb000        ;
         bra   e,chk_addrp2     ;
         jsr   err_cnt          ; 
chk_addrp2:
         ldrv  r1,6             ;
         ldpv  p2,mem4          ;
         addrp r1,p2            ;
         mvrp  r1,p2            ; 
         ldrp  r3,p2            ;
         cmprv r3,'hfe00        ;
         bra   e,chk_cmprp      ;
         jsr   err_cnt          ; 
chk_cmprp:
         ldrv  r1,'h123         ;
         ldpv  p2,'h123         ;
         cmprp r1,p2            ;
         bra   e,chk_cmprp2     ;
         jsr   err_cnt          ; 
chk_cmprp2: 
         ldrv  r1,'h123         ;
         ldpv  p2,'h120         ;
         cmprp r1,p2            ;
         bra   ge,chk_cmprp3    ;
         jsr   err_cnt          ; 
chk_cmprp3:
         ldrv  r1,'h100         ;
         ldpv  p2,'h120         ;
         cmprp r1,p2            ;
         bra   lt,chk_subrp     ;
         jsr   err_cnt          ; 
chk_subrp:
         ldrv  r1,3             ;
         ldpv  p2,mem3          ;
         swapp r1,p2            ; 
         subrp r1,p2            ;
         mvrp  r1,p1            ;
         ldrp  r3,p1            ;
         cmprv r3,'h200         ;
         bra   e,p_subrp        ;
         jsr   err_cnt          ; 
         bra   p_subrp           ; 
f_subrp: jsr   err_cnt          ; 
p_subrp: jsr   pass_fail        ;

         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 
   
         // Test test_logic.asm
         //=====================
         // Check AND, ANDV, NOT
chk_and: ldpv  p1,m_logic       ; 
         jsr   tx_line          ;
         ldrv  r1,'h123         ;
         ldrv  r2,'h0f0         ;
         not   r2,r3            ; 
         and   r3,r1            ;
         andv  r3,'h1f2         ; 
         cmprv r3,'h102         ;
         bra   e,chk_or         ;
         jsr   err_cnt          ;
         // OR,ORV
chk_or:  ldrv  r1,'h033         ;
         ldrv  r2,'hcc0         ;
         or    r1,r2            ;
         orv   r1,'h108         ;
         cmprv r1,'hdfb         ;
         bra   e,chk_xor        ;
         jsr   err_cnt          ; 
         // XOR,XORV
chk_xor: ldrv  r1,'h123         ;
         ldrv  r2,'h456         ;
         xor   r2,r1            ;
         xorv  r2,'hfff         ;
         cmprv r2,'ha8a         ;
         bra   ne,f_not         ; 
         ldpv  p1,p_msg         ;
         bra   p_not             ; 
f_not:   jsr   err_cnt          ; 
p_not:   jsr   pass_fail        ;


         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 

         // Test loop instructions
         //=====================
         // Check LDCNT, DCJNZ
chk_cnt: ldpv  p1,m_loopc       ; 
         jsr   tx_line          ;
         ldrv  r1,123           ;
         ldc   r1,40            ;
chk_cnt2:dec   r1               ; 
         dcjnz r1,chk_cnt2      ;
         cmprv r1,82            ; 
         bra   e,p_cnt          ; 
f_cnt:   jsr   err_cnt          ; 
p_cnt:   jsr   pass_fail        ;

   
         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 
   
         // Test user flags instructions
         //=====================
         // Check UFLAG, UPORT, JMPF
chk_usr: ldpv  p1,m_user        ; 
         jsr   tx_line          ;
         ldrv  r2,0             ; 
         uflag t1               ;
         uflag f2               ;
         uflag t3               ;
         uflag f1               ;
         uflag t2               ;
         jmp   f1,chk_uf3       ;
         ldrv  r2,'hbad         ;
chk_uf3: cmprv r2,0             ;
         bra   e,p_usr          ; 
f_usr:   jsr   err_cnt          ; 
p_usr:   jsr   pass_fail        ;

   
         uport t0               ; 
         jsr   waitk            ; // stop @
         uport f0               ; 

         // End Of Tests
         //=====================
end_test:ldpv  p1,end_msg       ; 
         jsr   tx_page          ; 
         jsr   tx_prmt          ;
         ldr   r0,e_code        ;
         str   r0,sys_val       ; 
         ldr   r1,tst_cnt       ; // increment test counter
         inc   r1               ;
         cmprv r1,'h03A         ;
         bra   ne,save          ;
         ldrv  r1,'h030         ;
save:    str   r1,tst_cnt       ;
         uport t0               ; 
         ldr   r1,e_code        ;
         or    r1,r1            ;
         bra   ne,f_test        ; 
         uport f0               ;
         bra   e,p_test         ; 
f_test:  uport t7               ;
p_test:  nop                    ;
         stop                   ;
         bra   p_test           ; // end of test


   ////////////////////////////////////////////////////////////
   // Vector routines    
hw_irq:  jmp hw_irq             ; 

sw_irq:  jmp sw_irq             ; 



   ////////////////////////////////////////////////////////////
   // System definitions
   // Stack area   
stack:   ds    STACK_SIZE       ; // Stack
last_stk:ds    1                ; // last stack
         
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   // BOOT LOADER
   //////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
@BOOT_LOADER  // Write program memory.
boot:    nop                    ; 
         jmp   reset_v          ;

@'h3fff  
sys_val: dw    'h1234           ; // used for debugging.


/////////////////// End of File //////////////////////////
