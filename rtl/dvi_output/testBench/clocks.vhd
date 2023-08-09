-- ###############################################################################
-- # [ clocks - Clock simulated generation ]
-- # =========================================================================== #
-- # PLL clock simulation
-- ###############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity clocks is   
port(
    -- Inputs
    clk_i : in std_ulogic;              -- Ignored for simulation
    
    -- Outputs	    
    clk0_o : out std_ulogic;			-- Clock 0 output @ 48000000Hz ( Target: 48000000Hz, error: 0Hz )
    clk1_o : out std_ulogic;			-- Clock 1 output @ 38100000Hz ( Target: 38250000Hz, error: 150000Hz )
    clk2_o : out std_ulogic;			-- Clock 2 output @ 190500000Hz ( Target: 191250000Hz, error: 750000Hz )
    clk3_o : out std_ulogic;			-- Clock 3 output @ 0Hz ( Target: 0Hz, error: 0Hz )

    locked : out std_ulogic 			-- PLL locked
);	
    
end entity;
    
architecture a of clocks is        
    signal clk0 : std_ulogic := '0';
    signal clk1 : std_ulogic := '0';
    signal clk2 : std_ulogic := '0';
    signal clk3 : std_ulogic := '0';

    
begin     
    
    clk0 <= not clk0 after ( ((1 sec) / 48000000) / 2 );
    clk1 <= not clk1 after ( ((1 sec) / 38100000) / 2 );
    clk2 <= not clk2 after ( ((1 sec) / 190500000) / 2 );
       
    clk0_o <= clk0;
    clk1_o <= clk1;
    clk2_o <= clk2;
    clk3_o <= clk3;
     
end architecture;