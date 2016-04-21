----------------------------------------------------------------------------------
-- Company: TTU ATI
-- Engineer: Romet Koiv
-- Module Name: bin_to_dec - Behavioral
-- Target Devices: Nexys 4
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity bin_to_dec is
    Port ( clk : in STD_LOGIC;
           sign : in STD_LOGIC;
           number : in STD_LOGIC_VECTOR(11 downto 0);
           result : out STD_LOGIC_VECTOR (19 downto 0));
end bin_to_dec;

architecture Behavioral of bin_to_dec is

begin

   
   bin_to_bcd : process (number,clk)
      
      variable shift : unsigned(27 downto 0);
      variable negative : unsigned(11 downto 0);
      
	  -- järgud
      alias num is shift(11 downto 0);
      alias one is shift(15 downto 12);
      alias ten is shift(19 downto 16);
      alias hun is shift(23 downto 20);
      alias tho is shift(27 downto 24);
   begin
            
      
      
      
      num := unsigned(number);
      --Muudame täiendkoodi tagasi otsekoodiks 
      if sign='1' then
          negative := num;
           
          for i in 0 to negative'Length-1 loop
           
           negative(i) := not negative(i);
           
          end loop;
          negative := negative + 1;
          num := negative;  
       end if;
      
      --algselt nullid
      one := X"0";
      ten := X"0";
      hun := X"0";
      tho := X"0";
      
	  -- Loop twelve times
      for i in 1 to num'Length loop
	    
         if one >= 5 then
            one := one + 3;
         end if;
         
         if ten >= 5 then
            ten := ten + 3;
         end if;
         
         if hun >= 5 then
            hun := hun + 3;
         end if;
         
         if tho >= 5 then
            tho := tho + 3;
         end if;
         
		 -- Shift entire register left once
         shift := shift_left(shift, 1);
      end loop;
      
	  -- Push decimal numbers to output
	  result(15 downto 12)    <= std_logic_vector(tho);
      result(11 downto 8)    <= std_logic_vector(hun);
      result(7 downto 4)     <= std_logic_vector(ten);
      result(3 downto 0)     <= std_logic_vector(one);
      
      if sign='0' then
                result(19 downto 16)    <= "1111";
      else
                result(19 downto 16)    <= "1101";
              
      end if;

      
     end process;
    

end Behavioral;
