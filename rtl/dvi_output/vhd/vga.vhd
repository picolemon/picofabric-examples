-- ###############################################################################
-- # [ vga - VGA timing generator ]
-- # =========================================================================== #
-- # :: Generated by the PicoFabric IDE Wizard -> ECP5 VGA Wizard               ::
-- # =========================================================================== #
-- # Generates valid VGA signal for use with VGA / DVI output.
-- ###############################################################################
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga is
    Port ( 
        resetn_i            : in std_logic;                         -- Reset ( active low )
        clk_pixel_i         : in std_logic;                         -- pixel clock
        vga_r_o             : out std_logic_vector( 7 downto 0 );   -- VGA output
        vga_g_o             : out std_logic_vector( 7 downto 0 );   -- VGA output
        vga_b_o             : out std_logic_vector( 7 downto 0 );   -- VGA output   
        hsync_o             : out std_logic;                        -- VGA sync signal
        vsync_o             : out std_logic;                        -- VGA sync signal
        blank_o             : out std_logic;                        -- VGA sync signal
        pixel_r_i           : in std_logic_vector( 7 downto 0 );    -- Input pixel for the current raster pos
        pixel_g_i           : in std_logic_vector( 7 downto 0 );    -- Input pixel for the current raster pos
        pixel_b_i           : in std_logic_vector( 7 downto 0 );    -- Input pixel for the current raster pos
        scanline_x_o        : out std_logic_vector(11 downto 0);    -- Raster scanline position
        scanline_y_o        : out std_logic_vector(11 downto 0)     -- Raster scanline position
    );
end vga;

architecture a of vga is    
    -- CVT parameters
    constant clock : natural := 38250000;
    constant clock5x : natural := 191250000;
    constant width : natural := 800;
    constant height : natural := 600;
    constant horizSyncStart : natural := 832;
    constant horizSyncEnd : natural := 912;
    constant horizTotal : natural := 1024;
    constant vertSyncStart : natural := 603;
    constant vertSyncEnd : natural := 607;
    constant vertTotal : natural := 624;

    signal scanline_x : std_logic_vector(11 downto 0);
    signal scanline_y : std_logic_vector(11 downto 0);
begin
    
    -- sync signals
    hsync_o <= '1' when (scanline_x >= horizSyncStart and scanline_x < horizSyncEnd) else '0';  
    vsync_o <= '1' when (scanline_y >= vertSyncStart and scanline_y < vertSyncEnd) else '0';

    vga_r_o <= pixel_r_i when scanline_x < width and scanline_y < height else (others=>'0');
    vga_g_o <= pixel_g_i when scanline_x < width and scanline_y < height else (others=>'0');
    vga_b_o <= pixel_b_i when scanline_x < width and scanline_y < height else (others=>'0');

    scanline_x_o <= scanline_x;
    scanline_y_o <= scanline_y;

    -- pixel gen
    process(clk_pixel_i)
    begin
        if rising_edge(clk_pixel_i)
        then           
            if resetn_i = '0' then
                scanline_x <= (others => '0');
                scanline_y <= (others => '0');
            else

                if scanline_x = horizTotal then
                    scanline_x <= (others => '0');

                    if scanline_y = vertTotal then                        
                        scanline_y <= (others => '0');
                    else
                        scanline_y <= scanline_y + 1; 
                    end if;
                else
                    scanline_x <= scanline_x + 1;
                end if;

                if scanline_x < width and scanline_y < height then                                
                    blank_o  <= '0';
                else
                    blank_o   <= '1';
                end if;
            end if;

        end if;
    end process;
end;