library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.signalAcquire_Package.all;				-- cw/sw indexes, delay counts
use work.basicBuildingBlocks_package.all;		-- include the basic building block library

entity signalAcquire_Datapath is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   cw : in STD_LOGIC_VECTOR(CW_WIDTH -1 downto 0);
		   sw : out STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   rfAddr: in STD_LOGIC_VECTOR(2 downto 0);
		   rfData: out STD_LOGIC_VECTOR(15 downto 0) );
end signalAcquire_Datapath;

architecture behavior of signalAcquire_Datapath is

    -- The counters are never loaded (c = "01" is not used), so their D inputs are tied to 0
    constant SHORT_DELAY_LOAD_VALUE : STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := (others => '0');
    constant LONG_DELAY_LOAD_VALUE : STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0) := (others => '0');
    constant REG_COUNTER_LOAD_VALUE : STD_LOGIC_VECTOR(REG_COUNTER_WIDTH - 1 downto 0) := (others => '0');

  	signal shortDelayCounter : STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);
  	signal longDelayCounter : STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);
  	signal regCounter : STD_LOGIC_VECTOR(REG_COUNTER_WIDTH - 1 downto 0);

begin

    ---------------------------------------------------------------------------
    -- Short delay: 16 clocks (320ns).  Used for the RESET pulse, the CONVST
    -- pulse, RD low while the data settles and RD high between channels.
    ---------------------------------------------------------------------------
	shortDelayCounter_inst: genericCounter
        GENERIC MAP(SHORT_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    c => cw(SHORT_DELAY_COUNTER_CW_BIT_INDEX + 1 downto SHORT_DELAY_COUNTER_CW_BIT_INDEX),
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
    -- Long delay: 65535 clocks (1.31ms) after power up, before the AD7606
    -- is reset.
    ---------------------------------------------------------------------------
	longDelayCounter_inst: genericCounter
        GENERIC MAP(LONG_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    c => cw(LONG_DELAY_COUNTER_CW_BIT_INDEX + 1 downto LONG_DELAY_COUNTER_CW_BIT_INDEX),
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
    -- Register counter: index of the AD7606 channel being read (0..7).
    -- It reads 7 while the 8th channel is being read, which tells the FSM
    -- to go back to waiting for a trigger after this sample is latched.
    ---------------------------------------------------------------------------
	regCounter_inst: genericCounter
        GENERIC MAP(REG_COUNTER_WIDTH)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    c => cw(REG_COUNTER_CW_BIT_INDEX + 1 downto REG_COUNTER_CW_BIT_INDEX),
                    d => REG_COUNTER_LOAD_VALUE,
                    q => regCounter);

	regCompare_inst: genericCompare
        GENERIC MAP(REG_COUNTER_WIDTH)
        PORT MAP(   x => regCounter,
                    y => LAST_AD_CHANNEL,
                    g => open,
                    l => open,
                    e => sw(ALL_CHANNELS_HAVE_BEEN_READ_SW_BIT_INDEX));

    ---------------------------------------------------------------------------
    -- Register file holding the 8 samples.  Channel 1 is stored in
    -- register 0, channel 2 in register 1 and so on.
    ---------------------------------------------------------------------------
	adSamples_inst: generic8RegisterFile
        GENERIC MAP(16)
        PORT MAP(   clk => clk,
                    resetn => resetn,
                    write => cw(REF_FILE_WRITE_CW_BIT_INDEX),
                    wrAddr => regCounter(2 downto 0),
                    rdAddr => rfAddr,
                    D => an7606data,
                    Q => rfData);

end behavior;