library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.signalAcquire_Package.all;			-- include your library here with added components ac97, ac97cmd

entity signalAcquire_Fsm is
    PORT (  clk : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            sw: in STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
            cw: out STD_LOGIC_VECTOR (CW_WIDTH - 1 downto 0));
end signalAcquire_Fsm;

architecture Behavioral of signalAcquire_Fsm is

	signal state: state_type;

	signal SHORT_DELAY_DONE_SW, LONG_DELAY_DONE_SW, ALL_CHANNELS_HAVE_BEEN_READ_SW : STD_LOGIC;
	signal START_CONV_SW, BUSY_SW : STD_LOGIC;

begin

    -- defining intuitive names for the status word bits to make interperting the
    -- logic in the state_process much easier and thus, you'll make fewer errors.
    SHORT_DELAY_DONE_SW <= sw(SHORT_DELAY_DONE_SW_BIT_INDEX);
    LONG_DELAY_DONE_SW <= sw(LONG_DELAY_DONE_SW_BIT_INDEX);
    ALL_CHANNELS_HAVE_BEEN_READ_SW <= sw(ALL_CHANNELS_HAVE_BEEN_READ_SW_BIT_INDEX);
    START_CONV_SW <= sw(START_CONV_SW_BIT_INDEX);
    BUSY_SW <= sw(BUSY_SW_BIT_INDEX);

	-------------------------------------------------------------------------------
	-- Next state logic.  Every state that waits on a delay stays put until the
	-- matching "done" status bit is set.  The short delay counter is started
	-- from 0 in every state that uses it (see the output process below).
	-------------------------------------------------------------------------------
	state_proces: process(clk)
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then
				state <= RESET_STATE;
			else
				case state is

                    -- Leave reset on the first clock edge after resetn goes high
                    when RESET_STATE =>
                        state <= LONG_DELAY_STATE;

                    -- Give the AD7606 ~1.3ms to power up
                    when LONG_DELAY_STATE =>
                        if (LONG_DELAY_DONE_SW = '1') then
                            state <= RESET_AD7606_STATE;
                        end if;

                    -- Hold the AD7606 RESET pin high for a short delay
                    when RESET_AD7606_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= WAIT_FOR_TRIGGER_STATE;
                        end if;

                    -- Idle until the button process asks for a conversion
                    when WAIT_FOR_TRIGGER_STATE =>
                        if (START_CONV_SW = '1') then
                            state <= ASSERT_CONV_STATE;
                        end if;

                    -- Hold CONVST low for a short delay; its rising edge starts the conversion
                    when ASSERT_CONV_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= WHILE_BUSY0_STATE;
                        end if;

                    -- Wait for BUSY to go high (conversion has started)
                    when WHILE_BUSY0_STATE =>
                        if (BUSY_SW = '1') then
                            state <= WHILE_BUSY1_STATE;
                        end if;

                    -- Wait for BUSY to go low (all 8 channels converted)
                    when WHILE_BUSY1_STATE =>
                        if (BUSY_SW = '0') then
                            state <= WAIT_FOR_VALID_AD_DATA_STATE;
                        end if;

                    -- RD and CS are low; give the data bus a short delay to settle
                    when WAIT_FOR_VALID_AD_DATA_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= LATCH_AD_DATA_STATE;
                        end if;

                    -- Write the sample into the register file and step the register
                    -- counter.  After the 8th channel (register 7) go back to waiting.
                    when LATCH_AD_DATA_STATE =>
                        if (ALL_CHANNELS_HAVE_BEEN_READ_SW = '1') then
                            state <= WAIT_FOR_TRIGGER_STATE;
                        else
                            state <= PAUSE_BETWEEN_AD_CHANNELS_STATE;
                        end if;

                    -- RD is high between channels for a short delay
                    when PAUSE_BETWEEN_AD_CHANNELS_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= CLEAR_SHORT_COUNTER_STATE;
                        end if;

                    -- One clock to put the short delay counter back to 0
                    -- before the next channel is read
                    when CLEAR_SHORT_COUNTER_STATE =>
                        state <= WAIT_FOR_VALID_AD_DATA_STATE;

				end case;
			end if;
		end if;
	end process;

    -------------------------------------------------------------------------------
    -- LPT: List all the bits of your control word and define their purpose.
    --      cw              Purpose
    --      10              CONVST to the AD7606, active low
    --      9               RD to the AD7606, active low
    --      8               CS to the AD7606, active low
    --      7               RESET to the AD7606, active high
    --      6..5            longDelayCounter control  (1.31ms power up delay)
    --      4..3            shortDelayCounter control (320ns pulse/pause timing)
    --      2..1            regCounter control (which register gets the sample)
    --      0               register file write
    --
    -- LPT: Add the truth table for any BBB which are used in the datapath
    --  counter control     Function
    --      00              hold
    --      01              load D
    --      10              increment
    --      11              reset to 0
    --
    --  register file write Function
    --      0               hold all 8 registers
    --      1               D -> register selected by wrAddr = regCounter(2 downto 0)
    -------------------------------------------------------------------------------
	output_process: process (state)
	begin
	    case state is
            --                                   CONVST RD CS RESET  long short  reg  write
            when RESET_STATE                     => cw <= B"1_1_1_0_11_11_11_0";       -- 77E
            when LONG_DELAY_STATE                => cw <= B"1_1_1_0_10_11_11_0";       -- 75E
            when RESET_AD7606_STATE              => cw <= B"1_1_1_1_00_10_11_0";       -- 796
            when WAIT_FOR_TRIGGER_STATE          => cw <= B"1_1_1_0_11_11_00_0";       -- 778
            when ASSERT_CONV_STATE               => cw <= B"0_1_1_0_00_10_11_0";       -- 316
            when WHILE_BUSY0_STATE               => cw <= B"1_1_1_0_00_11_11_0";       -- 71E
            when WHILE_BUSY1_STATE               => cw <= B"1_1_1_0_00_11_11_0";       -- 71E
            when WAIT_FOR_VALID_AD_DATA_STATE    => cw <= B"1_0_0_0_00_10_00_0";       -- 410
            when LATCH_AD_DATA_STATE             => cw <= B"1_1_0_0_00_11_10_1";       -- 61D
            when PAUSE_BETWEEN_AD_CHANNELS_STATE => cw <= B"1_1_0_0_00_10_00_0";       -- 610
            when CLEAR_SHORT_COUNTER_STATE       => cw <= B"1_1_0_0_00_11_00_0";       -- 618
		end case;
	end process;

end Behavioral;