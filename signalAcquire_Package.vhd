library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


package signalAcquire_Package is


-- Clock period definitions
constant clk_period : time := 20 ns;			-- 50Mhz crystal input (XTL_IN).


-------------------------------------------------------------------------------
-- CONTROL WORD  cw(10 downto 0)   (output of the FSM, input to the datapath)
--
--  bit   10      9    8     7          6..5        4..3         2..1      0
--      CONVST   RD   CS   RESET   longDelay    shortDelay   regCounter  regFile
--                         AD7606   counter c    counter c    counter c   write
--
--  CONVST, RD, CS are active low (idle = '1').  RESET is active high.
--  The 2-bit counter fields are the c input of genericCounter:
--      00 = hold,  01 = load,  10 = increment,  11 = reset (to 0)
-------------------------------------------------------------------------------
CONSTANT CONVST_CW_BIT_INDEX : NATURAL := 10;
CONSTANT RD_CW_BIT_INDEX : NATURAL := 9;
CONSTANT CS_CW_BIT_INDEX : NATURAL := 8;
CONSTANT RESET_AD7606_CW_BIT_INDEX : NATURAL := 7;
CONSTANT REF_FILE_WRITE_CW_BIT_INDEX : NATURAL := 0;            -- register file write

-- Lowest bit of each 2-bit counter control field (field = INDEX+1 downto INDEX)
CONSTANT LONG_DELAY_COUNTER_CW_BIT_INDEX : NATURAL := 5;        -- cw(6 downto 5)
CONSTANT SHORT_DELAY_COUNTER_CW_BIT_INDEX : NATURAL := 3;       -- cw(4 downto 3)
CONSTANT REG_COUNTER_CW_BIT_INDEX : NATURAL := 1;               -- cw(2 downto 1)

-- genericCounter c input values
CONSTANT COUNTER_HOLD : STD_LOGIC_VECTOR(1 downto 0) := "00";
CONSTANT COUNTER_LOAD : STD_LOGIC_VECTOR(1 downto 0) := "01";
CONSTANT COUNTER_INC : STD_LOGIC_VECTOR(1 downto 0) := "10";
CONSTANT COUNTER_RESET : STD_LOGIC_VECTOR(1 downto 0) := "11";


-------------------------------------------------------------------------------
-- STATUS WORD  sw(4 downto 0)   (input of the FSM)
--
--  bit      4          3           2              1              0
--         BUSY     START_CONV   LONG_DELAY    SHORT_DELAY    ALL_CHANNELS
--       (AD7606)   (button)       DONE           DONE      HAVE_BEEN_READ
--
--  Bits 2..0 come from the datapath (comparators), bit 3 from the
--  button process and bit 4 straight from the AD7606 BUSY pin.
-------------------------------------------------------------------------------
CONSTANT ALL_CHANNELS_HAVE_BEEN_READ_SW_BIT_INDEX : NATURAL := 0;
CONSTANT SHORT_DELAY_DONE_SW_BIT_INDEX : NATURAL := 1;
CONSTANT LONG_DELAY_DONE_SW_BIT_INDEX : NATURAL := 2;
CONSTANT DATAPATH_SW_WIDTH : NATURAL := 3;

CONSTANT START_CONV_SW_BIT_INDEX : NATURAL := 3;
CONSTANT BUSY_SW_BIT_INDEX : NATURAL := 4;

CONSTANT SW_WIDTH : NATURAL := 5;
CONSTANT CW_WIDTH : NATURAL := 11;

-- 65535 counts x 20ns = 1.31ms of start-up delay
CONSTANT LONG_DELAY_50Mhz_CONST_WIDTH : NATURAL := 24;
CONSTANT LONG_DELAY_50Mhz_COUNTS : STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := x"00FFFF";

-- 16 counts x 20ns = 320ns, longer than every AD7606 minimum pulse width
-- (RESET 50ns, CONVST low 25ns, RD low 24ns, RD high 15ns)
CONSTANT SHORT_DELAY_50Mhz_CONST_WIDTH : NATURAL := 8;
CONSTANT SHORT_DELAY_50Mhz_COUNTS : STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := x"10";

-- The register counter picks which of the 8 registers a sample is written to.
-- It is 4 bits so it can count past the last channel (7) to 8.
CONSTANT REG_COUNTER_WIDTH : NATURAL := 4;
CONSTANT LAST_AD_CHANNEL : STD_LOGIC_VECTOR(REG_COUNTER_WIDTH - 1 downto 0) := "0111";

-- The register read out to the LED comparators (channel 1 = register 0)
CONSTANT REG0_ADDRESS : STD_LOGIC_VECTOR(2 downto 0) := "000";

-- The AX7010 PL LEDs light when their pin is driven low
CONSTANT LED_ON : STD_LOGIC := '0';
CONSTANT LED_OFF : STD_LOGIC := '1';

-- You need to determine the 16-bit 2's complement ADC values for these voltages
-- The AD7606 maps -5V..+5V onto -32768..+32767 counts, so
--      counts = V / 5V * 32768 = V * 6553.6     (rounded to the nearest count)
CONSTANT FOURTH_THRESHOLD_CONSTANT : STD_LOGIC_VECTOR(15 downto 0)  := x"4396";   -- 2.64V = 17302
CONSTANT THIRD_THRESHOLD_CONSTANT : STD_LOGIC_VECTOR(15 downto 0) := x"32B0";     -- 1.98V = 12976
CONSTANT SECOND_THRESHOLD_CONSTANT : STD_LOGIC_VECTOR(15 downto 0)   := x"21CB";  -- 1.32V =  8651
CONSTANT FIRST_THRESHOLD_CONSTANT : STD_LOGIC_VECTOR(15 downto 0)   := x"10E5";   -- 0.66V =  4325


-- States of the control unit, in the order they are visited.
-- RESET_STATE must stay first so that state starts there in simulation.
type state_type is (RESET_STATE, LONG_DELAY_STATE, RESET_AD7606_STATE, WAIT_FOR_TRIGGER_STATE,
                    ASSERT_CONV_STATE, WHILE_BUSY0_STATE, WHILE_BUSY1_STATE,
                    WAIT_FOR_VALID_AD_DATA_STATE, LATCH_AD_DATA_STATE,
                    PAUSE_BETWEEN_AD_CHANNELS_STATE, CLEAR_SHORT_COUNTER_STATE);


component signalAcquire_Fsm is
    PORT (  clk : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            sw: in STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
            cw: out STD_LOGIC_VECTOR (CW_WIDTH - 1 downto 0));
end component;

component signalAcquire_Datapath is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   cw : in STD_LOGIC_VECTOR(CW_WIDTH -1 downto 0);
		   sw : out STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   rfAddr: in STD_LOGIC_VECTOR(2 downto 0);
		   rfData: out STD_LOGIC_VECTOR(15 downto 0) );
end component;

component signalAcquire is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   btn: in	STD_LOGIC_VECTOR(2 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   an7606convst, an7606cs, an7606rd, an7606reset: out STD_LOGIC;
		   an7606od: out STD_LOGIC_VECTOR(2 downto 0);
		   an7606busy : in STD_LOGIC;
		   reg0Magnitude: out STD_LOGIC_VECTOR(3 downto 0));
end component;

component an7606_tb IS
    PORT ( clk : in  STD_LOGIC;
           an7606data: out STD_LOGIC_VECTOR(15 downto 0);
           an7606convst, an7606cs, an7606rd, an7606reset: in STD_LOGIC;
           an7606od: in STD_LOGIC_VECTOR(2 downto 0);
           an7606busy : out STD_LOGIC);
END component;


end package;