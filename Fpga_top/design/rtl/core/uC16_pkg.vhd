------------------------------------------------------------------------
--                    Package Module                                           
------------------------------------------------------------------------
-- $Id:$
------------------------------------------------------------------------
                                                                         
------------------------------------------------------------------------
--                                                                     
--    Copyright 2006 Guillermo H. Romero
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  uCgro16_pkg.vhd
--         Date:  Jan, 2006
--       Author:  Gill Romero
--      Company:  GHR
--        Email:  romero@ieee.org
--        Phone:  617-846-1655
------------------------------------------------------------------------   
--                   Model : Module RTL
--    Development Platform : Windows XP
--   VHDL Software Version : Model Sim 6.0
--          Synthesis Tool : XST, Xilinx Synthesis Tool version 8.1i
--                           Quartus 6.0
--         Place and Route : ISE version 8.1i
--                           Quartus 6.0
------------------------------------------------------------------------   
--
--   Description :
--   ***********
--
--   
------------------------------------------------------------------------   
--   Modification History : (Date, Initials, Comments)
--    01-08-06 gill creation
--    01-03-14 gill added address map
--
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

package uC16_pkg is

    constant UARTDAT_ADDR : std_logic_vector(15 downto 0) := x"0010";
    constant UARTSTA_ADDR : std_logic_vector(15 downto 0) := x"0011";

    constant LED_ADDR     : std_logic_vector(15 downto 0) := x"1000";
    constant USBDAT_ADDR  : std_logic_vector(15 downto 0) := x"1010";
    constant USBSTA_ADDR  : std_logic_vector(15 downto 0) := x"1011";
    constant USBVER_ADDR  : std_logic_vector(15 downto 0) := x"1012";
    constant REGSTR_ADDR  : std_logic_vector(15 downto 0) := x"1020";
    constant REGEND_ADDR  : std_logic_vector(15 downto 0) := x"102F";

    constant DEVA_ADDR    : std_logic_vector(15 downto 0) := x"1100";
    constant DEVC_ADDR    : std_logic_vector(15 downto 0) := x"1110";
    
end uC16_pkg;

------------------------------------------------------------------------
-- PACKAGE BODY

package body uC16_pkg is
    
end uC16_pkg;

