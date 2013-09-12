library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.VgaPack.all;

entity VgaTestPattern is
port (
	Clk    : in bit1;
	ARst_N : in bit1;
	--
	Button0 : in bit1;
	Button1 : in bit1;
	--		
	HSyncN : out bit1;
	VSyncN : out bit1;
	Red    : out bit1;
	Green  : out bit1;
	Blue   : out bit1
);
end entity VgaTestPattern;

architecture rtl of VgaTestPattern is
	signal PixelClk   : bit1;
	signal Rst_N      : bit1;
	signal ARst : bit1;
	--
	signal Red_N, Green_N, Blue_N : bit1;
	
	signal XCord : word(VgaHVideoW-1 downto 0);
	signal YCord : word(VgaVVideoW-1 downto 0);
begin

	RstSync : entity work.ResetSync
	port map (
		Clk      => Clk,
		AsyncRst => ARst_N,
		--
		Rst_N    => Rst_N
	);
	
	ARst <= not ARst_N;
	PixelClkPll0 : entity work.PixelClkPll
	port map (
		inclk0 => Clk,
		areset => ARst,
		c0     => PixelClk,
		Locked => open
	);

	--

--	TestPatternGen : entity work.VgaTestPatternGen
--	port map (
--		Clk => PixelClk,
--		Rst_N => Rst_N,
--		--
--		Red    => Red_N,
--	   Green  => Green_N,
--	   Blue   => Blue_N
--	);

	Ball : entity work.VgaBall
		port map (
			Clk    => PixelClk,
			Rst_N  => Rst_N,
			--
			Button0 => Button0,
			Button1 => Button1,
			--
			XCord  => Xcord,
			YCord  => Ycord,
			--
			Red    => Red_N,
			Green  => Green_N,
			Blue   => Blue_N
		);

	VgaGen : entity work.VgaGenerator
	port map (
		Clk      => PixelClk,
		Rst_N    => Rst_N,
		--
		Red      => Red_N,
		Green    => Green_N,
		Blue     => Blue_N,
		--
		XCord    => XCord,
		YCord    => YCord,
		--
		HSyncN   => HSyncN,
		VSyncN   => VSyncN,
		RedOut   => Red,
		GreenOut => Green,
		BlueOut  => Blue
	);
end architecture;		
		