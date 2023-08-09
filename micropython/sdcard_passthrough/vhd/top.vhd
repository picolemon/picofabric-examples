library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is  
port(
	clk_48mhz : in std_logic;

	plgpio2 : in std_logic;
	plgpio3 : in std_logic;	
	plgpio4 : out std_logic;
	plgpio5 : in std_logic;

	sdcard0_clk : out std_logic;	
	sdcard0_cd : out std_logic;	
	sdcard0_cmd : out std_logic;	
	sdcard0_dat0 : in std_logic;		

	led0 : out std_logic
);	
end entity;
 
architecture a of top is  
begin  

	led0 <= plgpio5; -- blink on access
	
	sdcard0_clk <= plgpio2;
	sdcard0_cmd <= plgpio3;
	plgpio4 <= sdcard0_dat0;
	sdcard0_cd <=  plgpio5; -- altname: dat3

end architecture;
