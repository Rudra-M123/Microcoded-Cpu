library ieee; use ieee.std_logic_1164.all;
library lpm; use lpm.lpm_components.all;

entity lab7_useq is
	generic (uROM_width: integer := 25;
		uROM_file: string := "");
	port (opcode: in std_logic_vector(3 downto 0);
		uop: out std_logic_vector(1 to (uROM_width-9));
		debug_map_addr: out std_logic_vector(8 downto 0); -- for debugging
		enable, clear: in std_logic;
		clock: in std_logic);
end lab7_useq;

architecture structural of lab7_useq is	
	signal uROM_address: std_logic_vector (7 downto 0);
	signal uROM_out: std_logic_vector (uROM_width-1 downto 0);
	signal uPC_mux_data: std_logic_2D(1 downto 0, 7 downto 0);
	signal uPC_mux_sel: std_logic_vector(0 to 0);
	signal uPC_mux_out: std_logic_vector(7 downto 0);
	signal temp: std_logic_vector(7 downto 0);
begin
	temp <= opcode & "0000";

	for_label: for i in 0 to 7 generate
		uPC_mux_data(0, i) <= uROM_out(i);
		uPC_mux_data(1, i) <= temp(i);
	end generate;
	
	uPC_mux_sel(0) <= uROM_out(8);
	uPC_mux: lpm_mux
		generic map (lpm_width=>8, lpm_size=>2, lpm_widths=>1)
		port map (result=>uPC_mux_out, data=>uPC_mux_data, sel=>uPC_mux_sel);
	
	uPC: lpm_ff
		generic map (lpm_width=>8)
		port map (clock=>clock, data=>uPC_mux_out, q=>uROM_address,
			sclr=>clear, enable=>enable);
	
	uROM: lpm_rom
		generic map (lpm_widthad=>8, lpm_width=>uROM_width,
			lpm_file=>uROM_file)
		port map (address=>uROM_address, q=>uROM_out, inclock=>clock,
			outclock=>clock);

	uop <= uROM_out(uROM_width-1 downto 9);
	debug_map_addr <= uROM_out(8 downto 0);
end structural;
