-- ###############################################################################
-- # [ top - echo top ]
-- # =============================================================================
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
  port (
    -- Global control
    clk_48mhz       : in  std_ulogic; -- global fabric clock

    -- Uart debug output    
    plgpio4 : in  std_ulogic;
    plgpio5 : out std_ulogic;

    -- Output leds to board
    led0 : out std_ulogic
  );
end entity;

architecture top_rtl of top is

    -- reset logic
	signal resetn : std_logic;    -- init reset for root devices

    -- clocks
    signal clk_sys : std_ulogic;    
    
begin    

    -- reset device on startup
    reset_inst : entity work.reset 
    port map(     
        clk_i => clk_48mhz,    
        resetn_o => resetn
     );
     
     
    -- clock generation, provides clock from external clock input 
    clock_inst : entity work.clocks 
    port map(     
        clk_i => clk_48mhz,    
        clk_sys_o => clk_sys
     );
     
     -- echo control
     echo_inst: entity work.uart_echo
     port map (    
        clk_sys_i  => clk_48mhz,
        resetn_i  => resetn,
        uart0_txd_o  => plgpio5,
        uart0_rxd_i  => plgpio4,
        status_led_o  => led0
     );

end architecture;
