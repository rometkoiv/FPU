library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
USE IEEE.NUMERIC_STD.ALL;

--Veakoodid
--1001 Positiivset tulemust ei saa vähendada
--1010 Negatiivsed tulemust ei saa vähendada
--1111 mantissi ei saa vähendada

entity float_calc is
    Port ( clk : in STD_LOGIC;
           errorCode : out STD_LOGIC_VECTOR (3 downto 0):=(others => '0');
           mantA_in : in STD_LOGIC_VECTOR (12 downto 0):=(others => '0');
           mantB_in : in STD_LOGIC_VECTOR (12 downto 0):=(others => '0');
           powA_in : in STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
           powB_in : in STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
           mode : in STD_LOGIC_VECTOR (1 downto 0);
           mant : out STD_LOGIC_VECTOR (12 downto 0):=(others => '0');
           pow : out STD_LOGIC_VECTOR (7 downto 0):=(others => '0'));
           
end float_calc;

architecture Behavioral of float_calc is
begin



float_calculator : process(clk)
--Constants
variable mlen : INTEGER range 1 to (INTEGER'high) := 13;
variable plen : INTEGER range 1 to (INTEGER'high) := 7; 

--variables
variable tshift : INTEGER range 1 to (INTEGER'high):=1;
variable powA : STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
variable powB : STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
variable powC : STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
variable mantA : STD_LOGIC_VECTOR (13 downto 0):=(others => '0');
variable mantB : STD_LOGIC_VECTOR (13 downto 0):=(others => '0');
variable mantC : STD_LOGIC_VECTOR (13 downto 0):=(others => '0');
variable mantT : STD_LOGIC_VECTOR (13 downto 0):=(others => '0');
variable powMinus : STD_LOGIC_VECTOR (7 downto 0):=(others => '0');
variable powPlus : STD_LOGIC_VECTOR (8 downto 0):=(others => '0');

variable minusOne : STD_LOGIC_VECTOR (13 downto 0):=(others => '1');
variable mult : STD_LOGIC_VECTOR (27 downto 0):=(others => '0');
variable multMax : INTEGER range 1 to (INTEGER'high);

variable longShift : STD_LOGIC_VECTOR (27 downto 0):=(others => '0');

begin
 powA:=powA_in;
 powB:=powB_in;
 --Pikendame mantisse, et hõlbustada liitmise ja lahutamise arvutamist
 -- mantA:=mantA_in(mlen-1)&mantA_in;
 -- mantB:=mantB_in(mlen-1)&mantB_in;
  
  --Normaliseerime
  --A
  if mantA_in(mlen-1)='1' then
    for index in (mlen-2) downto 0 loop
    if mantA_in(index)='0' then
       mantA(mlen downto (mlen-2)-index):="11"&mantA_in(index downto 0);
       powA:= powA-((mlen-2)-index);
       exit;
       end if;
    end loop;
  else
    for index in (mlen-2) downto 0 loop
      if mantA_in(index)='1' then
         mantA(mlen downto (mlen-2)-index):="00"&mantA_in(index downto 0);
         powA:=powA-((mlen-2)-index);
         exit;
         end if;
      end loop;
  end if;
  
    --B
  if mantB(mlen-1)='1' then
    for index in (mlen-2) downto 0 loop
    if mantB_in(index)='0' then
       mantB(mlen downto (mlen-2)-index):="11"&mantB_in(index downto 0);
       powB:=powB-((mlen-2)-index);
       exit;
       end if;
    end loop;
  else
    for index in (mlen-2) downto 0 loop
      if mantB_in(index)='1' then
         mantB(mlen downto (mlen-2)-index):="00"&mantB_in(index downto 0);
         powB:=powB-((mlen-2)-index);
         exit;
         end if;
      end loop;
  end if;
 
   
  --Liitmine
   if mode="00" or mode="01" then
       
      --Lahutamine
      if mode = "01" then
        --muudame mantB märki
        mult := std_logic_vector(signed(mantB)*signed(minusOne));
        mantB := mult(13 downto 0);
      end if;
       
      --Teeme kindlaks kumb astendaja on suurem
      
      if to_integer(signed(powA)) > to_integer(signed(powB)) then
         powC:=powA;
      else
         powC:=powB;
      end if;
      
      --Olenevalt kumb astendaja on suurem tuleb valem kirjutada
      if powC=powA then
       
       powMinus := powB-powA;
       errorCode<= powMinus(3 downto 0);
       tshift := to_integer(signed(powMinus)*(-1));
         if powMinus(plen)='1' then
           mantC:=std_logic_vector(shift_right(signed(mantB), tshift))+mantA;
         else
           mantC:=std_logic_vector(shift_left(signed(mantB), tshift))+mantA;
         end if;
      
      else
       powMinus := powA-powB;
       tshift := to_integer(signed(powMinus)*(-1));
       if powMinus(plen)='1' then
          mantC:=std_logic_vector(shift_right(signed(mantA), tshift))+mantB;
       else 
          mantC:=std_logic_vector(shift_left(signed(mantA), tshift))+mantB;
       end if;
      end if;
      

   
   --korrutamine        
   elsif mode = "10" then
    mult:= std_logic_vector(signed(mantA)*signed(mantB));
    powPlus:= std_logic_vector(powA(7)&powA) + std_logic_vector(powB(7)&powB);
    
    --Korrutise väärtus
    if (to_integer(signed(mult))) > 4095 or (to_integer(signed(mult))) < -3072 then
        
        
        --positiivse mantissi vähendamine
        if (to_integer(signed(mult))) > 0 then
        
          for index in (mlen+mlen+1) downto mlen loop
              if mult(index) > '0'  then
                      
                  if (to_integer(signed(powPlus)) + (index-mlen))<=127 then  
                    mantC:= mult((index) downto (index-mlen));
                    powPlus:=powPlus + (index-mlen);
                    
                  else  
                    --Positiivset tulemust ei saa vähendada                  
                    errorCode<="1001";
                  end if;
                      
                 exit;
               end if;   
            end loop;
        --negatiivse mantissi suurendamine
        else
           for index in (mlen+mlen+1) downto mlen loop
               if mult(index) = '0'  then
                  if (to_integer(signed(powPlus)) - (index-mlen))>=-96 then  
                  
                    mantC:= mult((index) downto (index-mlen));
                    powPlus:=powPlus - (index-mlen);
                    
                  else  
                  --Negatiivset tulemust ei saa vähendada                  
                    errorCode<="1010";
                  end if;
                              
                 exit;
               end if;   
           end loop;
        end if;
       
     
    else
    --Kui korras kanname otse üle
    mantC:=mult(13 downto 0);
    end if;
    
    powC:=powPlus(7 downto 0);
   
   --Mode if end
   end if;
   

      --kui mantiss on liiga suur, suurendame astendajat
      if to_integer(signed(mantC)) < -3072 or to_integer(signed(mantC)) > 4095 then
         if to_integer(signed(powC))<127 or to_integer(signed(powC))>-96 then
          if mantC(13)='0' then
            powC := powC+1;
            mant<=mantC(13 downto 1);
          else
            
            powC := powC-1;
            mant<=mantC(13 downto 1);
                  
          end if;
         else 
         errorCode<="1111";
         end if;
      else
         mant<=mantC(12 downto 0);
      end if;

      pow<=powC;
      
end process;

end Behavioral;
