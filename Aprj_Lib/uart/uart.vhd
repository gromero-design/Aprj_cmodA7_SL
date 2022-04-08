-------------------------------------------------------------------------------
--                    Module                                           
-------------------------------------------------------------------------------
--                                                                     
--    Copyright 2001 Guillermo H Romero
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  uart.vhd
--         Date:  Oct 30th, 2001
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
--   This is the Entity and architecture of the top level UART.
--
--   References :
--       IEEE packages.
--
--   Dependencies :
--	 baud_gen.vhd.
--       uart_tx.edn, uart_rx.edn (Xilinx modules)
--
--   Address   read            write
--   ------------------------------------------------------------------- 
--	 0     receiver        transmit
--   1     status          control
--   2     baud rate low   baud rate low 
--   3     baud rate high  baud rate high
--
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

------------------------------------------------------------------------
-- LIBRARY

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------

entity uart is
	port (
		clk         : in  std_logic;  	-- system clock
		clke        : in  std_logic;
		reset       : in  std_logic;  	-- system reset active high
		wr_enb      : in  std_logic;  	-- write enable
		rd_enb      : in  std_logic;  	-- read enable
		cs_enb      : in  std_logic;  	-- chip select
		
		address     : in  std_logic_vector(1 downto 0);  -- register address
		data_in     : in  std_logic_vector(7 downto 0);  -- transmitt data
		data_out    : out std_logic_vector(7 downto 0);  -- receive data
		rx_dvld     : out std_logic;  	-- receiver data available
		
		-- Serial Interface RS232
		serial_txd  : out std_logic; -- transmit serial data
		serial_rxd  : in  std_logic; -- receive serial data
		tp1			: in std_logic;	-- test input
		tp2			: in std_logic;	-- test input
		tpack		: out std_logic;-- test acknowledge
		
		-- debug : loopback test
		loopback    : in  std_logic;    -- connects TxD to RxD
		
		-- baud rate
		baud_value  : in integer
	
	);
end entity uart;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture rtl of uart is

    -- UART defines
--    constant INPUT_CLK     : integer := 66; -- Mhz
--    constant BAUD_RATE     : integer := 115200;  -- baud rate
--    constant BAUD_RATE_ENB : integer := (INPUT_CLK*1000000)/(BAUD_RATE*16)+1;
    
    ---------------------------------------------------------------------------
    -- Component declarations
    ---------------------------------------------------------------------------
	component uart_rx is
		Port (
			clk                 : in std_logic;
			clke                : in std_logic;
			reset               : in std_logic;
			serial_in           : in std_logic;
			data_out            : out std_logic_vector(7 downto 0);
			read_buffer         : in std_logic;
			en_16_x_baud        : in std_logic;
			buffer_data_present : out std_logic;
			buffer_full         : out std_logic;
			buffer_empty        : out std_logic;
			data_bit_error      : out std_logic
		);
	end component uart_rx;
	
	component uart_tx is
		Port (
			clk                 : in std_logic;
			clke                : in std_logic;
			reset               : in std_logic;
			data_in             : in std_logic_vector(7 downto 0);
			write_buffer        : in std_logic;
			en_16_x_baud        : in std_logic;
			serial_out          : out std_logic;
			buffer_full         : out std_logic;
			buffer_empty        : out std_logic
		);
	end component uart_tx;
	
	component baud_gen is
		Port (
			clk         : in  std_logic;
			Reset       : in  std_logic;
			baud_data   : in  integer;
			baud_enb    : out std_logic
		);
	end component baud_gen;

    ---------------------------------------------------------------------------
    -- Signal declarations
    ---------------------------------------------------------------------------
    
    -- uart signals
    signal s_uart_cs       : std_logic;  -- status chip select
    signal s_uart_rd       : std_logic;
    signal s_uart_wr       : std_logic;
    signal s_uart_tx       : std_logic_vector(7 downto 0);
    signal s_uart_rx       : std_logic_vector(7 downto 0);
    signal s_uart_dvld     : std_logic;
    signal s_serial_txd    : std_logic;
    signal s_serial_rxd    : std_logic;

    signal s_en_16_x_baud  : std_logic;
    signal s_baud_count    : integer range 0 to 65535;
    
    signal s_tx_full       : std_logic;
    signal s_tx_empty      : std_logic;
    signal s_rx_full       : std_logic;
    signal s_rx_empty      : std_logic;

    signal s_status        : std_logic_vector(7 downto 0);
    signal s_data_out      : std_logic_vector(7 downto 0);
    signal s_data_in       : std_logic_vector(7 downto 0);

    signal s_data_bit_error : std_logic;  -- stop bit not detected.
	signal s_tp1  			: std_logic;-- test point1
	signal s_tp2   			: std_logic;-- test point2
	signal s_tpack			: std_logic;-- test acknowledge

attribute keep : string;
attribute mark_debug : string;
attribute mark_debug of s_uart_cs     : signal is "true";

attribute dont_touch : string;
attribute dont_touch of s_uart_cs     : signal is "true";
    
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
    
begin -- architecture rtl
    
    ---------------------------------------------------------------------------
    -- Component instantiation
    ---------------------------------------------------------------------------
	uart_rx_i: uart_rx
		port map (
			clk                 => clk,
			clke                => clke,
			reset               => reset,
			serial_in           => s_serial_rxd,
			read_buffer         => s_uart_rd,
			en_16_x_baud        => s_en_16_x_baud,
			data_out            => s_uart_rx,  
			buffer_data_present => s_uart_dvld,
			buffer_full         => s_rx_full,
			buffer_empty        => s_rx_empty,
			data_bit_error      => s_data_bit_error
		);
	
	uart_tx_i: uart_tx
	    port map (
	    	clk               => clk,
	    	clke              => clke,
	    	reset             => reset,
	    	data_in           => s_uart_tx,
	    	write_buffer      => s_uart_wr,
	    	en_16_x_baud      => s_en_16_x_baud,
	    	serial_out        => s_serial_txd,
	    	buffer_full       => s_tx_full,
	    	buffer_empty      => s_tx_empty
	    );
	
	baud_gen_i: baud_gen
	    port map (
	    	clk               => clk,
	    	reset             => reset,
	    	baud_data         => baud_value,
	    	baud_enb          => s_en_16_x_baud
	    );


    ---------------------------------------------------------------------------
    -- Process blocks
    ---------------------------------------------------------------------------
    -- Input registers
	PROCESS( clk, reset)
	BEGIN
		IF (reset = '1') THEN     -- async reset (active high)
			s_data_in  <= (others => '0');
		ELSIF (rising_edge( clk )) THEN  -- rising clock edge
			s_data_in  <= data_in;
		END IF;  --if Reset elsif Clk1
	END PROCESS;

	PROCESS( clk, reset)
	BEGIN
		IF (reset = '1') THEN     -- async reset (active high)
            rx_dvld   <= '0';
		ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            rx_dvld   <= s_uart_dvld;
		END IF;  --if Reset elsif Clk1
	END PROCESS;

    -- Internal registers
    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            s_data_out <= (others => '0');
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            case address is
                when "00" => s_data_out <= s_uart_rx;
                when "01" => s_data_out <= s_status;
                when others => s_data_out <= s_uart_rx;
            end case;
        END IF;  --if Reset elsif Clk1
    END PROCESS;

    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            s_tpack <= '0';
		    s_tp1   <= '0';
		    s_tp2   <= '0';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
		    s_tp1 <= tp1;
		    s_tp2 <= tp2;
            if(s_uart_cs = '1') then
	            if(s_tp1 = '1'or s_tp2 = '1') then
					s_tpack <= '1';
	            end if;
				if (s_tp1 = '0' and s_tp2 = '0') then
					s_tpack <= '0'; 
	            end if;
            end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS;
    
    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            s_serial_rxd  <= '1';
            serial_txd  <= '1';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
            s_serial_rxd  <= serial_rxd;
            if(loopback = '1') then
                serial_txd  <= s_serial_rxd;
            else
                serial_txd  <= s_serial_txd;
            end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS;

    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------
    
    s_uart_cs   <= '1' when(cs_enb = '1' and (address = "00" or address = "01")) else '0';
    s_uart_rd   <= '1' when(s_uart_cs = '1' and rd_enb = '1') else '0';
    s_uart_wr   <= '1' when(s_uart_cs = '1' and wr_enb = '1') else '0';

    s_uart_tx   <= s_data_in;
    data_out    <= s_data_out;
    s_status    <= s_uart_dvld      & s_tx_full & s_tx_empty & tp2 &
                   s_data_bit_error & s_rx_full & s_rx_empty & tp1;

    tpack <= s_tpack;
    
end architecture rtl;
