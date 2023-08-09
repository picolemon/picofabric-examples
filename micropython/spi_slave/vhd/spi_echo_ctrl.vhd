-- ###############################################################################
-- # [ spi_echo_ctrl - SPI Slave command dispatcher ]
-- # =========================================================================== #
-- # Reads commands from an SPI master and dispatches command eg. read a status or
-- # read/write a register value.
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
use std.textio.all;

entity spi_echo_cmd is  
port(
	clk_i : in std_logic;
  resetn_i : in std_logic;
	-- SPI interface
	spi_cs_i : in std_logic;                          -- SPI chip select
	spi_clk_i : in std_logic;                         -- SPI clock in
	spi_mosi_i : in std_logic;                        -- SPI Slave input
	spi_miso_o : out std_logic                        -- SPI Slave output  	
);	
end entity;
 
architecture a of spi_echo_cmd is  
    -- spi commands
    constant CMD_STATUS : std_ulogic_vector(7 downto 0) := x"01";
    constant CMD_WRITE_REG0 : std_ulogic_vector(7 downto 0) := x"02";
    constant CMD_READ_REG0 : std_ulogic_vector(7 downto 0) := x"03";

    signal rx_busy : std_logic;
    signal rx_ready : std_logic;
    signal rx_data : std_ulogic_vector(7 downto 0);
    signal rx_byte_cnt : natural range 0 to 32-1;
    signal tx_data : std_ulogic_vector(7 downto 0); 
    signal tx_data_wr : std_logic;

    signal curr_cmd : std_ulogic_vector(7 downto 0); 
    signal reg0_data : std_ulogic_vector(7 downto 0);  -- write cmd data

    -- convert 4bits to hex char
    function internal_to_hexchar( bits : std_ulogic_vector(3 downto 0) ) return character is
      variable result : character;  
    begin
      case bits is
        when x"0"   => result := '0';
        when x"1"   => result := '1';
        when x"2"   => result := '2';
        when x"3"   => result := '3';
        when x"4"   => result := '4';
        when x"5"   => result := '5';
        when x"6"   => result := '6';
        when x"7"   => result := '7';
        when x"8"   => result := '8';
        when x"9"   => result := '9';
        when x"a"   => result := 'a';
        when x"b"   => result := 'b';
        when x"c"   => result := 'c';
        when x"d"   => result := 'd';
        when x"e"   => result := 'e';
        when x"f"   => result := 'f';
        when others => result := 'X';
      end case;
      return result;    
    end function;

    -- Convert vec to string
    function to_hexstr( vec : std_ulogic_vector( 7 downto 0 ) ) return string is
      variable result : string(1 to 2);
    begin
        result( 1 ) := internal_to_hexchar( vec( 7 downto 4 ) );
        result( 2 ) := internal_to_hexchar( vec( 3 downto 0 ) );
        return result;
    end function;

begin  

	-- spi serializer
    top_inst: entity work.spi_slave
    port map (
        clk_i => clk_i,
        resetn_i => resetn_i,
        spi_cs_i => spi_cs_i,
        spi_clk_i => spi_clk_i,
        spi_mosi_i => spi_mosi_i,
        spi_miso_o => spi_miso_o,
        rx_ready_o => rx_ready,
        rx_data_o => rx_data,
        rx_byte_cnt_o => rx_byte_cnt,
        tx_data_i => tx_data,
        tx_data_wr_i => tx_data_wr,
        rx_busy_o => rx_busy
    );


    -- command dispatch process
    spi_cmd_main_proc : process(clk_i)
    begin
        if rising_edge(clk_i) then
			      if resetn_i = '0' then	    			
                tx_data_wr <= '0';

            else

                tx_data <= "00000000";
                tx_data_wr <= '0';

                -- detect rx trigger
                if rx_ready = '1' then
                    case rx_byte_cnt is                        
                        when 1 =>          

                            -- capture cmd
                            curr_cmd <= rx_data;

                            -- dispatch cmd
                            case rx_data is
                                when CMD_STATUS =>  -- [CMD] Status
                                    report "[spi_cmd_main_proc][Byte 0] CMD Status";
                                    tx_data <= "10000000"; -- Set status bit
                                    tx_data_wr <= '1';

                                when CMD_WRITE_REG0 => -- [CMD] Write
                                    report "[spi_cmd_main_proc][Byte 0] CMD Write";
                                    tx_data <= "00000000"; 
                                    tx_data_wr <= '1';

                                when CMD_READ_REG0 => -- [CMD] Read
                                    report "[spi_cmd_main_proc][Byte 0] CMD Read";
                                    tx_data <= reg0_data;
                                    tx_data_wr <= '1';
                                    
                                when others =>
                                    -- invalid cmd
                                    report "[spi_cmd_main_proc][Byte 0] Invalid cmd " & to_hexstr( rx_data);
                                    tx_data <= "11111111"; -- Invalid
                                    tx_data_wr <= '1';

                            end case; -- cmd 
                            
                    when others =>
                        case curr_cmd is
                            when CMD_STATUS =>  -- [CMD] Status
                                -- ignore

                            when CMD_WRITE_REG0 => -- [CMD] Write
                                report "[spi_cmd_main_proc][Byte 2+] Save reg0 " & to_hexstr( rx_data);
                                reg0_data <= rx_data;

                            when CMD_READ_REG0 => -- [CMD] Read
                                -- ignore

                            when others =>
                                report "[spi_cmd_main_proc][Byte 2>=+] Invalid cmd " & to_hexstr( rx_data);
                                -- ignore
                        end case;

                    end case;
                end if;

            end if;
      end if;    
    end process;
    

end architecture;
