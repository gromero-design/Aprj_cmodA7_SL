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
--    File Name:  pwm_channel.vhd
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
--   fpga1_pwm(rtl)

-------------------------------------------------------------------------------

------------------------------------------------------------------------   
-- Modification History : (Date, Initials, Comments)
--  08-23-19 gill creation
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

entity pwm_channel is
    port (
        -- system interface
        reset      : in std_logic;   -- system reset
        clk        : in std_logic;   -- 100MHz
        
        -- Inputs
        uC_sync    : in  std_logic;
        uC_oport1  : in  std_logic;
        uC_oport2  : in  std_logic;
        rgbcntflag : in  std_logic;
        pwmcntflag : in  std_logic;
        ledloadflg : in  std_logic;
        rg_reg     : in  std_logic_vector(15 downto 0);
        bw_reg     : in  std_logic_vector(15 downto 0);
        rg_reg_bg  : in  std_logic_vector(15 downto 0);
        bw_reg_bg  : in  std_logic_vector(15 downto 0);
        pwmcnt     : in  std_logic_vector(15 downto 0);
        pwm_lo_reg : in  std_logic_vector(15 downto 0);
        pwm_hi_reg : in  std_logic_vector(15 downto 0);

        -- PWM Out
        pwm_o      : out std_logic
        );
end pwm_channel;

-------------------------------------------------------------------------------
-- ARCHITECTURE:
-- This is the main architecture for the register module
-- Other architectures are defined separately and linked to this entity
-- using configuration statement in either .\design\rtl\fpga_top.vhd
-- for synthesis or in .\tb\tests\fpga_top_tb.vhd for simulation.
-------------------------------------------------------------------------------

architecture rtl of pwm_channel is
-------------------------------------------------------------------------------
-- Signal  and Constant definitions
-------------------------------------------------------------------------------
signal s_pwm       : std_logic; -- pwm output
signal s_rgbreg    : std_logic_vector(23 downto 0);  -- RGB reg

-------------------------------------------------------------------------------
-- BEGIN Architecture definition.
-------------------------------------------------------------------------------

begin

   	-- Load and SHIFT RGB register
    process (clk,reset)
    begin
      if reset = '1' then
        s_rgbreg <= (others => '0');
      elsif clk'event and clk = '1' then
      	if(uC_sync = '1' and uC_oport1 = '1') then
	       	-- Load RGB register every rgbcnt1flg
	       	if (rgbcntflag = '1') then
	       		if uC_oport2 = '0' then
		       		s_rgbreg <= rg_reg & bw_reg( 7 downto 0);
		       	else
		       		s_rgbreg <= rg_reg_bg & bw_reg_bg( 7 downto 0);
		       	end if;
	       	-- Shift RGB register every pwm bit
	       	elsif pwmcntflag = '1' and ledloadflg = '0' then
	       		s_rgbreg <= s_rgbreg(22 downto 0) & s_rgbreg(23);
	       	end if;
	    end if;
      end if;
    end process;
       	       		
       	-- PWM output based on RGB MSB 
    process (clk,reset)
    begin
      if reset = '1' then
      	s_pwm <= '0';
      elsif clk'event and clk = '1' then
	        if (s_rgbreg(23) = '1'  and uC_oport1 = '1') then
		        if pwmcnt >= x"0000" and pwmcnt <= pwm_hi_reg then -- HIGH
	    	      	s_pwm <= '1'; -- width
	        	else
	          		s_pwm <= '0';
	        	end if;
	        else
		        if pwmcnt >= x"0000" and pwmcnt <= pwm_lo_reg then -- LOW
	    	      	s_pwm <= '1'; -- width
	        	else
	          		s_pwm <= '0';
	        	end if;
	        end if;
	  end if;
    end process;

    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Inputs and Outputs
    ---------------------------------------------------------------------------
    -- OUT
	pwm_o <= s_pwm;

    ---------------------------------------------------------------------------  
    -- temporary Assignment for debugging
    ---------------------------------------------------------------------------
    
end rtl;

-------------------------------------------------------------------------------
-- End of File
-------------------------------------------------------------------------------
