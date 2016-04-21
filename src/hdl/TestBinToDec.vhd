----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2016 06:59:08 PM
-- Design Name: 
-- Module Name: TestBinToDec - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
