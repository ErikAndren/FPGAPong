library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.VgaPack.all;

entity VgaTestPattern is
port (
	Clk   : in bit1;
	ARst_N : in bit1;
	--		
	HSyncN : out bit1;
	VSyncN : out bit1;
	Red    : out bit1;
	Green  : out bit1;
	Blue   : out bit1
);
end entity VgaTestPattern;

architecture rtl of VgaTestPattern is
	signal PixelClk : bit1;
	signal Rst_N    : bit1;
begin
	RstSync : entity work.ResetSync
	port map (
		Clk      => Clk,
		AsyncRst => ARst_N,
		--
		Rst_N    => Rst_N
	);
	
	PixelClkPll0 : entity work.PixelClkPll
	port map (
		inclk0 => Clk,
		areset => ARst_N,
		c0     => PixelClk,
		Locked => open
	);
	
	
end architecture;		
		