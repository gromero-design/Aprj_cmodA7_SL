--#########################################################################
--###                 Opus Processor Version 1                          ###
--###                                                                   ###
--#########################################################################
--                                                                     
--    Copyright 2001  Guillermo H. Romero                  
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------###
--
--    File Name:  opus16_xil.v
--         Date:  May 30th, 2002
--        Model:  Module RTL
--    Simulator:  SynaptiCad verilog
--    Synthesis:  FPGA Xpress
--          P&R:  Xilinx ISE 4.2i
--
------------------------------------------------------------------------###
--
--       Author:  Gill Romero
--        Email:  romero@ieee.org
--        Phone:  617-846-1655 
--      Company:  GHR
--
--     Modified:  
--        Email:  
--
------------------------------------------------------------------------###
--
--  Description:  This module is a fully parameterizable central processing
--                unit, general purpose, caotic structure.
--  Notes: non bidirectional data bus
--
--                __________________________________
--               |                                  |
--               | ______       ____                |
--               ||      |     | RF |               |
--               ||Decode|     |____|               |
--               ||______|     |AGU |               |
--               |             |____|               |
--               |             FETCH                | data bus       
--               |             UNIT            DBUS |<=========>     
--               |                                  | address bus    
--               |              ____           ABUS |==========>     
--     --------->|CLK          | RF |               | control bus    
--               |         ____|____|____      CBUSO|==========>     
--     --------->|RESET   |     ALU      |          | status bus     
--  control bus  |        |______________|     SBUS |==========>     
--     =========>|CBUSI        | SU |               | instruction bus
--               |             |____|          IBUS |<=========      
--               |              EXEC                | program address
--               |              UNIT           PBUS |==========>   
--               |                                  |
--               |__________________________________|
--
-- AU : arithmetic unit
-- LU : logic unit
-- SU : shifter unit
-- RF : register file unit
-- SM : switch matrix
-- AGU: address generator unit
--
------------------------------------------------------------------------###
--
--  Revision Control:
--
--#########################################################################

-- LIBRARY

library IEEE;
use IEEE.std_logic_1164.all;

-------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------

entity opus16_xil is
    generic (
        ABUS_WIDTH    : integer := 16;
        DBUS_WIDTH    : integer := 16;
        OBUS_WIDTH    : integer := 16;
        PBUS_WIDTH    : integer := 12
        );   

    port (
        --OUTPUTS
        OPUS1_ADDR     : out std_logic_vector(ABUS_WIDTH-1 downto 0);   -- ADDRESS BUS
        OPUS1_BUSEN_N  : out std_logic; -- BUS ENABLE, ACTIVE LOW
        OPUS1_BUSDIR   : out std_logic; -- BUS DIRECTION
        OPUS1_READ_N   : out std_logic; -- READ CONTROL LINE, ACTIVE LOW
        OPUS1_RSTRB    : out std_logic; -- READ  STROBE
        OPUS1_WRITE_N  : out std_logic; -- WRITE CONTROL LINE, ACTIVE LOW
        OPUS1_WSTRB    : out std_logic; -- WRITE STROBE
        OPUS1_M_IO_N   : out std_logic; -- MEMORY OR IO SELECT
        OPUS1_INTENB   : out std_logic; -- INTERRUPT ENABLE
        OPUS1_INTA1    : out std_logic; -- INTERRUPT ACKNOWLEDGE
        OPUS1_INTA2    : out std_logic; -- INTERRUPT ACKNOWLEDGE
        OPUS1_INTA3    : out std_logic; -- INTERRUPT ACKNOWLEDGE
        OPUS1_INTA4    : out std_logic; -- INTERRUPT ACKNOWLEDGE
        OPUS1_INTB1    : out std_logic; -- INTERRUPT BUSY
        OPUS1_INTB2    : out std_logic; -- INTERRUPT BUSY
        OPUS1_INTB3    : out std_logic; -- INTERRUPT BUSY
        OPUS1_INTB4    : out std_logic; -- INTERRUPT BUSY
        OPUS1_DOWN     : out std_logic; -- POWER DOWN
        OPUS1_OPORT    : out std_logic_vector(OBUS_WIDTH-1 downto 0); -- USER PORT
        OPUS1_PAGE     : out std_logic_vector(ABUS_WIDTH-1 downto 0); -- address page.
        OPUS1_PAGEWR   : out std_logic; -- address page write pulse.
        OPUS1_SYNC     : out std_logic; -- SYNC
        OPUS1_HCODE    : out std_logic; -- PROTECTION OVERWRITE HIT
        
        --INPUTS
        OPUS1_CLK      : in  std_logic; -- SYSTEM CLOCK
        OPUS1_RESET    : in  std_logic; -- GLOBAL RESET
        OPUS1_INT1     : in  std_logic; -- INTERRUPT
        OPUS1_INT2     : in  std_logic; -- INTERRUPT
        OPUS1_INT3     : in  std_logic; -- INTERRUPT
        OPUS1_INT4     : in  std_logic; -- INTERRUPT
        OPUS1_READY    : in  std_logic; -- READY
        OPUS1_PCODE    : in  std_logic; -- PROTECTION OVERWRITE
        OPUS1_ECODE    : in  std_logic_vector(ABUS_WIDTH-1 downto 0); -- END CODE PROTECTION
        OPUS1_BCODE    : in  std_logic_vector(ABUS_WIDTH-1 downto 0); -- START OF BOOT CODE PROTECTION
        
        --INOUT
        OPUS1_DOUT     : out std_logic_vector(DBUS_WIDTH-1 downto 0); -- DATA BUS OUT
        OPUS1_DINP     : in  std_logic_vector(DBUS_WIDTH-1 downto 0); -- DATA BUS INPUT
        OPUS1_DOE_N    : out std_logic  -- DATA BUS OUTPUT ENABLE
        );
end opus16_xil;
    
-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture rtl of opus16_xil is

    component opus16_core is
    port(
        --OUTPUTS
        abus           : out std_logic_vector(ABUS_WIDTH-1 downto 0);   -- ADDRESS BUS
        busen_n        : out std_logic; -- BUS ENABLE, ACTIVE LOW
        busdir         : out std_logic; -- BUS DIRECTION
        read_n         : out std_logic; -- READ CONTROL LINE, ACTIVE LOW
        rstrb          : out std_logic; -- READ  STROBE
        write_n        : out std_logic; -- WRITE CONTROL LINE, ACTIVE LOW
        wstrb          : out std_logic; -- WRITE STROBE
        m_io_n         : out std_logic; -- MEMORY OR IO SELECT
        inte_enb       : out std_logic; -- INTERRUPT ENABLE
        int1_ack       : out std_logic; -- INTERRUPT ACKNOWLEDGE
        int2_ack       : out std_logic; -- INTERRUPT ACKNOWLEDGE
        int3_ack       : out std_logic; -- INTERRUPT ACKNOWLEDGE
        int4_ack       : out std_logic; -- INTERRUPT ACKNOWLEDGE
        int1_busy      : out std_logic; -- INTERRUPT BUSY
        int2_busy      : out std_logic; -- INTERRUPT BUSY
        int3_busy      : out std_logic; -- INTERRUPT BUSY
        int4_busy      : out std_logic; -- INTERRUPT BUSY
        dout           : out std_logic_vector(DBUS_WIDTH-1 downto 0);  -- DATA OUT
        oe_n           : out std_logic;  -- DATA OUTPUT ENABLE
        down           : out std_logic;  -- POWER DOWN
        oport          : out std_logic_vector(OBUS_WIDTH-1 downto 0); -- USER OUTPUT PORT
        apage          : out std_logic_vector(ABUS_WIDTH-1 downto 0); -- ADDRESS PAGE.
        apage_wr       : out std_logic;  -- 
        sync           : out std_logic;  -- 
        hcode          : out std_logic;  -- protection overwrite hit 
        
        --INPUTS
        clk            : in  std_logic; -- SYSTEM CLOCK
        reset          : in  std_logic; -- GLOBAL RESET
        int1           : in  std_logic; -- INTERRUPT
        int2           : in  std_logic; -- INTERRUPT
        int3           : in  std_logic; -- INTERRUPT
        int4           : in  std_logic; -- INTERRUPT
        ready_in       : in  std_logic; -- READY
        din            : in  std_logic_vector(DBUS_WIDTH-1 downto 0); -- DATA BUS INPUT
        pcode          : in  std_logic; -- protection overwrite
        ecode          : in  std_logic_vector(ABUS_WIDTH-1 downto 0); -- end code protection
        bcode          : in  std_logic_vector(ABUS_WIDTH-1 downto 0); -- start of boot code protection
        
        --PROGRAM MEMORY
        pm_addr        : out std_logic_vector(ABUS_WIDTH-1 downto 0); -- memory address
        pm_dout        : out std_logic_vector(DBUS_WIDTH-1 downto 0); -- data out
        pm_dinp        : in  std_logic_vector(DBUS_WIDTH-1 downto 0); -- data in
        pm_genb        : out std_logic;  -- global enable
        pm_wenb        : out std_logic   -- write enable
        );
    end component opus16_core;

    component prog_ram IS
        port (
            clka  : IN std_logic;
            addra : IN std_logic_VECTOR(PBUS_WIDTH-1 downto 0);
            dina  : IN std_logic_VECTOR(DBUS_WIDTH-1 downto 0);
            douta : OUT std_logic_VECTOR(DBUS_WIDTH-1 downto 0);
            ena   : IN std_logic;
            wea   : IN std_logic_VECTOR(0 downto 0)
            );
    END component prog_ram;

    ---------------------------------------------------------------------------
    -- Signal declarations
    ---------------------------------------------------------------------------
    signal s_pm_addr : std_logic_vector(ABUS_WIDTH-1 downto 0);
    signal s_pm_dout : std_logic_vector(DBUS_WIDTH-1 downto 0);
    signal s_pm_dinp : std_logic_vector(DBUS_WIDTH-1 downto 0);
    signal s_pm_genb : std_logic;
    signal s_pm_wenb : std_logic;
    signal s_pm_clk  : std_logic;
    
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
    
begin -- architecture rtl
    
   -- ---------------------------------------------------------------------
   --                        Continuous Assignments
   -- ---------------------------------------------------------------------
--   DBUG_DBUS <= s_pm_dinp;
   s_pm_clk  <= OPUS1_CLK;
   
   -- ---------------------------------------------------------------------
   --                       Sequential Blocks
   -- ---------------------------------------------------------------------

   -- ---------------------------------------------------------------------
   --                    Module Instantiations
   -- ---------------------------------------------------------------------
    opus16_core_i: opus16_core
        port map(
            abus          => OPUS1_ADDR   , -- ADDRESS BUS
            busen_n       => OPUS1_BUSEN_N, -- BUS ENABLE, ACTIVE LOW
            busdir        => OPUS1_BUSDIR , -- BUS DIRECTION
            read_n        => OPUS1_READ_N , -- READ CONTROL LINE, ACTIVE LOW
            rstrb         => OPUS1_RSTRB  , -- READ  STROBE
            write_n       => OPUS1_WRITE_N, -- WRITE CONTROL LINE, ACTIVE LOW
            wstrb         => OPUS1_WSTRB  , -- WRITE STROBE
            m_io_n        => OPUS1_M_IO_N , -- MEMORY OR IO SELECT
            inte_enb      => OPUS1_INTENB , -- INTERRUPT ENABLE
            int1_ack      => OPUS1_INTA1  , -- INTERRUPT ACKNOWLEDGE
            int2_ack      => OPUS1_INTA2  , -- INTERRUPT ACKNOWLEDGE
            int3_ack      => OPUS1_INTA3  , -- INTERRUPT ACKNOWLEDGE
            int4_ack      => OPUS1_INTA4  , -- INTERRUPT ACKNOWLEDGE
            int1_busy     => OPUS1_INTB1  , -- INTERRUPT BUSY
            int2_busy     => OPUS1_INTB2  , -- INTERRUPT BUSY
            int3_busy     => OPUS1_INTB3  , -- INTERRUPT BUSY
            int4_busy     => OPUS1_INTB4  , -- INTERRUPT BUSY
            dout          => OPUS1_DOUT   , -- data bus output    
            oe_n          => OPUS1_DOE_N  , -- data bus output enable
            down          => OPUS1_DOWN   , -- POWER DOWN
            oport         => OPUS1_OPORT  , -- user output port
            apage         => OPUS1_PAGE   , -- address page
            apage_wr      => OPUS1_PAGEWR , -- address page
            sync          => OPUS1_SYNC   , -- SYNC
            hcode         => OPUS1_HCODE  , -- PROTECTION OVERWRITE HIT
                          
            --INPUTS      
            clk           => OPUS1_CLK    , -- SYSTEM CLOCK
            reset         => OPUS1_RESET  , -- GLOBAL RESET
            int1          => OPUS1_INT1   , -- INTERRUPT           
            int2          => OPUS1_INT2   , -- INTERRUPT           
            int3          => OPUS1_INT3   , -- INTERRUPT           
            int4          => OPUS1_INT4   , -- INTERRUPT           
            ready_in      => OPUS1_READY  , -- READY SIGNAL 
            din           => OPUS1_DINP   , -- data bus input
            pcode         => OPUS1_PCODE  , -- PROTECTION OVERWRITE         
            ecode         => OPUS1_ECODE  , -- END CODE PROTECTION          
            bcode         => OPUS1_BCODE  , -- START OF BOOT CODE PROTECTION
              
              
            -- PROGRAM MEMORY
            pm_addr       => s_pm_addr, -- PROGRAM MEMORY ADDRESS
            pm_dout       => s_pm_dout, -- PROGRAM MEMORY DATA OUT
            pm_dinp       => s_pm_dinp, -- PROGRAM MEMORY DATA INPUT
            pm_genb       => s_pm_genb, -- PROGRAM MEMORY GLOBAL ENABLE
            pm_wenb       => s_pm_wenb  -- PROGRAM MEMORY WRITE ENABLE
            );

   ----------------------------------------------------------------------------
   -- Memory modules
   ----------------------------------------------------------------------------
      prog_ram_i : prog_ram -- ISE14.x and Vivado
          port map (
              clka    => s_pm_clk       ,
              addra   => s_pm_addr(PBUS_WIDTH-1 downto 0),
              dina    => s_pm_dout      ,
              douta   => s_pm_dinp      ,
              ena     => s_pm_genb      ,
              wea(0)  => s_pm_wenb
              );
   
--       prog_ram_i : prog_ram -- ISE prior to 14.x
--           port map (
--               clk    => s_pm_clk       ,
--               addr   => s_pm_addr(PBUS_WIDTH-1 downto 0),
--               din    => s_pm_dout      ,
--               dout   => s_pm_dinp      ,
--               en     => s_pm_genb      ,
--               we     => s_pm_wenb
--               );
   
   -- ---------------------------------------------------------------------
   --          TEMPORARY BEHAVIORAL LOGIC TO SUPPORT DEBUGGING
   -- ---------------------------------------------------------------------

end architecture rtl;

   -- ---------------------------------------------------------------------
   --                    End Of File              
   -- ---------------------------------------------------------------------
