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
--    File Name:  fpga1_regs.vhd
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
--   fpga1_regs(rtl)
--           |__ switches_control(rtl)
--           |__ pushbuttons_control(rtl)
--           |__ leds_control(rtl)
--

-------------------------------------------------------------------------------
-- Register Map, template
-------------------------------------------------------------------------------
-- Reg 00 to 0F Write Port 1      	  Read Port 1
-- address x"0" => s_reg_00           <= (15 downto 0);
-- address x"1" => s_reg_01           <= (15 downto 0);
-- address x"2" => s_reg_02           <= (15 downto 0);
-- address x"3" => s_reg_03           <= (15 downto 0);
-- address x"4" => s_reg_04           <= (15 downto 0);
-- address x"5" => s_reg_05           <= (15 downto 0);
-- address x"6" => s_reg_06           <= (15 downto 0);
-- address x"7" => s_reg_07           <= (15 downto 0);
-- address x"8" => s_reg_08           <= (15 downto 0);
-- address x"9" => s_reg_09           <= (15 downto 0);
-- address x"A" => s_reg_0a           <= (15 downto 0);
-- address x"B" => s_reg_0b           <= (15 downto 0);
-- address x"C" => s_reg_0c           <= (15 downto 0);
-- address x"D" => s_reg_0d           <= (15 downto 0);
-- address x"E" => s_reg_0e           <= (15 downto 0);
-- address x"F" => s_reg_0f           <= (15 downto 0);

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

entity fpga1_regs is
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
        reg00_io    : out std_logic_vector(15 downto 0); 
        reg01_io    : out std_logic_vector(15 downto 0); 
        reg02_io    : out std_logic_vector(15 downto 0); 
        reg03_io    : out std_logic_vector(15 downto 0); 
        reg04_io    : out std_logic_vector(15 downto 0); 
        reg05_io    : out std_logic_vector(15 downto 0); 
        reg06_io    : out std_logic_vector(15 downto 0); 
        reg07_io    : out std_logic_vector(15 downto 0); 
        reg08_io    : out std_logic_vector(15 downto 0); 
        reg09_io    : out std_logic_vector(15 downto 0); 

        -- Registers In
        reg0a_io    : in  std_logic_vector(15 downto 0); 
        reg0b_io    : in  std_logic_vector(15 downto 0); 
        reg0c_io    : in  std_logic_vector(15 downto 0); 
        reg0d_io    : in  std_logic_vector(15 downto 0); 
        reg0e_io    : in  std_logic_vector(15 downto 0); 
        reg0f_io    : in  std_logic_vector(15 downto 0)
        );
end fpga1_regs;

-------------------------------------------------------------------------------
-- ARCHITECTURE:
-- This is the main architecture for the register module
-- Other architectures are defined separately and linked to this entity
-- using configuration statement in either .\design\rtl\fpga_top.vhd
-- for synthesis or in .\tb\tests\fpga_top_tb.vhd for simulation.
-------------------------------------------------------------------------------

architecture rtl of fpga1_regs is
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

    ---------------------------------------------------------------------------
    -- hardware related
    ---------------------------------------------------------------------------
    signal s_uC_addr     : std_logic_vector(15 downto 0);
    signal s_uC_din      : std_logic_vector(15 downto 0);
    signal s_uC_dout     : std_logic_vector(15 downto 0);
    signal s_uC_write    : std_logic;
    signal s_uC_read     : std_logic;

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
	            case s_uC_addr(3 downto 0) is
	                when x"0" => s_uC_dout <= s_reg_00;
	                when x"1" => s_uC_dout <= s_reg_01;
	                when x"2" => s_uC_dout <= s_reg_02;
	                when x"3" => s_uC_dout <= s_reg_03;
	                when x"4" => s_uC_dout <= s_reg_04;
	                when x"5" => s_uC_dout <= s_reg_05;
	                when x"6" => s_uC_dout <= s_reg_06;
	                when x"7" => s_uC_dout <= s_reg_07;
	                when x"8" => s_uC_dout <= s_reg_08;
	                when x"9" => s_uC_dout <= s_reg_09;
	                when x"A" => s_uC_dout <= s_reg_0a;
	                when x"B" => s_uC_dout <= s_reg_0b;
	                when x"C" => s_uC_dout <= s_reg_0c;
	                when x"D" => s_uC_dout <= s_reg_0d;
	                when x"E" => s_uC_dout <= s_reg_0e;
	                when x"F" => s_uC_dout <= s_reg_0f;
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
        elsif rising_edge(clk) then
            if(uC_cs = '1' and s_uC_write = '1') then
                case s_uC_addr(3 downto 0) is
                    when x"0" => s_reg_00 <= s_uC_din(15 downto 0);
                    when x"1" => s_reg_01 <= s_uC_din(15 downto 0);
                    when x"2" => s_reg_02 <= s_uC_din(15 downto 0);
                    when x"3" => s_reg_03 <= s_uC_din(15 downto 0);
                    when x"4" => s_reg_04 <= s_uC_din(15 downto 0);
                    when x"5" => s_reg_05 <= s_uC_din(15 downto 0);
                    when x"6" => s_reg_06 <= s_uC_din(15 downto 0);
                    when x"7" => s_reg_07 <= s_uC_din(15 downto 0);
                    when x"8" => s_reg_08 <= s_uC_din(15 downto 0);
                    when x"9" => s_reg_09 <= s_uC_din(15 downto 0);
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

    ---------------------------------------------------------------------------
    -- Inputs and Outputs
    ---------------------------------------------------------------------------
    s_uC_addr  <= uC_addr;
    s_uC_din   <= uC_din;
    s_uC_write <= uC_write;
    s_uC_read  <= uC_read;

    uC_dout    <= s_uC_dout;

    -- OUT
	reg00_io <= s_reg_00;
	reg01_io <= s_reg_01;
	reg02_io <= s_reg_02;
	reg03_io <= s_reg_03;
	reg04_io <= s_reg_04;
	reg05_io <= s_reg_05;
	reg06_io <= s_reg_06;
	reg07_io <= s_reg_07;
	reg08_io <= s_reg_08;
	reg09_io <= s_reg_09;
	
	-- IN
	s_reg_0a <= reg0a_io; 
	s_reg_0b <= reg0b_io; 
	s_reg_0c <= reg0c_io; 
	s_reg_0d <= reg0d_io; 
	s_reg_0e <= reg0e_io; 
	s_reg_0f <= reg0f_io; 
	
    ---------------------------------------------------------------------------  
    -- temporary Assignment for debugging
    ---------------------------------------------------------------------------
    
end rtl;

-------------------------------------------------------------------------------
-- End of File
-------------------------------------------------------------------------------
