library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.acquireToHDMI_package.all;


entity acquireToHDMI_fsm is
    PORT (  clk : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            sw: in STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
            cw: out STD_LOGIC_VECTOR (CW_WIDTH - 1 downto 0));
end acquireToHDMI_fsm;

architecture Behavioral of acquireToHDMI_fsm is

	signal state: state_type;	-- define the state_type in your package file
	signal SHORT_DELAY_DONE_SW, LONG_DELAY_DONE_SW, MEMORY_FULL_SW, SAMPLE_INTERVAL_SW: STD_LOGIC;
    signal FORCED_MODE_SW, STORE_INTO_BRAM_SW, CH1_TRIGGER_SW: STD_LOGIC;
    signal SINGLE_FORCED_TRIGGER_SW, AD7606_BUSY_SW: STD_LOGIC;
begin

    SHORT_DELAY_DONE_SW <= sw(SHORT_DELAY_DONE_SW_BIT_INDEX);
    LONG_DELAY_DONE_SW <= sw(LONG_DELAY_DONE_SW_BIT_INDEX);
    MEMORY_FULL_SW <= sw(MEMORY_FULL_SW_BIT_INDEX);
    SAMPLE_INTERVAL_SW <= sw(SAMPLE_INTERVAL_SW_BIT_INDEX);
    CH1_TRIGGER_SW <= sw(CH1_TRIGGER_SW_BIT_INDEX);
    STORE_INTO_BRAM_SW <= sw(STORE_INTO_BRAM_SW_BIT_INDEX);
    SINGLE_FORCED_TRIGGER_SW <= sw(SINGLE_FORCED_TRIGGER_SW_BIT_INDEX);
    AD7606_BUSY_SW <= sw(AD7606_BUSY_SW_BIT_INDEX);
    FORCED_MODE_SW <= sw(FORCED_MODE_SW_BIT_INDEX);

	-------------------------------------------------------------------------------
	-- Next state
	-------------------------------------------------------------------------------
	state_proces: process(clk)
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then
				state <= RESET_STATE;
			else
				case state is
					when RESET_STATE =>
						  state <= LONG_DELAY_STATE;

					-- Give the AD7606 time to power up
					when LONG_DELAY_STATE =>
						if (LONG_DELAY_DONE_SW = '1') then
							state <= RESET_AD7606_STATE;
						end if;

					-- RESET pin high for 16 clocks
					when RESET_AD7606_STATE =>
						if (SHORT_DELAY_DONE_SW = '1') then
							if (FORCED_MODE_SW = '1') then
								state <= WAIT_FORCED_STATE;
							else
								state <= CLEAR_STORE_FLAG_STATE;
							end if;
						end if;

					-- Forced mode: wait for btn(0), or for the switch to trigger mode
					when WAIT_FORCED_STATE =>
						if (FORCED_MODE_SW = '0') then
							state <= CLEAR_STORE_FLAG_STATE;
						elsif (SINGLE_FORCED_TRIGGER_SW = '1') then
							state <= SET_STORE_FLAG_STATE;
						end if;

					-- Both flag states also reset the BRAM write address
					when SET_STORE_FLAG_STATE =>
						state <= BEGIN_CONVERSION_STATE;

					when CLEAR_STORE_FLAG_STATE =>
						state <= BEGIN_CONVERSION_STATE;

					-- Start of a sample interval
					when BEGIN_CONVERSION_STATE =>
						state <= ASSERT_CONV_STATE;

					-- CONVST low for 16 clocks
					when ASSERT_CONV_STATE =>
						if (SHORT_DELAY_DONE_SW = '1') then
							state <= WHILE_BUSY0_STATE;
						end if;

					-- Wait for BUSY to go high ...
					when WHILE_BUSY0_STATE =>
						if (AD7606_BUSY_SW = '1') then
							state <= WHILE_BUSY1_STATE;
						end if;

					-- ... and then low again (conversion done)
					when WHILE_BUSY1_STATE =>
						if (AD7606_BUSY_SW = '0') then
							state <= READ_LOW_CH1_STATE;
						end if;

					---------------- Channel 1 ----------------
					when READ_LOW_CH1_STATE =>
						if (SHORT_DELAY_DONE_SW = '1') then
							if (STORE_INTO_BRAM_SW = '1') then
								state <= WRITE_BRAM_CH1_STATE;
							else
								state <= WRITE_TRIGGER_CH1_STATE;
							end if;
						end if;

					when WRITE_TRIGGER_CH1_STATE =>
						state <= READ_HIGH_CH1_STATE;

					when WRITE_BRAM_CH1_STATE =>
						state <= READ_HIGH_CH1_STATE;

					when READ_HIGH_CH1_STATE =>
						if (SHORT_DELAY_DONE_SW = '1') then
							state <= RESET_SHORT_STATE;
						end if;

					when RESET_SHORT_STATE =>
						state <= READ_LOW_CH2_STATE;

					---------------- Channel 2 ----------------
					when READ_LOW_CH2_STATE =>
						if (SHORT_DELAY_DONE_SW = '1') then
							if (STORE_INTO_BRAM_SW = '1') then
								state <= WRITE_BRAM_CH2_STATE;
							else
								state <= WRITE_TRIGGER_CH2_STATE;
							end if;
						end if;

					when WRITE_TRIGGER_CH2_STATE =>
						state <= READ_HIGH_CH2_STATE;

					when WRITE_BRAM_CH2_STATE =>
						state <= READ_HIGH_CH2_STATE;

					-- RD goes back high; the conversion and readout are done
					when READ_HIGH_CH2_STATE =>
						state <= WAIT_FOR_NEXT_SAMPLE_INTERVAL_STATE;

					-- Decide what to do with the next sample
					when WAIT_FOR_NEXT_SAMPLE_INTERVAL_STATE =>
						if (SAMPLE_INTERVAL_SW = '1') then
							if (MEMORY_FULL_SW = '1') then
								state <= BRAM_FULL_STATE;           -- 1000 samples stored
							elsif (STORE_INTO_BRAM_SW = '1') then
								state <= BEGIN_CONVERSION_STATE;    -- keep filling
							elsif (FORCED_MODE_SW = '1') then
								state <= WAIT_FORCED_STATE;         -- switched to forced mode
							elsif (CH1_TRIGGER_SW = '1') then
								state <= SET_STORE_FLAG_STATE;      -- trigger found, start filling
							else
								state <= BEGIN_CONVERSION_STATE;    -- keep looking for a trigger
							end if;
						end if;

					when BRAM_FULL_STATE =>
						if (FORCED_MODE_SW = '1') then
							state <= WAIT_FORCED_STATE;
						else
							state <= CLEAR_STORE_FLAG_STATE;
						end if;

				end case;
			end if;
		end if;
	end process;

	-------------------------------------------------------------------------------
    -- Dedicated Control Word spreadsheet
    --                  CLR SET TRG2 TRG1 CPR STR BR2 BR1 CONVST RD CS RST  DSC  SMC  RATE LONG SHORT
    -------------------------------------------------------------------------------
	output_process: process (state)
	begin
		case state is
            when RESET_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"11"&"11"&"00"&"11"&"11";
            when LONG_DELAY_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"00"&"00"&"10"&"00";
            when RESET_AD7606_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'1'&"00"&"00"&"00"&"00"&"10";
            when WAIT_FORCED_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"00"&"00"&"00"&"00";
            when SET_STORE_FLAG_STATE  =>  cw <= '0'&'1'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"11"&"00"&"00"&"00"&"00";
            when CLEAR_STORE_FLAG_STATE  =>  cw <= '1'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"11"&"00"&"00"&"00"&"00";
            when BEGIN_CONVERSION_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"11"&"00"&"00"&"11";
            when ASSERT_CONV_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'0'&'1'&'1'&'0'&"00"&"10"&"00"&"00"&"10";
            when WHILE_BUSY0_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"10"&"00"&"00"&"11";
            when WHILE_BUSY1_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"10"&"00"&"00"&"11";
            when READ_LOW_CH1_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"10";
            when WRITE_TRIGGER_CH1_STATE  =>  cw <= '0'&'0'&'0'&'1'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when WRITE_BRAM_CH1_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'1'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when READ_HIGH_CH1_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&"00"&"10"&"00"&"00"&"10";
            when RESET_SHORT_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when READ_LOW_CH2_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"10";
            when WRITE_TRIGGER_CH2_STATE  =>  cw <= '0'&'0'&'1'&'0'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when WRITE_BRAM_CH2_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'1'&'0'&'1'&'0'&'0'&'0'&"10"&"10"&"00"&"00"&"11";
            when READ_HIGH_CH2_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&"00"&"10"&"00"&"00"&"00";
            when WAIT_FOR_NEXT_SAMPLE_INTERVAL_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&"00"&"10"&"00"&"00"&"00";
            when BRAM_FULL_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"00"&"00"&"00"&"00";
		end case;
	end process;

end Behavioral;