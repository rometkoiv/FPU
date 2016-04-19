library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
USE IEEE.NUMERIC_STD.ALL;

--Veakoodid
--0001
--
--1001
--1011 liiga suur mantiss
--1111 mantissi ei saa vähendada

entity float_calc is
    Generic ( mlen : INTEGER range 1 to (INTEGER'high) := 13;
            plen : INTEGER range 1 to (INTEGER'high) := 7 );
    Port ( clk : in STD_LOGIC;
           errorCode : out STD_LOGIC_VECTOR (3 downto 0):=(others => '0');
           mantA_in : in STD_LOGIC_VECTOR (12 downto 0):=(others => '0');
           mantB_in : in STD_LOGIC_VECTOR (12 downto 0):=(others => '0');
           powA : in STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
           powB : in STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
           mode : in STD_LOGIC_VECTOR (1 downto 0);
           mant : out STD_LOGIC_VECTOR (12 downto 0):=(others => '0');
           pow : out STD_LOGIC_VECTOR (7 downto 0):=(others => '0'));
end float_calc;

architecture Behavioral of float_calc is
begin



float_calculator : process(clk)
--variables
variable tshift : INTEGER range 1 to (INTEGER'high):=1;
variable powC : STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
variable mantA : STD_LOGIC_VECTOR (13 downto 0):=(others => '0');
variable mantB : STD_LOGIC_VECTOR (13 downto 0):=(others => '0');
variable mantC : STD_LOGIC_VECTOR (13 downto 0):=(others => '0');
variable powMinus : STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
variable powPlus : STD_LOGIC_VECTOR (8 downto 0):=(others => '0');

variable minusOne : STD_LOGIC_VECTOR (13 downto 0):=(others => '1');
variable mult : STD_LOGIC_VECTOR (27 downto 0):=(others => '0');
variable multMax : INTEGER range 1 to (INTEGER'high);


begin
  --Pikendame mantissi, et ületäitumine kaduma ei läheks
  if mantA_in(12)='0' then
    mantA:='0'&mantA_in;
  else
    mantA:='1'&mantA_in;
  end if;
  
  if mantB_in(12)='0' then
      mantB:='0'&mantB_in;
    else
      mantB:='1'&mantB_in;
  end if;
  
  
  --Liitmine
   if mode="00" or mode="01" then
       
      --Lahutamine
      if mode = "01" then
        --muudame mantB märki
        mult := std_logic_vector(signed(mantB)*signed(minusOne));
        mantB := mult(13 downto 0);
      end if;
       
      --Teeme kindlaks kumb mantiss on suurem
      if (powA(plen)=powB(plen)) and (powB(plen) ='0') then
      powC:=powA;
      mant(plen)<='1';
      for index in (plen-1) downto 0 loop
          
          if powB(index)> powA(index) then
          
          powC:=powB;
          exit;
          end if;   
      end loop;
      
      elsif (powA(plen)=powB(plen)) and (powB(plen) ='1') then
      powC:=powB;
      for index in (plen-1) downto 0 loop
                if powB(index)> powA(index) then
                powC:=powA;
                exit;
                end if;   
      end loop;
      
      elsif powA(plen)>powB(plen) then
      powC:=powB;
      elsif powA(plen)<powB(plen) then
            powC:=powA;
      end if;
      
      if powC=powA then
      
      powMinus := powB-powA;
      tshift := to_integer(unsigned(powMinus(6 downto 0)));
      if powMinus(7)='1' then
        mantC:=std_logic_vector(shift_left(unsigned(mantB), tshift))+mantA;
      else
        mantC:=std_logic_vector(shift_right(unsigned(mantB), tshift))+mantA;
      end if;
      
      else
       powMinus := powA-powB;
        tshift := to_integer(unsigned(powMinus(6 downto 0)));
        if powMinus(7)='1' then
           mantC:=std_logic_vector(shift_left(unsigned(mantA), tshift))+mantB;
        else 
           mantC:=std_logic_vector(shift_right(unsigned(mantA), tshift))+mantB;
        end if;
      end if;
      

   
   --korrutamine        
   elsif mode = "10" then
    mult:= std_logic_vector(signed(mantA)*signed(mantB));
    powPlus:= std_logic_vector(powA(7)&powA) + std_logic_vector(powB(7)&powB);
    
    --Korrutise väärtus
    if (to_integer(signed(mult))) > 4095 or (to_integer(signed(mult))) < -3072 then
        if to_integer(signed(powC))<127 or to_integer(signed(powC))>-96 then
        
        --positiivne
        if (to_integer(signed(mult))) > 0 then
          for index in ((mlen+mlen)-1) downto 0 loop
                      if mult(index) > '0'  then
                      
                      if (to_integer(signed(powC)) + index)<=127 then  
                      mantC:=std_logic_vector(shift_left(unsigned(mult), index-8));
                      powc:=powc + (index-8);
                      else                    
                        errorCode<="1001";
                      end if;
                      
                      exit;
                      end if;   
            end loop;
        --negatiivne
        else
        end if;
        else
        --Mantiss on suur, aga astendaja on ka suur
                   errorCode<="1011";
        end if;
     
    else
   
    mantC:=mult(13 downto 0);
    powC:=powPlus(7 downto 0);
    
    end if;
   
   
   --Mode if end
   end if;
   

      --kui mantiss on liiga suur suurendame astendajat
      if to_integer(signed(mantC)) < -3072 or to_integer(signed(mantC)) > 4095 then
         if to_integer(signed(powC))<127 or to_integer(signed(powC))>-96 then
         powC := powC+1;
         mant<=mantC(13 downto 1);
         else 
         errorCode<="1111";
         end if;
      else
         mant<=mantC(12 downto 0);
      end if;

      pow<=powC;
      
end process;

end Behavioral;
