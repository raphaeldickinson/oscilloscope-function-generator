library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.signalAcquire_Package.all;					-- Include any packages that are instantiated
use work.basicBuildingBlocks_package.all;			-- genericCompare for the LED comparators


entity signalAcquire is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   btn: in	STD_LOGIC_VECTOR(2 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   an7606convst, an7606cs, an7606rd, an7606reset: out STD_LOGIC;
		   an7606od: out STD_LOGIC_VECTOR(2 downto 0);
		   an7606busy : in STD_LOGIC;
		   reg0Magnitude: out STD_LOGIC_VECTOR(3 downto 0));
end signalAcquire;

architecture behavior of signalAcquire is

	signal cw: STD_LOGIC_VECTOR(CW_WIDTH - 1 downto 0);
	signal sw: STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);

	-- Button process
	signal prevButton, buttonActivity: STD_LOGIC_VECTOR(2 downto 0);

	-- Register 0 (channel 1) and the LED comparator results
	signal reg0Data: STD_LOGIC_VECTOR(15 downto 0);
	signal reg0Positive: STD_LOGIC;
	signal aboveFirstThreshold, aboveSecondThreshold: STD_LOGIC;
	signal aboveThirdThreshold, aboveFourthThreshold: STD_LOGIC;

begin

    ------------------------------------------------------------------------------
    -- AD7606 control pins come straight from the control word.
    -- od = "000" turns oversampling off (one sample per conversion).
    ------------------------------------------------------------------------------
    an7606convst <= cw(CONVST_CW_BIT_INDEX);
    an7606rd <= cw(RD_CW_BIT_INDEX);
    an7606cs <= cw(CS_CW_BIT_INDEX);
    an7606reset <= cw(RESET_AD7606_CW_BIT_INDEX);
    an7606od <= "000";

    ------------------------------------------------------------------------------
    -- Status word bits that do not come from the datapath
    ------------------------------------------------------------------------------
    sw(BUSY_SW_BIT_INDEX) <= an7606busy;
    sw(START_CONV_SW_BIT_INDEX) <= buttonActivity(0);

    ------------------------------------------------------------------------------
    -- Button process
    -- prevButton holds the buttons as they were on the last clock edge.
    -- buttonActivity has a '1' for one clock in each bit whose button went
    -- from '0' to '1'.  In the testbench that is the press of btn(0); on the
    -- board the PL keys are active low, so it is the release of PL_KEY4.
    -- buttonActivity is only updated once reset is released, so it reads
    -- 'U' until 30ns in simulation, as in the reference waveforms.
    ------------------------------------------------------------------------------
    buttonProcess: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                prevButton <= btn;
            else
                buttonActivity <= btn and not prevButton;
                prevButton <= btn;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------
    -- Datapath and control unit
    ------------------------------------------------------------------------------
 	datapath_inst: signalAcquire_Datapath
        PORT MAP (  clk => clk,
                    resetn => resetn,
                    cw => cw,
                    sw => sw(DATAPATH_SW_WIDTH - 1 downto 0),
                    an7606data => an7606data,
                    rfAddr => REG0_ADDRESS,
                    rfData => reg0Data);

	control_inst: signalAcquire_Fsm
	   PORT MAP (   clk => clk,
                    resetn => resetn,
                    sw => sw,
                    cw => cw);

    ------------------------------------------------------------------------------
    -- Channel 1 magnitude on the LEDs, as a bar graph that grows with voltage
    -- Each comparator says whether register 0 is above one of the four
    -- thresholds.  The comparators are unsigned, so a negative sample (a
    -- reading just below 0V) is forced to count as below every threshold.
    -- The PL LEDs light when their pin is low, so a pin is driven to LED_ON
    -- ('0') when the sample is above that LED's threshold.
    --   reg0Magnitude(0)  PL_LED1  on above 0.66V
    --   reg0Magnitude(1)  PL_LED2  on above 1.32V
    --   reg0Magnitude(2)  PL_LED3  on above 1.98V
    --   reg0Magnitude(3)  PL_LED4  on above 2.64V
    ------------------------------------------------------------------------------
    reg0Positive <= not reg0Data(15);

    firstThresholdCompare_inst: genericCompare
        GENERIC MAP(16)
        PORT MAP(   x => reg0Data,
                    y => FIRST_THRESHOLD_CONSTANT,
                    g => aboveFirstThreshold,
                    l => open,
                    e => open);

    secondThresholdCompare_inst: genericCompare
        GENERIC MAP(16)
        PORT MAP(   x => reg0Data,
                    y => SECOND_THRESHOLD_CONSTANT,
                    g => aboveSecondThreshold,
                    l => open,
                    e => open);

    thirdThresholdCompare_inst: genericCompare
        GENERIC MAP(16)
        PORT MAP(   x => reg0Data,
                    y => THIRD_THRESHOLD_CONSTANT,
                    g => aboveThirdThreshold,
                    l => open,
                    e => open);

    fourthThresholdCompare_inst: genericCompare
        GENERIC MAP(16)
        PORT MAP(   x => reg0Data,
                    y => FOURTH_THRESHOLD_CONSTANT,
                    g => aboveFourthThreshold,
                    l => open,
                    e => open);

    reg0Magnitude(0) <= LED_ON when (aboveFirstThreshold = '1' and reg0Positive = '1') else LED_OFF;
    reg0Magnitude(1) <= LED_ON when (aboveSecondThreshold = '1' and reg0Positive = '1') else LED_OFF;
    reg0Magnitude(2) <= LED_ON when (aboveThirdThreshold = '1' and reg0Positive = '1') else LED_OFF;
    reg0Magnitude(3) <= LED_ON when (aboveFourthThreshold = '1' and reg0Positive = '1') else LED_OFF;

end behavior;