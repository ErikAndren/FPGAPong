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
	Button0 : in bit1;
	Button1 : in bit1;
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
	signal SampleCnt_N, SampleCnt_D : word(bits(25000000)-1 downto 0);
	signal BallPosX_D, BallPosX_N : word(VgaHVideoW-1 downto 0);
	signal BallPosY_D, BallPosY_N : word(VgaVVideoW-1 downto 0);
begin	
	

	Sampler : process (Clk, Rst_N)
	begin
		if Rst_N = '0' then
			SampleCnt_D <= (others => '0');
			BallPosX_D  <= (others => '0');
			BallPosY_D  <= (others => '0');
		elsif rising_edge(Clk) then
			SampleCnt_D <= SampleCnt_N;
			BallPosX_D <= BallPosX_N;
			BallPosY_D <= BallPosY_N;
		end if;
	end process;

	SampleAsync : process (SampleCnt_D, BallPosX_D, BallPosY_D, Button0, Button1)
	begin
		BallPosX_N <= BallPosX_D;
		BallPosY_N <= BallPosY_D;
		SampleCnt_N <= SampleCnt_D + 1;
		
		if (SampleCnt_D = 2500000/2) then
			SampleCnt_N <= (others => '0');
		end if;
		-- Only sample once per second
		if RedOr(SampleCnt_D) = '0' then
			if Button0 = '0' then
				BallPosX_N <= BallPosX_D + 1;
				if BallPosX_D = VgaHVideo then
					BallPosX_N <= (others => '0');
				end if;
			end if;
			
			if Button1 = '0' then
				BallPosY_N <= BallPosY_D + 1;
				if BallPosY_D = VgaVVideo then
					BallPosY_N <= (others => '0');
				end if;
			end if;
		end if;
	end process;	

	DrawBall : process (XCord, YCord, BallPosX_D, BallPosY_D)
	begin
		Red   <= '0';
		Green <= '0';
		Blue  <= '0';
		
		if (XCord = BallPosX_D or XCord = BallPosX_D-1 or XCord = BallPosX_D+1) and
			(YCord = BallPosY_D or YCord = BallPosY_D-1 or YCord = BallPosY_D+1) then
			Red <= '1';	
		end if;
		
		-- Draw border
		if (XCord = 0 or XCord = 639 or
			 YCord = 0 or YCord = 479) then
			Green <= '1';
		end if;
	end process;
end architecture;
