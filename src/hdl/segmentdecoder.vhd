----------------------------------------------------------------------------------
-- Company: TTU ATI
-- Engineer: Romet Koiv
-- Module Name: segmentDecoder - Behavioral
-- Target Devices: Nexys 4
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity segmentdecoder is
    Port ( Digit : in STD_LOGIC_VECTOR (3 downto 0);
           segment : out STD_LOGIC_VECTOR(7 downto 0)
           );
end segmentdecoder;

architecture Behavioral of segmentdecoder is

begin
process(Digit)
    variable Decode_Data : std_logic_vector(7 downto 0);
    
    begin
    case Digit is
        when "0000" => Decode_Data := "01111110"; --0
        when "0001" => Decode_Data := "00110000"; --1
        when "0010" => Decode_Data := "01101101"; --2
        when "0011" => Decode_Data := "01111001"; --3
        when "0100" => Decode_Data := "00110011"; --4
        when "0101" => Decode_Data := "01011011"; --5
        when "0110" => Decode_Data := "01011111"; --6
        when "0111" => Decode_Data := "01110000"; --7
        when "1000" => Decode_Data := "01111111"; --8
        when "1001" => Decode_Data := "01111011"; --9
        
        when "1010" => Decode_Data := "00010101"; --M
        when "1011" => Decode_Data := "01100111"; --P
        
        when "1100" => Decode_Data := "11111110"; --null punkt
        when "1101" => Decode_Data := "00000001"; --miinus märk
        when "1110" => Decode_Data := "00110001"; -- miinus 1
        
        when others => Decode_Data := "00000000"; --Tühi
        end case;
        segment(0) <= not Decode_Data(6);
        segment(1) <= not Decode_Data(5);
        segment(2) <= not Decode_Data(4);
        segment(3) <= not Decode_Data(3);
        segment(4) <= not Decode_Data(2);
        segment(5) <= not Decode_Data(1);
        segment(6) <= not Decode_Data(0);
        
        segment(7) <= not Decode_Data(7);
        
        
    end process;

end Behavioral;
