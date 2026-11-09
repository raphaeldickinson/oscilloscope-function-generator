library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;                -- SIGNED for the trigger voltage
use work.acquireToHDMI_package.all;
use work.hdmi_package.all;
use work.basicBuildingBlocks_package.all;


entity acquireToHDMI is
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
           hdmiOen:    out STD_LOGIC
		   );
end acquireToHDMI;

architecture behavior of acquireToHDMI is

    -- Button lockout: after a button changes level, further changes on that
    -- button are ignored for 2^19 clocks (10.5 ms) so contact bounce does
    -- not give extra presses.  The first change is seen right away.
    constant LOCKOUT_WIDTH : NATURAL := 19;
    constant LOCKOUT_DONE : STD_LOGIC_VECTOR(LOCKOUT_WIDTH - 1 downto 0) := (others => '1');
    type lockoutArray is array (2 downto 0) of STD_LOGIC_VECTOR(LOCKOUT_WIDTH - 1 downto 0);

    signal cw: STD_LOGIC_VECTOR(CW_WIDTH -1 downto 0);
    signal sw: STD_LOGIC_VECTOR(SW_WIDTH -1 downto 0);
    signal forcedMode: STD_LOGIC;
    signal prevButton, buttonActivity: STD_LOGIC_VECTOR(2 downto 0);
    signal lockout: lockoutArray;
    signal triggerVolt16bitSigned: SIGNED(15 downto 0);
    signal triggerTimePixel: STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);

begin

    conversionPlusReadoutTime <= cw(CONVERSION_PLUS_READOUT_CW_BIT_INDEX);
    sampleTimerRollover <= cw(SAMPLE_TIMER_ROLLOVER_CW_BIT_INDEX);

    an7606convst <= cw(CONVST_CW_BIT_INDEX);
    an7606rd <= cw(RD_CW_BIT_INDEX);
    an7606cs <= cw(CS_CW_BIT_INDEX);
    an7606reset <= cw(RESET_AD7606_CW_BIT_INDEX);
    an7606od <= "000";

    triggerVolt16bitSigned <= TRIGGER_VOLT_16BIT_SIGNED;       -- 0 V
    triggerTimePixel <= TRIGGER_TIME_PIXEL;                     -- on the y-axis (column 640)

    ------------------------------------------------------------------------------
    -- Button Process
    -- buttonActivity has a '1' for one clock in each bit whose button went
    -- from '0' to '1'.  In the testbench that is a press.  On the board the
    -- PL keys are active low, so it is the release of the key.  prevButton
    -- is loaded with btn during reset so a key that is already '1' does not
    -- count as a press.
    -- forcedMode is '1' after reset and flips on every btn(1) activity.
    ------------------------------------------------------------------------------
    buttonProcess: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                prevButton <= btn;
                buttonActivity <= "000";
                lockout <= (others => LOCKOUT_DONE);
                forcedMode <= '1';
            else
                for i in 0 to 2 loop
                    if (btn(i) /= prevButton(i)) then
                        if (lockout(i) = LOCKOUT_DONE) then
                            buttonActivity(i) <= btn(i);        -- '1' only for a 0 -> 1 change
                        else
                            buttonActivity(i) <= '0';
                        end if;
                        lockout(i) <= (others => '0');
                    else
                        buttonActivity(i) <= '0';
                        if (lockout(i) /= LOCKOUT_DONE) then
                            lockout(i) <= lockout(i) + 1;
                        end if;
                    end if;
                end loop;
                prevButton <= btn;

                if (buttonActivity(1) = '1') then
                    forcedMode <= not forcedMode;
                end if;
            end if;
        end if;
    end process;

    sw(FORCED_MODE_SW_BIT_INDEX) <= forcedMode;
    sw(AD7606_BUSY_SW_BIT_INDEX) <= an7606busy;
    sw(SINGLE_FORCED_TRIGGER_SW_BIT_INDEX) <= buttonActivity(0);
    triggerCh1 <= sw(CH1_TRIGGER_SW_BIT_INDEX);
    triggerCh2 <= sw(CH2_TRIGGER_SW_BIT_INDEX);

 	datapath_inst: acquireToHDMI_datapath
        PORT MAP (
            clk => clk,
            resetn => resetn,
            cw => cw,
            sw => sw(DATAPATH_SW_WIDTH - 1 downto 0),
            an7606data => an7606data,
            triggerVolt16bitSigned => triggerVolt16bitSigned,
            triggerTimePixel => triggerTimePixel,
            ch1Data16bitSLV => open,
            ch2Data16bitSLV => open,
            tmdsDataP => tmdsDataP,
            tmdsDataN => tmdsDataN,
            tmdsClkP => tmdsClkP,
            tmdsClkN => tmdsClkN,
            hdmiOen => hdmiOen);

	control_inst: acquireToHDMI_fsm
	   PORT MAP (
            clk => clk,
            resetn => resetn,
            sw => sw,
            cw => cw);

end behavior;