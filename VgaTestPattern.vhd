library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;

entity VgaTestPattern is
port (
	Clk   : in bit1;
	Rst_N : in bit1;
	--		
	HSyncN : out bit1;
	VSyncN : out bit1;
	Red    : out bit1;
	Green  : out bit1;
	Blue   : out bit1
);
end entity VgaTestPattern;

architecture rtl of VgaTestPattern is
begin

end architecture;		
		