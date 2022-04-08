------------------------------------------------------------------------
--                    Package Module                                           
------------------------------------------------------------------------
-- $Id:$
------------------------------------------------------------------------
                                                                         
------------------------------------------------------------------------
--                                                                     
--    Copyright 200-2019 Guillermo H. Romero
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  fpga1_pkg.vhd
--         Date:  Jan, 2006
--       Author:  Gill Romero
--      Company:  GHR
--        Email:  romero@ieee.org
--        Phone:  617-905-0508
------------------------------------------------------------------------   
--                   Model : Module RTL
--    Development Platform : Windows 10
--   VHDL Software Version : Altera Model Sim / Vivado sim
--          Synthesis Tool : Vivado 18.2, Xilinx Synthesis Tool version 18.x
--                           Quartus Prime 17.1, Altera Synthesis Tool version 17.1
------------------------------------------------------------------------   
--
--   Description :
--   ***********
--
--   
------------------------------------------------------------------------   
--   Modification History : (Date, Initials, Comments)
--    01-08-06 gill creation
--    01-28-06 gill added constants
--    04-21-06 gill changed to Altera DE2 development board.
--    09-01-08 gill changed to DLP Design Xilinx Spartan 3e
--    04-27-19 gill changed to Artix 7 CMOD7
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

------------------------------------------------------------------------
-- PACKAGE DECLARATION

package fpga1_pkg is

    constant FPGA_VERSION_NUM: std_logic_vector(31 downto 0):= x"04302019";

    constant DATAI_MSB    : integer:= 63;
    constant DATAO_MSB    : integer:= 63;

    constant USERIO_MSB   : integer:=  47;  -- 14 & 15 inputs only
    
    constant D7SEG_MSB    : integer:=  7;
    constant LEDS_MSB     : integer:=  4;
    constant PUSHB_MSB    : integer:=  7;
    constant DIPSW_MSB    : integer:=  7;
    constant SSRAM_A_MSB  : integer:=  18;
    constant SSRAM_D_MSB  : integer:=  7;

    
end fpga1_pkg;

------------------------------------------------------------------------
-- PACKAGE BODY

package body fpga1_pkg is
    
end fpga1_pkg;

