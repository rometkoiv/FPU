library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TestFPU is
  Port ( 
  
  mant : out STD_LOGIC_VECTOR (12 downto 0);
  pow : out STD_LOGIC_VECTOR (7 downto 0)
  );
end TestFPU;

architecture Behavioral of TestFPU is
signal clk: STD_LOGIC := '1';

component float_calc is
    Port ( 
         clk : in STD_LOGIC;
         mantA_in : in STD_LOGIC_VECTOR (12 downto 0);
         mantB_in : in STD_LOGIC_VECTOR (12 downto 0);
         powA : in STD_LOGIC_VECTOR (7 downto 0);
         powB : in STD_LOGIC_VECTOR (7 downto 0);
         mode : in STD_LOGIC_VECTOR (1 downto 0);
         mant : out STD_LOGIC_VECTOR (12 downto 0);
         pow : out STD_LOGIC_VECTOR (7 downto 0));
end component;



begin
--Hertsid
clk <= not clk after 5 ns;

test_float_calc: float_calc PORT MAP(

                    clk =>CLK,
                      --mantA_in => "0000000000101", --5
                      mantA_in => "1111111111011", -- -5 
                      mantB_in => "0000000000111", --7 
                      powA => "10101111", -- -128
                      powB => "10101111", -- -81
                      --powA => "00000010", -- 2
                      --powB => "00000010", -- 2
                      mode => "01",
                      mant => mant,
                      pow =>pow
   );

end Behavioral;
