library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity reset is
port(
	-- Inputs
	clk_i              : in std_ulogic;     -- sytem clock
	resetn_o :          out std_ulogic        -- reset active-low
);	
	
end entity;
 
architecture a of reset is
	signal rst : std_logic := '0';    -- init reset for root devices
	signal init_rst : std_logic := '1';  -- main reset
	signal delay_init_rst : std_logic := '0';  -- main reset
begin     
	-- main reset
    process(clk_i) is	
    begin
        if rising_edge(clk_i) then
        
            -- set reset hi on first clock, initialized value set to 1
            if delay_init_rst = '1' then
                init_rst <= '0';                
                rst <= '1'; 	            
            end if;		
            
            delay_init_rst <= init_rst;
            	
        end if;
        
        resetn_o <= rst; 
        
    end process;
    
end architecture;