library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.Types.all;

package VgaPack is 	
	constant VgaClkFreq : integer  := 25175000;
	constant LineFreq   : integer  := 31469;
	constant FieldFreq  : integer  := 60; -- 59.94;

	constant VgaHFrontPorch  : positive := 16;
	constant VgaHVideo       : positive := 640;
	constant VgaHBackPorch   : positive := 48;
	--	
	constant VgaHPreHSync    : positive := VgaHFrontPorch + VgaHVideo + VgaHBackPorch;	
	--
	constant VgaHSync        : positive := 96;
	constant VgaHSyncCnt     : positive := VgaHSync;
	constant VgaHSyncCntW    : positive := bits(VgaHSyncCnt);
	--
	constant VgaHLine        : positive := VgaHPreHSync + VgaHSync;
	constant VgaHLineW       : positive := bits(VgaHLine);
	--
		
	constant VgaVFrontPorch   : positive := 11;
	constant VgaVVideo        : positive := 480;
	constant VgaVBackPorch    : positive := 31;
	--
	constant VgaVPreVSync      : positive := VgaVFrontPorch + VgaVVideo + VgaVBackPorch;
	--
	constant VgaVSync         : positive := 2;
	--
	constant VgaVSyncCnt      : positive := VgaVSync * VgaHLine;
	constant VgaVSyncCntW     : positive := bits(VgaVSyncCnt);
	--
	constant VgaVLine         : positive := VgaVPreVSync + VgaVSync;

   constant HCnt       : positive := VgaHLine; -- 800
	constant HCntW      : positive := bits(HCnt);
	
	constant VCnt       : positive := VgaVLine; -- 525	
	constant VCntW      : positive := bits(VCnt);														 
end package;
	
package body VgaPack is 

end package body VgaPack;