library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.VgaPack.all;

entity VgaBall is
port (
	Clk    : in bit1;
	Rst_N  : in bit1;
	--
	XCord  : in word(VgaHVideoW-1 downto 0);		
	YCord  : in word(VgaVVideoW-1 downto 0);
	--
	Red    : out bit1;
	Green  : out bit1;
	Blue   : out bit1
);
end entity;

architecture rtl of VgaBall is
begin	
	DrawBall : process (XCord, YCord)
	begin
		Red   <= '0';
		Green <= '0';
		Blue  <= '0';
		
		if (XCord >= 0 and XCord < 4 and 
		    YCord >= 0 and YCord < 4) then
			Red <= '1';	
		end if;
		
		-- Draw border
		-- Line begins at 7
		if (XCord = 0 or XCord = 639 or
			 YCord = 0 or YCord = 479) then
			Green <= '1';
		end if;
	end process;
end architecture;
