library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.Types.all;

package CharPack is
	constant CharWidth : positive  := 8;
	constant CharHeight : positive := 8;

	type MyChar is array(0 to CharHeight-1) of word(0 to CharWidth-1);
	type MyCharArr is array (natural range <>) of MyChar;
	
	constant MyCharZero : MyChar := (("00111100"),
								 	         ("01000010"),
									      	("01000010"),
									      	("01000010"),
												("01000010"),
												("01000010"),
												("01000010"),
												("00111100")
									      	);

	constant MyCharOne : MyChar :=  (("00011000"),
								 	         ("00111000"),
									      	("00011000"),
									      	("00011000"),
												("00011000"),
												("00011000"),
												("00011000"),
												("00111100")
									      	);

	constant MyCharSet : MyCharArr(0 to 2-1) := (MyCharZero, MyCharOne);

end package;

package body CharPack is


end package body;