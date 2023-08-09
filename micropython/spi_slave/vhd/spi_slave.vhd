-- ###############################################################################
-- # [ spi_slave - SPI Slave serializer ]
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

entity spi_slave is
generic(
  BITS : integer := 8;  -- send recieve byte size
  POLARITY : std_logic := '0' 
  ); 
port (
  clk_i : in std_logic;                             -- Main interface clock
  resetn_i : in std_logic;                          -- Reset active low
  -- SPI interface
  spi_cs_i : in std_logic;                          -- SPI chip select
  spi_clk_i : in std_logic;                         -- SPI clock in
  spi_mosi_i : in std_logic;                        -- SPI Slave input
  spi_miso_o : out std_logic;                       -- SPI Slave output  
  -- Ctrl interface
  rx_data_o : out std_ulogic_vector(BITS-1 downto 0);--current spi byte out  
  rx_ready_o : out std_logic;                       -- Recieved byte strobe
  rx_byte_cnt_o : out natural range 0 to 32-1 := 0; -- Recieve byte index
  tx_data_i : in std_ulogic_vector(BITS-1 downto 0);-- Next spi transmission byte for rx_byte_cnt_o
  tx_data_wr_i : in std_logic;                      -- Write next tx data
  rx_busy_o : out std_logic                         -- SPI transaction busy
);
end spi_slave;

architecture a of spi_slave is
  signal transaction_active : std_logic := '0';
  signal bit_count : natural range 0 to 8-1 := 0;
  signal rx_got_byte : std_logic;

  signal rx_byte_cnt : natural range 0 to 32-1;
  signal rx_ready_buff2 : std_logic;
  signal rx_ready_buff3 : std_logic;

  signal rx_data : std_ulogic_vector(BITS-1 downto 0);
  signal rx_data_buff : std_ulogic_vector(BITS-1 downto 0); 
  signal tx_data : std_ulogic_vector(BITS-1 downto 0); 

  signal latch_data : std_ulogic_vector(BITS-1 downto 0) := (others=>'0'); 

  signal sample_tx_data_next : std_logic := '0';
begin

  -- Interface buffer process
  iface_proc : process(clk_i)
  begin
		if rising_edge(clk_i) then
			if resetn_i = '0' then				
				rx_ready_o <= '0';
        rx_ready_buff2 <= '0';
        rx_ready_buff3 <= '0';
        rx_byte_cnt_o <= 0;
        rx_byte_cnt <= 0;        

			else

        -- capture next byte after rx strobe, app responds by setting next byte
        if tx_data_wr_i = '1' then
          latch_data <= tx_data_i;
        end if;

        -- [cross clock] Buffer ready from SPI domain
        rx_ready_buff2 <= rx_got_byte;
        rx_ready_buff3 <= rx_ready_buff2;

        -- Latch rx buffer from the SPI domain and strobe on edge
        if rx_ready_buff3 = '0' and rx_ready_buff2 = '1' then
          rx_ready_o <= '1';  -- strobe read data valid
          rx_data_o <= rx_data_buff;      
          rx_byte_cnt <= rx_byte_cnt + 1;
          rx_byte_cnt_o <= rx_byte_cnt + 1;   
        else      
          rx_ready_o <= '0';
        end if;

        -- reset byte counter when SPI deselected
        -- [cross clock] reset on cs low, 1 spi clock between re-activation of rx_got_byte
        if spi_cs_i = '1' then
          rx_byte_cnt_o <= 0;
          rx_byte_cnt <= 0;  
        end if;

      end if;
    end if;    
  end process;


  -- Spi input process
  main_input_proc : process(spi_clk_i)
  begin
    if( spi_clk_i = not POLARITY and spi_clk_i'event ) then -- Clock edge sample on rising edge if POLARITY == 0
      if spi_cs_i = '0' then
        rx_data <= rx_data( BITS-2 downto 0 ) & spi_mosi_i; -- sample mosi and shift

        if bit_count = 7 then          
          rx_data_buff <= rx_data( BITS-2 downto 0 ) & spi_mosi_i; -- sample final
        end if;

      end if;
    end if;
  end process;


  -- SPI output and main logic
  main_output_proc : process(spi_cs_i,  spi_clk_i)
  begin

    -- deselect
    if spi_cs_i = '1' then

      rx_got_byte <= '0';
      transaction_active <= '0'; -- Disable sending & transction      

    elsif( spi_clk_i = not POLARITY and spi_clk_i'event ) then -- Clock edge sample on rising edge if POLARITY == 0

      if bit_count = 0 then -- first bit, activate 

        -- copy minus first bit
        tx_data <= latch_data(BITS-2 downto 0) & '0';

        -- output first
        spi_miso_o <= latch_data(BITS-1);

      else
        
        -- shift
        tx_data <= tx_data(BITS-2 downto 0) & '0';

        -- output
        spi_miso_o <= tx_data(BITS-1);

      end if;

      -- activate on clock
      transaction_active <= '1';

      -- inc bit count ( wraps )
      rx_got_byte <= '0';
      if bit_count = 7 then
        bit_count <= 0;
        rx_got_byte <= '1';        
      else
        bit_count <= bit_count + 1;        
      end if;

    end if;

  end process;

  rx_busy_o <= transaction_active;

end architecture;

