-- ###############################################################################
-- # [ top test bench ]
-- # =========================================================================== #
-- # Tests SPI command dispatch by sending command and reading back response bit
-- # by bit.
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
    constant CMD_STATUS : std_ulogic_vector(7 downto 0) := x"01";
    constant CMD_WRITE_REG0 : std_ulogic_vector(7 downto 0) := x"02";
    constant CMD_READ_REG0 : std_ulogic_vector(7 downto 0) := x"03";

    constant f_clock_c               : natural := 48000000; 
    constant t_clock_c        : time := (1 sec) / f_clock_c;
    constant t_spi_delay_c        : time := (200 ns);

    signal clk_i : std_logic := '0';       
    signal resetn : std_logic := '1';

    signal spi_cs : std_logic;
    signal spi_clk : std_logic;
    signal spi_mosi : std_logic;
    signal spi_miso : std_logic;

    signal recieve_data_debug : std_ulogic_vector( 7 downto 0 );
begin

    clk_i <= not clk_i after (t_clock_c/2);
 
     
	-- command handler
    spi_echo_cmd_inst: entity work.spi_echo_cmd
    port map (
        clk_i => clk_i,
        resetn_i => resetn,
        spi_cs_i => spi_cs,
        spi_clk_i => spi_clk,
        spi_mosi_i => spi_mosi,
        spi_miso_o => spi_miso
    );

    -- main test runner
    test_runner : process
        variable send_data : std_ulogic_vector( 7 downto 0 );
	begin
        -- reset device
        resetn <= '0';
        wait for 10 ns;
        resetn <= '1';
        wait for 10 ns;

        -- init spi state
        spi_cs <= '1';
        spi_clk <= '0';
		wait for t_spi_delay_c;


        -- Run status command
        spi_cs <= '0';        
    
        -- byte[0] 
        send_data := CMD_STATUS; -- Status CMD
        for i in 0 to 7 loop
            spi_mosi <= send_data( 8-i-1 );            
            wait for t_spi_delay_c;
            spi_clk <= '1';
            wait for t_spi_delay_c;
            spi_clk <= '0';            
        end loop;
        
        -- byte[1] 
        send_data := "00000000"; -- dummy data
        for i in 0 to 7 loop
            spi_mosi <= send_data( 8-i-1 );            
            wait for t_spi_delay_c;
            spi_clk <= '1';
            wait for t_spi_delay_c;
            recieve_data_debug(8-i-1) <= spi_miso;
            spi_clk <= '0';            
        end loop;

        -- ensure status ( hard coded by ctrl )
        if not recieve_data_debug = "10000000" then
            report "Extected spi byte[1]" severity error;
        end if;

        -- desel
        wait for t_spi_delay_c;
        spi_cs <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
            

        -- Next command, write register over spi
        spi_cs <= '1';
        spi_clk <= '0';
		wait for t_spi_delay_c;

        spi_cs <= '0';        
        
        -- byte[0] 
        send_data := CMD_WRITE_REG0; -- Write CMD
        for i in 0 to 7 loop
            spi_mosi <= send_data( 8-i-1 );            
            wait for t_spi_delay_c;
            spi_clk <= '1';
            wait for t_spi_delay_c;
            spi_clk <= '0';            
        end loop;
        
        -- byte[1] 
        send_data := "01000001"; -- Reg0 payload
        for i in 0 to 7 loop
            spi_mosi <= send_data( 8-i-1 );            
            wait for t_spi_delay_c;
            spi_clk <= '1';
            wait for t_spi_delay_c;
            recieve_data_debug(8-i-1) <= spi_miso;
            spi_clk <= '0';            
        end loop;

        -- ensure status ( hard coded by ctrl )
        if not recieve_data_debug = "00000000" then
            report "Extected spi byte[1]" severity error;
        end if;


        spi_cs <= '1';
        spi_clk <= '0';
		wait for t_spi_delay_c;


        -- Read back register and verify value matches written
        spi_cs <= '0';        
        
        -- byte[0] 
        send_data := CMD_READ_REG0; -- WrReadite CMD
        for i in 0 to 7 loop
            spi_mosi <= send_data( 8-i-1 );            
            wait for t_spi_delay_c;
            spi_clk <= '1';
            wait for t_spi_delay_c;
            spi_clk <= '0';            
        end loop;
        
        -- byte[1] 
        send_data := "00000000"; -- dummy
        for i in 0 to 7 loop
            spi_mosi <= send_data( 8-i-1 );            
            wait for t_spi_delay_c;
            spi_clk <= '1';
            wait for t_spi_delay_c;
            recieve_data_debug(8-i-1) <= spi_miso;
            spi_clk <= '0';            
        end loop;

        -- ensure status
        if not recieve_data_debug = "01000001" then
            report "Extected spi byte[1] payload match prev written reg0" severity error;
        end if;

        wait for t_spi_delay_c;
        recieve_data_debug <= "00000000";

        spi_cs <= '1';
        spi_clk <= '0';
		wait for t_spi_delay_c;


        -- end timeout
        wait for 100 ms;

	end process;
	
end;
