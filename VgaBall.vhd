library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.Types.all;
use work.VgaPack.all;
use work.CharPack.all;

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
	
	constant PaddleWidth   : positive := 40;
	constant PaddleDepth   : positive := 4;
	
	constant XRes : positive := 640;
	constant YRes : positive := 480;
	
	constant Paddle0YPos : positive := 10;
	constant Paddle1YPos : positive := YRes - 10;
	
	signal Paddle0XPos_N, Paddle0XPos_D : word(bits(XRes)-1 downto 0);
	signal Paddle1XPos_N, Paddle1XPos_D : word(bits(XRes)-1 downto 0);
	
	signal BallXDir_N, BallXDir_D : word(2-1 downto 0);
	signal BallYDir_N, BallYDir_D : word(2-1 downto 0);
	
	signal Player0Score_N, Player0Score_D : word(4-1 downto 0);
	signal Player1Score_N, Player1Score_D : word(4-1 downto 0);
	
	constant ScoreBoard0XOffs : natural := 4;
	constant ScoreBoard0YOffs : natural := YRes / 2 - 16;

	constant ScoreBoard1XOffs : natural := 4;
	constant ScoreBoard1YOffs : natural := YRes / 2 + 9;
	
begin	
	Sampler : process (Clk, Rst_N)
	begin
		if Rst_N = '0' then
			SampleCnt_D   <= (others => '0');
			BallPosX_D    <= conv_word(XRes / 2, BallPosX_D'length);
			BallPosY_D    <= conv_word(YRes / 2, BallPosY_D'length);
			Paddle0XPos_D <= conv_word(XRes / 2, Paddle0XPos_D'length);
			Paddle1XPos_D <= conv_word(XRes / 2, Paddle1XPos_D'length);
			BallXDir_D    <= (others => '0');
			BallYDir_D    <= "10";
			Player0Score_D <= (others => '0');
			Player1Score_D <= (others => '0');
			
		elsif rising_edge(Clk) then
			SampleCnt_D <= SampleCnt_N;
			BallPosX_D  <= BallPosX_N;
			BallPosY_D  <= BallPosY_N;
			--
			BallXDir_D <= BallXDir_N;
			BallYDir_D <= BallYDir_N;
			--
			Paddle0XPos_D <= Paddle0XPos_N;
			Paddle1XPos_D <= Paddle1XPos_N;
			--
			Player0Score_D <= Player0Score_N;
			Player1Score_D <= Player1Score_N;
			--
		end if;
	end process;

	SampleAsync : process (SampleCnt_D, BallPosX_D, BallPosY_D, Button0, Button1, Paddle0XPos_D, Paddle1XPos_D, BallXDir_D, BallYDir_D,
								  Player0Score_D, Player1Score_D
								)
	begin
		BallPosX_N <= BallPosX_D;
		BallPosY_N <= BallPosY_D;
		SampleCnt_N <= SampleCnt_D + 1;
		BallXDir_N <= BallXDir_D;
		BallYDir_N <= BallYDir_D;
		Player0Score_N <= Player0Score_D;
		Player1Score_N <= Player1Score_D;
		
		Paddle0XPos_N <= Paddle0XPos_D;
		Paddle1XPos_N <= Paddle1XPos_D;
		
		if (SampleCnt_D = 250000/2) then
			SampleCnt_N <= (others => '0');
		end if;

		-- Only sample once per second
		if RedOr(SampleCnt_D) = '0' then
			if (BallYDir_D = "10") then
				BallPosY_N <= BallPosY_D - 1;
			elsif (BallYDir_D = "01") then
				BallPosY_N <= BallPosY_D + 1;
			end if;
			
			if (BallXDir_D = "10") then
				BallPosX_N <= BallPosX_D - 1;
			elsif (BallXDir_D = "01") then
				BallPosX_N <= BallPosX_D + 1;
			end if;
			
			if (BallPosY_D = Paddle0YPos and BallPosX_D > Paddle0XPos_D - PaddleWidth / 2 and BallPosX_D < Paddle0XPos_D + PaddleWidth / 2) then
				BallYDir_N <= "01";
			elsif (BallPosY_D = Paddle1YPos and BallPosX_D > Paddle1XPos_D - PaddleDepth / 2 and BallPosX_D < Paddle1XPos_D + PaddleWidth / 2) then
				BallYDir_N <= "10";
			end if;
			
			-- Score for player 1
			if (BallPosY_D = 0) then
				Player1Score_N <= Player1Score_D + 1;
				
				-- Reset state, give ball to losing player
				BallPosX_N <= conv_word(XRes / 2, BallPosX_N'length);
				BallPosY_N <= conv_word(YRes-20 / 2, BallPosY_N'length);
				BallXDir_N <= "00";
				BallYDir_N <= "10";	
			end if;
			
			-- Score for player 0
			if (BallPosY_D = YRes-1) then
				Player0Score_N <= Player0Score_D + 1;
				
				-- Reset state, give ball to losing player
				BallPosX_N <= conv_word(XRes / 2, BallPosX_N'length);
				BallPosY_N <= conv_word(20, BallPosY_N'length);
				--
				BallXDir_N <= "00";
				BallYDir_N <= "01";	
			end if;

			if (Button0 = '0' and Button1 = '0') then
				null;
				
			elsif Button0 = '0' then
				if (Paddle0XPos_D < XRes-PaddleWidth / 2) then
					Paddle0XPos_N <= Paddle0XPos_D + 1;
				end if;
			
			elsif Button1 = '0' then
				if (Paddle0XPos_D > PaddleWidth / 2) then
					Paddle0XPos_N <= Paddle0XPos_D - 1;
				end if;
			end if;
		end if;
	end process;	

	DrawBall : process (XCord, YCord, BallPosX_D, BallPosY_D, Paddle0XPos_D, Paddle1XPos_D, Player0Score_D, Player1Score_D)
	begin
		Red   <= '0';
		Green <= '0';
		Blue  <= '0';
		
		if (XCord = BallPosX_D or XCord = BallPosX_D-1 or XCord = BallPosX_D+1) and
			(YCord = BallPosY_D or YCord = BallPosY_D-1 or YCord = BallPosY_D+1) then
			Red <= '1';	
		end if;
		
		if (YCord = (YRes / 2) and Modulo(XCord, 8) < 4) then
			Green <= '1';
			Blue  <= '1';
			Red   <= '1';
		end if;
		
		if ((YCord > (Paddle0YPos - PaddleDepth / 2) and YCord < (Paddle0YPos + PaddleDepth / 2)) and (XCord > (Paddle0XPos_D - PaddleWidth / 2) and XCord < (Paddle0XPos_D + PaddleWidth / 2))) then
			Green <= '1';
		end if;
		
		if ((YCord > (Paddle1YPos - PaddleDepth / 2) and YCord < (Paddle1YPos + PaddleDepth / 2)) and (XCord > (Paddle1XPos_D - PaddleWidth / 2) and XCord < (Paddle1XPos_D + PaddleWidth / 2))) then
			Blue <= '1';
		end if;
		
		if (XCord >= ScoreBoard0XOffs and XCord < ScoreBoard0XOffs + CharWidth and YCord >= ScoreBoard0YOffs and YCord < ScoreBoard0YOffs + CharHeight) then
			Green <= MyCharSet(conv_integer(Player0Score_D))(conv_integer(YCord - ScoreBoard0YOffs))(conv_integer(XCord - ScoreBoard0XOffs));
			Blue  <= MyCharSet(conv_integer(Player0Score_D))(conv_integer(YCord - ScoreBoard0YOffs))(conv_integer(XCord - ScoreBoard0XOffs));
			Red   <= MyCharSet(conv_integer(Player0Score_D))(conv_integer(YCord - ScoreBoard0YOffs))(conv_integer(XCord - ScoreBoard0XOffs));
		end if;
		
		if (XCord >= ScoreBoard1XOffs and XCord < ScoreBoard1XOffs + CharWidth and YCord >= ScoreBoard1YOffs and YCord < ScoreBoard1YOffs +	CharHeight) then
			Green <= MyCharSet(conv_integer(Player1Score_D))(conv_integer(YCord - ScoreBoard1YOffs))(conv_integer(XCord - ScoreBoard1XOffs));
			Blue  <= MyCharSet(conv_integer(Player1Score_D))(conv_integer(YCord - ScoreBoard1YOffs))(conv_integer(XCord - ScoreBoard1XOffs));
			Red   <= MyCharSet(conv_integer(Player1Score_D))(conv_integer(YCord - ScoreBoard1YOffs))(conv_integer(XCord - ScoreBoard1XOffs));
		end if;
	end process;
end architecture;
