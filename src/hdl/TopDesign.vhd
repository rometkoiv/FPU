----------------------------------------------------------------------------------
-- Company: TTU ATI
-- Engineer: Romet Koiv
-- Module Name: TopDesign - Behavioral
-- Dependency: float_calc,debouncer, bin_to_dec, segmentdriver
-- Target Devices: Nexys 4
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.NUMERIC_STD.ALL;


--Siinsed pordid peavad olema sama nimega kui constriant fail
entity TopDesign is
    Port ( 
           SW 			: in  STD_LOGIC_VECTOR (15 downto 0);
          BTN             : in  STD_LOGIC_VECTOR (4 downto 0);
           CLK             : in  STD_LOGIC;
           LED             : out  STD_LOGIC_VECTOR (15 downto 0);
           SSEG_CA         : out  STD_LOGIC_VECTOR (7 downto 0);
           SSEG_AN         : out  STD_LOGIC_VECTOR (7 downto 0)
           );
end TopDesign;

architecture Behavioral of TopDesign is
component segmentdriver is
    Port ( display : in STD_LOGIC_VECTOR (31 downto 0);
           seg : out STD_LOGIC_VECTOR(7 downto 0);
           select_Display : out STD_LOGIC_VECTOR(7 downto 0);
           clk : in STD_LOGIC);
end component;

component bin_to_dec is
    Port ( clk : in STD_LOGIC; 
           sign : in STD_LOGIC;
           number : in STD_LOGIC_VECTOR(11 downto 0);
           result : out STD_LOGIC_VECTOR (19 downto 0)
           );
end component;

component float_calc is
    Port ( 
         clk : in STD_LOGIC;
         errorCode : out STD_LOGIC_VECTOR (3 downto 0);
         mantA_in : in STD_LOGIC_VECTOR (12 downto 0);
         mantB_in : in STD_LOGIC_VECTOR (12 downto 0);
         powA_in : in STD_LOGIC_VECTOR (7 downto 0);
         powB_in : in STD_LOGIC_VECTOR (7 downto 0);
         mode : in STD_LOGIC_VECTOR (1 downto 0);
         mant : out STD_LOGIC_VECTOR (12 downto 0);
         pow : out STD_LOGIC_VECTOR (7 downto 0));
end component;


component debouncer
Generic(
        DEBNC_CLOCKS : integer;
        PORT_WIDTH : integer);
Port(
		SIGNAL_I : in std_logic_vector(4 downto 0);
		CLK_I : in std_logic;          
		SIGNAL_O : out std_logic_vector(4 downto 0)
		);
end component;


SIGNAL numberToSeg : STD_LOGIC_VECTOR(31 downto 0):=(others=>'1');
SIGNAL decimalNumber : STD_LOGIC_VECTOR(19 downto 0):=(others=>'0');
--onscreen
SIGNAL onscreen : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
--Vars
SIGNAL mant_a : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
SIGNAL mant_b : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
SIGNAL mant : STD_LOGIC_VECTOR(12 downto 0);
SIGNAL pow_a : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
SIGNAL pow_b : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
SIGNAL pow : STD_LOGIC_VECTOR(7 downto 0);

SIGNAL errorCode : STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');

--Millised nupud
signal btnReg : std_logic_vector (4 downto 0) := "00000";
signal btnDeBnc : std_logic_vector(4 downto 0):= "00000";

signal mode : std_logic_vector(1 downto 0):="11";

begin
   
   --Siin seome komponendid kokku
   mapFloatingPointUnit: float_calc Port MAP( 
      clk => clk,
      errorCode=>errorCode,
      mantA_in =>mant_a,
      mantB_in =>mant_b,
      powA_in =>pow_a,
      powB_in =>pow_b,
      mode =>mode,
      mant=>mant,
      pow =>pow
   );
   
   --Debounces btn signals
   Inst_btn_debounce: debouncer 
     generic map(
      DEBNC_CLOCKS => 15, --(2**16)
      PORT_WIDTH => 5)
     port map(
      SIGNAL_I => BTN,
      CLK_I => CLK,
      SIGNAL_O => btnDeBnc
   );
   
   mapBinToDec: bin_to_dec PORT MAP(
      clk=> clk,
      sign =>onscreen(12),
      number => onscreen(11 downto 0),
      result => decimalNumber
   );        

   map_segmentDriver: segmentDriver PORT MAP(
      display => numberToSeg,
      seg =>SSEG_CA,
      select_Display => SSEG_AN,
      clk => clk

   );
   

   
    --registreerime nupuvajutuse
    btn_reg_process : process (CLK)
       begin
          if (rising_edge(CLK)) then
            btnReg <= btnDeBnc(4 downto 0);
          end if;
              
    end process;
      
   action_map : process(clk,btnReg) --clk,btnReg,
   variable toScreen :STD_LOGIC_VECTOR (12 downto 0):=(others => '0');
   variable numbers : STD_LOGIC_VECTOR(31 downto 0):=(others=>'1');
   begin
       --BTNR sisestus
       if btnReg = "00001" then
          if SW(14 downto 13)="00" then
              numbers(31 downto 28):="1010"; --M
              numbers(27 downto 24):="0001"; --1
              mant_a<=SW(15)&SW(11 downto 0); --mantiss A
              onscreen<=mant_a;          
          elsif SW(14 downto 13)="01" then
              numbers(31 downto 28):="1011"; --P
              numbers(27 downto 24):="0001"; --1          
              pow_a<=SW(15)&SW(6 downto 0); --power A
              
              onscreen(12)<=pow_a(7);
              onscreen(6 downto 0)<=pow_a(6 downto 0);
              if pow_a(7)='1' then
                onscreen(11 downto 7)<="11111";
              else
                onscreen(11 downto 7)<="00000";
              end if;   
          elsif SW(14 downto 13)="10" then
              numbers(31 downto 28):="1010"; --M
              numbers(27 downto 24):="0010"; --2          
              mant_b<=SW(15)&SW(11 downto 0); --mantiss B
              onscreen<=mant_b;  
          elsif SW(14 downto 13)="11" then
              numbers(31 downto 28):="1011"; --P
              numbers(27 downto 24):="0010"; --2          
              pow_b<=SW(15)&SW(6 downto 0); --power B
              
              onscreen(12)<=pow_b(7);
              onscreen(6 downto 0)<=pow_b(6 downto 0);
              if pow_b(7)='1' then
              onscreen(11 downto 7)<="11111";
              else
              onscreen(11 downto 7)<="00000";
              end if;  
          end if;
       end if;
       --Tehted
       
       --Liitmine BTNC
        if btnReg = "10000" then
          mode<="00";
          numbers(27 downto 24):="0011"; --3
           
                 if SW(14 downto 13)="00" then
                    numbers(31 downto 28):="1010"; --M
                    onscreen<=mant;
                 elsif SW(14 downto 13)="01" then
                    numbers(31 downto 28):="1011"; --P
                    onscreen(12 downto 7)<=pow(7)&pow(7)&pow(7)&pow(7)&pow(7)&pow(7);
                    onscreen(6 downto 0)<=pow(6 downto 0);         
                 end if;
                 --Veakood ekraaanile
                 if errorCode(3)='1' then
                  numbers(31 downto 0):=(others=>'1');
                  onscreen(3 downto 0 )<=errorCode;
                 end if;
       end if;
        --Lahutamine BTNL
        if btnReg = "01000" then
         mode<="01";
         numbers(27 downto 24):="0100"; --4
          
                if SW(14 downto 13)="00" then
                   numbers(31 downto 28):="1010"; --M
                   onscreen<=mant;
                elsif SW(14 downto 13)="01" then
                   numbers(31 downto 28):="1011"; --P
                   onscreen(12 downto 7)<=pow(7)&pow(7)&pow(7)&pow(7)&pow(7)&pow(7);
                   onscreen(6 downto 0)<=pow(6 downto 0);         
                end if;
                --Veakood ekraaanile
                if errorCode(3)='1' then
                 numbers(31 downto 0):=(others=>'1');
                 onscreen(3 downto 0 )<=errorCode;
                end if;
        end if;
     --Korrutamine BTNU
     if btnReg = "00100" then
         mode<="10";
         numbers(27 downto 24):="0101"; --5
          
                if SW(14 downto 13)="00" then
                   numbers(31 downto 28):="1010"; --M
                   onscreen<=mant;
                elsif SW(14 downto 13)="01" then
                   numbers(31 downto 28):="1011"; --P
                   onscreen(12 downto 7)<=pow(7)&pow(7)&pow(7)&pow(7)&pow(7)&pow(7);
                   onscreen(6 downto 0)<=pow(6 downto 0);         
                end if;
                --Veakood ekraaanile
                if errorCode(3)='1' then
                 numbers(31 downto 0):=(others=>'1');
                 onscreen(3 downto 0 )<=errorCode;
                end if;
      end if;
       
      
      
      
      if btnReg = "00010" then
      --Kui BTND siis nullime
      mant_a<=(others=>'0');
      mant_b<=(others=>'0');
      pow_a<=(others=>'0');
      pow_b<=(others=>'0');
      --mant<=(others=>'0');
      --pow<=(others=>'0');
      numbers(31 downto 0):=(others=>'1');
      onscreen<=(others=>'0');
      end if; 
     
     numberToSeg<=numbers;
     numberToSeg(19 downto 0)<=decimalNumber;
     
     --Testing
     LED(4 downto 0)<=btnReg;
     
   end process;
   
   
  end Behavioral;
