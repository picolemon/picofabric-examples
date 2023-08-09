-- ###############################################################################
-- # [ top_tb - Top test bench ]
-- # =============================================================================
-- # Tests for LED blinking.
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
use ieee.math_real.all;


entity top_tb is
end;

architecture a of top_tb is
    constant f_clock_c               : natural := 48000000; 
    constant t_clock_c        : time := (1 sec) / f_clock_c;
    -- external board clock
    signal clk_i : std_logic := '0';       

	signal led0 : std_logic;

begin

    clk_i <= not clk_i after (t_clock_c/2);
 
    top_inst: entity work.top
    port map (    
        clk_48mhz  => clk_i,
        led0 => led0
    );

	test_runner : process
	begin
        wait for t_clock_c;
        
        if not led0 = '1' then
            report "Expected led0 == 1" severity error;
        end if;

        -- wait for just over half second
		wait for 0.51 sec;

        if not led0 = '0' then
            report "Expected led0 == 0" severity error;
        end if;

        -- wait sim exit
        wait for 99 sec;
	end process;
	
end;
