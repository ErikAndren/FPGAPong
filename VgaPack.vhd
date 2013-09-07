library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.Types.all;

package VgaPack is 
	constant VgaClkFreq : integer  := 25175000;
	constant LineFreq   : integer  := 31469;
	constant FieldFreq  : integer  := 60; -- 59.94;
	
	constant HCnt       : positive := VgaClkFreq / LineFreq;
	constant HCntW      : positive := bits(HCnt);
	
	constant VCnt       : positive := VgaClkFreq / FieldFreq;
	constant VCntW      : positive := bits(VCnt);

	constant VgaHFrontPorch  : positive := 8;
	constant VgaHLeftBorder  : positive := 8;
	constant VgaHVideo       : positive := 640;
	constant VgaHRightBorder : positive := 8;
	constant VgaHSync        : positive := 96;
	constant VgaHSyncCnt     : positive := VgaHSync;
	constant VgaHSyncCntW    : positive := bits(VgaHSyncCnt);
	constant VgaHBackPorch   : positive := 40;
	constant VgaHLine        : positive := VgaHFrontPorch + 
	                                       VgaHSync + 
														VgaHBackPorch + 
														VgaHLeftBorder + 
														VgaHVideo +
														VgaHRightBorder;
	constant VgaHLineW        : positive := bits(VgaHLine);

	constant VgaVFrontPorch   : positive := 2;
	constant VgaVSync         : positive := 2;
	constant VgaVSyncCnt      : positive := VgaVSync * VgaHLine;
	constant VgaVSyncCntW     : positive := bits(VgaVSyncCnt);
	constant VgaVBackPorch    : positive := 25;
	constant VgaVTopBorder    : positive := 8;
	constant VgaVVideo        : positive := 480;
	constant VgaVBottomBorder : positive := 8;
	constant VgaVLine         : positive := VgaVFrontPorch +
														 VgaVSync +
														 VgaVBackPorch +
														 VgaVTopBorder +
														 VgaVVideo +
														 VgaVBottomBorder;
end package;
	
package body VgaPack is 

end package body VgaPack;