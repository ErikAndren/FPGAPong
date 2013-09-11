library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.VgaPack.all;

entity VgaTestPatternGen is
port (
	Clk    : in bit1;
	Rst_N  : in bit1;
	--
	Red    : out bit1;
	Green  : out bit1;
	Blue   : out bit1
);
end entity;

architecture rtl of VgaTestPatternGen is
	signal Tick_N, Tick_D : word2;
begin

	Tick_N <= Tick_D + 1;

	process (Clk, Rst_N)
	begin
		if Rst_N = '0' then	
			
			Tick_D <= (others => '0');
		elsif rising_edge(Clk) then
			Tick_D <= Tick_N;
		
		end if;
	end process;

	Red   <= '1' when Tick_D = "00" else '0';
	Green <= '1' when Tick_D = "00" else '0';
	Blue  <= '1' when Tick_D = "00" else '0';
	

end architecture;
