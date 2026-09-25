library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use work.scopeToHdmi_package.all;

entity scopeToHdmi is
    PORT ( sysClk : in  STD_LOGIC;
         resetn : in  STD_LOGIC;
         btn: in	STD_LOGIC_VECTOR(2 downto 0);
         tmdsDataP : out  STD_LOGIC_VECTOR (2 downto 0);
         tmdsDataN : out  STD_LOGIC_VECTOR (2 downto 0);
         tmdsClkP : out STD_LOGIC;
         tmdsClkN : out STD_LOGIC;
         hdmiOen:    out STD_LOGIC);
end scopeToHdmi;


architecture structure of scopeToHdmi is


    signal red, green, blue: STD_LOGIC_VECTOR(7 downto 0);

    signal triggerTime, triggerVolt: STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
    signal pixelHorz, pixelVert: STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
	    
    signal ch1Wave, ch2Wave: STD_LOGIC;

    signal videoClk, videoClk5x, clkLocked: STD_LOGIC;

    -- Video timing from videoSignalGenerator to hdmi_tx_0
    signal hs, vs, de: STD_LOGIC;

    -- hdmi_tx_0 wants an active HIGH reset
    signal reset: STD_LOGIC;

    -- resetn re-timed to videoClk for videoSignalGenerator and scopeFace.
    -- The initial value "00" means the video logic starts out in reset.
    signal videoResetSync: STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal videoResetn: STD_LOGIC;

    -- Button handling (sysClk domain)
    signal btnMeta, btnSync: STD_LOGIC_VECTOR(2 downto 0);                  -- 2-flop synchronizer
    signal debounceCount: STD_LOGIC_VECTOR(DEBOUNCE_COUNTER_WIDTH - 1 downto 0);
    signal sampleTick: STD_LOGIC;                                           -- '1' for one clock every ~21 ms
    signal prevButton, currButton, activeButton: STD_LOGIC_VECTOR(2 downto 0);

begin

    reset <= not resetn;
    hdmiOen <= '1';             -- enable the HDMI output on the ALINX board


    ------------------------------------------------------------------------------
    -- Video-domain reset synchronizer (asynchronous assert, synchronous release)
    -- resetn also resets the clocking wizard, so videoClk is STOPPED while
    -- resetn = '0'.  A synchronous reset inside videoSignalGenerator/scopeFace
    -- would therefore never see a clock edge while resetn is low (in simulation
    -- the testbench releases resetn at 30 ns, but videoClk does not start until
    -- ~10 us).  Here resetn clears the two flip-flops immediately, and they only
    -- release videoResetn two videoClk edges after videoClk is running, so the
    -- video logic always gets a clean reset.  It also removes the button's
    -- asynchronous timing from the videoClk domain.
    ------------------------------------------------------------------------------
    process(videoClk, resetn)
    begin
        if resetn = '0' then
            videoResetSync <= "00";
        elsif rising_edge(videoClk) then
            videoResetSync <= videoResetSync(0) & '1';
        end if;
    end process;

    videoResetn <= videoResetSync(1);


    vsg: videoSignalGenerator
        PORT MAP (
            clk => videoClk,
            resetn => videoResetn,
            hs => hs,
            vs => vs,
            de => de,
            pixelHorz => pixelHorz,
            pixelVert => pixelVert);
                 

    sf: scopeFace
        PORT MAP (
            clk => videoClk,
            resetn => videoResetn,
            pixelHorz => pixelHorz,
            pixelVert => pixelVert,
            triggerVolt => triggerVolt,
            triggerTime => triggerTime,
            red => red,
            green => green,
            blue => blue,
            ch1 => ch1Wave,
            ch1Enb => '1',
            ch2 => ch2Wave,
            ch2Enb => '1');
                 

    hdmi_inst: hdmi_tx_0
        PORT MAP (
            pix_clk => videoClk,
            pix_clkx5 => videoClk5x,
            pix_clk_locked => clkLocked,
            rst => reset,
            red => red,
            green => green,
            blue => blue,
            hsync => hs,
            vsync => vs,
            vde => de,
            aux0_din => "0000",
            aux1_din => "0000",
            aux2_din => "0000",
            ade => '0',
            TMDS_CLK_P => tmdsClkP,
            TMDS_CLK_N => tmdsClkN,
            TMDS_DATA_P => tmdsDataP,
            TMDS_DATA_N => tmdsDataN);
            

    vc: clk_wiz_0
	PORT MAP( 
	    clk_out1 => videoClk,
	    clk_out2 => videoClk5x,
	    resetn => resetn,
	    locked => clkLocked,
	    clk_in1 => sysClk);

    ------------------------------------------------------------------------------
    -- Create a process which generates a 3-bit vector which shows if button
    -- has change state.  Use this change vector to determine if you should 
    -- increment/decrement the triggerTime or triggerVolt values
    ------------------------------------------------------------------------------

    -- Debounce timer.  A free-running counter; sampleTick is high for the one
    -- clock where the counter is all ones (every 2^20 clocks = ~21 ms).
    -- Looking at the buttons that rarely means a bouncing contact can produce
    -- at most one change between two looks, so one press/release = one step.
    process(sysClk)
    begin
        if rising_edge(sysClk) then
            if resetn = '0' then
                debounceCount <= (others => '0');
            else
                debounceCount <= debounceCount + 1;
            end if;
        end if;
    end process;

    sampleTick <= '1' when (debounceCount = (debounceCount'range => '1')) else '0';

    -- Hold the current and previous state of the three buttons.
    --   btnMeta/btnSync: two flip-flops that bring the asynchronous button
    --                    inputs safely into the sysClk domain.
    --   currButton:      the synchronized buttons, captured on each sampleTick.
    --   prevButton:      what currButton was on the previous sampleTick.
    -- All of them reset to the nominal (released) value "111".
    process(sysClk)
    begin
        if rising_edge(sysClk) then
            if resetn = '0' then
                btnMeta <= BUTTON_NOMINAL;
                btnSync <= BUTTON_NOMINAL;
                currButton <= BUTTON_NOMINAL;
                prevButton <= BUTTON_NOMINAL;
            else
                btnMeta <= btn;
                btnSync <= btnMeta;
                if (sampleTick = '1') then
                    prevButton <= currButton;
                    currButton <= btnSync;
                end if;
            end if;
        end if;
    end process;

    -- A '1' in activeButton means that button changed between the last two samples.
    activeButton <= prevButton xor currButton;

    -- Update the trigger values.
    -- activeButton only changes on a sampleTick and then holds for ~21 ms.  So
    -- this process also acts only on sampleTick: at that edge it still sees the
    -- prev/curr pair from the previous sample (the new pair is being loaded on
    -- the same edge), which means every detected change is acted on exactly
    -- once.  A change is a release when the button now reads '1' (released).
    process(sysClk)
    begin
        if rising_edge(sysClk) then
            if resetn = '0' then
                triggerVolt <= TRIGGER_VOLT_INIT;
                triggerTime <= TRIGGER_TIME_INIT;
            elsif (sampleTick = '1') then

                -- PL_KEY3 released (changed, and now back at '1')
                if (activeButton(BTN_VOLT) = '1') and (currButton(BTN_VOLT) = BUTTON_RELEASED) then
                    if (currButton(BTN_MODIFIER) = BUTTON_PRESSED) then
                        triggerVolt <= triggerVolt + TRIGGER_STEP;
                    else
                        triggerVolt <= triggerVolt - TRIGGER_STEP;
                    end if;
                end if;

                -- PL_KEY4 released
                if (activeButton(BTN_TIME) = '1') and (currButton(BTN_TIME) = BUTTON_RELEASED) then
                    if (currButton(BTN_MODIFIER) = BUTTON_PRESSED) then
                        triggerTime <= triggerTime + TRIGGER_STEP;
                    else
                        triggerTime <= triggerTime - TRIGGER_STEP;
                    end if;
                end if;
            end if;
        end if;
    end process;
 

    -- Test waveforms (from the lab schematic)
    --   ch1: a diagonal wherever row = column
    --   ch2: a horizontal line at the trigger voltage level
    ch1Wave <= '1' when  (pixelHorz = pixelVert) else '0';
    ch2Wave <= '1' when  (pixelVert = triggerVolt) else '0';

end structure;
