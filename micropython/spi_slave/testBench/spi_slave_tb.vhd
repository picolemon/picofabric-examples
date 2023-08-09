library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity spi_slave_tb is
end;

architecture a of spi_slave_tb is
    constant f_clock_c               : natural := 48000000; 
    constant t_clock_c        : time := (1 sec) / f_clock_c;
    constant t_spi_delay_c        : time := (200 ns);

    -- external board clock
    signal clk_i : std_logic := '0';       
    signal resetn : std_logic := '1';

    signal spi_cs : std_logic;
    signal spi_clk : std_logic;
    signal spi_mosi : std_logic;
    signal spi_miso : std_logic;
    
    signal rx_busy : std_logic;
    signal rx_ready : std_logic;
    signal rx_data : std_ulogic_vector(7 downto 0);
    signal rx_byte_cnt : natural range 0 to 32-1;
    signal tx_data : std_ulogic_vector(7 downto 0); 
begin

    clk_i <= not clk_i after (t_clock_c/2);
 
    top_inst: entity work.spi_slave
    port map (
        clk_i => clk_i,
        resetn_i => resetn,
        spi_cs_i => spi_cs,
        spi_clk_i => spi_clk,
        spi_mosi_i => spi_mosi,
        spi_miso_o => spi_miso,
        rx_ready_o => rx_ready,
        rx_data_o => rx_data,
        rx_byte_cnt_o => rx_byte_cnt,
        tx_data_i => tx_data,
        rx_busy_o => rx_busy
    );

	test_runner : process
	begin
        -- reset device
        resetn <= '0';
        wait for 10 ns;
        resetn <= '1';
        wait for 10 ns;

        tx_data <= "00000000";
        spi_cs <= '1';
        spi_clk <= '1';
		wait for t_spi_delay_c;

        spi_cs <= '0';        

        -- bit 0
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';

        -- bit 1
        wait for t_spi_delay_c;
        spi_mosi <= '0';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';     

        -- ensure rx_busy_o, take a few bits to propergate
        if not rx_busy = '1' then
            report "Extected rx_busy_o == 1" severity error;
        end if;

        -- bit 2
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 3
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 4
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 5
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 6
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 7
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- wait for sync just after rising edge
        wait for t_clock_c;
        wait for t_clock_c;

        -- ensure rx_busy_o, take a few bits to propergate
        if not rx_ready = '1' then
            report "Extected rx_ready == 1" severity error;
        end if;        
        
        if not rx_data = "10111111" then
            report "Extected rx_data == BA" severity error;
        end if;                

        tx_data <= "10111110";


        -- bit 0
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';

        -- bit 1
        wait for t_spi_delay_c;
        if not spi_miso = '1' then -- bit[0] falling edge
            report "Extected spi_miso state" severity warning;
        end if;    

        spi_mosi <= '0';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';     

        -- bit 2
        wait for t_spi_delay_c;
        if not spi_miso = '0' then -- bit[1] falling edge
            report "Extected spi_miso state" severity warning;
        end if;    

        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 3
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 4
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 5
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 6
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';               

        -- bit 7
        wait for t_spi_delay_c;
        spi_mosi <= '1';
        spi_clk <= '0';
        wait for t_spi_delay_c;
        spi_clk <= '1';          

        -- final clock
        wait for t_spi_delay_c;
        spi_clk <= '0';        

        wait for t_spi_delay_c;
        spi_cs <= '1';

        -- end timeout
        wait for 100 ms;

	end process;
	
end;
