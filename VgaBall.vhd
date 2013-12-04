library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

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
	Player1Left  : in bit1;
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
	constant Frequency  : natural := 31250;
	constant UpdateCnt  : natural := 8;
	
	type UpdateVector is array (0 to UpdateCnt-1) of word(UpdateCnt-1 downto 0);
	constant UpVec : UpdateVector := ("00000001",
												 "00010001",
												 "00010101",
												 "01010101",
												 "01010111",
												 "01110111",
												 "01111111",
												 "11111111");

	--
	signal UpdateCnt_N, UpdateCnt_D : word(UpdateCnt-1 downto 0);
	signal SampleCnt_N, SampleCnt_D : word(bits(Frequency)-1 downto 0);
	--
	type BallPos is array (2-1 downto 0) of word(maxval(VgaHVideoW, VgaVVideoW)-1 downto 0);
	signal BallPos_D, BallPos_N : BallPos;
	--
	constant PaddleWidth   : positive := 40;
	--constant PaddleWidth : positive := 640;
	constant PaddleDepth : positive := 4;
	--
	constant X : natural := 0;
	constant Y : natural := 1;
	--
	--
	constant BallSz : positive := 6;
	--
	constant XRes : positive := 640;
	constant YRes : positive := 480;
	--
	constant Paddle0YPos : positive := 10;
	constant Paddle1YPos : positive := YRes - 10;
	--
	signal Paddle0XPos_N, Paddle0XPos_D : word(bits(XRes)-1 downto 0);
	signal Paddle1XPos_N, Paddle1XPos_D : word(bits(XRes)-1 downto 0);
	--
	type BallDir is array (2-1 downto 0) of word(2-1 downto 0);
	constant GOING_LEFT  : word(2-1 downto 0) := "10";
	constant GOING_RIGHT : word(2-1 downto 0) := "01";
	constant GOING_UP    : word(2-1 downto 0) := "10";
	constant GOING_DOWN  : word(2-1 downto 0) := "01";
	--
	signal BallDir_N, BallDir_D : BallDir;
	
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
	signal Bounces_N, Bounces_D : word(8-1 downto 0);
	--
	signal AiEnabled_N, AiEnabled_D : word(2-1 downto 0);

begin	
	Sampler : process (Clk, Rst_N)
	begin
		if Rst_N = '0' then
			SampleCnt_D    <= (others => '0');
			BallPos_D(X)   <= conv_word(XRes / 2, BallPos_D(X)'length);
			BallPos_D(Y)   <= conv_word(YRes / 2, BallPos_D(Y)'length);
			Paddle0XPos_D  <= conv_word(XRes / 2, Paddle0XPos_D'length);
			Paddle1XPos_D  <= conv_word(XRes / 2, Paddle1XPos_D'length);
			BallDir_D      <= (others => (others => '0'));
			Player0Score_D <= (others => '0');
			Player1Score_D <= (others => '0');
			BallSpeed_D    <= (others => (others => '0'));
			UpdateCnt_D    <= (others => '0');
			Bounces_D      <= (others => '0');
			AiEnabled_D    <= (others => '1');
			
		elsif rising_edge(Clk) then
			SampleCnt_D <= SampleCnt_N;
			BallPos_D   <= BallPos_N;
			--
			BallDir_D <= BallDir_N;
			--
			Paddle0XPos_D <= Paddle0XPos_N;
			Paddle1XPos_D <= Paddle1XPos_N;
			--
			Player0Score_D <= Player0Score_N;
			Player1Score_D <= Player1Score_N;
			--
			BallSpeed_D <= BallSpeed_N;
			UpdateCnt_D <= UpdateCnt_N;
			--
			Bounces_D   <= Bounces_N;
			AiEnabled_D <= AiEnabled_N;
		end if;
	end process;

	SampleAsync : process (SampleCnt_D,
									BallPos_D, 
									Player0Right, Player0Left, 
									Paddle0XPos_D, Paddle1XPos_D, 
									BallDir_D,
									Player0Score_D, Player1Score_D, 
									Player1Right, Player1Left,
									BallSpeed_D, Rand,
									UpdateCnt_D, Bounces_D,
									AiEnabled_D
								)
	begin
		BallPos_N     <= BallPos_D;
		SampleCnt_N    <= SampleCnt_D + 1;
		BallDir_N      <= BallDir_D;
		Player0Score_N <= Player0Score_D;
		Player1Score_N <= Player1Score_D;
		--
		Paddle0XPos_N  <= Paddle0XPos_D;
		Paddle1XPos_N  <= Paddle1XPos_D;
		--
		BallSpeed_N    <= BallSpeed_D;
		--
		UpdateCnt_N    <= UpdateCnt_D;
		Bounces_N      <= Bounces_D;
		--
		BallSpeed_N(X) <= BallSpeed_D(X);
		BallSpeed_N(Y) <= BallSpeed_D(Y);
		--
		AiEnabled_N    <= AiEnabled_D;

		if SampleCnt_D = Frequency then
			SampleCnt_N    <= (others => '0');
			UpdateCnt_N    <= UpdateCnt_D(UpdateCnt_D'high-1 downto 0) & '0';
			if (RedOr(UpdateCnt_D) = '0') then
				UpdateCnt_N <= xt0(UpdateCnt_N'length-1) & '1';
			end if;

			-- X direction is mandantory
			if (RedXor(BallDir_D(X)) = '0') then
				if (Rand(0)) = '0' then
					BallDir_N(X) <= GOING_RIGHT;
				else
					BallDir_N(X) <= GOING_LEFT;
				end if;
			end if;

			-- Y direction is mandantory
			if (RedXor(BallDir_D(Y)) = '0') then
				if (Rand(1)) = '0' then
					BallDir_N(Y) <= GOING_DOWN;
				else
					BallDir_N(Y) <= GOING_UP;
				end if;
			end if;
		
			if RedOr((UpVec(conv_integer(BallSpeed_D(Y))) and UpdateCnt_D)) = '1' then
				if (BallDir_D(Y) = GOING_UP) then 
					BallPos_N(Y) <= BallPos_D(Y) - 1;
				elsif (BallDir_D(Y) = GOING_DOWN) then
					BallPos_N(Y) <= BallPos_D(Y) + 1;
				end if;
			end if;

			if RedOr((UpVec(conv_integer(BallSpeed_D(X))) and UpdateCnt_D)) = '1' then
				if (BallDir_D(X) = GOING_LEFT) then
					BallPos_N(X) <= BallPos_D(X) - 1;
				elsif (BallDir_D(X) = GOING_RIGHT) then
					BallPos_N(X) <= BallPos_D(X) + 1;
				end if;
			end if;	

			-- Bounce on paddle
			if (BallDir_D(Y) = GOING_UP and 
			    BallPos_D(Y) >= Paddle0YPos - PaddleDepth / 2 and BallPos_D(Y) <= Paddle0YPos + PaddleDepth / 2 and 
				 BallPos_D(X) >= Paddle0XPos_D - PaddleWidth / 2 and BallPos_D(X) <= Paddle0XPos_D + PaddleWidth / 2) then
				BallDir_N(Y) <= GOING_DOWN;
				
				if (Bounces_D < xt1(Bounces_D'length)) then
					Bounces_N <= Bounces_D + 1;
				end if;

				if (Bounces_D > Rand(4-1 downto 0) and RedAnd(BallSpeed_D(X)) = '0') then
					BallSpeed_N(X) <= BallSpeed_D(X) + 1;
					Bounces_N <= (others => '0');
				end if;
				
				if (Bounces_D > Rand(8-1 downto 4) and RedAnd(BallSpeed_D(X)) = '0') then
					BallSpeed_N(Y) <= BallSpeed_D(Y) + 1;
					Bounces_N <= (others => '0');
				end if;

			elsif (BallDir_D(Y) = GOING_DOWN and 
			       BallPos_D(Y) >= Paddle1YPos - PaddleDepth / 2 and BallPos_D(Y) <= Paddle1YPos + PaddleDepth / 2 and 
					 BallPos_D(X) >= Paddle1XPos_D - PaddleWidth / 2 and BallPos_D(X) <= Paddle1XPos_D + PaddleWidth / 2) then
				BallDir_N(Y) <= GOING_UP;

				if (Bounces_D < xt1(Bounces_D'length)) then
					Bounces_N <= Bounces_D + 1;
				end if;
				
				if (Bounces_D > Rand(4-1 downto 0) and RedAnd(BallSpeed_D(X)) = '0') then
					BallSpeed_N(X) <= BallSpeed_D(X) + 1;
					Bounces_N <= (others => '0');
				end if;
				
				if (Bounces_D > Rand(8-1 downto 4) and RedAnd(BallSpeed_D(X)) = '0') then
					BallSpeed_N(Y) <= BallSpeed_D(Y) + 1;
					Bounces_N <= (others => '0');
				end if;
			end if;

			-- Score for player 1
			if (BallPos_D(Y) = 0) then
				if (Player1Score_D >= 9) then
					Player1Score_N <= (others => '0');
				else
					Player1Score_N <= Player1Score_D + 1;
				end if;
				
				-- Reset state, give ball to losing player
				BallPos_N(X) <= conv_word(XRes / 2, BallPos_N(X)'length);
				BallPos_N(Y) <= conv_word(YRes-20 / 2, BallPos_N(Y)'length);
				BallDir_N(X) <= "00";
				BallDir_N(Y) <= GOING_UP;
				BallSpeed_N(X) <= (others => '0');
				BallSpeed_N(Y) <= (others => '0');
				Bounces_N  <= (others => '0');
			end if;
			
			-- Score for player 0
			if (BallPos_D(Y) = YRes-1) then
				if Player0Score_D >= 9 then
					Player0Score_N <= (others => '0');
				else
					Player0Score_N <= Player0Score_D + 1;
				end if;
				
				-- Reset state, give ball to losing player
				BallPos_N(X) <= conv_word(XRes / 2, BallPos_N(X)'length);
				BallPos_N(Y) <= conv_word(20, BallPos_N(Y)'length);
				--
				BallDir_N(X) <= "00";
				BallDir_N(Y) <= GOING_DOWN;
				BallSpeed_N(X) <= (others => '0');
				BallSpeed_N(Y) <= (others => '0');
				Bounces_N  <= (others => '0');
			end if;
			
			-- Bounce on walls
			if (BallPos_D(X) = 0) then
				BallDir_N(X) <= GOING_RIGHT;
			elsif (BallPos_D(X) = XRes-1) then
				BallDir_N(X) <= GOING_LEFT;
			end if;

			-- Add throttle factor
			if (RedOr(UpdateCnt_D(8-1 downto 2)) = '0') then
				-- AI
				if (AiEnabled_D(0) = '1') and (BallDir_D(Y) = GOING_UP) then
					if (BallPos_D(X) > (Paddle0XPos_D + PaddleWidth / 2)) then
						Paddle0XPos_N <= Paddle0XPos_D + 1;
					elsif (BallPos_D(X) < (Paddle0XPos_D - PaddleWidth / 2)) then
						Paddle0XPos_N <= Paddle0XPos_D - 1;
					end if;
				end if;
				
				if AiEnabled_D(1) = '1' and BallDir_D(Y) = GOING_DOWN then
					if (BallPos_D(X) > (Paddle1XPos_D + PaddleWidth / 2)) then
						Paddle1XPos_N <= Paddle1XPos_D + 1;
					elsif (BallPos_D(X) < (Paddle1XPos_D - PaddleWidth / 2)) then
						Paddle1XPos_N <= Paddle1XPos_D - 1;
					end if;
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
		end if;
	end process;	

	Draw : process (XCord, YCord, BallPos_D, Paddle0XPos_D, Paddle1XPos_D, Player0Score_D, Player1Score_D)
	begin
		Red   <= '0';
		Green <= '0';
		Blue  <= '0';
		
		if XCord >= BallPos_D(X) - BallSz / 2 and XCord <= BallPos_D(X) + BallSz / 2 and
			YCord >= BallPos_D(Y) - BallSz / 2 and YCord <= BallPos_D(Y) + BallSz / 2 and
			not (XCord = BallPos_D(X) - BallSz / 2 and YCord = BallPos_D(Y) - BallSz / 2) and
			not (XCord = BallPos_D(X) + BallSz / 2 and YCord = BallPos_D(Y) + BallSz / 2) and
			not (XCord = BallPos_D(X) - BallSz / 2 and YCord = BallPos_D(Y) + BallSz / 2) and
			not (XCord = BallPos_D(X) + BallSz / 2 and YCord = BallPos_D(Y) - BallSz / 2)
			then
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
