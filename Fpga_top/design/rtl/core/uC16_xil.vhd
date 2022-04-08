------------------------------------------------------------------------
--                    Module                                           
------------------------------------------------------------------------
-- $Id:$
------------------------------------------------------------------------
                                                                         
------------------------------------------------------------------------
--    DIGGIN : Digital GIll Innovation
--    Copyright 2000-2019 Guillermo H. Romero
--    All rights reserved.                                 
--                                                                     
------------------------------------------------------------------------   
--    File Name:  uC16xil.vhd
--         Date:  Jan, 2006
--       Author:  Gill Romero
--      Company:  fpgahelp
--        Email:  romero@ieee.org
--        Phone:  617-905-0508
------------------------------------------------------------------------   
--                   Model : Module RTL
--    Development Platform : Windows
--   VHDL Software Version : Model Sim 6.0
--          Synthesis Tool : Any
--         Place and Route : Any
------------------------------------------------------------------------   
--
--   Description :
--   ***********
--   This is the Entity and architecture of the core module for the
--   FPGA demo board.
--
--   SMART: State Machine And Receiver Transmitter
--   ASPECT: Application SPECific Task
-- 
--   References :
--   **********
--       work.uC16_pkg.all; application specific package.
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
------------------------------------------------------------------------   
-- Modification History : (Date, Initials, Comments)
--  01-08-01 gill creation
--  01-03-14 gill updated for stand alone generic uController
--  05-02-19 gill updated for embedded controller only
--  09-25-21 gill added interrupts
--                perhaps int2 and int3 could be used externally
--                int1 used by a 1 or 10 mS timer
--                int4 used by the UART, low speed low priority
--  01-03-22 gill new opus16 core with code write protection
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
use work.uC16_pkg.all;

------------------------------------------------------------------------
-- ENTITY
------------------------------------------------------------------------

entity uC16 is
    generic(PBUS_WIDTH  : integer;
            ABUS_WIDTH  : integer := 16;
            DBUS_WIDTH  : integer := 16;
            OBUS_WIDTH  : integer := 16;
  	 		UART_CLOCK 	: integer;
    		UART_BRATE 	: integer;
    		UART_ADDR	: std_logic_vector;
    		TEST_UART	: std_logic);

    port (
        -- system interface
        reset      : in std_logic;      -- system reset
        clk        : in std_logic;      -- 

        -- Serial Interface RS232 / RS422
        serial_rxd	: in  std_logic;    -- receive data
        serial_txd	: out std_logic;    -- transmit dat
		tp1			: in std_logic;	    -- test input
		tp2			: in std_logic;	    -- test input
		tpack		: out std_logic;    -- test acknowledge

        -- User Misc.
        heartbeat	: out std_logic;   -- I'm alive
        timerbeat	: out std_logic;   -- 1 mS pulse square
        uC_iport    : in  std_logic_vector(7 downto 0);
        secPulse    : in  std_logic;
        secPulse_ack: out std_logic;
        
        -- External Interface Port
        uC_addr     : out std_logic_vector(ABUS_WIDTH-1 downto 0);
        uC_page     : out std_logic_vector(ABUS_WIDTH-1 downto 0);
        uC_pagewr   : out std_logic;
        uC_down     : out std_logic;
        uC_dinp     : in  std_logic_vector(DBUS_WIDTH-1 downto 0);
        uC_dvld     : in  std_logic;
        uC_rd       : out std_logic;
        uC_dout     : out std_logic_vector(DBUS_WIDTH-1 downto 0);
        uC_wr       : out std_logic;
        uC_mio      : out std_logic;    -- memory=1 or io=0 access
        uC_busen    : out std_logic;    -- bus enable
        uC_oport    : out std_logic_vector(OBUS_WIDTH-1 downto 0);
        uC_sync		: out std_logic;
        uC_hcode	: out std_logic;
        uC_pcode    : in  std_logic; -- protection overwrite
        uC_ecode    : in  std_logic_vector(ABUS_WIDTH-1 downto 0); -- end code protection
        uC_bcode    : in  std_logic_vector(ABUS_WIDTH-1 downto 0)  -- start of boot code protection
        );
end uC16;

-------------------------------------------------------------------------------
-- ARCHITECTURE:
-------------------------------------------------------------------------------

architecture rtl of uC16 is
-------------------------------------------------------------------------------
-- Signal  and Constant definitions
-------------------------------------------------------------------------------
  constant UART_BAUD_RATE : integer := ( (UART_CLOCK)/(UART_BRATE*16)); 
    
  constant MAXCOUNT : integer := 2**22;
  constant TMRCOUNT : integer := ( (UART_CLOCK)/(1000));
--  constant TMRCOUNT : integer := 100000;

    ---------------------------------------------------------------------------
    -- Signals for the OPUS1 processor
    ---------------------------------------------------------------------------
    --OUTPUTS
    signal s_opus1_addr     : std_logic_vector(ABUS_WIDTH-1 downto 0);   -- ADDRESS BUS
    signal s_opus1_page     : std_logic_vector(ABUS_WIDTH-1 downto 0);   -- ADDRESS page
    signal s_opus1_pagewr   : std_logic; -- ADDRESS page
    signal s_opus1_sync     : std_logic; -- SYNC
    signal s_opus1_busen_n  : std_logic; -- BUS ENABLE, ACTIVE LOW
    signal s_opus1_busdir   : std_logic; -- BUS DIRECTION
    signal s_opus1_read_n   : std_logic; -- READ CONTROL LINE, ACTIVE LOW
    signal s_opus1_rstrb    : std_logic; -- READ  STROBE
    signal s_opus1_write_n  : std_logic; -- WRITE CONTROL LINE, ACTIVE LOW
    signal s_opus1_wstrb    : std_logic; -- WRITE STROBE
    signal s_opus1_m_io_n   : std_logic; -- MEMORY OR IO SELECT
    signal s_opus1_intenb   : std_logic; -- INTERRUPT ENABLE
    signal s_opus1_inta1    : std_logic; -- INTERRUPT ACKNOWLEDGE
    signal s_opus1_inta2    : std_logic; -- INTERRUPT ACKNOWLEDGE
    signal s_opus1_inta3    : std_logic; -- INTERRUPT ACKNOWLEDGE
    signal s_opus1_inta4    : std_logic; -- INTERRUPT ACKNOWLEDGE
    signal s_opus1_intb1    : std_logic; -- INTERRUPT BUSY
    signal s_opus1_intb2    : std_logic; -- INTERRUPT BUSY
    signal s_opus1_intb3    : std_logic; -- INTERRUPT BUSY
    signal s_opus1_intb4    : std_logic; -- INTERRUPT BUSY
    signal s_opus1_down     : std_logic; -- POWER DOWN
    signal s_opus1_oport    : std_logic_vector(OBUS_WIDTH-1 downto 0); -- USER OUTPUT PORT
    signal s_opus1_hcode    : std_logic; -- HCODE
    --inputs                  
    signal s_opus1_clk      : std_logic; -- SYSTEM CLOCK
    signal s_opus1_reset    : std_logic; -- GLOBAL RESET
    signal s_opus1_int1     : std_logic; -- INTERRUPT
    signal s_opus1_int2     : std_logic; -- INTERRUPT
    signal s_opus1_int3     : std_logic; -- INTERRUPT
    signal s_opus1_int4     : std_logic; -- INTERRUPT
    signal s_opus1_ready    : std_logic; -- READY
    signal s_opus1_pcode    : std_logic; -- protection overwrite
    signal s_opus1_ecode    : std_logic_vector(ABUS_WIDTH-1 downto 0); -- end code protection
    signal s_opus1_bcode    : std_logic_vector(ABUS_WIDTH-1 downto 0); -- start of boot code protection
    --inout                   
    signal s_opus1_dout     : std_logic_vector(DBUS_WIDTH-1 downto 0); -- DATA BUS OUT
    signal s_opus1_dinp     : std_logic_vector(DBUS_WIDTH-1 downto 0); -- DATA BUS INPUT
    signal s_opus1_doe_n    : std_logic;  -- DATA BUS OUTPUT ENABLE
    signal s_opus1_inmux    : std_logic_vector(DBUS_WIDTH-1 downto 0); -- DATA BUS INPUT

    -- uart signals
    signal s_uart_rx        : std_logic_vector(7 downto 0);
    signal s_uart_tx        : std_logic_vector(7 downto 0);
    signal s_uart_rd        : std_logic;
    signal s_uart_wr        : std_logic;
    signal s_uart_dvld      : std_logic;
    signal s_uart_error     : std_logic;
    signal s_tx_full        : std_logic;
    signal s_uart_addr      : std_logic_vector(1 downto 0);-- reg address
    signal s_uart_cs        : std_logic;
    signal s_uartd_cs       : std_logic;  -- data chip select
    signal s_uart_loop      : std_logic;  -- loopback select.
	signal s_tp1			: std_logic;	-- test input
	signal s_tp2			: std_logic;	-- test input
	signal s_tp1_p			: std_logic;	-- pixel pulse
	signal s_tp2_p			: std_logic;	-- strip pulse
	signal s_tp1_int		: std_logic;	-- pixel pulse interrupt
	signal s_tp2_int		: std_logic;	-- strip pulse interrupt
	signal s_tpack			: std_logic;	-- test acknowledge
	signal s_rx_dvld		: std_logic;	-- Rx data valid


    signal clke : std_logic;

    signal s_rs232_rxd      : std_logic; -- receiver data input
    signal s_rs232_txd      : std_logic; -- transmitter data output

    signal s_opus16_rx      : std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------------
    -- hardware related
    ---------------------------------------------------------------------------
    signal s_io_addr     	: std_logic_vector(ABUS_WIDTH-1 downto 0);
    signal s_uart_data     	: std_logic_vector(DBUS_WIDTH-1 downto 0);

    ---------------------------------------------------------------------------
    -- Programmable registers
    ---------------------------------------------------------------------------
    -- for debugg
    signal s_counter_rxe : std_logic;
    signal s_counter_rxd : integer range 0 to MAXCOUNT;
    signal s_counter_txe : std_logic;
    signal s_counter_txd : integer range 0 to MAXCOUNT;
    signal s_blink_rxd   : std_logic;
    signal s_blink_txd   : std_logic;
    signal s_counter_tmr : integer range 0 to TMRCOUNT;
    signal s_pulse_tmr   : std_logic;
    signal s_timer_int   : std_logic;

    ---------------------------------------------------------------------------
    -- Miscellaneous signals
    ---------------------------------------------------------------------------
    
    -- External Interface Port
    signal s_uC_addr     : std_logic_vector(ABUS_WIDTH-1 downto 0);
    signal s_uC_page     : std_logic_vector(ABUS_WIDTH-1 downto 0);
    signal s_uC_pagewr   : std_logic;
    signal s_uC_down     : std_logic;
    signal s_uC_dinp     : std_logic_vector(DBUS_WIDTH-1 downto 0);
    signal s_uC_dout     : std_logic_vector(DBUS_WIDTH-1 downto 0);
    signal s_uC_wr       : std_logic;
    signal s_uC_rd       : std_logic;
    signal s_uC_mio      : std_logic;
    signal s_uC_busen    : std_logic;
    signal s_uC_oport    : std_logic_vector(OBUS_WIDTH-1 downto 0);
    signal s_uC_dvld     : std_logic;
    signal s_uC_sync     : std_logic;
    signal s_uC_hcode    : std_logic;

---------------------------------------------------------------------------
-- Component Definitions
--------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Components OPUS1 processor
    ---------------------------------------------------------------------------
    component opus16_xil
        generic(PBUS_WIDTH	: integer);
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
            OPUS1_DOE_N    : out std_logic   -- DATA BUS OUTPUT ENABLE
            );
    end component;
    
    component uart
        port (
            clk         : in  std_logic;  	-- system clock
            clke        : in  std_logic;  	-- clock enable
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
            
            -- Debug: loopback test
            loopback    : in std_logic;  -- connects TxD to RxD
            
            -- baud rate
            baud_value  : in integer
            
            );
    end component uart;
    ---------------------------------------------------------------------------
    -- End of component declaration for the OPUS1 processor
    ---------------------------------------------------------------------------

    
begin
-------------------------------------------------------------------------------
-- Component Instantiation
-------------------------------------------------------------------------------
    
    opus1_0: opus16_xil
    	generic map (
			PBUS_WIDTH  => PBUS_WIDTH)
        port map(
            OPUS1_ADDR     => s_opus1_addr   , -- ADDRESS BUS
            OPUS1_BUSEN_N  => s_opus1_busen_n, -- BUS ENABLE, ACTIVE LOW
            OPUS1_BUSDIR   => s_opus1_busdir , -- BUS DIRECTION
            OPUS1_READ_N   => s_opus1_read_n , -- READ CONTROL LINE, ACTIVE LOW
            OPUS1_RSTRB    => s_opus1_rstrb  , -- READ  STROBE
            OPUS1_WRITE_N  => s_opus1_write_n, -- WRITE CONTROL LINE, ACTIVE LOW
            OPUS1_WSTRB    => s_opus1_wstrb  , -- WRITE STROBE
            OPUS1_M_IO_N   => s_opus1_m_io_n , -- MEMORY OR IO SELECT
            OPUS1_INTENB   => s_opus1_intenb , -- INTERRUPT ENABLE
            OPUS1_INTA1    => s_opus1_inta1  , -- INTERRUPT ACKNOWLEDGE
            OPUS1_INTA2    => s_opus1_inta2  , -- INTERRUPT ACKNOWLEDGE
            OPUS1_INTA3    => s_opus1_inta3  , -- INTERRUPT ACKNOWLEDGE
            OPUS1_INTA4    => s_opus1_inta4  , -- INTERRUPT ACKNOWLEDGE
            OPUS1_INTB1    => s_opus1_intb1  , -- INTERRUPT BUSY       
            OPUS1_INTB2    => s_opus1_intb2  , -- INTERRUPT BUSY       
            OPUS1_INTB3    => s_opus1_intb3  , -- INTERRUPT BUSY       
            OPUS1_INTB4    => s_opus1_intb4  , -- INTERRUPT BUSY       
            OPUS1_DOWN     => s_opus1_down   , -- POWER DOWN
            OPUS1_OPORT    => s_opus1_oport  , -- USER OUTPUT PORT
            OPUS1_PAGE     => s_opus1_page   , -- ADDRESS PAGE
            OPUS1_PAGEWR   => s_opus1_pagewr , -- ADDRESS PAGE
            OPUS1_SYNC     => s_opus1_sync   , -- SYNC
            OPUS1_HCODE    => s_opus1_hcode  , -- PROTECTION OVERWRITE HIT
            --INPUTS
            OPUS1_CLK      => s_opus1_clk    , -- SYSTEM CLOCK
            OPUS1_RESET    => s_opus1_reset  , -- GLOBAL RESET
            OPUS1_INT1     => s_opus1_int1   , -- INTERRUPT
            OPUS1_INT2     => s_opus1_int2   , -- INTERRUPT
            OPUS1_INT3     => s_opus1_int3   , -- INTERRUPT
            OPUS1_INT4     => s_opus1_int4   , -- INTERRUPT
            OPUS1_READY    => s_opus1_ready  , -- READY
            OPUS1_PCODE    => s_opus1_pcode  , -- PROTECTION OVERWRITE
            OPUS1_ECODE    => s_opus1_ecode  , -- END CODE PROTECTION
            OPUS1_BCODE    => s_opus1_bcode  , -- START OF BOOT CODE PROTECTION
            --INOUT              
            OPUS1_DOUT     => s_opus1_dout   , -- DATA BUS OUT
            OPUS1_DINP     => s_opus1_dinp   , -- DATA BUS INPUT
            OPUS1_DOE_N    => s_opus1_doe_n    -- DATA BUS OUTPUT ENABLE
            );

    uart_i: uart
        port map (
            clk         => clk,
            clke        => clke,
            reset       => reset,
            wr_enb      => s_uart_wr,
            rd_enb      => s_uart_rd,
            cs_enb      => s_uart_cs,
                        
            address     => s_uart_addr,
            data_in     => s_uart_tx,
            data_out    => s_uart_rx,  
            rx_dvld     => s_rx_dvld,  
                        
            serial_txd  => s_rs232_txd,
            serial_rxd  => s_rs232_rxd,
			tp1			=> tp1,
			tp2			=> tp2,
			tpack		=> s_tpack,
                        
            loopback    => s_uart_loop,
            baud_value  => UART_BAUD_RATE
            );
    
    ---------------------------------------------------------------------------
    -- Register Input Signals.
    ---------------------------------------------------------------------------
    process (clk,reset)
    begin  
        if reset = '1' then
            clke <= '0';
        elsif rising_edge(clk) then
            clke <= '1';
        end if;
    end process;

    -- Select RS232 Mode : serial data path = TxD and RxD
    process (clk,reset)
    begin  
        if reset = '1' then
          serial_txd  <= '1';             
          s_rs232_rxd <= '1';             
        elsif rising_edge(clk) then
          serial_txd  <= s_rs232_txd;
          s_rs232_rxd <= serial_rxd;
        end if;
    end process;

 
    ---------------------------------------------------------------------------
    -- Register Output Signals.
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Control logic: TO Interface data path.
    ---------------------------------------------------------------------------
    -- Input and Output OPUS16 instructions
     opus1_out_p:process (s_uart_data, s_uart_cs, s_uC_dinp)
     begin  
            if(s_uart_cs = '1') then
                s_opus1_inmux <= s_uart_data;  -- UART
            else
                s_opus1_inmux <= s_uC_dinp;
            end if;
     end process;
    
    ---------------------------------------------------------------------------
    -- Control signals
    ---------------------------------------------------------------------------
    s_uC_addr	<= s_opus1_addr;
    s_uC_page	<= s_opus1_page;
    s_uC_pagewr	<= s_opus1_pagewr;
    s_uC_down	<= s_opus1_down;
    s_uC_dout	<= s_opus1_dout;
    s_uC_wr		<= not s_opus1_busen_n and not s_opus1_write_n;
    s_uC_rd		<= not s_opus1_busen_n and not s_opus1_read_n;
    s_uC_mio	<= not s_opus1_busen_n and s_opus1_m_io_n;
    s_uC_busen	<= not s_opus1_busen_n;
    s_uC_oport	<= s_opus1_oport;
	s_uC_sync	<= s_opus1_sync;
	s_uC_hcode	<= s_opus1_hcode;
	    
    -- temporary
--     process (clk,reset)
--     begin  
--         if reset = '1' then
-- 			s_uC_sync	<= '0';
--         elsif rising_edge(clk) then
-- 			s_uC_sync	<= s_opus1_sync;
--         end if;
--     end process;

    ---------------------------------------------------------------------------
    -- Blink RXD and TXD from UART
    ---------------------------------------------------------------------------
    
    process (clk, reset)
    begin  -- for test only
        if reset = '1' then
            s_counter_rxd <= 0;
            s_counter_txd <= 0;
            s_blink_rxd   <= '0';
            s_counter_rxe <= '0';
            s_blink_txd   <= '0';
            s_counter_txe <= '0';
        elsif clk'event and clk = '1' then
            -- Blink RXD 
            s_counter_rxd <= s_counter_rxd + 1;
            if(s_counter_rxd = MAXCOUNT) then
                s_counter_rxd <= 0;
                s_counter_rxe <= '1';
            end if;
                
            if(s_counter_rxe = '1' and not s_rs232_rxd = '1' and s_blink_rxd = '0') then
                s_blink_rxd   <= '1';
                s_counter_rxd <= 0;
                s_counter_rxe <= '0';
            elsif(s_counter_rxd >= MAXCOUNT/2 and s_blink_rxd = '1') then
                s_blink_rxd <= '0';
            end if;

            -- Blink TXD
            s_counter_txd <= s_counter_txd + 1;
            if(s_counter_txd = MAXCOUNT) then
                s_counter_txd <= 0;
                s_counter_txe <= '1';
            end if;
                
            if(s_counter_txe = '1' and not s_rs232_txd = '1' and s_blink_txd = '0') then
                s_blink_txd   <= '1';
                s_counter_txd <= 0;
                s_counter_txe <= '0';
            elsif(s_counter_txd >= MAXCOUNT/2 and s_blink_txd = '1') then
                s_blink_txd <= '0';
            end if;

        end if;
    end process;
    
    ---------------------------------------------------------------------------
    -- 1 mS timer
    ---------------------------------------------------------------------------
    
    process (clk, reset)
    begin  -- for test only
        if reset = '1' then
            s_counter_tmr <= 0;
            s_pulse_tmr   <= '0';
            s_timer_int   <= '0';
        elsif clk'event and clk = '1' then
            s_counter_tmr <= s_counter_tmr + 1;
            if(s_counter_tmr = TMRCOUNT) then
                s_counter_tmr <= 0;
            end if;
            -- timer reference for scope 
            if(s_counter_tmr >= 0 and s_counter_tmr < TMRCOUNT/2) then
                s_pulse_tmr <= '1';
            else
	            s_pulse_tmr <= '0';
            end if;
            -- clear pulse with intack    
            if(s_counter_tmr >= 0 and s_counter_tmr < 8) then
                s_timer_int <= '1';
            elsif (s_opus1_inta3 = '1') then
		        s_timer_int <= '0';
            end if;
        end if;
    end process;
    
    
    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            tpack    <= '0';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
			tpack   <= s_tpack;
        END IF;  --if Reset elsif Clk1
    END PROCESS;
    
    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            s_tp1_int  <= '0';
            s_tp1      <= '0';
            s_tp1_p    <= '0';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
        	s_tp1   <= tp1;
        	s_tp1_p <= tp1 and not s_tp1;
        	if(s_tp1_p = '1') then
	        	s_tp1_int <= '1';
	        end if;
        	if(s_opus1_inta1 = '1') then
	        	s_tp1_int <= '0';
	        end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS;
    
    PROCESS( clk, reset)
    BEGIN
        IF (reset = '1') THEN     -- async reset (active high)
            s_tp2_int  <= '0';
            s_tp2      <= '0';
            s_tp2_p    <= '0';
        ELSIF (rising_edge( clk )) THEN  -- rising clock edge
        	s_tp2   <= tp2;
        	s_tp2_p <= tp2 and not s_tp2;
        	if(s_tp2_p = '1') then
	        	s_tp2_int <= '1';
	        end if;
        	if(s_opus1_inta2 = '1') then
	        	s_tp2_int <= '0';
	        end if;
        END IF;  --if Reset elsif Clk1
    END PROCESS;
    
    ---------------------------------------------------------------------------
    -- Concurrent statements
    ---------------------------------------------------------------------------
    s_opus1_clk      <= clk;
    s_opus1_reset    <= reset;
    s_opus1_int1     <= s_tp1_int;   -- pixel counter
    s_opus1_int2     <= s_tp2_int;   -- strip counter
    s_opus1_int3     <= s_timer_int; -- 1 mSec timer
    s_opus1_int4     <= secPulse;    -- 1 Sec  timer
    s_opus1_ready    <= '1'; -- SRAM is fast enough to keep with rd/wr
    s_opus1_pcode    <= uC_pcode;
    s_opus1_ecode    <= uC_ecode;
    s_opus1_bcode    <= uC_bcode;
    
    s_opus1_dinp     <= s_opus1_inmux;

    -- UART access
    s_uart_addr <= s_io_addr(1 downto 0);
    
    s_uart_cs   <= '1' when ((s_io_addr = UART_ADDR or
    						s_io_addr = UART_ADDR+1) and
                            s_opus1_busen_n = '0' and
                            s_opus1_m_io_n = '0')
						else '0';
               
    s_uartd_cs <= '1' when (s_uart_cs = '1' and s_opus1_addr(0) = '0')
						else '0';
               
    s_uart_rd  <= '1' when(s_uartd_cs = '1' and s_opus1_rstrb = '1')
						else '0';
               
    s_uart_wr  <= '1' when(s_uartd_cs = '1' and s_opus1_wstrb = '1')
						else '0';
               
    s_uart_tx  <= s_opus1_dout(7 downto 0);
    s_uart_data <= uC_iport & s_uart_rx;
    
    s_io_addr <= s_opus1_addr;

    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Inputs and Outputs
    ---------------------------------------------------------------------------

   -- External Access
    uC_addr    <= s_uC_addr;
    uC_page    <= s_uC_page;
    uC_pagewr  <= s_uC_pagewr;
    uC_down    <= s_uC_down;
    s_uC_dinp  <= uC_dinp;
    s_uC_dvld  <= uC_dvld;
    uC_dout    <= s_uC_dout;
    uC_wr      <= s_uC_wr;  
    uC_rd      <= s_uC_rd;  
    uC_mio     <= s_uC_mio; 
    uC_busen   <= s_uC_busen; 
    uC_oport   <= s_uC_oport; 
    uC_sync    <= s_uC_sync; 
    uC_hcode   <= s_uC_hcode;

    -- Hardware resources.
--	heartbeat    <= (s_blink_rxd or s_blink_txd);
	heartbeat    <= s_blink_rxd;
	timerbeat    <= s_blink_txd;
	secPulse_ack <= s_opus1_inta4;
	
    -- Debug/Test UART
    s_uart_loop  <= TEST_UART;

    ---------------------------------------------------------------------------  
    -- temporary Assignment for debugging
    ---------------------------------------------------------------------------
    
end rtl;

-------------------------------------------------------------------------------
-- End of File
-------------------------------------------------------------------------------
