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
	
	constant PaddleLen   : positive := 40;
	constant PaddleDepth : positive := 4;
	
	constant XRes : positive := 640;
	constant YRes : positive := 480;
	
	constant Paddle0YPos : positive := 10;
	constant Paddle1YPos : positive := YRes - 10;
	
	signal Paddle0XPos_N, Paddle0XPos_D : word(bits(XRes)-1 downto 0);
	signal Paddle1XPos_N, Paddle1XPos_D : word(bits(XRes)-1 downto 0);
	
begin	
	Sampler : process (Clk, Rst_N)
	begin
		if Rst_N = '0' then
			SampleCnt_D <= (others => '0');
			BallPosX_D  <= (others => '0');
			BallPosY_D  <= (others => '0');
			Paddle0XPos_D <= conv_word(XRes / 2, Paddle0XPos_D'length);
			Paddle1XPos_D <= conv_word(XRes / 2, Paddle1XPos_D'length);
			
		elsif rising_edge(Clk) then
			SampleCnt_D <= SampleCnt_N;
			BallPosX_D  <= BallPosX_N;
			BallPosY_D  <= BallPosY_N;
			
			Paddle0XPos_D <= Paddle0XPos_N;
			Paddle1XPos_D <= Paddle1XPos_N;
		end if;
	end process;

	SampleAsync : process (SampleCnt_D, BallPosX_D, BallPosY_D, Button0, Button1, Paddle0XPos_D, Paddle1XPos_D)
	begin
		BallPosX_N <= BallPosX_D;
		BallPosY_N <= BallPosY_D;
		SampleCnt_N <= SampleCnt_D + 1;
		
		Paddle0XPos_N <= Paddle0XPos_D;
		Paddle1XPos_N <= Paddle1XPos_D;
		
		if (SampleCnt_D = 250000/2) then
			SampleCnt_N <= (others => '0');
		end if;

		-- Only sample once per second
		if RedOr(SampleCnt_D) = '0' then
			BallPosX_N <= BallPosX_D + 1;
			BallPosY_N <= BallPosY_D + 1;	
		
			if (Button0 = '0' and Button1 = '0') then
				null;
				
			elsif Button0 = '0' then
				Paddle0XPos_N <= Paddle0XPos_D + 1;
			
			elsif Button1 = '0' then
				Paddle0XPos_N <= Paddle0XPos_D - 1;
			end if;
		end if;
	end process;	

	DrawBall : process (XCord, YCord, BallPosX_D, BallPosY_D, Paddle0XPos_D, Paddle1XPos_D)
	begin
		Red   <= '0';
		Green <= '0';
		Blue  <= '0';
		
		if (XCord = BallPosX_D or XCord = BallPosX_D-1 or XCord = BallPosX_D+1) and
			(YCord = BallPosY_D or YCord = BallPosY_D-1 or YCord = BallPosY_D+1) then
			Red <= '1';	
		end if;
		
		if ((YCord > (Paddle0YPos - PaddleDepth / 2) and YCord < (Paddle0YPos + PaddleDepth / 2)) and (XCord > (Paddle0XPos_D - PaddleLen / 2) and XCord < (Paddle0XPos_D + PaddleLen / 2))) then
			Green <= '1';
		end if;
		
		if ((YCord > (Paddle1YPos - PaddleDepth / 2) and YCord < (Paddle1YPos + PaddleDepth / 2)) and (XCord > (Paddle1XPos_D - PaddleLen / 2) and XCord < (Paddle1XPos_D + PaddleLen / 2))) then
			Blue <= '1';
		end if;
	end process;
end architecture;
