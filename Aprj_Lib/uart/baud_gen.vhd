-------------------------------------------------------------------------------
--                    Module                                           
-------------------------------------------------------------------------------
--                                                                     
--    Copyright 2001 Guillermo H. Romero
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  baud_gen.vhd
--         Date:  Oct 29th, 2001
--       Author:  Gill Romero
--      Company:  Mutant Technology
--        Email:  romero@ieee.org
--        Phone:  617-846-1655
------------------------------------------------------------------------   
--                   Model : Module RTL
--    Development Platform : PC
--   VHDL Software Version : Model Sim 5.1
--          Synthesis Tool : XST, Xilinx Synthesis Tool version 5.1
--         Place and Route : ISE version 5.1
------------------------------------------------------------------------   
--
--   Description :
--   This is the Entity and architecture of the baud rate generator.
--
--   References :
--       IEEE packages.
--
--   Dependencies :
--
--
--------------------------------------------------------------------------
------------------------------------------------------------------------   
--   Modification History : (Date, Initials, Comments)
--       10-29-01  ghr  creation
--
------------------------------------------------------------------------   
--
--  Revision Control:
--
--/*
-- * $Header:$
-- * $Log:$
-- */
-------------------------------------------------------------------------------

------------------------------------------------------------------------
-- LIBRARY

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------

entity baud_gen is
    port (
        clk         : in  std_logic;
        Reset       : in  std_logic;
        baud_data   : in  integer;
        baud_enb    : out std_logic
	);
end entity baud_gen;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture rtl of baud_gen is

    -- UART defines
    constant INPUT_CLK     : integer := 66; -- Mhz
    constant BAUD_RATE     : integer := 115200;  -- baud rate
    constant BAUD_RATE_ENB : integer := (INPUT_CLK*1000000)/(BAUD_RATE*16)+1;
    
    ---------------------------------------------------------------------------
    -- Signal declarations
    ---------------------------------------------------------------------------
    
    -- uart signals
    signal s_en_16_x_baud  : std_logic;
    signal s_baud_count    : integer;
    signal s_baud_load     : integer;



-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
    
begin -- architecture rtl
    
    ---------------------------------------------------------------------------
    -- Process relative to the UART
    ---------------------------------------------------------------------------
    
    baud_timer: PROCESS( Clk, Reset)
    BEGIN
        IF (Reset = '1') THEN     -- async reset (active high)
            s_baud_count   <= 0;
	    s_en_16_x_baud <= '0';
        ELSIF (rising_edge( Clk )) THEN  -- rising clock edge
            IF (s_baud_count = s_baud_load) THEN
                s_baud_count   <= 0;
                s_en_16_x_baud <= '1';
            else
                s_baud_count   <= s_baud_count + 1;
                s_en_16_x_baud <= '0';
            end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS baud_timer;


    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------
--  s_baud_load <= BAUD_RATE_ENB;  	     -- fixed baud rate.
    s_baud_load <= baud_data;  -- programmable baud rate.
    
    baud_enb    <= s_en_16_x_baud;
    
end architecture rtl;
