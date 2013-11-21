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
												
	constant MyCharTwo : MyChar :=  (("00011000"),
								 	         ("00100100"),
									      	("01000010"),
									      	("00000100"),
												("00001000"),
												("00010000"),
												("00100000"),
												("01111110")
									      	);
												
	constant MyCharThree : MyChar := (("00111100"),
								 	          ("01000010"),
									       	 ("00000010"),
									      	 ("00011110"),
												 ("00000010"),
												 ("00000010"),
												 ("01000010"),
												 ("00111100")
									      	 );
												 
	constant MyCharFour : MyChar :=  (("01000010"),
								 	          ("01000010"),
									       	 ("01000010"),
									      	 ("01000010"),
												 ("01111110"),
												 ("00000010"),
												 ("00000010"),
												 ("00000010")
									      	 );
												 
	constant MyCharFive : MyChar :=  (("01111110"),
								 	          ("01000000"),
									       	 ("01000000"),
									      	 ("01111110"),
												 ("00000010"),
												 ("00000010"),
												 ("00000010"),
												 ("01111110")
									      	 );
												 
	constant MyCharSix  : MyChar :=  (("00011110"),
								 	          ("00100000"),
									       	 ("01000000"),
									      	 ("01000000"),
      										 ("01111110"),
												 ("01000010"),
												 ("01000010"),
												 ("01111110")
									      	 );


	constant MyCharSeven  : MyChar :=(("01111110"),
								 	          ("00000010"),
									       	 ("00000010"),
									      	 ("00000010"),
												 ("00000010"),
												 ("00000010"),
												 ("00000010"),
												 ("00000010")
									      	 );
					
  constant MyCharEight  : MyChar := (("00111100"),
								 	          ("01000010"),
									       	 ("01000010"),
									      	 ("01000010"),
												 ("01111110"),
												 ("01000010"),
												 ("01000010"),
												 ("00111100")
									      	 );	
	
	constant MyCharNine  : MyChar := (("00111100"),
								 	          ("01000010"),
									       	 ("01000010"),
									      	 ("01000010"),
												 ("01111110"),
												 ("00000010"),
												 ("00000010"),
												 ("00111100")
									      	 );
	

	constant MyCharSet : MyCharArr(0 to 9) := (MyCharZero, MyCharOne, MyCharTwo, MyCharThree, MyCharFour, MyCharFive, MyCharSix, MyCharSeven, MyCharEight, MyCharNine);
end package;

package body CharPack is
end package body;