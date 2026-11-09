library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.acquireToHDMI_Package.all;
use work.basicBuildingBlocks_package.all;
use work.hdmi_package.all;

entity acquireToHDMI_datapath is
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
           hdmiOen:    out STD_LOGIC
		   );
end acquireToHDMI_datapath;

architecture behavior of acquireToHDMI_datapath is

    -- Center row of the scope face: (60 + 660) / 2 = 360  (400 at the handout position)
    constant V_CENTER : NATURAL := (to_integer(unsigned(T_EDGE)) + to_integer(unsigned(B_EDGE))) / 2;

    -- Convert a 16-bit 2's complement sample into a row of the scope face.
    --     row = V_CENTER - (sample * SCOPE_HEIGHT) / 65536
    -- Full scale (+32767 / -32768) lands on the top / bottom edge (60 / 660)
    -- and 0 V lands on the center line.  The divide by 65536 is an
    -- arithmetic shift right by 16.
    function twosToPixel(sample: SIGNED(15 downto 0)) return STD_LOGIC_VECTOR is
        variable product : SIGNED(27 downto 0);
        variable row : SIGNED(27 downto 0);
    begin
        product := sample * to_signed(-SCOPE_HEIGHT, 12);
        row := shift_right(product, 16) + to_signed(V_CENTER, 28);
        return STD_LOGIC_VECTOR(row(VIDEO_WIDTH_IN_BITS - 1 downto 0));
    end function;

    -- The counters are never loaded (c = "01" is not used), so their D inputs are tied to 0
    constant SHORT_DELAY_LOAD_VALUE : STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := (others => '0');
    constant LONG_DELAY_LOAD_VALUE : STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := (others => '0');
    constant DATA_STORAGE_LOAD_VALUE : STD_LOGIC_VECTOR(BRAM_ADDR_WIDTH - 1 downto 0) := (others => '0');
    constant TIMER_LOAD_VALUE : STD_LOGIC_VECTOR(SAMPLE_TIMER_WIDTH - 1 downto 0) := (others => '0');

    signal storeIntoBramFlag: STD_LOGIC;

    -- Counters
    signal shortDelayCounter : STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);
    signal longDelayCounter : STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);
    signal dataStorageCounter : STD_LOGIC_VECTOR(BRAM_ADDR_WIDTH - 1 downto 0);
    signal timerCounter : STD_LOGIC_VECTOR(SAMPLE_TIMER_WIDTH - 1 downto 0);
    signal sampleRate : STD_LOGIC_VECTOR(SAMPLE_TIMER_WIDTH - 1 downto 0);

    -- Trigger registers and compares
    signal firstCh1DataStdLogicVector, secondCh1DataStdLogicVector : STD_LOGIC_VECTOR(15 downto 0);
    signal firstCh2DataStdLogicVector, secondCh2DataStdLogicVector : STD_LOGIC_VECTOR(15 downto 0);
    signal firstCh1GreaterThanTrigger, secondCh1LessThanTrigger : STD_LOGIC;
    signal firstCh2GreaterThanTrigger, secondCh2LessThanTrigger : STD_LOGIC;

    -- Video
    signal videoClk, videoClk5x, clkLocked : STD_LOGIC;
    signal reset : STD_LOGIC;                                       -- hdmi_tx_0 reset is active high
    signal hs, vs, de : STD_LOGIC;
    signal pixelHorz, pixelVert : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
    signal red, green, blue : STD_LOGIC_VECTOR(7 downto 0);
    signal bramReadAddress : STD_LOGIC_VECTOR(BRAM_ADDR_WIDTH - 1 downto 0);
    signal ch1BramData, ch2BramData : STD_LOGIC_VECTOR(15 downto 0);
    signal ch1Pixel, ch2Pixel, triggerVoltPixel : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
    signal ch1, ch2 : STD_LOGIC;

begin

    ---------------------------------------------------------------------------
    -- Simple SR Latch to assist FSM
    ---------------------------------------------------------------------------
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(resetn ='0') then
                storeIntoBramFlag <= '0';
            elsif (cw(SET_STORE_FLAG_CW_BIT_INDEX) = '1') then
                storeIntoBramFlag <= '1';
            elsif (cw(CLEAR_STORE_FLAG_CW_BIT_INDEX) = '1') then
                storeIntoBramFlag <= '0';
            end if;
        end if;
    end process;

    sw(STORE_INTO_BRAM_SW_BIT_INDEX) <= storeIntoBramFlag;

    ---------------------------------------------------------------------------
    -- Short delay: 16 clocks.  CONVST pulse, AD7606 RESET pulse, RD low
    -- and RD high times.
    ---------------------------------------------------------------------------
	shortDelayCounter_inst: genericCounter
        GENERIC MAP(SHORT_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    c => cw(SHORT_DELAY_COUNTER_CW_BIT_INDEX + CONTROL_CW_WIDTH - 1 downto SHORT_DELAY_COUNTER_CW_BIT_INDEX),
                    d => SHORT_DELAY_LOAD_VALUE,
                    q => shortDelayCounter);

	shortDelayCompare_inst: genericCompare
        GENERIC MAP(SHORT_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(   x => shortDelayCounter,
                    y => SHORT_DELAY_50Mhz_COUNTS,
                    g => open,
                    l => open,
                    e => sw(SHORT_DELAY_DONE_SW_BIT_INDEX));

    ---------------------------------------------------------------------------
    -- Long delay: 65535 clocks (1.31 ms) after power up, before the AD7606
    -- is reset.
    ---------------------------------------------------------------------------
	longDelayCounter_inst: genericCounter
        GENERIC MAP(LONG_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    c => cw(LONG_DELAY_COUNTER_CW_BIT_INDEX + CONTROL_CW_WIDTH - 1 downto LONG_DELAY_COUNTER_CW_BIT_INDEX),
                    d => LONG_DELAY_LOAD_VALUE,
                    q => longDelayCounter);

	longDelayCompare_inst: genericCompare
        GENERIC MAP(LONG_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(   x => longDelayCounter,
                    y => LONG_DELAY_50Mhz_COUNTS,
                    g => open,
                    l => open,
                    e => sw(LONG_DELAY_DONE_SW_BIT_INDEX));

    ---------------------------------------------------------------------------
    -- Sample timer.  Reset at the start of every sample (BEGIN_CONVERSION)
    -- and compared against the interval picked by SAMPLING_RATE_SELECT.
    ---------------------------------------------------------------------------
	timerCounter_inst: genericCounter
        GENERIC MAP(SAMPLE_TIMER_WIDTH)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    c => cw(SAMPLING_COUNTER_CW_BIT_INDEX + CONTROL_CW_WIDTH - 1 downto SAMPLING_COUNTER_CW_BIT_INDEX),
                    d => TIMER_LOAD_VALUE,
                    q => timerCounter);

    sampleRateMux_inst: genericMux4x1
        GENERIC MAP(SAMPLE_TIMER_WIDTH)
        PORT MAP(   y3 => LOWEST_RATE,
                    y2 => LOW_RATE,
                    y1 => HIGH_RATE,
                    y0 => HIGHEST_RATE,
                    s => cw(SAMPLING_RATE_SELECT_CW_BIT_INDEX + CONTROL_CW_WIDTH - 1 downto SAMPLING_RATE_SELECT_CW_BIT_INDEX),
                    f => sampleRate);

	timerCompare_inst: genericCompare
        GENERIC MAP(SAMPLE_TIMER_WIDTH)
        PORT MAP(   x => timerCounter,
                    y => sampleRate,
                    g => open,
                    l => open,
                    e => sw(SAMPLE_INTERVAL_SW_BIT_INDEX));

    ---------------------------------------------------------------------------
    -- Data storage counter: the BRAM write address.  Reset when the store
    -- flag is set or cleared, incremented after ch2 is written.
    ---------------------------------------------------------------------------
	dataStorageCounter_inst: genericCounter
        GENERIC MAP(BRAM_ADDR_WIDTH)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    c => cw(DATA_STORAGE_COUNTER_CW_BIT_INDEX + CONTROL_CW_WIDTH - 1 downto DATA_STORAGE_COUNTER_CW_BIT_INDEX),
                    d => DATA_STORAGE_LOAD_VALUE,
                    q => dataStorageCounter);

	dataStorageCompare_inst: genericCompare
        GENERIC MAP(BRAM_ADDR_WIDTH)
        PORT MAP(   x => dataStorageCounter,
                    y => NUMBER_OF_SAMPLES,
                    g => open,
                    l => open,
                    e => sw(MEMORY_FULL_SW_BIT_INDEX));

    ---------------------------------------------------------------------------
    -- Trigger registers.  Each TRIG_CHx_WRITE shifts the new sample into
    -- "first" and moves the old "first" into "second".
    ---------------------------------------------------------------------------
    firstCh1Register_inst: genericRegister
        GENERIC MAP(16)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    load => cw(TRIG_CH1_WRITE_CW_BIT_INDEX),
                    d => an7606data,
                    q => firstCh1DataStdLogicVector);

    secondCh1Register_inst: genericRegister
        GENERIC MAP(16)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    load => cw(TRIG_CH1_WRITE_CW_BIT_INDEX),
                    d => firstCh1DataStdLogicVector,
                    q => secondCh1DataStdLogicVector);

    firstCh2Register_inst: genericRegister
        GENERIC MAP(16)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    load => cw(TRIG_CH2_WRITE_CW_BIT_INDEX),
                    d => an7606data,
                    q => firstCh2DataStdLogicVector);

    secondCh2Register_inst: genericRegister
        GENERIC MAP(16)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    load => cw(TRIG_CH2_WRITE_CW_BIT_INDEX),
                    d => firstCh2DataStdLogicVector,
                    q => secondCh2DataStdLogicVector);

    -- The samples are 2's complement, so these compares are signed
    firstCh1GreaterThanTrigger <= '1' when (signed(firstCh1DataStdLogicVector) > triggerVolt16bitSigned) else '0';
    secondCh1LessThanTrigger <= '1' when (signed(secondCh1DataStdLogicVector) < triggerVolt16bitSigned) else '0';
    sw(CH1_TRIGGER_SW_BIT_INDEX) <= firstCh1GreaterThanTrigger and secondCh1LessThanTrigger;

    firstCh2GreaterThanTrigger <= '1' when (signed(firstCh2DataStdLogicVector) > triggerVolt16bitSigned) else '0';
    secondCh2LessThanTrigger <= '1' when (signed(secondCh2DataStdLogicVector) < triggerVolt16bitSigned) else '0';
    sw(CH2_TRIGGER_SW_BIT_INDEX) <= firstCh2GreaterThanTrigger and secondCh2LessThanTrigger;

    ch1Data16bitSLV <= firstCh1DataStdLogicVector;
    ch2Data16bitSLV <= firstCh2DataStdLogicVector;

    ---------------------------------------------------------------------------
    -- Sample storage.  Port A writes on clk at dataStorageCounter.
    -- Port B reads on videoClk.  Port B has a 2 clock read latency, so it
    -- is addressed BRAM_READ_LATENCY columns ahead: the word that comes out
    -- belongs to the column pixelHorz is on by then.
    ---------------------------------------------------------------------------
    bramReadAddress <= STD_LOGIC_VECTOR(resize(unsigned(pixelHorz) - unsigned(L_EDGE) + BRAM_READ_LATENCY, BRAM_ADDR_WIDTH));

    dataStorage_ch1: blk_mem_gen_0
        PORT MAP (  clka => clk,
                    ena => '1',
                    wea => cw(DATA_STORAGE_CH1_WRITE_CW_BIT_INDEX downto DATA_STORAGE_CH1_WRITE_CW_BIT_INDEX),
                    addra => dataStorageCounter,
                    dina => an7606data,
                    clkb => videoClk,
                    enb => '1',
                    addrb => bramReadAddress,
                    doutb => ch1BramData);

    dataStorage_ch2: blk_mem_gen_0
        PORT MAP (  clka => clk,
                    ena => '1',
                    wea => cw(DATA_STORAGE_CH2_WRITE_CW_BIT_INDEX downto DATA_STORAGE_CH2_WRITE_CW_BIT_INDEX),
                    addra => dataStorageCounter,
                    dina => an7606data,
                    clkb => videoClk,
                    enb => '1',
                    addrb => bramReadAddress,
                    doutb => ch2BramData);

    ---------------------------------------------------------------------------
    -- Sample -> row on the screen.  A trace pixel is drawn where the row
    -- of the stored sample matches the row being drawn.
    ---------------------------------------------------------------------------
    ch1Pixel <= twosToPixel(signed(ch1BramData));
    ch2Pixel <= twosToPixel(signed(ch2BramData));
    triggerVoltPixel <= twosToPixel(triggerVolt16bitSigned);

    ch1 <= '1' when (ch1Pixel = pixelVert) else '0';
    ch2 <= '1' when (ch2Pixel = pixelVert) else '0';

    ---------------------------------------------------------------------------
    -- Video (same as Lab 2)
    ---------------------------------------------------------------------------
    reset <= not resetn;
    hdmiOen <= '1';             -- enable the HDMI output on the ALINX board

    vc: clk_wiz_0
        PORT MAP (
            clk_in1 => clk,
            clk_out1 => videoClk,
            resetn => resetn,
            locked => clkLocked,
            clk_out2 => videoClk5x);

    -- The video logic uses resetn directly, like the reference design.
    -- resetn also holds the clocking wizard in reset, so videoClk is not
    -- running when resetn changes; it starts about 10 us after resetn goes
    -- high.  videoSignalGenerator and scopeFace start from their initial
    -- values (counters at 0) and count from the first videoClk edge, which
    -- puts h_cnt at 64 and v_cnt at 31 at 700 us, as in the reference.
    vsg: videoSignalGenerator
        PORT MAP (
            clk => videoClk,
            resetn => resetn,
            hs => hs,
            vs => vs,
            de => de,
            pixelHorz => pixelHorz,
            pixelVert => pixelVert);

    sf: scopeFace
        PORT MAP (
            clk => videoClk,
            resetn => resetn,
            pixelHorz => pixelHorz,
            pixelVert => pixelVert,
            triggerVolt => triggerVoltPixel,
            triggerTime => triggerTimePixel,
            red => red,
            green => green,
            blue => blue,
            ch1 => ch1,
            ch1Enb => '1',
            ch2 => ch2,
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

end behavior;