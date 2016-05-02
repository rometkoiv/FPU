----------------------------------------------------------------------------------
-- Company: TTU ATI
-- Engineer: Romet Koiv
-- Module Name: TestBinToDec - Behavioral
-- Dependency: bin_to_dec
-- Target Devices: Nexys 4
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TestBinToDec is
 Port ( result : out STD_LOGIC_VECTOR (19 downto 0));
end TestBinToDec;

architecture Behavioral of TestBinToDec is
signal clk: STD_LOGIC := '1';


component bin_to_dec is
     Port ( clk : in STD_LOGIC;
         sign : in STD_LOGIC;
         number : in STD_LOGIC_VECTOR(11 downto 0);
         result : out STD_LOGIC_VECTOR (19 downto 0));
end component;



begin
--Hertsid
clk <= not clk after 50 ns;

testBinToDec: bin_to_dec PORT MAP(

                    clk =>CLK,
                    sign =>'0',
                    number =>"000000000000",
                    result => result
   );


end Behavioral;
