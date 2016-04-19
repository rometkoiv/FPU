----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2016 02:07:20 PM
-- Design Name: 
-- Module Name: segmentdriver - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity segmentdriver is
    Port ( display : in STD_LOGIC_VECTOR (31 downto 0);
           seg : out STD_LOGIC_VECTOR(7 downto 0);

           select_Display : out STD_LOGIC_VECTOR(7 downto 0);
           clk : in STD_LOGIC);
end segmentdriver;

architecture Behavioral of segmentdriver is
--Component Declaration
    COMPONENT segmentDecoder
    PORT(
        Digit : in std_logic_vector(3 downto 0);
        segment : out STD_LOGIC_VECTOR(7 downto 0)

    );
    END COMPONENT;
    
    COMPONENT clock_divider
    PORT(
        clk : in STD_LOGIC;
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        data_clk : out STD_LOGIC_VECTOR (15 downto 0)
    );
    END COMPONENT;
    
SIGNAL temporary_data : std_logic_vector(3 downto 0);
SIGNAL clock_word : STD_LOGIC_VECTOR(15 downto 0);
SIGNAL slow_clock : STD_LOGIC;    

begin

--Component instantination
    uut: segmentDecoder PORT MAP(
        Digit => temporary_data,
        segment => seg
      
    );
    
    uut1: clock_divider PORT MAP(
        clk => clk,
        enable=>'1',
        reset=>'0',
        data_clk=> clock_word
    );

slow_clock <=clock_word(15);

process(slow_clock)

    variable display_selection : STD_LOGIC_VECTOR(2 DOWNTO 0);

    begin
    
    if slow_clock'event and slow_clock = '1' then
    case display_selection is
    when "000" => temporary_data <=display(3 downto 0);
        select_display <= "11111110";
        display_selection := display_selection + '1';
    
    when "001" => temporary_data <=display(7 downto 4);
        select_display <= "11111101";
        display_selection := display_selection + '1';    
    when "010" => temporary_data <=display(11 downto 8);
        select_display <= "11111011";
        display_selection := display_selection + '1';    
    when "011" => temporary_data <=display(15 downto 12);
        select_display <= "11110111";
        display_selection := display_selection + '1';    
    when "100" => temporary_data <=display(19 downto 16);
        select_display <= "11101111";
        display_selection := display_selection + '1';    
    when "101" => temporary_data <=display(23 downto 20);
        select_display <= "11011111";
        display_selection := display_selection + '1';    
    
    when "110" => temporary_data <=display(27 downto 24);
        select_display <= "10111111";
        display_selection := display_selection + '1';    
    
    when others => temporary_data <=display(31 downto 28);
        select_display <= "01111111";
        display_selection := display_selection + '1';    
                                                             
    
    end case;
    end if;

end process;


end Behavioral;
