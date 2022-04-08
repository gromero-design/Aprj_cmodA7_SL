 -------------------------------------------------------------------------------
--                    Module                                           
-------------------------------------------------------------------------------
--                                                                     
--    Copyright 2001 Guillermo H Romero
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  uart_tx.vhd
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
--   Description :
--   This is the Entity and architecture of the top level UART.
--   UART Transmitter with integral 16 byte FIFO buffer
--   8 bit, no parity, 1 stop bit
--
--
--   References :
--       IEEE packages.
--
--   Dependencies :
--	 uart_fifo
--
------------------------------------------------------------------------
------------------------------------------------------------------------   
--   Modification History : (Date, Initials, Comments)
--       10-30-01  ghr  creation
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

-------------------------------------------------------------------------------
-- LIBRARY
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------

entity uart_tx is
    Port (
	clk          	 : in std_logic;
	clke         	 : in std_logic;
	reset 	         : in std_logic;
	data_in      	 : in std_logic_vector(7 downto 0);
	write_buffer 	 : in std_logic;
	en_16_x_baud 	 : in std_logic;
	serial_out  	 : out std_logic;
	buffer_full 	 : out std_logic;
	buffer_empty     : out std_logic
	);
    end uart_tx;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture struct of uart_tx is

    ---------------------------------------------------------------------------
    -- Component declarations
    ---------------------------------------------------------------------------
    component uart_fifo
        port(
            -- OUTPUTS
            fifo_full    : out std_logic;
            fifo_empty   : out std_logic;
            fifo_out     : out std_logic_vector(7 downto 0);
            fifo_dvld    : out std_logic;
            -- INPUTS
            clk          : in  std_logic;
            reset        : in  std_logic;
            fifo_wren    : in  std_logic;
            fifo_rden    : in  std_logic;   
            fifo_in      : in  std_logic_vector(7 downto 0)
            );
    end component;
    
    
    ---------------------------------------------------------------------------
    -- Signal declarations
    ---------------------------------------------------------------------------
    type   TX_STATE is (IDLE_ST, LOAD_ST, START_ST, DATA_ST, STOP_ST);
    signal ps_state : TX_STATE;
    signal nx_state : TX_STATE;
    
    signal fifo_data_out      : std_logic_vector(7 downto 0);
    signal fifo_data_present  : std_logic;
    signal fifo_read          : std_logic;
    
    signal s_fifo_full    : std_logic;
    signal s_fifo_empty   : std_logic;
    signal s_fifo_out     : std_logic_vector(7 downto 0);
    signal s_fifo_dvld    : std_logic;

    signal s_fifo_wren    : std_logic;
    signal s_data_in      : std_logic_vector(7 downto 0);

    signal s_serial_out   : std_logic;

    signal s_counter16    : std_logic_vector(4 downto 0);
    signal s_counter16_co : std_logic;
    
    signal s_bit_cnt      : std_logic_vector(3 downto 0);
    signal s_bit_cnt_co   : std_logic;
    
    signal s_shift_reg    : std_logic_vector(9 downto 0);
    signal s_shift_enb    : std_logic;
    signal s_shift_co     : std_logic;
    signal s_shift_load   : std_logic;

--  signal s_bit_center   : std_logic;
--  signal s_bit_center_r : std_logic;

    
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
    
begin

    ---------------------------------------------------------------------------
    -- Component instantiation
    ---------------------------------------------------------------------------

    fifo_tx: uart_fifo
	port map (
            -- OUTPUTS
            fifo_full    => s_fifo_full, 
            fifo_empty   => s_fifo_empty,
            fifo_out     => s_fifo_out,
            fifo_dvld    => s_fifo_dvld,
            
            -- INPUTS
            clk          => clk,
            reset        => reset,
            fifo_wren    => s_fifo_wren,
            fifo_rden    => fifo_read,
            fifo_in      => s_data_in
            );

    ---------------------------------------------------------------------------
    -- Process blocks
    ---------------------------------------------------------------------------
    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            s_fifo_wren <= '0';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            s_fifo_wren <= write_buffer;
        END IF;
    END PROCESS;

    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            s_data_in   <= (others => '0');
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(write_buffer = '1') then
                s_data_in  <= data_in;
            end if;
        END IF;
    END PROCESS;

    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            serial_out <= '1';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(clke = '1') then
                serial_out <= s_serial_out;
            else
                serial_out <= '1';
            end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS;

    -- State Machine
    reg_proc : process (clk, reset)
    begin  
	if reset = '1' then
	    ps_state <= IDLE_ST;
	elsif clk'event and clk = '1' then
	    ps_state <= nx_state;
	end if;
    end process reg_proc;
 
    state_machine : process (ps_state, fifo_data_present, s_counter16_co, s_bit_cnt_co)
    begin  -- process state_machine
	nx_state <= ps_state;
        case ps_state is
            
            when IDLE_ST    =>
	       nx_state     <= IDLE_ST;
	       if (fifo_data_present = '1') then
		   nx_state <= LOAD_ST;
	       end if;
               
            when LOAD_ST   =>
	       nx_state     <= START_ST;
               
            when START_ST   =>
	       nx_state     <= START_ST;
	       if (s_counter16_co = '1') then
		   nx_state <= DATA_ST;
	       end if;
               
            when DATA_ST   =>
	       nx_state     <= DATA_ST;
	       if (s_bit_cnt_co = '1') then
		   nx_state <= STOP_ST;
	       end if;
               
            when STOP_ST    =>
	       nx_state     <= STOP_ST;
	       if (s_counter16_co = '1') then
		   nx_state <= IDLE_ST;
               end if; 
	       
            when others     =>
	       nx_state     <= IDLE_ST;
       end case;
    end process state_machine;

    -- Counter 16 clock enables
    PROCESS( clk, reset)
    BEGIN
        IF(reset = '1') THEN
            s_counter16 <= (others => '0');
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(ps_state = IDLE_ST or s_counter16(4) = '1') then
                s_counter16 <= (others => '0');
            elsif(en_16_x_baud = '1') then
                s_counter16 <= s_counter16 + '1';
            end if;
        END IF;
    END PROCESS;

    
    -- Compute the center of data bit
    PROCESS( clk, reset)
    BEGIN
        IF(reset = '1') THEN
--          s_bit_center_r <= '0';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
--          s_bit_center_r <= s_counter16(3);
        END IF;
    END PROCESS;

    
    -- Bit Counter , 8 bits.
    PROCESS( clk, reset)
    BEGIN
        IF(reset = '1') THEN
            s_bit_cnt <= (others => '0');
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(ps_state = IDLE_ST) then
                s_bit_cnt <= (others => '0');
            elsif(ps_state = DATA_ST and s_counter16_co = '1') then
                s_bit_cnt <= s_bit_cnt + '1';
            end if;
        END IF;
    END PROCESS;

    
    -- Shift register
    PROCESS( clk, reset)
    BEGIN
        IF(reset = '1') THEN
            s_shift_reg <= (others => '1');
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(s_shift_load = '1') then
                s_shift_reg <= '1' & fifo_data_out & '0';
            elsif(s_shift_enb = '1' and s_counter16_co = '1') then
                s_shift_reg <= '1' & s_shift_reg(9 downto 1);
            end if;
        END IF;
    END PROCESS;

    -- Shift register
    PROCESS( clk, reset)
    BEGIN
        IF(reset = '1') THEN
            s_shift_co <= '1';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            if(s_shift_enb = '0') then
                s_shift_co <= '1';
            else
                s_shift_co <= s_shift_reg(0);
            end if;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------
    buffer_full         <= s_fifo_full; 
    buffer_empty        <= s_fifo_empty;
    fifo_data_present   <= s_fifo_dvld; 
    fifo_data_out       <= s_fifo_out;

    s_counter16_co      <= s_counter16(4);
    s_bit_cnt_co        <= s_bit_cnt(3);
    s_shift_enb         <= '1' when (ps_state /= IDLE_ST) else '0';
    s_shift_load        <= '1' when (ps_state = LOAD_ST) else '0';

    fifo_read           <= s_shift_load;
    s_serial_out        <= s_shift_co;

--  s_bit_center        <= s_counter16(3) and not s_bit_center_r;
    
end struct;

------------------------------------------------------------------------------------
-- END OF FILE UART_TX.VHD
------------------------------------------------------------------------------------


