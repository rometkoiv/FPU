library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


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
         powA : in STD_LOGIC_VECTOR (7 downto 0);
         powB : in STD_LOGIC_VECTOR (7 downto 0);
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
SIGNAL mant_a : STD_LOGIC_VECTOR(12 downto 0);
SIGNAL mant_b : STD_LOGIC_VECTOR(12 downto 0);
SIGNAL pow_a : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL pow_b : STD_LOGIC_VECTOR(7 downto 0);

--Used to determine when a button press has occured
signal btnReg : std_logic_vector (4 downto 0) := "00000";
signal btnDetect : std_logic;
signal btnDeBnc : std_logic_vector(4 downto 0);

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

       elsif btnReg = "10000" then
       
          numbers(31 downto 28)<="1011"; --P
          numbers(27 downto 24)<="0010"; --2
       
       end if; 
   end process;
   
   
   --numbers(7 downto 0)<= SW(7 downto 0);
   
   
   numbers(23 downto 20)<="1111"; --R
   --numbers(19 downto 16)<="1111"; --O
   
   --numbers(11 downto 8)<="1111";

   




end Behavioral;
