-- ###############################################################################
-- # [ top - DAC passthrough ]
-- # =========================================================================== #
-- # Routes SPI & I2C through FPGA from the Pico to the DAC. 
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

	-- GPIO
	plgpio : in std_logic_vector(10 downto 0);

	-- DAC interface
	snd_bck : out std_logic;
	snd_din : out std_logic;
	snd_mcscl : out std_logic; 
	snd_mdsda : out std_logic;
	snd_scki : out std_logic;
	snd_lcrk : out std_logic;
	snd_msadr : out std_logic; 
	snd_mode : out std_logic;

	-- LEDs
	led0 : out std_logic
);	
end entity;
 
architecture a of top is  
	signal clk_div2 : std_logic := '0';
	signal clk_div3 : std_logic := '0';	
	signal clocks: std_logic_vector(3 downto 0);
begin  

	-- LED on
	led0 <= '1';

	-- DAC passthrough to PICO over GPIO
	snd_mode <= '0'; 		-- SPI=0, I2C=1	
	snd_msadr <= plgpio(5); -- SPI csn 
	snd_mcscl <= plgpio(6); -- SPI clk
	snd_mdsda <= plgpio(7); -- SPI MOSI	
	
	snd_din <= plgpio(4);
	snd_bck <= plgpio(2);
	snd_lcrk <= plgpio(3);	
	snd_scki <= clk_div3; -- 12 Mhz sysclock
	
	-- generate 12mhz DAC sysclock ( 48 / 4 )
	process (clk_48mhz)
	begin		
		if rising_edge(clk_48mhz) then		
			clk_div2 <= not clk_div2;			
			if clk_div2 = '1' then
				clk_div3 <= not clk_div3;
			end if;
		end if;
	end process;

end architecture;
