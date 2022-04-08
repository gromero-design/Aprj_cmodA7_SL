-------------------------------------------------------------------------------
--                    N-WORD DEEP, N-BIT WIDE
--                     Synchronous FIFO      
-------------------------------------------------------------------------------
--                                                                     
--    Copyright 1998 Guillermo H Romero
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  sync_fifo.vhd
--         Date:  Oct 30th, 2001
--       Author:  Gill Romero
--      Company:  GHR
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
--  Description:
--   Common FIFO inplementation found in many books.
--   This module is a fifo to be used by the UART interface.
--   This block generates a syncronous 16 deep syncronous fifo 16 bits
--   wide.
--
------------------------------------------------------------------------
------------------------------------------------------------------------   
--   Modification History : (Date, Initials, Comments)
--       10-30-01  ghr  creation, translation from the verilog code.
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

entity uart_fifo is
    generic (
        constant FIFO_WIDTH     : integer :=  8;
        constant FIFO_DEPTH     : integer := 64;
        constant ALMOST_FULL    : integer := 62
        );
    
    port (
        -- OUTPUTS
        fifo_full   : out std_logic; -- fifo full, count = DEPTH-1
        fifo_empty  : out std_logic; -- fifo empty, count = 0
        fifo_out    : out std_logic_vector(FIFO_WIDTH-1 downto 0);
        fifo_dvld   : out std_logic;    -- fifo data present/valid
        
        -- INPUTS
        clk         : in  std_logic;  	-- system clock
        reset       : in  std_logic;  	-- system reset active high
		fifo_wren   : in  std_logic;  	-- write enable
		fifo_rden   : in  std_logic;  	-- read enable
        fifo_in     : in  std_logic_vector(7 downto 0)   -- transmitt data
        );
end entity uart_fifo;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture rtl of uart_fifo is

    
    ---------------------------------------------------------------------------
    -- Component declarations
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Signal declarations
    ---------------------------------------------------------------------------
    subtype word is std_logic_vector(FIFO_WIDTH-1 downto 0);
    type ram_type is array (0 to FIFO_DEPTH-1) of word;
    
    signal s_fifo_ram  : ram_type;
    
    signal wr_ptr      : integer;
    signal rd_ptr      : integer range 0 to FIFO_DEPTH-1;
    signal fifo_count  : integer;
    
    signal fifo_count_sel  : std_logic_vector( 1 downto 0);
    
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
    
begin -- architecture rtl
    
    ---------------------------------------------------------------------------
    -- Component instantiation
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------

    fifo_empty <= '1' when (fifo_count = 0) else '0';
    fifo_full  <= '1' when (fifo_count >= ALMOST_FULL) else '0';
    fifo_dvld  <= '1' when (fifo_count /= 0) else '0';
   
    ---------------------------------------------------------------------------
    -- Process blocks
    ---------------------------------------------------------------------------
    
--   /***********************************************
--    If this is a write access, put the data on the
--    input bus into the location pointed to by the
--    fifo write pointer
--    ************************************************/
	PROCESS( clk, reset)
	BEGIN
		IF(reset = '1') THEN
			s_fifo_ram(0) <= (others => '0');
    	ELSIF (rising_edge( clk )) THEN  -- rising clock edge
			if(fifo_wren = '1') then
				s_fifo_ram(wr_ptr) <= fifo_in;
			end if;
		END IF;  --if Reset elsif Clk1
	END PROCESS;

--   /***********************************************
--    If this is a read get the data that is in
--    the location pointed to by the read pointer
--    and put it onto the output bus
--    ************************************************/
	PROCESS( clk, reset)
	BEGIN
		IF(reset = '1') THEN
			fifo_out <= (others => '0');
    	ELSIF (rising_edge( clk )) THEN  -- rising clock edge
			fifo_out <= s_fifo_ram(rd_ptr);
		END IF;  --if Reset elsif Clk1
	END PROCESS;

--   /************************************************
--    Increment the write pointer on every write and 
--    the read pointer on every read
--    ************************************************/
    PROCESS( clk, reset)
    BEGIN
        IF(reset = '1') THEN
            wr_ptr <= 0;
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(fifo_wren = '1') then
                if(wr_ptr < FIFO_DEPTH-1) then
                    wr_ptr <= wr_ptr + 1;
                else
                    wr_ptr <= 0;
                end if;
            end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS;

    PROCESS( clk, reset)
    BEGIN
        IF(reset = '1') THEN
            rd_ptr <= 0;
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(fifo_rden = '1') then
                if(rd_ptr < FIFO_DEPTH-1) then
                    rd_ptr <= rd_ptr + 1;
                else
                    rd_ptr <= 0;
                end if;
            end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS;

--   /*********************************************
--   The fifo counter increment on every write and 
--   decrement on every read 
--   **********************************************/
    fifo_count_sel <= fifo_wren & fifo_rden;
    
    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            fifo_count <= 0;
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            case (fifo_count_sel) is
                when "00" => fifo_count <= fifo_count;
                when "01" => if(fifo_count /= 0) then
                                 fifo_count <= fifo_count - 1;
                             else
                                 fifo_count <= fifo_count;
                             end if;
                                         
                when "10" => if(fifo_count < FIFO_DEPTH) then
                                 fifo_count <= fifo_count + 1;
                             else
                                 fifo_count <= fifo_count;
                             end if;
                when "11" => fifo_count <= fifo_count;
                when others => fifo_count <= fifo_count;
            end case; 
        END IF;  --if Reset elsif Clk1
    END PROCESS;

    --PROCESS( clk, reset)
    --BEGIN
    --    IF(reset = '1') THEN
    --        fifo_dvld <= '0';
    --    ELSIF (rising_edge( clk )) THEN  -- rising clock edge
    --        if(fifo_count /= 0) then
    --            fifo_dvld <= '1';
    --        else
    --            fifo_dvld <= '0';
    --        end if;
    --    END IF;  --if Reset elsif Clk1
    --END PROCESS;

end architecture rtl;





