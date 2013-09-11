library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.VgaPack.all;

entity VgaGenerator is
port (
	Clk      : in bit1;
	Rst_N    : in bit1;
	--
	Red      : in bit1;
	Green    : in bit1;
	Blue     : in bit1;
	--
	XCord    : out word(VgaHVideoW-1 downto 0);
	YCord    : out word(VgaVVideoW-1 downto 0);
	--
	HSyncN   : out bit1;
	VSyncN   : out bit1;
	RedOut   : out bit1;
	GreenOut : out bit1;
	BlueOut  : out bit1
);
end entity VgaGenerator;

architecture rtl of VgaGenerator is
	signal HCnt_D, HCnt_N         : word(HCntW-1 downto 0);
	signal VCnt_D, VCnt_N         : word(VCntW-1 downto 0);
	--
	signal InHSync : bit1;
	signal InVSync : bit1;
	--
	signal InDisplayWindow_N, InDisplayWindow_D	 : bit1;

	signal XCord_N, XCord_D : word(VgaHVideoW-1 downto 0);
	signal YCord_N, YCord_D : word(VgaVVideoW-1 downto 0);
begin
	SyncCountersAsync : process (HCnt_D, VCnt_D, InDisplayWindow_D, XCord_D, YCord_D)
	begin	
		HCnt_N     <= HCnt_D + 1;
		VCnt_N     <= VCnt_D;
		XCord_N    <= XCord_D;
		YCord_N    <= YCord_D;

		if HCnt_D = (HCnt-1) then
			HCnt_N     <= (others => '0');
			VCnt_N     <= VCnt_D + 1;
			
			if VCnt_D = (VCnt-1) then
				VCnt_N     <= (others => '0');
			end if;
	   end if;
		
		if (InDisplayWindow_D = '1') then
			XCord_N <= XCord_D + 1;
		else
			XCord_N <= (others => '0');
		end if;
		
		-- Detect edge
		if (XCord_D = VgaHVideo) then
			YCord_N <= YCord_D + 1;
		end if;
		
		if YCord_D = VgaVVideo then
			YCord_N <= (others => '0');
		end if;
	end process;	
	
	InDisplayCalcProc : process (HCnt_D, VCnt_D)
	begin
		InDisplayWindow_N <= '1';

		if (HCnt_D < VgaHfrontPorch) then
			InDisplayWindow_N <= '0';
		end if;

		if (HCnt_D >= VgaHFrontPorch + VgaHVideo) then
			InDisplayWindow_N <= '0';
		end if;

		if (VCnt_D < VgaVFrontPorch) then
			InDisplayWindow_N <= '0';
		end if;

		if (VCnt_D >= VgaVFrontPorch + VgaVVideo) then
			InDisplayWindow_N <= '0';
		end if;
	end process;

	InHSync <= '1' when HCnt_D >= VgaHPreHSync else '0';
	InVSync <= '1' when VCnt_D >= VgaVPreVSync else '0';

	SyncCountersSync : process(Clk, Rst_N)
	begin
		if Rst_N = '0' then
			HCnt_D            <= (others => '0');
			VCnt_D            <= (others => '0');
			InDisplayWindow_D <= '0';
	   elsif rising_edge(Clk) then
			HCnt_D <= HCnt_N;
			VCnt_D <= VCnt_N;
			InDisplayWindow_D <= InDisplayWindow_N;
			
			XCord_D <= XCord_N;
			YCord_D <= YCord_N;
		end if;
	end process;
	
	HSyncOutAssign : HSyncN <= not InHSync;
	VSyncOutAssign : VSyncN <= not InVSync;
	
	XCordAssign : XCord <= XCord_D;
	YCordAssign : YCord <= YCord_D;
	
	RedFeed   : RedOut   <= Red   when InDisplayWindow_D = '1' else '0';
	GreenFeed : GreenOut <= Green when InDisplayWindow_D = '1' else '0';
	BlueFeed  : BlueOut  <= Blue  when InDisplayWindow_D = '1' else '0';
	end architecture;
	
