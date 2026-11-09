library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.hdmi_package.all;


package acquireToHDMI_package is


-- Clock period definitions
CONSTANT clk_period : time := 20 ns;			-- 50Mhz crystal input (XTL_IN).

-- One state per row of controlWord.xlsx (rows 10 to 30), in the same order
type state_type is (RESET_STATE, LONG_DELAY_STATE, RESET_AD7606_STATE, WAIT_FORCED_STATE,
                    SET_STORE_FLAG_STATE, CLEAR_STORE_FLAG_STATE, BEGIN_CONVERSION_STATE,
                    ASSERT_CONV_STATE, WHILE_BUSY0_STATE, WHILE_BUSY1_STATE,
                    READ_LOW_CH1_STATE, WRITE_TRIGGER_CH1_STATE, WRITE_BRAM_CH1_STATE, READ_HIGH_CH1_STATE,
                    RESET_SHORT_STATE,
                    READ_LOW_CH2_STATE, WRITE_TRIGGER_CH2_STATE, WRITE_BRAM_CH2_STATE, READ_HIGH_CH2_STATE,
                    WAIT_FOR_NEXT_SAMPLE_INTERVAL_STATE, BRAM_FULL_STATE);


---------------------------- CONTROL WORD -----------------------------
--  21  CLEAR_STORE_FLAG          1 = clear storeIntoBramFlag
--  20  SET_STORE_FLAG            1 = set storeIntoBramFlag
--  19  TRIG_CH2_WRITE            1 = shift ch2 sample into the trigger registers
--  18  TRIG_CH1_WRITE            1 = shift ch1 sample into the trigger registers
--  17  CONVERSION_PLUS_READOUT   1 = a conversion or readout is happening (LED / probe)
--  16  SAMPLE_TIMER_ROLLOVER     1 = start of a sample interval (LED / probe)
--  15  DATA_STORAGE_CH2_WRITE    1 = write AD7606 data into the ch2 BRAM
--  14  DATA_STORAGE_CH1_WRITE    1 = write AD7606 data into the ch1 BRAM
--  13  CONVST                    AD7606 CONVST pin
--  12  RD                        AD7606 RD pin  (active low)
--  11  CS                        AD7606 CS pin  (active low)
--  10  RESET_AD7606              AD7606 RESET pin (active high)
--  9,8 DATA_STORAGE_COUNTER      BRAM write address counter
--  7,6 SAMPLING_COUNTER          sample interval timer
--  5,4 SAMPLING_RATE_SELECT      00 HIGHEST, 01 HIGH, 10 LOW, 11 LOWEST
--  3,2 LONG_DELAY_COUNTER
--  1,0 SHORT_DELAY_COUNTER
--  Counter fields: 00 hold, 01 load, 10 increment, 11 reset
CONSTANT CW_WIDTH : NATURAL := 22;
CONSTANT CONTROL_CW_WIDTH : NATURAL := 2;          -- width of each counter control field (and the rate select)

CONSTANT CLEAR_STORE_FLAG_CW_BIT_INDEX : NATURAL := 21;
CONSTANT SET_STORE_FLAG_CW_BIT_INDEX : NATURAL := 20;
CONSTANT TRIG_CH2_WRITE_CW_BIT_INDEX : NATURAL := 19;
CONSTANT TRIG_CH1_WRITE_CW_BIT_INDEX : NATURAL := 18;
CONSTANT CONVERSION_PLUS_READOUT_CW_BIT_INDEX : NATURAL := 17;
CONSTANT SAMPLE_TIMER_ROLLOVER_CW_BIT_INDEX : NATURAL := 16;
CONSTANT DATA_STORAGE_CH2_WRITE_CW_BIT_INDEX : NATURAL := 15;
CONSTANT DATA_STORAGE_CH1_WRITE_CW_BIT_INDEX : NATURAL := 14;
CONSTANT CONVST_CW_BIT_INDEX : NATURAL := 13;
CONSTANT RD_CW_BIT_INDEX : NATURAL := 12;
CONSTANT CS_CW_BIT_INDEX : NATURAL := 11;
CONSTANT RESET_AD7606_CW_BIT_INDEX : NATURAL := 10;
CONSTANT DATA_STORAGE_COUNTER_CW_BIT_INDEX : NATURAL := 8;     -- bits 9,8
CONSTANT SAMPLING_COUNTER_CW_BIT_INDEX : NATURAL := 6;         -- bits 7,6
CONSTANT SAMPLING_RATE_SELECT_CW_BIT_INDEX : NATURAL := 4;     -- bits 5,4
CONSTANT LONG_DELAY_COUNTER_CW_BIT_INDEX : NATURAL := 2;       -- bits 3,2
CONSTANT SHORT_DELAY_COUNTER_CW_BIT_INDEX : NATURAL := 0;      -- bits 1,0

---------------------------- STATUS WORD -----------------------------
--  9  FORCED MODE          '1' forced mode, '0' trigger mode  (top level, btn(1) toggles)
--  8  AD7606 BUSY          AD7606 BUSY pin                    (top level)
--  7  SINGLE FORCED        one clock pulse per btn(0) press    (top level)
--  6  STORE INTO BRAM      storeIntoBramFlag                  (datapath)
--  5  CH2 TRIGGER          ch2 crossed the trigger level going up
--  4  CH1 TRIGGER          ch1 crossed the trigger level going up
--  3  SAMPLE INTERVAL      sample timer reached the selected rate
--  2  MEM FULL             BRAM write address = number of samples on screen
--  1  LONG DELAY DONE
--  0  SHORT DELAY DONE
CONSTANT SW_WIDTH : NATURAL := 10;
CONSTANT DATAPATH_SW_WIDTH : NATURAL := 7;         -- bits 6 downto 0 come from the datapath
CONSTANT FORCED_MODE_SW_BIT_INDEX : NATURAL := 9;
CONSTANT AD7606_BUSY_SW_BIT_INDEX : NATURAL := 8;
CONSTANT SINGLE_FORCED_TRIGGER_SW_BIT_INDEX : NATURAL := 7;
CONSTANT STORE_INTO_BRAM_SW_BIT_INDEX : NATURAL := 6;
CONSTANT CH2_TRIGGER_SW_BIT_INDEX : NATURAL := 5;
CONSTANT CH1_TRIGGER_SW_BIT_INDEX : NATURAL := 4;
CONSTANT SAMPLE_INTERVAL_SW_BIT_INDEX : NATURAL := 3;
CONSTANT MEMORY_FULL_SW_BIT_INDEX : NATURAL := 2;
CONSTANT LONG_DELAY_DONE_SW_BIT_INDEX : NATURAL := 1;
CONSTANT SHORT_DELAY_DONE_SW_BIT_INDEX : NATURAL := 0;


CONSTANT LONG_DELAY_50Mhz_CONST_WIDTH : NATURAL := 24;
CONSTANT LONG_DELAY_50Mhz_COUNTS : STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := x"00FFFF";

CONSTANT SHORT_DELAY_50Mhz_CONST_WIDTH : NATURAL := 8;
CONSTANT SHORT_DELAY_50Mhz_COUNTS : STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := x"10";

-- Sample interval in 50 MHz clocks.  The lowest rate has the longest interval.
CONSTANT SAMPLE_TIMER_WIDTH : NATURAL := 32;
CONSTANT HIGHEST_RATE   : STD_LOGIC_VECTOR(31 downto 0) := STD_LOGIC_VECTOR(to_unsigned(300, 32));     -- select "00"
CONSTANT HIGH_RATE      : STD_LOGIC_VECTOR(31 downto 0) := STD_LOGIC_VECTOR(to_unsigned(600, 32));     -- select "01"
CONSTANT LOW_RATE       : STD_LOGIC_VECTOR(31 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1200, 32));    -- select "10"
CONSTANT LOWEST_RATE    : STD_LOGIC_VECTOR(31 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2400, 32));    -- select "11"

-- BRAM: 1024 x 16 per channel, one sample per column of the scope face
CONSTANT BRAM_ADDR_WIDTH : NATURAL := 10;
CONSTANT NUMBER_OF_SAMPLES : STD_LOGIC_VECTOR(BRAM_ADDR_WIDTH - 1 downto 0) := STD_LOGIC_VECTOR(to_unsigned(SCOPE_WIDTH, BRAM_ADDR_WIDTH));  -- 1000

-- Port B of the BRAM has a 2 clock read latency (address register plus the
-- primitive output register), so it is addressed 2 pixels ahead.
CONSTANT BRAM_READ_LATENCY : NATURAL := 2;

-- Trigger settings used by the top level
CONSTANT TRIGGER_VOLT_16BIT_SIGNED : SIGNED(15 downto 0) := (others => '0');       -- 0 V
CONSTANT TRIGGER_TIME_PIXEL : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) :=
    STD_LOGIC_VECTOR(to_unsigned(640, VIDEO_WIDTH_IN_BITS));                        -- center column of the face


component acquireToHDMI_fsm is
    PORT (  clk : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            sw: in STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
            cw: out STD_LOGIC_VECTOR (CW_WIDTH - 1 downto 0));
end component;

component acquireToHDMI_datapath is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
           cw : in STD_LOGIC_VECTOR(CW_WIDTH -1 downto 0);
           sw : out STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
           an7606data: in STD_LOGIC_VECTOR(15 downto 0);
           triggerVolt16bitSigned: in SIGNED(15 downto 0);
           triggerTimePixel: in STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0);
           ch1Data16bitSLV, ch2Data16bitSLV: out STD_LOGIC_VECTOR(15 downto 0);
           tmdsDataP : out  STD_LOGIC_VECTOR (2 downto 0);
           tmdsDataN : out  STD_LOGIC_VECTOR (2 downto 0);
           tmdsClkP : out STD_LOGIC;
           tmdsClkN : out STD_LOGIC;
           hdmiOen:    out STD_LOGIC);
end component;

component acquireToHDMI is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
           btn: in	STD_LOGIC_VECTOR(2 downto 0);
           triggerCh1, triggerCh2: out STD_LOGIC;
           conversionPlusReadoutTime: out STD_LOGIC;
           sampleTimerRollover: out STD_LOGIC;
           an7606data: in STD_LOGIC_VECTOR(15 downto 0);
           an7606convst, an7606cs, an7606rd, an7606reset: out STD_LOGIC;
           an7606od: out STD_LOGIC_VECTOR(2 downto 0);
           an7606busy : in STD_LOGIC;
           tmdsDataP : out  STD_LOGIC_VECTOR (2 downto 0);
           tmdsDataN : out  STD_LOGIC_VECTOR (2 downto 0);
           tmdsClkP : out STD_LOGIC;
           tmdsClkN : out STD_LOGIC;
           hdmiOen:    out STD_LOGIC);
end component;

component an7606 is
    PORT ( clk : in  STD_LOGIC;
           an7606data: out STD_LOGIC_VECTOR(15 downto 0);
           an7606convst, an7606cs, an7606rd, an7606reset: in STD_LOGIC;
           an7606od: in STD_LOGIC_VECTOR(2 downto 0);
           an7606busy : out STD_LOGIC);
END component;

component blk_mem_gen_0 is
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;

end package;