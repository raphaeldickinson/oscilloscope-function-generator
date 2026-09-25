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

    ------------------------------------------------------------------------------
    -- TRIGGER MARKER SETTINGS (used by the sysClk processes below)
    -- Everything is derived from the face outline in the package, using the
    -- same spacing scopeFace uses: 10 divisions x 5 hatch parts = 50 hatch
    -- spaces across and 50 down.  Elaboration-time arithmetic only.
    -- triggerVolt is a screen row, triggerTime is a screen column.
    ------------------------------------------------------------------------------
    constant FACE_LEFT   : NATURAL := to_integer(unsigned(L_EDGE));     -- 140
    constant FACE_RIGHT  : NATURAL := to_integer(unsigned(R_EDGE));     -- 1140
    constant FACE_TOP    : NATURAL := to_integer(unsigned(T_EDGE));     -- 60
    constant FACE_BOTTOM : NATURAL := to_integer(unsigned(B_EDGE));     -- 660
    constant HATCH_SPACES_PER_AXIS : NATURAL := 50;                     -- 10 divisions x 5 parts

    constant H_HATCH : NATURAL := (FACE_RIGHT - FACE_LEFT) / HATCH_SPACES_PER_AXIS;   -- 20 pixels
    constant V_HATCH : NATURAL := (FACE_BOTTOM - FACE_TOP) / HATCH_SPACES_PER_AXIS;   -- 12 pixels

    -- One click moves a marker by one hatch mark
    constant TIME_STEP : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := std_logic_vector(to_unsigned(H_HATCH, VIDEO_WIDTH_IN_BITS));
    constant VOLT_STEP : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := std_logic_vector(to_unsigned(V_HATCH, VIDEO_WIDTH_IN_BITS));

    -- Markers stay between the first and last hatch mark inside the face
    constant TIME_MIN : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := std_logic_vector(to_unsigned(FACE_LEFT   + H_HATCH, VIDEO_WIDTH_IN_BITS));  -- 160
    constant TIME_MAX : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := std_logic_vector(to_unsigned(FACE_RIGHT  - H_HATCH, VIDEO_WIDTH_IN_BITS));  -- 1120
    constant VOLT_MIN : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := std_logic_vector(to_unsigned(FACE_TOP    + V_HATCH, VIDEO_WIDTH_IN_BITS));  -- 72
    constant VOLT_MAX : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := std_logic_vector(to_unsigned(FACE_BOTTOM - V_HATCH, VIDEO_WIDTH_IN_BITS));  -- 648

    -- Reset positions, on hatch marks: time on the center line,
    -- volt three hatches below the center line so it doesn't hide the axis.
    constant TRIGGER_TIME_INIT : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) :=
        std_logic_vector(to_unsigned(FACE_LEFT + 25 * H_HATCH, VIDEO_WIDTH_IN_BITS));     -- 640
    constant TRIGGER_VOLT_INIT : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) :=
        std_logic_vector(to_unsigned(FACE_TOP + 28 * V_HATCH, VIDEO_WIDTH_IN_BITS));      -- 396

    -- The ALINX PL_KEY buttons read '1' when released and '0' when pressed.
    constant BUTTON_NOMINAL  : STD_LOGIC_VECTOR(2 downto 0) := "111";
    constant BUTTON_PRESSED  : STD_LOGIC := '0';
    constant BUTTON_RELEASED : STD_LOGIC := '1';

    -- Which btn bit does what
    constant BTN_MODIFIER : NATURAL := 0;      -- PL_KEY2: hold to reverse direction
    constant BTN_VOLT     : NATURAL := 1;      -- PL_KEY3: moves triggerVolt
    constant BTN_TIME     : NATURAL := 2;      -- PL_KEY4: moves triggerTime

    -- Debounce: buttons are sampled once every 2^20 sysClk cycles (~21 ms)
    constant DEBOUNCE_COUNTER_WIDTH : NATURAL := 20;



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
    signal sampleDone: STD_LOGIC;                     -- '1' the clock after a new sample is taken
    signal voltReverse, timeReverse: STD_LOGIC;       -- KEY2 was seen during this KEY3 / KEY4 press

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
    --   sampleDone:      '1' for the one clock right after a sample, when
    --                    prev/curr/activeButton already show the new sample.
    -- All of them reset to the nominal (released) value "111".
    process(sysClk)
    begin
        if rising_edge(sysClk) then
            if resetn = '0' then
                btnMeta <= BUTTON_NOMINAL;
                btnSync <= BUTTON_NOMINAL;
                currButton <= BUTTON_NOMINAL;
                prevButton <= BUTTON_NOMINAL;
                sampleDone <= '0';
            else
                btnMeta <= btn;
                btnSync <= btnMeta;
                sampleDone <= sampleTick;
                if (sampleTick = '1') then
                    prevButton <= currButton;
                    currButton <= btnSync;
                end if;
            end if;
        end if;
    end process;

    -- A '1' in activeButton means that button changed between the last two samples.
    activeButton <= prevButton xor currButton;

    -- Update the trigger values, once per new sample (sampleDone).
    --
    -- For each of KEY3 (volt) and KEY4 (time):
    --   * just pressed:  start remembering whether KEY2 is down
    --   * still held:    keep remembering if KEY2 goes down at any point
    --   * just released: move one hatch.  If KEY2 was seen at any time during
    --                    the press, or is down right now, move down / right;
    --                    otherwise move up / left.  Never move past the first
    --                    or last hatch mark.
    -- A move happens on the release, so each click moves exactly one hatch.
    process(sysClk)
        variable modifierDown : BOOLEAN;
    begin
        if rising_edge(sysClk) then
            if resetn = '0' then
                triggerVolt <= TRIGGER_VOLT_INIT;
                triggerTime <= TRIGGER_TIME_INIT;
                voltReverse <= '0';
                timeReverse <= '0';
            elsif (sampleDone = '1') then
                modifierDown := (currButton(BTN_MODIFIER) = BUTTON_PRESSED);

                ---------------- PL_KEY3: trigger volt marker (up / down) ----------------
                if (currButton(BTN_VOLT) = BUTTON_PRESSED) then
                    if (activeButton(BTN_VOLT) = '1') then          -- just pressed
                        if modifierDown then voltReverse <= '1'; else voltReverse <= '0'; end if;
                    elsif modifierDown then                         -- held, KEY2 now down
                        voltReverse <= '1';
                    end if;
                elsif (activeButton(BTN_VOLT) = '1') then           -- just released
                    if (voltReverse = '1') or modifierDown then
                        if (triggerVolt + VOLT_STEP <= VOLT_MAX) then
                            triggerVolt <= triggerVolt + VOLT_STEP;  -- down one hatch
                        end if;
                    else
                        if (triggerVolt >= VOLT_MIN + VOLT_STEP) then
                            triggerVolt <= triggerVolt - VOLT_STEP;  -- up one hatch
                        end if;
                    end if;
                    voltReverse <= '0';
                end if;

                ---------------- PL_KEY4: trigger time marker (left / right) -------------
                if (currButton(BTN_TIME) = BUTTON_PRESSED) then
                    if (activeButton(BTN_TIME) = '1') then          -- just pressed
                        if modifierDown then timeReverse <= '1'; else timeReverse <= '0'; end if;
                    elsif modifierDown then                         -- held, KEY2 now down
                        timeReverse <= '1';
                    end if;
                elsif (activeButton(BTN_TIME) = '1') then           -- just released
                    if (timeReverse = '1') or modifierDown then
                        if (triggerTime + TIME_STEP <= TIME_MAX) then
                            triggerTime <= triggerTime + TIME_STEP;  -- right one hatch
                        end if;
                    else
                        if (triggerTime >= TIME_MIN + TIME_STEP) then
                            triggerTime <= triggerTime - TIME_STEP;  -- left one hatch
                        end if;
                    end if;
                    timeReverse <= '0';
                end if;
            end if;
        end if;
    end process;
 

    -- Test waveforms (from the lab schematic)
    --   ch1: a 45 degree diagonal measured from the face's upper-left corner,
    --        i.e. (column - L_EDGE) = (row - T_EDGE).  The lab's original
    --        "pixelHorz = pixelVert" only starts at the corner when the corner
    --        sits on the screen diagonal, as (100,100) did; this form follows
    --        the face wherever it is placed.
    --   ch2: a horizontal line at the trigger voltage level
    ch1Wave <= '1' when  (pixelHorz - L_EDGE = pixelVert - T_EDGE) else '0';
    ch2Wave <= '1' when  (pixelVert = triggerVolt) else '0';

end structure;
