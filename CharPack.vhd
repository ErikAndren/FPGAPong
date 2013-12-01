library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.Types.all;

package CharPack is
	constant CharWidth : positive  :=  6;
	constant CharHeight : positive := 10;

	type MyChar is array(0 to CharHeight-1) of word(0 to CharWidth-1);
	type MyCharArr is array (natural range <>) of MyChar;
	
	constant MyCharZero : MyChar := (("111111"),
								 	         ("111111"),
									      	("110011"),
									      	("110011"),
												("110011"),
												("110011"),
												("110011"),
												("110011"),
												("111111"),
												("111111")

									      	);

	constant MyCharOne : MyChar :=  (("000011"),
								 	         ("000011"),
									      	("000011"),
									      	("000011"),
												("000011"),
												("000011"),
												("000011"),
												("000011"),
												("000011"),
												("000011")
									      	);
												
	constant MyCharTwo : MyChar :=  (("111111"),
								 	         ("111111"),
									      	("000011"),
									      	("000011"),
												("111111"),
												("111111"),
												("110000"),
												("110000"),
												("111111"),
												("111111")
									      	);
												
	constant MyCharThree : MyChar := (("111111"),
								 	          ("111111"),
									       	 ("000011"),
									      	 ("000011"),
												 ("111111"),
												 ("111111"),
												 ("000011"),
												 ("000011"),
												 ("111111"),
												 ("111111")
									      	 );
												 
	constant MyCharFour : MyChar :=  (("110011"),
								 	          ("110011"),
									       	 ("110011"),
									      	 ("110011"),
												 ("111111"),
												 ("111111"),
												 ("000011"),
												 ("000011"),
												 ("000011"),
												 ("000011")
									      	 );
												 
	constant MyCharFive : MyChar :=  (("111111"),
								 	          ("111111"),
									       	 ("110000"),
									      	 ("110000"),
												 ("111111"),
												 ("111111"),
												 ("000011"),
							                ("000011"),
												 ("111111"),
						                   ("111111")
									      	 );
												 
	constant MyCharSix  : MyChar :=  (("111111"),
								 	          ("111111"),
									       	 ("110000"),
									      	 ("110000"),
      										 ("111111"),
												 ("111111"),
												 ("110011"),
												 ("110011"),
												 ("111111"),
												 ("111111")
									      	 );


	constant MyCharSeven  : MyChar :=(("111111"),
								 	          ("111111"),
									       	 ("000011"),
									      	 ("000011"),
												 ("000011"),
												 ("000011"),
												 ("000011"),
												 ("000011"),
												 ("000011"),
												 ("000011")
									      	 );
					
  constant MyCharEight  : MyChar := (("111111"),
								 	          ("111111"),
									       	 ("110011"),
									      	 ("110011"),
												 ("111111"),
												 ("111111"),
												 ("110011"),
												 ("110011"),
												 ("111111"),
												 ("111111")
									      	 );	
	
	constant MyCharNine  : MyChar := (("111111"),
								 	          ("111111"),
									       	 ("110011"),
									      	 ("110011"),
												 ("111111"),
												 ("111111"),
												 ("000011"),
												 ("000011"),
												 ("111111"),
												 ("111111")
									      	 );
	

	constant MyCharSet : MyCharArr(0 to 9) := (MyCharZero, MyCharOne, MyCharTwo, MyCharThree, MyCharFour, MyCharFive, MyCharSix, MyCharSeven, MyCharEight, MyCharNine);
end package;

package body CharPack is
end package body;