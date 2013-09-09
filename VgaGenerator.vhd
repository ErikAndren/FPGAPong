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

begin
	--assert HCnt = 800 report "HLine differs from 800" severity failure;
	--		assert VCnt = 525 report "VLine differs from 525" severity failure;

	SyncCountersAsync : process (HCnt_D, VCnt_D)
	begin
		HCnt_N     <= HCnt_D + 1;
		VCnt_N     <= VCnt_D;

		if HCnt_D = HCnt then
			HCnt_N     <= (others => '0');
			VCnt_N     <= VCnt_D + 1;
	   end if;

		if VCnt_D = VCnt then
			VCnt_N     <= (others => '0');
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
		end if;
	end process;
	
	HSyncOutAssign : HSyncN <= not InHSync;
	VSyncOutAssign : VSyncN <= not InVSync;
	
	RedFeed   : RedOut   <= Red   when InDisplayWindow_D = '1' else '0';
	GreenFeed : GreenOut <= Green when InDisplayWindow_D = '1' else '0';
	BlueFeed  : BlueOut  <= Blue  when InDisplayWindow_D = '1' else '0';
	end architecture;
	
