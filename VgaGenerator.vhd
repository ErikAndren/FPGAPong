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
	Green   : in bit1;
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
	signal HCnt_D, HCnt_N : word(HCntW-1 downto 0);
	signal VCnt_D, VCnt_N : word(VCntW-1 downto 0);
	signal GenHSync_N, GenVSync_N : bit1;
	--
	signal IncHSyncCnt : bit1;
	signal IncVSyncCnt : bit1;
	signal HSyncCnt_D : word(VgaHSyncCntW downto 0);
	signal VSyncCnt_D : word(VgaVSyncCntW downto 0);

begin
	SyncCountersAsync : process (HCnt_D, VCnt_D)
	begin
		HCnt_N     <= HCnt_D + 1;
		VCnt_N     <= VCnt_D;
		GenHSync_N <= '0';
		GenVSync_N <= '0';

		if HCnt_D = HCnt then
			HCnt_N     <= (others => '0');
			VCnt_N     <= VCnt_D + 1;
			GenHSync_N <= '1';
	   end if;

		if VCnt_D = VCnt then
			VCnt_N     <= (others => '0');
			GenVSync_N <= '1';
		end if;
	end process;
	
	IncHSyncCnt <= '1' when HSyncCnt_D > 0 or GenHSync_N = '1' else '0';
	IncVSyncCnt <= '1' when VSyncCnt_D > 0 or GenVSync_N = '1' else '0';

	SyncCountersSync : process(Clk, Rst_N)
	begin
		if Rst_N = '0' then
			HCnt_D     <= (others => '0');
			VCnt_D     <= (others => '0');
			HSyncCnt_D <= (others => '0');
			VSyncCnt_D <= (others => '0');
	   elsif rising_edge(Clk) then
			HCnt_D <= HCnt_N;
			VCnt_D <= VCnt_N;
			
			if IncHSyncCnt = '1' then
				HSyncCnt_D <= HSyncCnt_D + 1;
			end if;
			
			if IncVSyncCnt = '1' then
				VSyncCnt_D <= VSyncCnt_D + 1;
			end if;
		end if;
	end process;
	
	HSyncOutAssign : HSyncN <= not IncHSyncCnt;
	VSyncOutAssign : VSyncN <= not IncVSyncCnt;
	
	RedFeed   : RedOut   <= Red;
	GreenFeed : GreenOut <= Green;
	BlueFeed  : BlueOut  <= Blue;
end architecture;
	
