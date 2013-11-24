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
	Player0Right : in bit1;
	Player0Left  : in bit1;
	Player1Right : in bit1;
	Player1Left : in bit1;
	--
	Rand : in word(16-1 downto 0);
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
	-- Update 8 times every cycle
	-- constant Frequency  : natural := 3125000;
   constant Frequency  : natural := 150000;
	constant UpdateCnt  : natural := 8;
	--
	signal UpdateCnt_N, UpdateCnt_D : word(bits(UpdateCnt)-1 downto 0);
	signal SampleCnt_N, SampleCnt_D : word(bits(Frequency)-1 downto 0);
	--
	signal BallPosX_D, BallPosX_N : word(VgaHVideoW-1 downto 0);
	signal BallPosY_D, BallPosY_N : word(VgaVVideoW-1 downto 0);
	
	constant PaddleWidth   : positive := 40;
	constant PaddleDepth   : positive := 4;
	
	constant X : natural := 0;
	constant Y : natural := 1;
	
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
	--
	constant ScoreBoard0XOffs : natural := 4;
	constant ScoreBoard0YOffs : natural := YRes / 2 - 16;
	--
	constant ScoreBoard1XOffs : natural := 4;
	constant ScoreBoard1YOffs : natural := YRes / 2 + 9;
	--
	constant MaxSpeed : positive := 3;
	type BallSpeed is array (2-1 downto 0) of word(MaxSpeed-1 downto 0);
	signal BallSpeed_N, BallSpeed_D : BallSpeed;
	--

	
begin	
	Sampler : process (Clk, Rst_N)
	begin
		if Rst_N = '0' then
			SampleCnt_D   <= (others => '0');
			BallPosX_D    <= conv_word(XRes / 2, BallPosX_D'length);
			BallPosY_D    <= conv_word(YRes / 2, BallPosY_D'length);
			Paddle0XPos_D <= conv_word(XRes / 2, Paddle0XPos_D'length);
			Paddle1XPos_D <= conv_word(XRes / 2, Paddle1XPos_D'length);
			BallXDir_D    <= "00";
			BallYDir_D    <= "00";
			Player0Score_D <= (others => '0');
			Player1Score_D <= (others => '0');
			BallSpeed_D    <= (others => (others => '0'));
			UpdateCnt_D    <= (others => '0');
			
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
			BallSpeed_D <= BallSpeed_N;
			UpdateCnt_D <= UpdateCnt_N;
		end if;
	end process;

	SampleAsync : process (SampleCnt_D,
									BallPosX_D, BallPosY_D, 
									Player0Right, Player0Left, 
									Paddle0XPos_D, Paddle1XPos_D, 
									BallXDir_D, BallYDir_D,
									Player0Score_D, Player1Score_D, 
									Player1Right, Player1Left,
									BallSpeed_D, Rand,
									UpdateCnt_D
								)
	begin
		BallPosX_N     <= BallPosX_D;
		BallPosY_N     <= BallPosY_D;
		SampleCnt_N    <= SampleCnt_D + 1;
		BallXDir_N     <= BallXDir_D;
		BallYDir_N     <= BallYDir_D;
		Player0Score_N <= Player0Score_D;
		Player1Score_N <= Player1Score_D;
		--
		Paddle0XPos_N  <= Paddle0XPos_D;
		Paddle1XPos_N  <= Paddle1XPos_D;
		--
		BallSpeed_N    <= BallSpeed_D;
		--
		UpdateCnt_N    <= UpdateCnt_D;

		if SampleCnt_D = 150000 then
			SampleCnt_N <= (others => '0');
			UpdateCnt_N <= UpdateCnt_D + 1;
		
			-- Ball must never stand still in Y direction
			if (BallSpeed_D(Y) = 0) then
				BallSpeed_N(Y) <= Rand(MaxSpeed-1 downto 0);
			end if;
			
			-- Ball must never stand still in Y direction
			if (BallSpeed_D(X) = 0) then
				BallSpeed_N(X) <= Rand(MaxSpeed-1 downto 0);
			end if;

			-- X direction is mandantory
			if (RedXor(BallXDir_D) = '0') then
				if (Rand(0)) = '0' then
					BallXDir_N <= "01";
				else
					BallXDir_N <= "10";
				end if;
			end if;

			-- Y direction is mandantory
			if (RedXor(BallYDir_D) = '0') then
				if (Rand(1)) = '0' then
					BallYDir_N <= "01";
				else
					BallYDir_N <= "10";
				end if;
			end if;
		
			if (RedOr(SHL(UpdateCnt_D, BallSpeed_D(Y))) = '0') then
				if (BallYDir_D = "10") then 
					BallPosY_N <= BallPosY_D - BallSpeed_D(Y);
				elsif (BallYDir_D = "01") then
					BallPosY_N <= BallPosY_D + BallSpeed_D(Y);
				end if;
			end if;

			if (RedOr(SHL(UpdateCnt_D, BallSpeed_D(X))) = '0') then
				if (BallXDir_D = "10") then
					BallPosX_N <= BallPosX_D - BallSpeed_D(X);
				elsif (BallXDir_D = "01") then
					BallPosX_N <= BallPosX_D + BallSpeed_D(X);
				end if;
			end if;	

			if (BallPosY_D = Paddle0YPos and BallPosX_D > Paddle0XPos_D - PaddleWidth / 2 and BallPosX_D < Paddle0XPos_D + PaddleWidth / 2) then
				BallYDir_N <= "01";
			elsif (BallPosY_D = Paddle1YPos and BallPosX_D > Paddle1XPos_D - PaddleDepth / 2 and BallPosX_D < Paddle1XPos_D + PaddleWidth / 2) then
				BallYDir_N <= "10";
			end if;

			-- Score for player 1
			if (BallPosY_D = 0) then
				if (Player1Score_D >= 9) then
					Player1Score_N <= (others => '0');
				else
					Player1Score_N <= Player1Score_D + 1;
				end if;
				
				-- Reset state, give ball to losing player
				BallPosX_N <= conv_word(XRes / 2, BallPosX_N'length);
				BallPosY_N <= conv_word(YRes-20 / 2, BallPosY_N'length);
				BallXDir_N <= "00";
				BallYDir_N <= "00";	
			end if;
			
			-- Score for player 0
			if (BallPosY_D = YRes-1) then
				if Player0Score_D >= 9 then
					Player0Score_N <= (others => '0');
				else
					Player0Score_N <= Player0Score_D + 1;
				end if;
				
				-- Reset state, give ball to losing player
				BallPosX_N <= conv_word(XRes / 2, BallPosX_N'length);
				BallPosY_N <= conv_word(20, BallPosY_N'length);
				--
				BallXDir_N <= "00";
				BallYDir_N <= "00";	
			end if;

			if (Player0Right = '0' and Player0Left = '0') then
				null;
				
			elsif Player0Right = '0' then
				if (Paddle0XPos_D < XRes-PaddleWidth / 2) then
					Paddle0XPos_N <= Paddle0XPos_D + 1;
				end if;
			
			elsif Player0Left = '0' then
				if (Paddle0XPos_D > PaddleWidth / 2) then
					Paddle0XPos_N <= Paddle0XPos_D - 1;
				end if;
			end if;
			
			if (Player1Right = '0' and Player1Left = '0') then
				null;
				
			elsif Player1Right = '0' then
				if (Paddle1XPos_D < XRes-PaddleWidth / 2) then
					Paddle1XPos_N <= Paddle1XPos_D + 1;
				end if;
			
			elsif Player1Left = '0' then
				if (Paddle1XPos_D > PaddleWidth / 2) then
					Paddle1XPos_N <= Paddle1XPos_D - 1;
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
		
		-- Draw middle line
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
