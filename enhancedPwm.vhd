----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.basicBuildingBlocks_package.all;

entity enhancedPwm is
    PORT ( clk       : in  STD_LOGIC;
           resetn    : in STD_LOGIC;
           enb       : in STD_LOGIC;
           dutyCycle : in STD_LOGIC_VECTOR (8 downto 0);
           pwmCount  : out STD_LOGIC_VECTOR (7 downto 0);
           rollOver  : out STD_LOGIC;
           pwmSignal : out STD_LOGIC
	);		   
end enhancedPwm;

architecture structure of enhancedPwm is

    constant CNT_HOLD     : STD_LOGIC_VECTOR (1 downto 0) := "00";
    constant CNT_UP       : STD_LOGIC_VECTOR (1 downto 0) := "10";
    constant CNT_CLEAR    : STD_LOGIC_VECTOR (1 downto 0) := "11";
    
    signal pwmCount_int   : STD_LOGIC_VECTOR (7 downto 0);
    signal pwmCount9bit   : STD_LOGIC_VECTOR (8 downto 0);
    signal dutyCycle9bit  : STD_LOGIC_VECTOR (8 downto 0);
    signal cw             : STD_LOGIC_VECTOR (1 downto 0);
    signal dutyGreaterCnt : STD_LOGIC;
    signal E255           : STD_LOGIC;    
    
begin
    cw <= CNT_CLEAR when E255 = '1' else
          CNT_UP    when enb  = '1' else
          CNT_HOLD;
    pwmCount9bit <= '0' & pwmCount_int;
    pwmCount <= pwmCount_int;
    rollOver <= E255; 
    
    pwmCounter  : genericCounter
        GENERIC MAP (8)
        PORT MAP (clk    => clk,
                  resetn => resetn,
                  c      => cw,
                  d      => x"00",
                  q      => pwmCount_int
        );
    
    rollOverCompare : genericCompare
        GENERIC MAP (8)
        PORT MAP (x => x"FF",
                  y => pwmCount_int,
                  g => open,
                  l => open,
                  e => E255
        );

    dutyRegister : genericRegister
        GENERIC MAP (9)
        PORT MAP (clk    => clk,
                  resetn => resetn,
                  load   => E255,
                  d      => dutyCycle,
                  q      => dutyCycle9bit
        );
    
    dutyCompare : genericCompare
        generic map (9)
        PORT MAP (x => dutyCycle9bit,
                  y => pwmCount9bit,
                  g => dutyGreaterCnt,
                  l => open,
                  e => open
        );            
    
    pwmSignalReg : process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                pwmSignal <= '0';
            else
                pwmSignal <= dutyGreaterCnt;
            end if;
        end if;
    end process;
    
end structure;