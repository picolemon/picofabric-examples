-- ###############################################################################
-- # [ top - Blink LED ]
-- # =============================================================================
-- # Blinks LEDs every 0.5 seconds.
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

entity top is  
port(
	clk_48mhz : in std_logic; 	
	led0 : out std_logic
);	
end entity;
 
architecture a of top is  
	signal led_buff : std_logic;	
	signal clockDelay : natural := 0;
begin  
	
	led0 <= led_buff;	
	
	process (clk_48mhz)
	begin		
		if rising_edge(clk_48mhz) then
		
			clockDelay <= clockDelay + 1;

			if clockDelay = 0 then
				-- Enable Led 0 (yellow)
				led_buff <= '1';
			elsif clockDelay > 48000000 then			
				-- Reset every 1 second
				clockDelay <= 0;
			elsif clockDelay > 24000000 then			
				-- Disable Led 0 (yellow)
				led_buff <= '0';
			end if;

		end if;

	end process;

end architecture;
