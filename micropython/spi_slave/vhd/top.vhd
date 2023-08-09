-- ###############################################################################
-- # [ top - SPI Slave main ]
-- # =========================================================================== #
-- # Implements a simple SPI slave. Outputs recieved bytes and the byte index for
-- # dispatching responses via the tx_data_i.
-- # The SPI clock should work cross domain but must be slower than the clk_i clock.
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
    
	-- SPI interface
	plgpio2 : in std_logic;
	plgpio3 : in std_logic; 
	plgpio4 : out std_logic; 
	plgpio5 : in std_logic  	
);	
end entity;

architecture a of top is  

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
     
	-- command handler
    top_inst: entity work.spi_echo_cmd
    port map (
        clk_i => clk_sys,
        resetn_i => resetn,        
        spi_clk_i => plgpio2,
        spi_mosi_i => plgpio3,
        spi_miso_o => plgpio4,
        spi_cs_i => plgpio5
    );


end architecture;
