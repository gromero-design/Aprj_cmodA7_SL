-------------------------------------------------------------------------------
--                    Top Module
-------------------------------------------------------------------------------
-- Board: CmodA7 Artix 7 xcA35T-1CPG236G
-- Flash: Micron n25q32-3.3v-spi-x1_x2_x4  Density(Mb) 32
------------------------------------------------------------------------
-- RGB Configuration
-- reg100[7:0]   RED
-- reg100[15:8]  BLU
-- reg101[7:0]   GRN
-- reg101[15:8]  ---
--
-- Serial shift bit 23 first ws2811/12 format 
-- GRN->RED->BLU-> brg sequence
--                                                                         
------------------------------------------------------------------------
--    fpgahelp.com
--    DIGGIN: DIGital Gill INnovation
--    Copyright 1994-2020 GHR
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  fpga1_top.vhd
--         Date:  Jan, 2001
--       Author:  Gill Romero
--      Company:  fpgahelp
--        Email:  fpgahelp@gmail.com
--        Phone:  617-905-0508
------------------------------------------------------------------------   
--                   Model : Module RTL
--    Development Platform : Windows 10
--   VHDL Software Version : Altera Model Sim / Vivado sim
--          Synthesis Tool : Vivado 18.2, Xilinx Synthesis Tool version 18.x
--                           Quartus Prime 17.1, Altera Synthesis Tool version 17.1
-----------------------------------------------------------------------   
--
--  Description :
--  ***********
--  This is the Entity and architecture of the Artix7 CMOD7 development board.
--
--  -- I/O ports
-- LED0/1 positive logic
-- LED2/3/4 negative logic, R/G/B
-- 
--   References :
--   **********
--       work.fpga1_pkg.all; application specific package.
--
--   Nomenclature:
--   ************
--     suffixes:
--             _o => output
--             _n => output inverted (negated)
--             _b => input  inverted (negated)
--             _r => registered signal
--
--     alternates: (not used in modules / submodules)
--             _l => active low (low)
--
--   Dependencies :
--   ************
--
--   entity_name(arch_name1, arch_name2,..)
--
-- fpga1_top(struct)
--        |__ clk
--        |__ reset 
--        |__ uC16(rtl)
--        |      |___ Opus16_xil
--        |      |___ uart
--        |__ fpga1_regs(rtl)
--        |__ fpga1_regs(rtl)
--
------------------------------------------------------------------------
-- USB-FTD232 , CPU-UART , BT-HC04 connections
-- 1. FTD232 to BT-HC04 for programming baud rate, device name etc.
--    press BTN0 and BTN1 same time, release BTN0
--    USB_FTD232 is connected directly to BT-HC04
--    Program BT-HC04
--    press BTN0 to normal operation
--
-- 2. CPU-UART to BT-HC04 for normal operation
--    pio_usb_sel is level high (1=Vcc)
--    also it powers the BT device
--
-- 3. CPU-UART to FTD232 for debugging with a terminal emulator
--    pio_usb_sel is level low (0=gnd)
--    removes power to BT device
--
------------------------------------------------------------------------   
-- Modification History : (Date, Initials, Comments)
-- 01-01-06 gill creation
-- 04-01-19 Cmod7 setup:
-- 01-03-22 added code protection with new opus1 core
-- 01-12-22 compute boot address with PBUS_WIDTH
-- 01-20-22 added 1 Sec pulse
-- 01-21-22 added pio_usb_ovr signal to qualify pio_usb_sel

------------------------------------------------------------------------   
--
--  Revision Control:
--
--/*
-- * $Header:$
-- * $Log:$
-- */
-- Base Address Register defined at the top
-- BASE_ADDR_REG = x"1000"
-- register address = BASE_ADDR_REG(15:4) & s_io_addr(3 downto 0)

------------------------------------------------------------------------
-- LIBRARY 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_STD.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.fpga1_pkg.all;

------------------------------------------------------------------------
-- ENTITY   PROTO2

entity fpga1_top is
    generic(BASE_ADDR_REG1	: std_logic_vector := x"0000";-- local space x0000-x00FF
            BASE_ADDR_REG2	: std_logic_vector := x"0100";-- user space x0100-xFFFF
            PBUS_WIDTH      : integer          := 14;     -- 16K or x"4000" program RAM
            ABUS_WIDTH      : integer          := 16;
            DBUS_WIDTH      : integer          := 16;
            OBUS_WIDTH      : integer          := 16;
            UART_CLOCK		: integer          := 100000000; --100 000 000 MHz
            UART_BRATE		: integer          :=    115200;
       		UART_ADDR    	: std_logic_vector := x"0010";-- uC16 space x0000-x00FF
    		TEST_UART		: std_logic        :='0';
            TEST_CFG        : std_logic_vector := x"0021";-- CCIP : 00/IRQ=2/Proto=1
            TEST_DATE       : std_logic_vector := x"0329";-- MMDD : fpga1_top date
            TEST_VERSION    : std_logic_vector := x"0113";-- MMDD : Opus16_ip_core date
            DEBUG_ENABLED	: integer          := 0);

    port (
        -- system interface
        sysrst    : in std_logic;  -- system reset, active HIGH
        sysclk    : in std_logic;  -- main clock
        
        -- UART interface
        uart_txd_in : in  std_logic; -- TxD FT232, RxD FPGA
        uart_rxd_out: out std_logic; -- RxD FT232, TxD FPGA

        -- Peripherals
        btn1        : in  std_logic;
        led         : out std_logic_vector(1 downto 0);
        led0_r      : out std_logic;
        led0_g      : out std_logic;
        led0_b      : out std_logic;
        
        -- SRAM
        MemDB		: inout std_logic_vector(7 downto 0);
        MemAdr		: out std_logic_vector(18 downto 0);
        RamOEn		: out std_logic;
        RamWEn		: out std_logic;
        RamCEn		: out std_logic;

        -- PMOD JA
        ja			: out std_logic_vector(7 downto 0);
                
        -- I/O ports
        -- Inputs must be 3.3V max, use a divider when power is 5V
        -- UART interface
        pio_txd_in  : in  std_logic; -- pio05 TxD BC04, RxD FPGA 
        pio_rxd_out : out std_logic; -- pio06 RxD BC04, TxD FPGA
        pio_usb_sel : in  std_logic; -- pio46 selects between BC04 (1) and USB (0) 
--      pio_usb_ovr : in  std_logic; -- pio45 usb_sel overwrite
        pio_bt_pwr  : out std_logic; -- pio07 bluetooth power
        
        -- External Interface Port
        grnled      : out std_logic; -- pio36
        redled      : out std_logic; -- pio37
        blueled     : out std_logic  -- pio48
        );
end entity fpga1_top;



-------------------------------------------------------------------------------
-- ARCHITECTURE: structural
-------------------------------------------------------------------------------

architecture struct of fpga1_top is
-------------------------------------------------------------------------------
-- Signal and Constant definitions
-------------------------------------------------------------------------------
constant BOOT_ADDRESS   : integer := 2**PBUS_WIDTH-256;
constant TRG_SRC_MSB    : integer := 15; -- trigger source bits
constant SCP_SRC_MSB    : integer := 13; -- scope source bits
constant PCODE_OVW_BIT  : integer := 1;  -- code protection bit
constant TARGET_RST_BIT : integer := 0;  -- target reset bit

-- System clock and reset.
signal s_reset		   : std_logic;
signal clk			   : std_logic;    -- base clock
signal clk2 		   : std_logic;    -- base clock
signal locked		   : std_logic;    -- base clock
signal s_40nScnt       : std_logic_vector(2 downto 0); -- 40 nano Sec sync counter
signal s_nScnt         : std_logic_vector(31 downto 0); -- nano Sec sync counter
signal s_Spulse		   : std_logic;    -- 1.0  S pulse
signal s_Spulse_ack	   : std_logic;    -- 1.0  S pulse ack
signal s_Second		   : std_logic;    -- 1.0  S square wave

-- Test signals
signal s_user_led    : std_logic_vector(LEDS_MSB downto 0);  -- user LEDS
signal s_user_pb     : std_logic_vector(PUSHB_MSB downto 0);  -- push buttons
signal s_user_sw     : std_logic_vector(DIPSW_MSB downto 0);  -- dip switch
signal s_btn1_reg    : std_logic;
signal s_usb_sel     : std_logic;
signal s_blueled     : std_logic;
signal s_hitled      : std_logic;

-- uC16 interface
signal s_uC_addr     : std_logic_vector(ABUS_WIDTH-1 downto 0);
signal s_uC_page     : std_logic_vector(ABUS_WIDTH-1 downto 0);
signal s_uC_pagewr   : std_logic;
signal s_uC_down     : std_logic;
signal s_uC_dinp     : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dinp1    : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dinp2    : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dinp3    : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dinp4    : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dvld     : std_logic;
signal s_uC_dout     : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dout_r1  : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dout_r2  : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_dout_r3  : std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_uC_wr       : std_logic;
signal s_uC_rd       : std_logic;
signal s_uC_mio      : std_logic;
signal s_uC_busen    : std_logic;
signal s_uC_oport    : std_logic_vector(OBUS_WIDTH-1 downto 0);
signal s_uC_iport    : std_logic_vector(7 downto 0);
signal s_uC_sync     : std_logic;
signal s_uC_hcode    : std_logic;
signal s_uC_pcode    : std_logic; -- 0=no protect, 1=protect
signal s_uC_ecode    : std_logic_vector(ABUS_WIDTH-1 downto 0); -- end code protection
signal s_uC_bcode    : std_logic_vector(ABUS_WIDTH-1 downto 0); -- start of boot code protection
signal s_uC_pcode_r  : std_logic; -- 0=no protect, 1=protect
signal s_uC_ecode_r  : std_logic_vector(ABUS_WIDTH-1 downto 0); -- end code protection
signal s_uC_bcode_r  : std_logic_vector(ABUS_WIDTH-1 downto 0); -- start of boot code protection
-- regs/ios
signal s_uC_wregs    : std_logic;
signal s_uC_rregs    : std_logic;
-- sram
signal s_uC_rdmem    : std_logic;
signal s_uC_wrmem    : std_logic;
signal s_uC_cemem    : std_logic;

signal s_uC_memcs1   : std_logic;
    
-- Control lines from uC16
signal s_serial_rxd : std_logic;
signal s_serial_txd : std_logic;
signal s_heartbeat  : std_logic;
signal s_timerbeat  : std_logic;
signal s_tp1		: std_logic;	-- available test point/UART
signal s_tp2		: std_logic;	-- available test point/UART
signal s_tpack		: std_logic;	-- s_tp acknowledge

-- Internal Registers
signal s_reg_cs1	: std_logic;
signal s_base_adr1	: std_logic_vector(ABUS_WIDTH-1 downto 0);
signal s_reg_00 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_01 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_02 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_03 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_04 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_05 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_06 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_07 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_08 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_09 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_0a 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_0b 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_0c 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_0d 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_0e 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_0f 	: std_logic_vector(DBUS_WIDTH-1 downto 0);

-- External Registers
signal s_reg_cs2	: std_logic;
signal s_base_adr2	: std_logic_vector(ABUS_WIDTH-1 downto 0);
signal s_reg_100 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_101 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_102 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_103 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_104 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_105 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_106 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_107 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_108 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_109 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_10a 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_10b 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_10c 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_10d 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_10e 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_10f 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_110 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_111 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_112 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_113 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_114 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_115 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_116 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_117 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_118 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_119 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_11a 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_11b 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_11c 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_11d 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_11e 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_11f 	: std_logic_vector(DBUS_WIDTH-1 downto 0);

signal s_reg_120 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_121 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_122 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_123 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_124 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_125 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_126 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_127 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_128 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_129 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_12a 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_12b 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_12c 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_12d 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_12e 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_12f 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_130 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_131 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_132 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_133 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_134 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_135 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_136 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_137 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_138 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_139 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_13a 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_13b 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_13c 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_13d 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_13e 	: std_logic_vector(DBUS_WIDTH-1 downto 0);
signal s_reg_13f 	: std_logic_vector(DBUS_WIDTH-1 downto 0);

-- Common Timing
signal s_pwmcnt     : std_logic_vector(DBUS_WIDTH-1 downto 0);  -- pwm timing counter
signal s_pwmcntflag : std_logic;  -- pwm bit flag
signal s_rgbcnt     : std_logic_vector(07 downto 0);  -- bit counter, every pwm cycle
signal s_rgbcntflag : std_logic;  -- rgb bit flag
signal s_ledcnt     : std_logic_vector(DBUS_WIDTH-1 downto 0);  -- led counter, every 24 bits
signal s_ledcntflag : std_logic;  -- led bit flag
signal s_loadcnt    : std_logic_vector(DBUS_WIDTH-1 downto 0);  -- led load signal
signal s_ledloadflg : std_logic;  -- led load flag

-- for debug
signal s_scope_src  : std_logic;
signal s_trigg_src  : std_logic;
signal s_target_rst	: std_logic;
--signal s_uart_out   : std_logic;

--debug1:
--if(DEBUG_ENABLED = 1) generate
-- On Module:
attribute keep : string;
-- attribute mark_debug : string;
-- attribute mark_debug of s_tp1     	: signal is "true";
-- attribute mark_debug of s_tp2     	: signal is "true";
-- attribute mark_debug of s_tpack      : signal is "true";
-- attribute mark_debug of s_trigg_src  : signal is "true";
-- attribute mark_debug of s_scope_src  : signal is "true";
-- 	
-- attribute dont_touch : string;
-- attribute dont_touch of s_tp1     	: signal is "true";
-- attribute dont_touch of s_tp2     	: signal is "true";
-- attribute dont_touch of s_tpack      : signal is "true";
-- attribute dont_touch of s_trigg_src  : signal is "true";
-- attribute dont_touch of s_scope_src  : signal is "true";
	
	
--end generate;

-------------------------------------------------------------------------------
-- Component Definitions
-------------------------------------------------------------------------------

component clk_wiz_12to100_50
	port(
	    clk_in1         : in std_logic;
	    clk_out1        : out std_logic;
	    locked			: out std_logic;
	    reset           : in std_logic
	);
end component;
	
	

component uC16
    generic(PBUS_WIDTH  : integer;
            ABUS_WIDTH  : integer := 16;
            DBUS_WIDTH  : integer := 16;
            OBUS_WIDTH  : integer := 16;
    		UART_CLOCK	: integer;
    		UART_BRATE 	: integer;
    		UART_ADDR	: std_logic_vector;
    		TEST_UART	: std_logic);
    port (
        -- system interface
        reset       : in std_logic;
        clk         : in std_logic;

        -- Serial Interface serial / RS422
        serial_rxd  : in  std_logic;    -- receive data
        serial_txd  : out std_logic;    -- transmit dat
		tp1			: in std_logic;	-- test input
		tp2			: in std_logic;	-- test input
		tpack		: out std_logic;-- test acknowledge

		-- User Misc.
        heartbeat   : out std_logic;   -- I'm alive
        timerbeat	: out std_logic;   -- I'm alive
        uC_iport    : in  std_logic_vector(7 downto 0);
        secPulse    : in  std_logic;
        secPulse_ack: out std_logic;
        
        -- External Interface Port
        uC_addr     : out std_logic_vector(ABUS_WIDTH-1 downto 0);
        uC_page     : out std_logic_vector(ABUS_WIDTH-1 downto 0);
        uC_pagewr   : out std_logic;
        uC_down     : out std_logic;
        uC_dinp     : in  std_logic_vector(DBUS_WIDTH-1 downto 0);
        uC_dvld     : in  std_logic;
        uC_rd       : out std_logic;
        uC_dout     : out std_logic_vector(DBUS_WIDTH-1 downto 0);
        uC_wr       : out std_logic;
        uC_mio      : out std_logic;    -- memory=1 or io=0 access
        uC_busen    : out std_logic;    -- bus enable
        uC_oport    : out std_logic_vector(OBUS_WIDTH-1 downto 0);
        uC_sync		: out std_logic;
        uC_hcode	: out std_logic;
        uC_pcode    : in  std_logic; -- 0=no protect, 1=protect
        uC_ecode    : in  std_logic_vector(ABUS_WIDTH-1 downto 0); -- end code protection
        uC_bcode    : in  std_logic_vector(ABUS_WIDTH-1 downto 0)  -- start of boot code protection
        );
end component;

component fpga1_regs
    port (
        -- system interface
        reset      : in std_logic;  -- system reset
        clk        : in std_logic;

        -- IO Bus from uC16
        uC_addr     : in  std_logic_vector(ABUS_WIDTH-1 downto 0);
        uC_din      : in  std_logic_vector(DBUS_WIDTH-1 downto 0);
        uC_cs		: in  std_logic;
        uC_write    : in  std_logic;
        uC_read     : in  std_logic;
        uC_dout     : out std_logic_vector(DBUS_WIDTH-1 downto 0);

        -- Registers Out
        reg00_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg01_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg02_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg03_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg04_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg05_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg06_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg07_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg08_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg09_io    : out std_logic_vector(DBUS_WIDTH-1 downto 0); 

         -- Registers In
        reg0a_io    : in  std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0b_io    : in  std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0c_io    : in  std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0d_io    : in  std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0e_io    : in  std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0f_io    : in  std_logic_vector(DBUS_WIDTH-1 downto 0)
        );
end component;

component fpga1_rout
    port (
        -- system interface
        reset      : in std_logic;  -- system reset
        clk        : in std_logic;

        -- IO Bus from uC16
        uC_addr     : in  std_logic_vector(ABUS_WIDTH-1 downto 0);
        uC_din      : in  std_logic_vector(DBUS_WIDTH-1 downto 0);
        uC_cs		: in  std_logic;
        uC_write    : in  std_logic;
        uC_read     : in  std_logic;
        uC_dout     : out std_logic_vector(DBUS_WIDTH-1 downto 0);

        -- Registers Out
        reg00_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg01_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg02_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg03_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg04_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg05_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg06_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg07_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg08_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg09_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0a_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0b_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0c_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0d_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0e_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg0f_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0);
        reg10_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg11_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg12_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg13_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg14_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg15_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg16_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg17_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg18_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg19_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg1a_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg1b_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg1c_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg1d_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg1e_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg1f_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0);
        reg20_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg21_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg22_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg23_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg24_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg25_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg26_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg27_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg28_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg29_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg2a_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg2b_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg2c_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg2d_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg2e_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg2f_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0);
        reg30_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg31_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg32_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg33_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg34_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg35_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg36_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg37_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg38_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg39_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg3a_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg3b_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg3c_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg3d_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg3e_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0); 
        reg3f_o     : out std_logic_vector(DBUS_WIDTH-1 downto 0)
        );
end component;

-------------------------------------------------------------------------------
-- BEGIN Architecture definition.
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- Component Instantiation
-------------------------------------------------------------------------------
--Instantiation of sub-level modules
	clk1_12to100: clk_wiz_12to100_50
	 PORT MAP(
		clk_in1		=> sysclk,
		clk_out1	=> clk,		-- 100MHz
		locked		=> locked,
		reset		=> '0'
	);

    uC16_0: uC16
		generic map (
			PBUS_WIDTH  => PBUS_WIDTH,
			UART_CLOCK  => UART_CLOCK,
    		UART_BRATE  => UART_BRATE,
			UART_ADDR	=> UART_ADDR,
			TEST_UART	=> TEST_UART)
		
		port map (
			reset        => s_reset,
			clk          => clk,

			-- Serial Interface RS232 / RS422, main UART
			serial_rxd	 => s_serial_rxd,
			serial_txd	 => s_serial_txd,
			tp1			 => s_tp1,
			tp2			 => s_tp2,
			tpack		 => s_tpack,
			
			-- User Misc.
			heartbeat    => s_heartbeat,
			timerbeat    => s_timerbeat,
			uC_iport     => s_uC_iport,
			secPulse     => s_Spulse,
			secPulse_ack => s_Spulse_ack,
						
        	-- External Interface Port
			uC_addr      => s_uC_addr,
			uC_page      => s_uC_page,
			uC_pagewr    => s_uC_pagewr,
			uC_down      => s_uC_down,
			uC_dinp      => s_uC_dinp,
			uC_dvld      => s_uC_dvld,
			uC_rd        => s_uC_rd,
			uC_dout      => s_uC_dout,
			uC_wr        => s_uC_wr,
			uC_mio       => s_uC_mio,
			uC_busen     => s_uC_busen, 
			uC_oport     => s_uC_oport, 
			uC_sync      => s_uC_sync,  -- 1 machine cycle = 4 clocks
			uC_hcode     => s_uC_hcode,
			uC_pcode     => s_uC_pcode, -- 0=no protect, 1=protect   
			uC_ecode     => s_uC_ecode, -- end of program            
			uC_bcode     => s_uC_bcode  -- start of boot code 16K-256
        );
        
              
    regs_1: fpga1_regs
        PORT MAP(
            -- system interface
            reset       => s_reset,
            clk         => clk,
            
            -- IO Bus from uC16
            uC_addr     => s_uC_addr, 
            uC_din      => s_uC_dout_r1,  
            uC_cs       => s_reg_cs1,
            uC_write    => s_uC_wregs,
            uC_read     => s_uC_rregs,
            uC_dout     => s_uC_dinp1,

            -- Registers Out
            reg00_io    => s_reg_00,-- feedback, tempvar address
            reg01_io    => s_reg_01,-- 
            reg02_io    => s_reg_02,-- ECODE                            
            reg03_io    => s_reg_03,-- BCODE                            
            reg04_io    => s_reg_04,-- 
            reg05_io    => s_reg_05,-- 
            reg06_io    => s_reg_06,-- 
            reg07_io    => s_reg_07,-- triger src[15:14], scope src[13:12], PCODE[1], target rst[0]
            reg08_io    => s_reg_08,-- low  word for 1 mSec timer
            reg09_io    => s_reg_09,-- high work for 1 mSec timer

            -- Registers In
            reg0a_io    => s_reg_0a,
            reg0b_io    => s_reg_0b,
            reg0c_io    => s_reg_0c,
            reg0d_io    => s_reg_0d,
            reg0e_io    => s_reg_0e,
            reg0f_io    => s_reg_0f
            );
            
    regs_2: fpga1_rout
        PORT MAP(
            -- system interface
            reset       => s_reset,
            clk         => clk,
            
            -- IO Bus from uC16
            uC_addr     => s_uC_addr, 
            uC_din      => s_uC_dout_r2,  
            uC_cs       => s_reg_cs2,
            uC_write    => s_uC_wregs,
            uC_read     => s_uC_rregs,
            uC_dout     => s_uC_dinp2,

            -- Registers Out
            reg00_o     => s_reg_100,
            reg01_o     => s_reg_101,
            reg02_o     => s_reg_102,
            reg03_o     => s_reg_103,
            reg04_o     => s_reg_104,
            reg05_o     => s_reg_105,
            reg06_o     => s_reg_106,
            reg07_o     => s_reg_107,
            reg08_o     => s_reg_108,
            reg09_o     => s_reg_109,
            reg0a_o     => s_reg_10a,
            reg0b_o     => s_reg_10b,
            reg0c_o     => s_reg_10c,
            reg0d_o     => s_reg_10d,
            reg0e_o     => s_reg_10e,
            reg0f_o     => s_reg_10f,
            reg10_o     => s_reg_110,
            reg11_o     => s_reg_111,
            reg12_o     => s_reg_112,
            reg13_o     => s_reg_113,
            reg14_o     => s_reg_114,
            reg15_o     => s_reg_115,
            reg16_o     => s_reg_116,
            reg17_o     => s_reg_117,
            reg18_o     => s_reg_118,
            reg19_o     => s_reg_119,
            reg1a_o     => s_reg_11a,
            reg1b_o     => s_reg_11b,
            reg1c_o     => s_reg_11c,
            reg1d_o     => s_reg_11d,
            reg1e_o     => s_reg_11e,
            reg1f_o     => s_reg_11f,
            reg20_o     => s_reg_120,
            reg21_o     => s_reg_121,
            reg22_o     => s_reg_122,
            reg23_o     => s_reg_123,
            reg24_o     => s_reg_124,
            reg25_o     => s_reg_125,
            reg26_o     => s_reg_126,
            reg27_o     => s_reg_127,
            reg28_o     => s_reg_128,
            reg29_o     => s_reg_129,
            reg2a_o     => s_reg_12a,
            reg2b_o     => s_reg_12b,
            reg2c_o     => s_reg_12c,
            reg2d_o     => s_reg_12d,
            reg2e_o     => s_reg_12e,
            reg2f_o     => s_reg_12f,
            reg30_o     => s_reg_130,
            reg31_o     => s_reg_131,
            reg32_o     => s_reg_132,
            reg33_o     => s_reg_133,
            reg34_o     => s_reg_134,
            reg35_o     => s_reg_135,
            reg36_o     => s_reg_136,
            reg37_o     => s_reg_137,
            reg38_o     => s_reg_138,
            reg39_o     => s_reg_139,
            reg3a_o     => s_reg_13a,
            reg3b_o     => s_reg_13b,
            reg3c_o     => s_reg_13c,
            reg3d_o     => s_reg_13d,
            reg3e_o     => s_reg_13e,
            reg3f_o     => s_reg_13f
            );
            

    ---------------------------------------------------------------------------
    -- Register inputs
    ---------------------------------------------------------------------------
    process (clk)
    begin  -- 8 push_buttons and 8 switches
        if clk'event and clk = '1' then
            s_user_pb    <= (others => '0');
            s_user_sw    <= (others => '0');
            s_uC_dout_r1 <= s_uC_dout;
            s_uC_dout_r2 <= s_uC_dout;
            s_uC_dout_r3 <= s_uC_dout;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- Register output
    ---------------------------------------------------------------------------
    process (clk, s_reset)
    begin  -- process 7 seg digits and LEDs
        if s_reset = '1' then
            led            <= (others => '0');
            led0_r         <= '1';
            led0_g         <= '1';
            led0_b         <= '1';
        elsif clk'event and clk = '1' then
            led            <= s_user_led(1 downto 0); -- LEDs active HIGH
            led0_r         <= not s_user_led(2);      -- LEDs active LOW
            led0_g         <= not s_user_led(3);
            led0_b         <= not s_user_led(4);
        end if;
    end process;

    process (clk, s_reset)
    begin  -- process 7 seg digits and LEDs
        if s_reset = '1' then
   	        s_usb_sel    <= '0';
        elsif clk'event and clk = '1' then
   	        s_usb_sel    <= pio_usb_sel;-- and not pio_usb_ovr;
        end if;
    end process;

    process (clk, s_reset)
    begin  -- process 7 seg digits and LEDs
        if s_reset = '1' then
   	        s_blueled  <= '0';
        elsif clk'event and clk = '1' then
        	if s_blueled = '0' then
	   	        s_blueled   <= s_uC_down;
	   	    elsif s_target_rst = '1' then
	   	        s_blueled   <= '0';
			end if;
        end if;
    end process;

    process (clk, s_reset)
    begin  -- process 7 seg digits and LEDs
        if s_reset = '1' then
   	        s_hitled   <= '0';
        elsif clk'event and clk = '1' then
        	if s_uC_hcode = '1' then
	   	        s_hitled   <= '1';
	   	    elsif s_target_rst = '1' then
	   	        s_hitled   <= '0';
			end if;
        end if;
    end process;

    process (clk,s_reset)
    begin
        if s_reset = '1' then
            uart_rxd_out <= '1';             
            pio_rxd_out  <= '1';             
            s_serial_rxd <= '1';             
   	        pio_bt_pwr   <= '0';
        elsif rising_edge(clk) then
   	        pio_bt_pwr   <= s_usb_sel;
        	if s_usb_sel = '0' then
        		-- UART connects to USB , wired UART shares with Xilinx
	            uart_rxd_out <= s_serial_txd;
    	        s_serial_rxd <= uart_txd_in;
    	    else
    	    	if s_btn1_reg = '1' then 
	    	    	-- USB connects to BT BC04, to program the BC04
		            pio_rxd_out  <= uart_txd_in;
	    	        uart_rxd_out <= pio_txd_in;
    	    	else
	    	    	-- UART connects to BT BC04, wireless normal operation
		            pio_rxd_out  <= s_serial_txd;
	    	        s_serial_rxd <= pio_txd_in;
		            uart_rxd_out <= pio_txd_in;
    	        end if;
			end if;    	        
        end if;
    end process;
    
    -- UART connects to BT BC04, to program the BC04
	-- Register btn1 for connecting directly to BT
    process (clk,s_reset,btn1)
    begin 
        if s_reset = '1' then
            s_btn1_reg <= btn1;            
        elsif rising_edge(clk) then
            s_btn1_reg <= s_btn1_reg;            
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------
    process (clk,s_reset)
    begin
      if s_reset = '1' then
        s_tp1 <= '0';
        s_tp2 <= '0';
      elsif clk'event and clk = '1' then
    	s_tp1 <= '0';
    	s_tp2 <= '0';
      end if;
    end process;

    process (clk,s_reset)
    begin
      if s_reset = '1' then
        s_uC_pcode_r  <= '0';
		s_uC_ecode_r  <= (others => '0');    -- end of program            
		s_uC_bcode_r  <= (others => '0');    -- start of boot code 16K-256
      elsif clk'event and clk = '1' then
		s_uC_pcode_r  <= s_reg_07(PCODE_OVW_BIT); -- 0=no protect, 1=protect   
		s_uC_ecode_r  <= s_reg_02;    -- end of program            
		s_uC_bcode_r  <= s_reg_03;    -- start of boot code 16K-256
      end if;
    end process;
    
    process (clk,s_reset)
    begin
      if s_reset = '1' then
        s_Second    <= '0';
        s_Spulse    <= '0';
		s_nScnt     <= (others => '0');
		s_40nScnt   <= (others => '0');
      elsif clk'event and clk = '1' then
      	if(s_uC_oport(6) = '1') then
	        s_Second    <= '0';
	        s_Spulse    <= '0';
			s_nScnt     <= (others => '0');
			s_40nScnt   <= (others => '0');
	   	end if;
   		s_40nScnt <= s_40nScnt + '1';
      	if (s_40nScnt = "011") then
			s_40nScnt  <= (others => '0');
      		s_nScnt    <= s_nScnt + '1';
      		if (s_nScnt > s_reg_09 & s_reg_08) then
      			s_nScnt     <= (others => '0');
      			s_Spulse    <= '1';
	      		s_Second    <= not s_Second;
      		end if;
	      	if (s_Spulse_ack = '1') then
    	  		s_Spulse <= '0';
    	  	end if;
      	end if;
      end if;
    end process;
    
    ---------------------------------------------------------------------------
    -- Control logic: TO Interface data path.
    ---------------------------------------------------------------------------
    -- Input and Output 

    opus1_dinp:process (s_uC_dinp,s_uC_dinp1,s_uC_dinp2,s_uC_dinp3,s_reg_cs1,s_reg_cs2,s_uC_rdmem)
--    process (clk)
    begin  
--		if clk'event and clk = '1' then
			if(s_reg_cs1 = '1') then
				s_uC_dinp <= s_uC_dinp1; 
			elsif(s_reg_cs2 = '1') then
			    s_uC_dinp <= s_uC_dinp2;
			elsif(s_uC_rdmem = '1') then
			    s_uC_dinp <= s_uC_dinp3;
			else
				s_uC_dinp <= s_uC_dinp1; 
			end if;
--        end if;
    end process;
    
    ---------------------------------------------------------------------------
    process (clk,s_reset)
    begin  
        if s_reset = '1' then
			s_reg_0a  <= (others => '0');
			s_reg_0b  <= (others => '0');
			s_reg_0c  <= (others => '0');
			s_reg_0d  <= (others => '0');
			s_reg_0e  <= (others => '0');
			s_reg_0f  <= (others => '0');
        elsif rising_edge(clk) then
			s_reg_0a <= (others => '0');
			s_reg_0b <= (others => '0');
			s_reg_0c <= std_logic_vector(to_unsigned(BOOT_ADDRESS,16));
			s_reg_0d <= TEST_CFG;
			s_reg_0e <= TEST_DATE;
			s_reg_0f <= TEST_VERSION;
        end if;
    end process;


    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------
    s_reset     <= sysrst;
    s_uC_dvld   <= '0';
    
    -- SRAM ---
    s_uC_wrmem  <= s_uC_wr    and s_uC_mio;
    s_uC_rdmem  <= s_uC_busen and s_uC_mio;
    s_uC_cemem  <= s_uC_busen and s_uC_mio;
		
	-- Registers/IOs ---
    s_uC_wregs  <= s_uC_wr and not s_uC_mio;
    s_uC_rregs  <= s_uC_rd and not s_uC_mio;
    
	s_uC_memcs1 <= s_uC_wrmem  and s_uC_cemem; -- use uC_page to select SRAM versus other RAMs

    s_base_adr1 <= BASE_ADDR_REG1;
    s_reg_cs1   <= '1' when (s_uC_addr(ABUS_WIDTH-1 downto 4) = s_base_adr1(ABUS_WIDTH-1 downto 4) and (s_uC_mio='0'))
                    else '0';

    s_base_adr2 <= BASE_ADDR_REG2;
    s_reg_cs2   <= '1' when (s_uC_addr(ABUS_WIDTH-1 downto 6) = s_base_adr2(ABUS_WIDTH-1 downto 6) and (s_uC_mio='0'))
                    else '0';

	s_target_rst <= s_reg_07(TARGET_RST_BIT);
	s_uC_iport	 <= x"00";

	s_uC_pcode   <= s_uC_pcode_r; -- 0=no protect, 1=protect   
	s_uC_ecode   <= s_uC_ecode_r; -- end of program            
	s_uC_bcode   <= s_uC_bcode_r; -- start of boot code 16K-256
		
    ---------------------------------------------------------------------------
    -- SRAM interface
    ---------------------------------------------------------------------------
   	MemAdr(ABUS_WIDTH-1 downto 0)	<= s_uC_addr;
	MemAdr(18 downto ABUS_WIDTH)    <= s_uC_page(2 downto 0);
	RamOEn				            <= not s_uC_rdmem;
	RamWEn				            <= not s_uC_wrmem;
	RamCEn				            <= not s_uC_cemem;
	
	MemDB 		<= s_uC_dout_r3(7 downto 0) when (s_uC_memcs1 = '1') else (others => 'Z');
	s_uC_dinp3	<= x"00" & MemDB;
--	s_uC_dinp3	<= MemDB & MemDB;

    ---------------------------------------------------------------------------
    -- I/O ports
    ---------------------------------------------------------------------------
	s_user_led(0)	<= s_btn1_reg;
	s_user_led(1)	<= s_reg_07(PCODE_OVW_BIT);
	s_user_led(2)	<= s_uC_oport(1);
	s_user_led(3)	<= s_uC_oport(2);
	s_user_led(4)	<= s_uC_oport(3);
	
 	grnled       	<= s_hitled;      -- protected RAM write hit
 	redled       	<= s_uC_oport(4) and s_Second; -- IRQ enabled
	blueled         <= s_blueled;     -- bad instruction code or STOP
	
			
    ---------------------------------------------------------------------------
    -- Debug and Test Logic
    ---------------------------------------------------------------------------
    process (clk)
    begin  
        if rising_edge(clk) then
        -- TRIGGER SOURCE
		if(s_reg_07(TRG_SRC_MSB downto TRG_SRC_MSB-1) = "00") then
        	s_trigg_src <= s_uC_oport(0); 
        end if;
		if(s_reg_07(TRG_SRC_MSB downto TRG_SRC_MSB-1) = "01") then
        	s_trigg_src <= s_uC_sync; 
        end if;
		if(s_reg_07(TRG_SRC_MSB downto TRG_SRC_MSB-1) = "10") then
        	s_trigg_src <= s_uC_oport(2); 
        end if;
		if(s_reg_07(TRG_SRC_MSB downto TRG_SRC_MSB-1) = "11") then
        	s_trigg_src <= s_tpack;
        end if;
        
    	-- SCOPE SOURCE
		if(s_reg_07(SCP_SRC_MSB downto SCP_SRC_MSB-1) = "00") then
        	s_scope_src <= s_uC_oport(1); 
        end if;
		if(s_reg_07(SCP_SRC_MSB downto SCP_SRC_MSB-1) = "01") then
        	s_scope_src <= '0';
        end if;
		if(s_reg_07(SCP_SRC_MSB downto SCP_SRC_MSB-1) = "10") then
        	s_scope_src <= '0';
        end if;
		if(s_reg_07(SCP_SRC_MSB downto SCP_SRC_MSB-1) = "11") then
        	s_scope_src <= '0';
        end if;
        end if;
    end process;
	---------------------------------------------------------------------------
	-- uport(0) main loop trigger/signal            s_uC_oport(0)
	-- uport(1)                               		s_uC_oport(1)
	-- uport(2)                                     s_uC_oport(2)
	-- uport(3)                                     s_uC_oport(3)
	-- uport(4) hw interrupt enable flag            s_uC_oport(4)
	-- uport(5)                                     s_uC_oport(5)
	-- uport(6)                                     s_uC_oport(6)
	-- uport(7)                                     s_uC_oport(7)
	-- uport(8) IRQ 1 trigger/signal  			    s_uC_oport(8)
	-- uport(9) IRQ 2 trigger/signal				s_uC_oport(9)
	-- uport(8->F) available
	---------------------------------------------------------------------------
	                            --        JA PMOD        
--	ja(0)	<= s_uC_oport(0);   --   |---------------|   
--	ja(1)	<= s_uC_oport(1);   -- 1 | ja(0) | ja(4) | 7 
--	ja(2)	<= s_uC_oport(3);   -- 2 | ja(1) | ja(5) | 8 
--	ja(3)	<= s_uC_oport(3);   -- 3 | ja(2) | ja(6) | 9 
--	ja(4)	<= s_uC_oport(4);   -- 4 | ja(3) | ja(7) | 10
--	ja(5)	<= s_uC_oport(5);   --   |_______|_______|   
--	ja(6)	<= s_uC_oport(8);   -- 5 |__GND__|__GND__| 11
--	ja(7)	<= s_uC_oport(9);   -- 6 |__VCC__|__VCC__| 12
	                 
								--        JA PMOD
	ja(0)	<= s_trigg_src;		--   |---------------|
	ja(1)	<= s_scope_src;		-- 1 | ja(0) | ja(4) | 7
	ja(2)	<= s_uC_oport(0);	-- 2 | ja(1) | ja(5) | 8
	ja(3)	<= s_uC_oport(5);	-- 3 | ja(2) | ja(6) | 9
	ja(4)	<= s_uC_oport(6); 	-- 4 | ja(3) | ja(7) | 10
	ja(5)	<= s_uC_oport(7);  	--   |_______|_______|
	ja(6)	<= s_uC_oport(8);	-- 5 |__GND__|__GND__| 11
	ja(7)	<= s_uC_oport(9);   -- 6 |__VCC__|__VCC__| 12

end architecture struct;                                    

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------

-- CONFIGURATION

configuration fpga1_top_c of fpga1_top is

  for struct

      for uC16_0 : uC16
          use entity work.uC16(rtl);
      end for;

      for regs_1 : fpga1_regs
          use entity work.fpga1_regs(rtl);
      end for;
  
      for regs_2 : fpga1_rout
          use entity work.fpga1_rout(rtl);
      end for;
  
  end for;
  
end fpga1_top_c;

-------------------------------------------------------------------------------
-- End of File
-------------------------------------------------------------------------------