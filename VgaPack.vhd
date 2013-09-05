library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package VgaPack is 
	constant VgaClkFreq : real := 25.175e6;
	constant LineFreq   : real  := 31469.0;
	constant FieldFreq  : real  := 59.94;
	
	constant VgaHFrontPorch  : positive := 8;
	constant VgaHSync        : positive := 96;
	constant VgaHBackPorch   : positive := 40;
	constant VgaHLeftBorder  : positive := 8;
	constant VgaHVideo       : positive := 640;
	constant VgaHRightBorder : positive := 8;
	constant VgaHLine        : positive := VgaHFrontPorch + 
	                                       VgaHSync + 
														VgaHBackPorch + 
														VgaHLeftBorder + 
														VgaHVideo +
														VgaHRightBorder;
	
	constant VgaVFrontPorch   : positive := 2;
	constant VgaVSync         : positive := 2;
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