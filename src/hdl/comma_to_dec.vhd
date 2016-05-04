
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity comma_to_dec is
    Port ( clk : in STD_LOGIC;
           sign : in STD_LOGIC;
           number : in STD_LOGIC_VECTOR (11 downto 0);
           result : out STD_LOGIC_VECTOR (11 downto 0));
end comma_to_dec;

architecture Behavioral of comma_to_dec is

begin

comma_to_dec : process(clk)
--0 to 4095 annab to_unsigned(4095,12) kõik ühed
--Võtan 2 astmes 30
--variable ac : integer range 0 to 1073741824:=0;

variable ac : STD_LOGIC_VECTOR (9 downto 0):=(others =>'0');
variable ad : STD_LOGIC_VECTOR (9 downto 0):=(others =>'0');

begin
   for i in number'Length-1 downto 0  loop
      if number(i)='1' then
      case i is
           when 11=>   ad:="0111110100"; 
           when 10=>   ad:="0011111010";
           when 9 =>   ad:="0001111101";
           when 8 =>   ad:="0000111110"; 
           when 7 =>   ad:="0000011111";
           when 6 =>   ad:="0000001111";
           when 5 =>   ad:="0000000111";
           when 4 =>   ad:="0000000011";
           when 3 =>   ad:="0000000001";
           
           when others => ad:="0000000000";
      end case;
      
      ac:= std_logic_vector(unsigned(ac) + unsigned(ad));
      
      end if;
   end loop;
   
   
   result<="00"&ac;
end process;

end Behavioral;
