library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is  
port(
	clk_48mhz : in std_logic;
	led0 : out std_logic;
	dvi_p : out std_logic_vector(3 downto 0)
);	
end entity;
 
architecture a of top is  
	  
    constant width : natural := 800;
    constant height : natural := 600;
	
	-- clocks and reset
	signal all_clocks: std_logic_vector(3 downto 0);	
	signal led_buff : std_logic;
	signal clockDelay : natural := 0;
	signal clk3_unused : std_logic;
	signal resetn : std_logic;	
	signal sys_clk : std_logic;

	-- video signals
	signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);
	signal clk_pixel, clk_shift: std_logic;
	signal vga_hsync, vga_vsync, vga_blank : std_logic;
	signal vga_r, vga_g, vga_b: std_logic_vector(7 downto 0);	
	

	-- video state
	signal pixel_r : std_logic_vector( 7 downto 0 );  
	signal pixel_g : std_logic_vector( 7 downto 0 );
	signal pixel_b  : std_logic_vector( 7 downto 0 );        
	signal scanline_x : std_logic_vector(11 downto 0);  
	signal scanline_y : std_logic_vector(11 downto 0);        

	-- pingy/pong box
	signal draw_box_pos_x : integer := 0;
	signal draw_box_pos_y : integer  := 0;
	signal draw_box_vel_x : integer  := 10;
	signal draw_box_vel_y : integer  := 10;
	signal draw_box_size_x : integer  := 100;
	signal draw_box_size_y : integer  := 100;
	signal enable_box_move : std_logic := '1';
	signal box_delay : integer := 0;

	-- declare clocks
	component clocks
		port(	
			clk_i : in std_logic;
			clk0_o : out std_logic;
			clk1_o : out std_logic;
			clk2_o : out std_logic;
			clk3_o : out std_logic
		);
	end component;
	
	-- declare DDR
	component ODDRX1F
		port (D0, D1, SCLK, RST: in std_logic; Q: out std_logic);
	end component;
begin  

	-- led
	led0 <= led_buff;	

	--dvi_p(0) <=  '0';
	--dvi_p(1) <=  '0';
	--dvi_p(2) <=  '0';
	--dvi_p(3) <=  '0';

	-- clocks
    clkgen2_inst: clocks    
    port map
    (
      clk_i => clk_48mhz,
      clk0_o => sys_clk,
	  clk1_o => clk_pixel,
	  clk2_o => clk_shift,
	  clk3_o => clk3_unused
    );

	-- reset
    reset_inst: entity work.reset    
    port map
    (
      clk_i => clk_48mhz,
      resetn_o => resetn
    );

	-- main
	process (clk_pixel)
	begin		
		if rising_edge(clk_pixel) then
		
			-- led blinky
			clockDelay <= clockDelay + 1;				
			if clockDelay > 12000000 then
				clockDelay <= 0;	
				led_buff <= not led_buff;
			end if;

			-- draw quads
			pixel_r   <= (others => '1');
			pixel_g   <= (others => '0');
			pixel_b   <= (others => '0');   			
			if scanline_x < width/2 then
				pixel_r   <= (others => '0');
				pixel_g   <= (others => '1');
				pixel_b   <= (others => '0');                        
			end if;
			if scanline_y < height / 2 then                        
				pixel_b   <= (others => '1');                        
			end if;                     

			-- overlay moving box
			if to_integer(unsigned(scanline_x)) >= draw_box_pos_x and to_integer(unsigned(scanline_x)) <= draw_box_pos_x + draw_box_size_x
				and to_integer(unsigned(scanline_y)) >= draw_box_pos_y and to_integer(unsigned(scanline_y)) <= draw_box_pos_y + draw_box_size_y then			
				pixel_r <= (others => '1');
				pixel_g <= (others => '1');
				pixel_b <= (others => '1');  				
			end if;

			-- move box on every frame eg. 60 fps, bounce when hitting corners
			if scanline_x = 0 and scanline_y = 0 then

				if box_delay = 0 then
		
					draw_box_pos_x <= draw_box_pos_x + draw_box_vel_x;
					draw_box_pos_y <= draw_box_pos_y + draw_box_vel_y;

					if draw_box_pos_x < 0 then
						draw_box_vel_x <= 10;
					elsif draw_box_pos_x > width-draw_box_size_x then
						draw_box_vel_x <= -10;					
					end if;

					if draw_box_pos_y < 0 then
						draw_box_vel_y <=10;
					elsif draw_box_pos_y > height-draw_box_size_y then
						draw_box_vel_y <= -10;					
					end if;
				
				else
					box_delay <= box_delay - 1;
				end if;
			end if;
		end if;
	end process;

	-- vga sync generator
    new_vga_inst: entity work.vga    
    port map
    (
        resetn_i  => resetn,
        clk_pixel_i => clk_pixel,
        vga_r_o => vga_r,
        vga_g_o => vga_g,
        vga_b_o => vga_b,
		hsync_o  => vga_hsync,
		vsync_o  => vga_vsync,
		blank_o  => vga_blank,
		pixel_r_i => pixel_r,
        pixel_g_i => pixel_g,
        pixel_b_i => pixel_b,
        scanline_x_o => scanline_x,
        scanline_y_o => scanline_y			
    );

	-- vga to dvi converter
	dvid_inst: entity work.vga2dvid
	generic map
	(
		c_shift_clock_synchronizer => '0',
		c_ddr => '1'
	)
	port map
	(
		clk_pixel => clk_pixel,
		clk_shift => clk_shift,
		in_red    => vga_r,
		in_green  => vga_g,
		in_blue   => vga_b,
		in_hsync  => vga_hsync,
		in_vsync  => vga_vsync,
		in_blank  => vga_blank,

		out_red   => dvid_red,
		out_green => dvid_green,
		out_blue  => dvid_blue,
		out_clock => dvid_clock
	);

	-- DDR output	
	ddr_red: ODDRX1F port map( D0=>dvid_red(0),   D1=>dvid_red(1),   Q=>dvi_p(2), SCLK=>clk_shift, RST=>'0' );
	ddr_green: ODDRX1F port map( D0=>dvid_green(0), D1=>dvid_green(1), Q=>dvi_p(1), SCLK=>clk_shift, RST=>'0' );
	ddr_blue: ODDRX1F port map( D0=>dvid_blue(0),  D1=>dvid_blue(1),  Q=>dvi_p(0), SCLK=>clk_shift, RST=>'0' );
	ddr_clock: ODDRX1F port map( D0=>dvid_clock(0), D1=>dvid_clock(1), Q=>dvi_p(3), SCLK=>clk_shift, RST=>'0' );


end architecture;
