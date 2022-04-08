------------------------------------------------------------------------
--                    Module                                           
------------------------------------------------------------------------
-- $Id:$
------------------------------------------------------------------------
                                                                         
------------------------------------------------------------------------
--    fpgahelp.com
--    Copyright 1994-2014 GHR
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  fpga1_rout.vhd
--         Date:  Jan, 2010
--       Author:  GHR
--      Company:  fpgahelp
--        Email:  fpgahelp@gmail.com
--        Phone:  617-905-0508
------------------------------------------------------------------------   
--                   Model : Module RTL
--    Development Platform : Windows
--   VHDL Software Version : 
--          Synthesis Tool : Any
--         Place and Route : Any
------------------------------------------------------------------------   
--
--   Description :
--   ***********
--   This is the Entity and architecture of the regs module for the
--   Artix7 FPGA, Digilent Cmod7
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
--   fpga1_rout(rtl)
--           |__ switches_control(rtl)
--           |__ pushbuttons_control(rtl)
--           |__ leds_control(rtl)
--

-------------------------------------------------------------------------------
-- Register Map, template
-------------------------------------------------------------------------------
-- Reg 00 to 0F Write Port 1 ead Port 1
-- address x"00" => s_reg_00 <= (15 downto 0);
-- address x"01" => s_reg_01 <= (15 downto 0);
-- address x"02" => s_reg_02 <= (15 downto 0);
-- address x"03" => s_reg_03 <= (15 downto 0);
-- address x"04" => s_reg_04 <= (15 downto 0);
-- address x"05" => s_reg_05 <= (15 downto 0);
-- address x"06" => s_reg_06 <= (15 downto 0);
-- address x"07" => s_reg_07 <= (15 downto 0);
-- address x"08" => s_reg_08 <= (15 downto 0);
-- address x"09" => s_reg_09 <= (15 downto 0);
-- address x"0A" => s_reg_0a <= (15 downto 0);
-- address x"0B" => s_reg_0b <= (15 downto 0);
-- address x"0C" => s_reg_0c <= (15 downto 0);
-- address x"0D" => s_reg_0d <= (15 downto 0);
-- address x"0E" => s_reg_0e <= (15 downto 0);
-- address x"0F" => s_reg_0f <= (15 downto 0);
-- address x"10" => s_reg_10 <= (15 downto 0);
-- address x"11" => s_reg_11 <= (15 downto 0);
-- address x"12" => s_reg_12 <= (15 downto 0);
-- address x"13" => s_reg_13 <= (15 downto 0);
-- address x"14" => s_reg_14 <= (15 downto 0);
-- address x"15" => s_reg_15 <= (15 downto 0);
-- address x"16" => s_reg_16 <= (15 downto 0);
-- address x"17" => s_reg_17 <= (15 downto 0);
-- address x"18" => s_reg_18 <= (15 downto 0);
-- address x"19" => s_reg_19 <= (15 downto 0);
-- address x"1A" => s_reg_1a <= (15 downto 0);
-- address x"1B" => s_reg_1b <= (15 downto 0);
-- address x"1C" => s_reg_1c <= (15 downto 0);
-- address x"1D" => s_reg_1d <= (15 downto 0);
-- address x"1E" => s_reg_1e <= (15 downto 0);
-- address x"1F" => s_reg_1f <= (15 downto 0);

------------------------------------------------------------------------   
-- Modification History : (Date, Initials, Comments)
--  01-08-06 gill creation
--  10-15-10 gill modified to adapt to Opal Kelly XEM3010-1500 board
--                Added:   io bus
--  04-29-14 gill split register access, Port 1 and Port 2
--  05-01-19 gill modified to adapt to Cmod7 board
------------------------------------------------------------------------   
--
--  Revision Control:
--
--/*
-- * $Header:$
-- * $Log:$
-- */
------------------------------------------------------------------------
-- LIBRARY


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_STD.all;

library work;
use work.fpga1_pkg.all;

------------------------------------------------------------------------
-- ENTITY
------------------------------------------------------------------------

entity fpga1_rout is
    port (
        -- system interface
        reset      : in std_logic;   -- system reset
        clk        : in std_logic;   -- 100MHz
        
        -- IO Bus from uC16
        uC_addr     : in  std_logic_vector(15 downto 0);
        uC_din      : in  std_logic_vector(15 downto 0);
        uC_cs		: in  std_logic;
        uC_write    : in  std_logic;
        uC_read     : in  std_logic;
        uC_dout     : out std_logic_vector(15 downto 0);

        -- Registers Out
        reg00_o     : out std_logic_vector(15 downto 0); 
        reg01_o     : out std_logic_vector(15 downto 0); 
        reg02_o     : out std_logic_vector(15 downto 0); 
        reg03_o     : out std_logic_vector(15 downto 0); 
        reg04_o     : out std_logic_vector(15 downto 0); 
        reg05_o     : out std_logic_vector(15 downto 0); 
        reg06_o     : out std_logic_vector(15 downto 0); 
        reg07_o     : out std_logic_vector(15 downto 0); 
        reg08_o     : out std_logic_vector(15 downto 0); 
        reg09_o     : out std_logic_vector(15 downto 0); 
        reg0a_o     : out std_logic_vector(15 downto 0); 
        reg0b_o     : out std_logic_vector(15 downto 0); 
        reg0c_o     : out std_logic_vector(15 downto 0); 
        reg0d_o     : out std_logic_vector(15 downto 0); 
        reg0e_o     : out std_logic_vector(15 downto 0); 
        reg0f_o     : out std_logic_vector(15 downto 0);
        reg10_o     : out std_logic_vector(15 downto 0); 
        reg11_o     : out std_logic_vector(15 downto 0); 
        reg12_o     : out std_logic_vector(15 downto 0); 
        reg13_o     : out std_logic_vector(15 downto 0); 
        reg14_o     : out std_logic_vector(15 downto 0); 
        reg15_o     : out std_logic_vector(15 downto 0); 
        reg16_o     : out std_logic_vector(15 downto 0); 
        reg17_o     : out std_logic_vector(15 downto 0); 
        reg18_o     : out std_logic_vector(15 downto 0); 
        reg19_o     : out std_logic_vector(15 downto 0); 
        reg1a_o     : out std_logic_vector(15 downto 0); 
        reg1b_o     : out std_logic_vector(15 downto 0); 
        reg1c_o     : out std_logic_vector(15 downto 0); 
        reg1d_o     : out std_logic_vector(15 downto 0); 
        reg1e_o     : out std_logic_vector(15 downto 0); 
        reg1f_o     : out std_logic_vector(15 downto 0);
        reg20_o     : out std_logic_vector(15 downto 0); 
        reg21_o     : out std_logic_vector(15 downto 0); 
        reg22_o     : out std_logic_vector(15 downto 0); 
        reg23_o     : out std_logic_vector(15 downto 0); 
        reg24_o     : out std_logic_vector(15 downto 0); 
        reg25_o     : out std_logic_vector(15 downto 0); 
        reg26_o     : out std_logic_vector(15 downto 0); 
        reg27_o     : out std_logic_vector(15 downto 0); 
        reg28_o     : out std_logic_vector(15 downto 0); 
        reg29_o     : out std_logic_vector(15 downto 0); 
        reg2a_o     : out std_logic_vector(15 downto 0); 
        reg2b_o     : out std_logic_vector(15 downto 0); 
        reg2c_o     : out std_logic_vector(15 downto 0); 
        reg2d_o     : out std_logic_vector(15 downto 0); 
        reg2e_o     : out std_logic_vector(15 downto 0); 
        reg2f_o     : out std_logic_vector(15 downto 0);
        reg30_o     : out std_logic_vector(15 downto 0); 
        reg31_o     : out std_logic_vector(15 downto 0); 
        reg32_o     : out std_logic_vector(15 downto 0); 
        reg33_o     : out std_logic_vector(15 downto 0); 
        reg34_o     : out std_logic_vector(15 downto 0); 
        reg35_o     : out std_logic_vector(15 downto 0); 
        reg36_o     : out std_logic_vector(15 downto 0); 
        reg37_o     : out std_logic_vector(15 downto 0); 
        reg38_o     : out std_logic_vector(15 downto 0); 
        reg39_o     : out std_logic_vector(15 downto 0); 
        reg3a_o     : out std_logic_vector(15 downto 0); 
        reg3b_o     : out std_logic_vector(15 downto 0); 
        reg3c_o     : out std_logic_vector(15 downto 0); 
        reg3d_o     : out std_logic_vector(15 downto 0); 
        reg3e_o     : out std_logic_vector(15 downto 0); 
        reg3f_o     : out std_logic_vector(15 downto 0)
        );
end fpga1_rout;

-------------------------------------------------------------------------------
-- ARCHITECTURE:
-- This is the main architecture for the register module
-- Other architectures are defined separately and linked to this entity
-- using configuration statement in either .\design\rtl\fpga_top.vhd
-- for synthesis or in .\tb\tests\fpga_top_tb.vhd for simulation.
-------------------------------------------------------------------------------

architecture rtl of fpga1_rout is
-------------------------------------------------------------------------------
-- Signal  and Constant definitions
-------------------------------------------------------------------------------
    signal s_reg_00         : std_logic_vector(15 downto 0);
    signal s_reg_01         : std_logic_vector(15 downto 0);
    signal s_reg_02         : std_logic_vector(15 downto 0);
    signal s_reg_03         : std_logic_vector(15 downto 0);
    signal s_reg_04         : std_logic_vector(15 downto 0);
    signal s_reg_05         : std_logic_vector(15 downto 0);
    signal s_reg_06         : std_logic_vector(15 downto 0);
    signal s_reg_07         : std_logic_vector(15 downto 0);
    signal s_reg_08         : std_logic_vector(15 downto 0);
    signal s_reg_09         : std_logic_vector(15 downto 0);
    signal s_reg_0a         : std_logic_vector(15 downto 0);
    signal s_reg_0b         : std_logic_vector(15 downto 0);
    signal s_reg_0c         : std_logic_vector(15 downto 0);
    signal s_reg_0d         : std_logic_vector(15 downto 0);
    signal s_reg_0e         : std_logic_vector(15 downto 0);
    signal s_reg_0f         : std_logic_vector(15 downto 0);
    signal s_reg_10         : std_logic_vector(15 downto 0);
    signal s_reg_11         : std_logic_vector(15 downto 0);
    signal s_reg_12         : std_logic_vector(15 downto 0);
    signal s_reg_13         : std_logic_vector(15 downto 0);
    signal s_reg_14         : std_logic_vector(15 downto 0);
    signal s_reg_15         : std_logic_vector(15 downto 0);
    signal s_reg_16         : std_logic_vector(15 downto 0);
    signal s_reg_17         : std_logic_vector(15 downto 0);
    signal s_reg_18         : std_logic_vector(15 downto 0);
    signal s_reg_19         : std_logic_vector(15 downto 0);
    signal s_reg_1a         : std_logic_vector(15 downto 0);
    signal s_reg_1b         : std_logic_vector(15 downto 0);
    signal s_reg_1c         : std_logic_vector(15 downto 0);
    signal s_reg_1d         : std_logic_vector(15 downto 0);
    signal s_reg_1e         : std_logic_vector(15 downto 0);
    signal s_reg_1f         : std_logic_vector(15 downto 0);

    signal s_reg_20         : std_logic_vector(15 downto 0);
    signal s_reg_21         : std_logic_vector(15 downto 0);
    signal s_reg_22         : std_logic_vector(15 downto 0);
    signal s_reg_23         : std_logic_vector(15 downto 0);
    signal s_reg_24         : std_logic_vector(15 downto 0);
    signal s_reg_25         : std_logic_vector(15 downto 0);
    signal s_reg_26         : std_logic_vector(15 downto 0);
    signal s_reg_27         : std_logic_vector(15 downto 0);
    signal s_reg_28         : std_logic_vector(15 downto 0);
    signal s_reg_29         : std_logic_vector(15 downto 0);
    signal s_reg_2a         : std_logic_vector(15 downto 0);
    signal s_reg_2b         : std_logic_vector(15 downto 0);
    signal s_reg_2c         : std_logic_vector(15 downto 0);
    signal s_reg_2d         : std_logic_vector(15 downto 0);
    signal s_reg_2e         : std_logic_vector(15 downto 0);
    signal s_reg_2f         : std_logic_vector(15 downto 0);
    signal s_reg_30         : std_logic_vector(15 downto 0);
    signal s_reg_31         : std_logic_vector(15 downto 0);
    signal s_reg_32         : std_logic_vector(15 downto 0);
    signal s_reg_33         : std_logic_vector(15 downto 0);
    signal s_reg_34         : std_logic_vector(15 downto 0);
    signal s_reg_35         : std_logic_vector(15 downto 0);
    signal s_reg_36         : std_logic_vector(15 downto 0);
    signal s_reg_37         : std_logic_vector(15 downto 0);
    signal s_reg_38         : std_logic_vector(15 downto 0);
    signal s_reg_39         : std_logic_vector(15 downto 0);
    signal s_reg_3a         : std_logic_vector(15 downto 0);
    signal s_reg_3b         : std_logic_vector(15 downto 0);
    signal s_reg_3c         : std_logic_vector(15 downto 0);
    signal s_reg_3d         : std_logic_vector(15 downto 0);
    signal s_reg_3e         : std_logic_vector(15 downto 0);
    signal s_reg_3f         : std_logic_vector(15 downto 0);

    ---------------------------------------------------------------------------
    -- hardware related
    ---------------------------------------------------------------------------
    signal s_uC_addr     : std_logic_vector(15 downto 0);
    signal s_uC_din      : std_logic_vector(15 downto 0);
    signal s_uC_dout     : std_logic_vector(15 downto 0);
    signal s_uC_write    : std_logic;
    signal s_uC_read     : std_logic;

    signal s_address     : std_logic_vector(7 downto 0);
    
-------------------------------------------------------------------------------
-- BEGIN Architecture definition.
-------------------------------------------------------------------------------

begin

    ---------------------------------------------------------------------------
    -- Read programmable registers into uC16
    ---------------------------------------------------------------------------
    process (clk,reset)
    begin  
        if reset = '1' then
            s_uC_dout <= (others => '0');
        elsif rising_edge(clk) then
            if(uC_cs = '1') then
	            case s_address is
	                when x"00" => s_uC_dout <= s_reg_00;
	                when x"01" => s_uC_dout <= s_reg_01;
	                when x"02" => s_uC_dout <= s_reg_02;
	                when x"03" => s_uC_dout <= s_reg_03;
	                when x"04" => s_uC_dout <= s_reg_04;
	                when x"05" => s_uC_dout <= s_reg_05;
	                when x"06" => s_uC_dout <= s_reg_06;
	                when x"07" => s_uC_dout <= s_reg_07;
	                when x"08" => s_uC_dout <= s_reg_08;
	                when x"09" => s_uC_dout <= s_reg_09;
	                when x"0A" => s_uC_dout <= s_reg_0a;
	                when x"0B" => s_uC_dout <= s_reg_0b;
	                when x"0C" => s_uC_dout <= s_reg_0c;
	                when x"0D" => s_uC_dout <= s_reg_0d;
	                when x"0E" => s_uC_dout <= s_reg_0e;
	                when x"0F" => s_uC_dout <= s_reg_0f;
	                when x"10" => s_uC_dout <= s_reg_10;
	                when x"11" => s_uC_dout <= s_reg_11;
	                when x"12" => s_uC_dout <= s_reg_12;
	                when x"13" => s_uC_dout <= s_reg_13;
	                when x"14" => s_uC_dout <= s_reg_14;
	                when x"15" => s_uC_dout <= s_reg_15;
	                when x"16" => s_uC_dout <= s_reg_16;
	                when x"17" => s_uC_dout <= s_reg_17;
	                when x"18" => s_uC_dout <= s_reg_18;
	                when x"19" => s_uC_dout <= s_reg_19;
	                when x"1A" => s_uC_dout <= s_reg_1a;
	                when x"1B" => s_uC_dout <= s_reg_1b;
	                when x"1C" => s_uC_dout <= s_reg_1c;
	                when x"1D" => s_uC_dout <= s_reg_1d;
	                when x"1E" => s_uC_dout <= s_reg_1e;
	                when x"1F" => s_uC_dout <= s_reg_1f;
	                when x"20" => s_uC_dout <= s_reg_20;
	                when x"21" => s_uC_dout <= s_reg_21;
	                when x"22" => s_uC_dout <= s_reg_22;
	                when x"23" => s_uC_dout <= s_reg_23;
	                when x"24" => s_uC_dout <= s_reg_24;
	                when x"25" => s_uC_dout <= s_reg_25;
	                when x"26" => s_uC_dout <= s_reg_26;
	                when x"27" => s_uC_dout <= s_reg_27;
	                when x"28" => s_uC_dout <= s_reg_28;
	                when x"29" => s_uC_dout <= s_reg_29;
	                when x"2A" => s_uC_dout <= s_reg_2a;
	                when x"2B" => s_uC_dout <= s_reg_2b;
	                when x"2C" => s_uC_dout <= s_reg_2c;
	                when x"2D" => s_uC_dout <= s_reg_2d;
	                when x"2E" => s_uC_dout <= s_reg_2e;
	                when x"2F" => s_uC_dout <= s_reg_2f;
	                when x"30" => s_uC_dout <= s_reg_30;
	                when x"31" => s_uC_dout <= s_reg_31;
	                when x"32" => s_uC_dout <= s_reg_32;
	                when x"33" => s_uC_dout <= s_reg_33;
	                when x"34" => s_uC_dout <= s_reg_34;
	                when x"35" => s_uC_dout <= s_reg_35;
	                when x"36" => s_uC_dout <= s_reg_36;
	                when x"37" => s_uC_dout <= s_reg_37;
	                when x"38" => s_uC_dout <= s_reg_38;
	                when x"39" => s_uC_dout <= s_reg_39;
	                when x"3A" => s_uC_dout <= s_reg_3a;
	                when x"3B" => s_uC_dout <= s_reg_3b;
	                when x"3C" => s_uC_dout <= s_reg_3c;
	                when x"3D" => s_uC_dout <= s_reg_3d;
	                when x"3E" => s_uC_dout <= s_reg_3e;
	                when x"3F" => s_uC_dout <= s_reg_3f;
	                when others => s_uC_dout <= s_reg_00;
	            end case;
	        end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- Write programmable registers from uC16
    ---------------------------------------------------------------------------
    process (clk,reset)
    begin  
        if reset = '1' then
           s_reg_00  <= (others => '0');
           s_reg_01  <= (others => '0');
           s_reg_02  <= (others => '0');
           s_reg_03  <= (others => '0');
           s_reg_04  <= (others => '0');
           s_reg_05  <= (others => '0');
           s_reg_06  <= (others => '0');
           s_reg_07  <= (others => '0');
           s_reg_08  <= (others => '0');
           s_reg_09  <= (others => '0');
           s_reg_0a  <= (others => '0');
           s_reg_0b  <= (others => '0');
           s_reg_0c  <= (others => '0');
           s_reg_0d  <= (others => '0');
           s_reg_0e  <= (others => '0');
           s_reg_0f  <= (others => '0');
           s_reg_10  <= (others => '0');
           s_reg_11  <= (others => '0');
           s_reg_12  <= (others => '0');
           s_reg_13  <= (others => '0');
           s_reg_14  <= (others => '0');
           s_reg_15  <= (others => '0');
           s_reg_16  <= (others => '0');
           s_reg_17  <= (others => '0');
           s_reg_18  <= (others => '0');
           s_reg_19  <= (others => '0');
           s_reg_1a  <= (others => '0');
           s_reg_1b  <= (others => '0');
           s_reg_1c  <= (others => '0');
           s_reg_1d  <= (others => '0');
           s_reg_1e  <= (others => '0');
           s_reg_1f  <= (others => '0');
           s_reg_20  <= (others => '0');
           s_reg_21  <= (others => '0');
           s_reg_22  <= (others => '0');
           s_reg_23  <= (others => '0');
           s_reg_24  <= (others => '0');
           s_reg_25  <= (others => '0');
           s_reg_26  <= (others => '0');
           s_reg_27  <= (others => '0');
           s_reg_28  <= (others => '0');
           s_reg_29  <= (others => '0');
           s_reg_2a  <= (others => '0');
           s_reg_2b  <= (others => '0');
           s_reg_2c  <= (others => '0');
           s_reg_2d  <= (others => '0');
           s_reg_2e  <= (others => '0');
           s_reg_2f  <= (others => '0');
           s_reg_30  <= (others => '0');
           s_reg_31  <= (others => '0');
           s_reg_32  <= (others => '0');
           s_reg_33  <= (others => '0');
           s_reg_34  <= (others => '0');
           s_reg_35  <= (others => '0');
           s_reg_36  <= (others => '0');
           s_reg_37  <= (others => '0');
           s_reg_38  <= (others => '0');
           s_reg_39  <= (others => '0');
           s_reg_3a  <= (others => '0');
           s_reg_3b  <= (others => '0');
           s_reg_3c  <= (others => '0');
           s_reg_3d  <= (others => '0');
           s_reg_3e  <= (others => '0');
           s_reg_3f  <= (others => '0');
        elsif rising_edge(clk) then
            if(uC_cs = '1' and s_uC_write = '1') then
                case s_address is
                    when x"00" => s_reg_00 <= s_uC_din(15 downto 0);
                    when x"01" => s_reg_01 <= s_uC_din(15 downto 0);
                    when x"02" => s_reg_02 <= s_uC_din(15 downto 0);
                    when x"03" => s_reg_03 <= s_uC_din(15 downto 0);
                    when x"04" => s_reg_04 <= s_uC_din(15 downto 0);
                    when x"05" => s_reg_05 <= s_uC_din(15 downto 0);
                    when x"06" => s_reg_06 <= s_uC_din(15 downto 0);
                    when x"07" => s_reg_07 <= s_uC_din(15 downto 0);
                    when x"08" => s_reg_08 <= s_uC_din(15 downto 0);
                    when x"09" => s_reg_09 <= s_uC_din(15 downto 0);
                    when x"0a" => s_reg_0a <= s_uC_din(15 downto 0);
                    when x"0b" => s_reg_0b <= s_uC_din(15 downto 0);
                    when x"0c" => s_reg_0c <= s_uC_din(15 downto 0);
                    when x"0d" => s_reg_0d <= s_uC_din(15 downto 0);
                    when x"0e" => s_reg_0e <= s_uC_din(15 downto 0);
                    when x"0f" => s_reg_0f <= s_uC_din(15 downto 0);
                    when x"10" => s_reg_10 <= s_uC_din(15 downto 0);
                    when x"11" => s_reg_11 <= s_uC_din(15 downto 0);
                    when x"12" => s_reg_12 <= s_uC_din(15 downto 0);
                    when x"13" => s_reg_13 <= s_uC_din(15 downto 0);
                    when x"14" => s_reg_14 <= s_uC_din(15 downto 0);
                    when x"15" => s_reg_15 <= s_uC_din(15 downto 0);
                    when x"16" => s_reg_16 <= s_uC_din(15 downto 0);
                    when x"17" => s_reg_17 <= s_uC_din(15 downto 0);
                    when x"18" => s_reg_18 <= s_uC_din(15 downto 0);
                    when x"19" => s_reg_19 <= s_uC_din(15 downto 0);
                    when x"1a" => s_reg_1a <= s_uC_din(15 downto 0);
                    when x"1b" => s_reg_1b <= s_uC_din(15 downto 0);
                    when x"1c" => s_reg_1c <= s_uC_din(15 downto 0);
                    when x"1d" => s_reg_1d <= s_uC_din(15 downto 0);
                    when x"1e" => s_reg_1e <= s_uC_din(15 downto 0);
                    when x"1f" => s_reg_1f <= s_uC_din(15 downto 0);
                    when x"20" => s_reg_20 <= s_uC_din(15 downto 0);
                    when x"21" => s_reg_21 <= s_uC_din(15 downto 0);
                    when x"22" => s_reg_22 <= s_uC_din(15 downto 0);
                    when x"23" => s_reg_23 <= s_uC_din(15 downto 0);
                    when x"24" => s_reg_24 <= s_uC_din(15 downto 0);
                    when x"25" => s_reg_25 <= s_uC_din(15 downto 0);
                    when x"26" => s_reg_26 <= s_uC_din(15 downto 0);
                    when x"27" => s_reg_27 <= s_uC_din(15 downto 0);
                    when x"28" => s_reg_28 <= s_uC_din(15 downto 0);
                    when x"29" => s_reg_29 <= s_uC_din(15 downto 0);
                    when x"2a" => s_reg_2a <= s_uC_din(15 downto 0);
                    when x"2b" => s_reg_2b <= s_uC_din(15 downto 0);
                    when x"2c" => s_reg_2c <= s_uC_din(15 downto 0);
                    when x"2d" => s_reg_2d <= s_uC_din(15 downto 0);
                    when x"2e" => s_reg_2e <= s_uC_din(15 downto 0);
                    when x"2f" => s_reg_2f <= s_uC_din(15 downto 0);
                    when x"30" => s_reg_30 <= s_uC_din(15 downto 0);
                    when x"31" => s_reg_31 <= s_uC_din(15 downto 0);
                    when x"32" => s_reg_32 <= s_uC_din(15 downto 0);
                    when x"33" => s_reg_33 <= s_uC_din(15 downto 0);
                    when x"34" => s_reg_34 <= s_uC_din(15 downto 0);
                    when x"35" => s_reg_35 <= s_uC_din(15 downto 0);
                    when x"36" => s_reg_36 <= s_uC_din(15 downto 0);
                    when x"37" => s_reg_37 <= s_uC_din(15 downto 0);
                    when x"38" => s_reg_38 <= s_uC_din(15 downto 0);
                    when x"39" => s_reg_39 <= s_uC_din(15 downto 0);
                    when x"3a" => s_reg_3a <= s_uC_din(15 downto 0);
                    when x"3b" => s_reg_3b <= s_uC_din(15 downto 0);
                    when x"3c" => s_reg_3c <= s_uC_din(15 downto 0);
                    when x"3d" => s_reg_3d <= s_uC_din(15 downto 0);
                    when x"3e" => s_reg_3e <= s_uC_din(15 downto 0);
                    when x"3f" => s_reg_3f <= s_uC_din(15 downto 0);
                    when others => s_reg_00 <= s_uC_din(15 downto 0);
                end case;
            end if;
        end if;
    end process;


    ---------------------------------------------------------------------------
    -- Debug and Test Logic
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------
	s_address <= "00" & s_uC_addr(5 downto 0);
	
    ---------------------------------------------------------------------------
    -- Inputs and Outputs
    ---------------------------------------------------------------------------
    s_uC_addr  <= uC_addr;
    s_uC_din   <= uC_din;
    s_uC_write <= uC_write;
    s_uC_read  <= uC_read;

    uC_dout    <= s_uC_dout;

    -- OUT
	reg00_o <= s_reg_00;
	reg01_o <= s_reg_01;
	reg02_o <= s_reg_02;
	reg03_o <= s_reg_03;
	reg04_o <= s_reg_04;
	reg05_o <= s_reg_05;
	reg06_o <= s_reg_06;
	reg07_o <= s_reg_07;
	reg08_o <= s_reg_08;
	reg09_o <= s_reg_09;
	reg0a_o <= s_reg_0a;
	reg0b_o <= s_reg_0b;
	reg0c_o <= s_reg_0c;
	reg0d_o <= s_reg_0d;
	reg0e_o <= s_reg_0e;
	reg0f_o <= s_reg_0f;
	reg10_o <= s_reg_10;
	reg11_o <= s_reg_11;
	reg12_o <= s_reg_12;
	reg13_o <= s_reg_13;
	reg14_o <= s_reg_14;
	reg15_o <= s_reg_15;
	reg16_o <= s_reg_16;
	reg17_o <= s_reg_17;
	reg18_o <= s_reg_18;
	reg19_o <= s_reg_19;
	reg1a_o <= s_reg_1a;
	reg1b_o <= s_reg_1b;
	reg1c_o <= s_reg_1c;
	reg1d_o <= s_reg_1d;
	reg1e_o <= s_reg_1e;
	reg1f_o <= s_reg_1f;
	reg20_o <= s_reg_20;
	reg21_o <= s_reg_21;
	reg22_o <= s_reg_22;
	reg23_o <= s_reg_23;
	reg24_o <= s_reg_24;
	reg25_o <= s_reg_25;
	reg26_o <= s_reg_26;
	reg27_o <= s_reg_27;
	reg28_o <= s_reg_28;
	reg29_o <= s_reg_29;
	reg2a_o <= s_reg_2a;
	reg2b_o <= s_reg_2b;
	reg2c_o <= s_reg_2c;
	reg2d_o <= s_reg_2d;
	reg2e_o <= s_reg_2e;
	reg2f_o <= s_reg_2f;
	reg30_o <= s_reg_30;
	reg31_o <= s_reg_31;
	reg32_o <= s_reg_32;
	reg33_o <= s_reg_33;
	reg34_o <= s_reg_34;
	reg35_o <= s_reg_35;
	reg36_o <= s_reg_36;
	reg37_o <= s_reg_37;
	reg38_o <= s_reg_38;
	reg39_o <= s_reg_39;
	reg3a_o <= s_reg_3a;
	reg3b_o <= s_reg_3b;
	reg3c_o <= s_reg_3c;
	reg3d_o <= s_reg_3d;
	reg3e_o <= s_reg_3e;
	reg3f_o <= s_reg_3f;
 	
    ---------------------------------------------------------------------------  
    -- temporary Assignment for debugging
    ---------------------------------------------------------------------------
    
end rtl;

-------------------------------------------------------------------------------
-- End of File
-------------------------------------------------------------------------------
