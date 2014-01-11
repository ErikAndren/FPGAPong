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
	Button0      : in bit1;
	Button1      : in bit1;
	Button2      : in bit1;
	Button3      : in bit1;
	--
	Player0PadLeft  : in bit1;
	Player0PadRight : in bit1;
	--
	Led0         : out bit1;
	Led1         : out bit1;
	Led2         : out bit1;
	Led3         : out bit1;
	--
	Buzz         : out bit1;
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
	--
	signal Red_N, Green_N, Blue_N : bit1;
	
	signal XCord : word(10-1 downto 0);
	signal YCord : word(10-1 downto 0);

	signal Rand : word(16-1 downto 0);
begin
	Led0 <= Button0;
	Led1 <= Button1;
	Led2 <= Button2;
	Led3 <= Button3;

	RstSync : entity work.ResetSync
	port map (
		Clk      => PixelClk,
		AsyncRst => ARst_N,
		--
		Rst_N    => Rst_N
	);

	ClkDiv : process (Clk)
	begin
		if rising_edge(Clk) then
			PixelClk <= not PixelClk;
		end if;
	end process;

	--
	
	Randomizer : entity work.LFSR
	port map (
		Clk		=> PixelClk,                 
		RstN	   => Rst_N,                    
		LFSR_Out => Rand
	);
	
	Ball : entity work.VgaBall
		port map (
			Clk    => PixelClk,
			Rst_N  => Rst_N,
			--
			Rand => Rand,
			--
			Player0Right => Button0,
			Player0Left  => Button1,
			Player1Right => Button2,
			Player1Left  => Button3,
			--
			Buzz   => Buzz,
			--
			XCord  => Xcord,
			YCord  => Ycord(9-1 downto 0),
			--
			Red    => Red_N,
			Green  => Green_N,
			Blue   => Blue_N
		);

--	VgaGen : entity work.VgaGenerator
--	port map (
--		Clk      => PixelClk,
--		Rst_N    => Rst_N,
--		--
--		Red      => Red_N,
--		Green    => Green_N,
--		Blue     => Blue_N,
--		--
--		XCord    => XCord,
--		YCord    => YCord,
--		--
--		HSyncN   => HSyncN,
--		VSyncN   => VSyncN,
--		RedOut   => Red,
--		GreenOut => Green,
--		BlueOut  => Blue
--	);

	VgaGen : entity work.VGAVHDL
	port map (
		Clk => PixelClk,
		--
		Red      => Red_N,
		Green    => Green_N,
		Blue     => Blue_N,
		--
		XCord    => XCord,
		YCord    => YCord,
		--
		HSync    => HSyncN,
		VSync    => VSyncN,
		RedOut   => Red,
		GreenOut => Green,
		BlueOut  => Blue
	);
	
end architecture;		
		