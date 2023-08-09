-- ###############################################################################
-- # [ uart_tx - UART reciever
-- # =========================================================================== #
-- # A very simple UART reciever using 1 start bit, 8 data bits and 1 stop bit 
-- # configuration.
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
 
entity uart_rx is
	generic (
		BAUD : natural;  		-- Baud rate eg. 19200
		FREQ: natural			-- Frequency of clk_i to calculate correct timings.
	);
port(
	-- Inputs
	clk_i : in std_ulogic;
	rst_i : in std_ulogic;	
	rx_i : in std_ulogic;	    
    
	-- Outputs
	rx_busy_o : out std_ulogic;
	rx_error_o : out std_ulogic;
	rx_ready_o : out std_ulogic;
	rx_data_o : out std_ulogic_vector(7 downto 0)		
);	
	
end entity;
 
architecture a of uart_rx is
    constant cycles_per_bit : natural :=  FREQ / BAUD;  	
begin     
    main : process(clk_i) is        
		type RxState_t is (Idle, RecievingData, Done);
		variable rx_state : RxState_t := Idle;
		variable latch_rx_data : std_ulogic_vector(7 downto 0); 
		variable rx_index : natural range 0 to rx_data_o'length-1 := 0;
		variable rx_bit_counter : natural range 0 to cycles_per_bit-1 := 0;
    begin				
		if rising_edge(clk_i) then

			if rst_i = '0' then
				
				rx_busy_o <= '0';				
				rx_ready_o <= '0';				
				
			else
				rx_busy_o <= '0';
				rx_ready_o <= '0';
				
				case rx_state is
					when Idle =>						
						
						-- wait for start 
						if rx_i = '0' then
						
							-- wait for half cycle to lock rx
							if rx_bit_counter = cycles_per_bit/2 - 1 then
								rx_state := RecievingData;
								rx_bit_counter := 0;
								rx_index := 0;								
								rx_error_o <= '0';
								
							else								
								rx_bit_counter := rx_bit_counter + 1;
							end if;
							
						else						
							-- keep zero when not rx
							rx_bit_counter := 0;
						end if;
						
					when RecievingData =>
						rx_busy_o <= '1';
						
						-- bit sample timer
						if rx_bit_counter = cycles_per_bit - 1 then
						
							-- sample rx
							latch_rx_data := rx_i & latch_rx_data(latch_rx_data'length-1 downto 1);
							rx_bit_counter := 0;						
							
							if rx_index = latch_rx_data'length - 1 then
							  rx_state := Done;
							else
							  rx_index := rx_index + 1;
							end if;
							
						else
							rx_bit_counter := rx_bit_counter + 1;
						end if;		

					when Done =>
					
						rx_busy_o <= '1';
												
						-- final bit sample timer
						if rx_bit_counter = cycles_per_bit - 1 then
							
							if rx_i = '1' then
								rx_state := Idle;						
								rx_data_o <= latch_rx_data;
								rx_ready_o <= '1'; -- ready strobe
							else 
								rx_error_o <= '1';								
							end if;
							
						else
							rx_bit_counter := rx_bit_counter + 1;
						end if;							
						
				end case;				
				  
			end if;
		
		end if;
		

    end process;
end architecture;