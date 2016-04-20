library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.NUMERIC_STD.ALL;


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
    Port ( sign : in STD_LOGIC;
           number : in STD_LOGIC_VECTOR(11 downto 0);
           result : out STD_LOGIC_VECTOR (19 downto 0)
           );
end component;

component float_calc is
    Port ( 
         clk : in STD_LOGIC;
         errorCode : out STD_LOGIC_VECTOR (3 downto 0):=(others => '0');
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


SIGNAL numbers : STD_LOGIC_VECTOR(31 downto 0);
--onscreen
SIGNAL onscreen : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
--Vars
SIGNAL mant_a : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
SIGNAL mant_b : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
SIGNAL mant : STD_LOGIC_VECTOR(12 downto 0):=(others=>'0');
SIGNAL pow_a : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
SIGNAL pow_b : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
SIGNAL pow : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');

SIGNAL errorCode : STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');

--Used to determine when a button press has occured
signal btnReg : std_logic_vector (4 downto 0) := "00000";
signal btnDetect : std_logic;
signal btnDeBnc : std_logic_vector(4 downto 0);

signal mode : std_logic_vector(1 downto 0);

begin

        --Debounces btn signals
        Inst_btn_debounce: debouncer 
            generic map(
                DEBNC_CLOCKS => (2**16),
                PORT_WIDTH => 5)
            port map(
                SIGNAL_I => BTN,
                CLK_I => CLK,
                SIGNAL_O => btnDeBnc
            );
        
        --Registers the debounced button signals, for edge detection.
        btn_reg_process : process (CLK)
        begin
            if (rising_edge(CLK)) then
                btnReg <= btnDeBnc(4 downto 0);
            end if;
            
        end process;



   uut2: segmentDriver PORT MAP(
      display => numbers,
      seg =>SSEG_CA,
      select_Display => SSEG_AN,
      clk => clk

   );
   
   mapBinToDec: bin_to_dec PORT MAP(
      --sign =>SW(15),
      --number => SW(11 downto 0),
      sign =>onscreen(12),
      number => onscreen(11 downto 0),
            
      result => numbers(19 downto 0)
   );
   
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
   
   
   action_map : process(btnReg)
   begin
       if btnReg = "00001" then
          if SW(14 downto 13)="00" then
              numbers(31 downto 28)<="1010"; --M
              numbers(27 downto 24)<="0001"; --1
              mant_a<=SW(15)&SW(11 downto 0); --mantiss A
              onscreen<=mant_a;          
          elsif SW(14 downto 13)="01" then
              numbers(31 downto 28)<="1011"; --P
              numbers(27 downto 24)<="0001"; --1          
              pow_a<=SW(15)&SW(11 downto 5); --power A
              
              onscreen(12)<=SW(15);
              onscreen(6 downto 0)<=pow_a(6 downto 0);
              if SW(15)='1' then
                onscreen(11 downto 7)<="11111";
              else
                onscreen(11 downto 7)<="00000";
              end if;   
          elsif SW(14 downto 13)="10" then
              numbers(31 downto 28)<="1010"; --M
              numbers(27 downto 24)<="0010"; --2          
              mant_b<=SW(15)&SW(11 downto 0); --mantiss B
              onscreen<=mant_b;  
          elsif SW(14 downto 13)="11" then
              numbers(31 downto 28)<="1011"; --P
              numbers(27 downto 24)<="0010"; --2          
              pow_b<=SW(15)&SW(11 downto 5); --power B
              
              onscreen(12)<=SW(15);
                            onscreen(6 downto 0)<=pow_b(6 downto 0);
                            if SW(15)='1' then
                              onscreen(11 downto 7)<="11111";
                            else
                              onscreen(11 downto 7)<="00000";
                           end if;  
          end if;
       --Tehted
       elsif btnReg = "10000" or btnReg = "01000" or btnReg = "00100" then
       --Liitmine
        if btnReg = "10000" then
          mode<="00";
          numbers(27 downto 24)<="0011"; --3
        --Lahutamine
        elsif btnReg = "01000" then
         mode<="01";
         numbers(27 downto 24)<="0100"; --4
        --Korrutamine
        elsif btnReg = "01000" then
         mode<="10";
         numbers(27 downto 24)<="0101"; --5
        end if;
        
        if SW(14 downto 13)="00" then
           numbers(31 downto 28)<="1010"; --M
           onscreen<=mant;
        elsif SW(14 downto 13)="01" then
           numbers(31 downto 28)<="1011"; --P
           onscreen(12 downto 7)<=pow(7)&pow(7)&pow(7)&pow(7)&pow(7)&pow(7);
           onscreen(6 downto 0)<=pow(6 downto 0);         
        end if;
      --Veakood ekraaanile
      if errorCode(3)='1' then
         -- numbers(31 downto 0)<=(others=>'1');
         -- onscreen(3 downto 0 )<=errorCode;
      end if;
                    
      --Kui nuppe ei vajuta on tühi
      numbers(31 downto 0)<=(others=>'1');
     end if; 
   end process;
   
   
   --numbers(7 downto 0)<= SW(7 downto 0);
   
   
   --numbers(23 downto 20)<="1111"; --R
   --numbers(19 downto 16)<="1111"; --O
   
   --numbers(11 downto 8)<="1111";

   




end Behavioral;
