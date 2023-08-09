-- ###############################################################################
-- # [ uart_echo - Echos serial data
-- # =========================================================================== #
-- ###############################################################################
-- # Copyright (c) 2023 picoLemon
-- # 
-- # Permission is hereby granted, free of charge, to any person obtaining a copy
-- # of this software and associated documentation files (the "Software"), to deal
-- # in the Software without restriction, including without limitation the rights
-- # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- # copies of the Software, and to permit persons to whom the Software is
-- # furnished to do so, subject to the following conditions:
-- # 
-- # The above copyright notice and this permission notice shall be included in all
-- # copies or substantial portions of the Software.
-- # 
-- # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- # SOFTWARE.
-- ###############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
entity uart_echo is
  generic(
    CLOCKFREQ : natural := 48000000  -- default 100 Mhz clock
  );
  port (
    -- Global control --            
    clk_sys_i : in std_ulogic;    
    resetn_i : in std_ulogic;

    -- UART0
    uart0_txd_o : out std_ulogic; -- UART0 send data
    uart0_rxd_i : in std_ulogic; -- UART0 recieve data
    
    -- Debug led
    status_led_o : out std_ulogic
  );
end entity;

architecture a of uart_echo is
    type EchoState_t is (InitDelay, SendWelcome, WaitData, Response);    
    signal echo_state : EchoState_t := SendWelcome;
    signal debug_echo_state : integer;
    signal counter : natural := 0;

    signal tx_data : std_ulogic_vector(7 downto 0);		
    signal tx_busy : std_ulogic;
    signal tx_en : std_ulogic;
    
    signal rx_busy : std_ulogic;
    signal rx_error : std_ulogic;
    signal rx_ready : std_ulogic;
    signal rx_data : std_ulogic_vector(7 downto 0);

    signal send_data : std_ulogic_vector(7 downto 0);
begin
	
    debug_echo_state <=  EchoState_t'POS(echo_state) ; 

    -- Main test state machine
    testmain_inst : process(clk_sys_i)            
    begin
        if rising_edge(clk_sys_i) then		
        
          if resetn_i = '0' then -- reset
        
            echo_state <= InitDelay;
            
            counter <= 0;
            status_led_o <= '0';
            tx_en <= '0';
            
          else

            tx_en <= '0';

            -- test state machine
            case echo_state is
                when InitDelay =>

                  counter <= counter + 1;

                  -- 10ms delay
                  if counter > 4800000 then
                    counter <= 0;
                    echo_state <= SendWelcome;
                  end if;

                when SendWelcome =>
                  
                  -- wait send & send hello msg byte by byte.
                  if tx_busy = '0' and tx_en = '0' then

                    -- next char
                    counter <= counter + 1;

                    case counter is
                      when 0 =>                      
                        tx_data <= x"48"; -- H
                        tx_en <= '1';
                      when 1 =>                      
                        tx_data <= x"69"; -- i        
                        tx_en <= '1';                
                      when 2 =>                      
                        tx_data <= x"0A"; -- \n                        
                        tx_en <= '1';
                      when others =>                      
                        -- echo mode
                        echo_state <= WaitData;
                        status_led_o <= '1';
                    end case;
                  end if;
                  
                when WaitData =>            

                  if rx_ready = '1' then
                    send_data <= rx_data;
                    echo_state <= Response;
                  end if;

                when Response =>

                  -- check recieve and send back
                  if tx_busy = '0' and tx_en = '0' then
                    tx_data <= send_data;
                    tx_en <= '1';

                    echo_state <= WaitData;
                  end if;
               
            end case;          
          end if;
        end if; 
    end process;    


	-- Debug UART output
	uart_tx_inst : entity work.uart_tx(a)	 
		generic map (
			BAUD => 19200,		-- Baud
			FREQ => CLOCKFREQ -- Configure clk_sys_i freq 
		)	
	port map(
		clk_i => clk_sys_i,
		resetn_i => resetn_i,
		tx_o => uart0_txd_o,		
		tx_data_i => tx_data,		
		tx_busy_o => tx_busy,
		tx_en_i => tx_en
	);


  -- Debug UART input
	uart_rx_inst : entity work.uart_rx(a)	 
		generic map (
			BAUD => 19200,		-- Baud
			FREQ => CLOCKFREQ -- Configure clk_sys_i freq 
		)	
	port map(
    clk_i => clk_sys_i,
    rst_i => resetn_i,
    rx_i => uart0_rxd_i,   
    rx_busy_o => rx_busy,
    rx_error_o => rx_error,
    rx_ready_o => rx_ready,
    rx_data_o => rx_data
	);  


end architecture;
