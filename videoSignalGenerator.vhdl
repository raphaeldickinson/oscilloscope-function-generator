-- Purp:    Generates the 1280x720 @ 60 Hz raster timing.  Two counters sweep
--          an imaginary beam across the screen: h_cnt steps once per pixel
--          clock and v_cnt steps once per line.  From those two counts this
--          module produces
--              hs, vs      - horizontal / vertical sync pulses (active low)
--              de          - data enable, '1' only inside the 1280x720 image
--              pixelHorz   - column (0..1279) of the pixel being drawn now
--              pixelVert   - row of the pixel being drawn now
--          scopeFace uses pixelHorz/pixelVert to pick a color and the
--          hdmi_tx_0 IP uses hs/vs/de to frame that color data.
--
--          Every output is registered (driven from a clocked process) so all
--          of them change on the same clock edge.
--
-- Lab 4 changes (to match the Lab 4 reference simulation):
--      * Every register has an initial value (counters 0, hs/vs '1', de '0').
--        In Lab 4 resetn comes straight from the board, and the clocking
--        wizard does not run videoClk while resetn is low, so the reset may
--        never see a clock edge.  The initial values make the counters start
--        at 0 and count from the first videoClk edge instead of being 'U'.
--      * pixelHorz = h_cnt - 370, so it reads 0..1279 and holds 1279 during
--        the blanking interval (the reference shows 1279 there, and 1274
--        when h_cnt is 1645).  h_activeArea moved one clock later to match,
--        so de still lines up with the colors for pixels 0..1279.
--
-- Timing reference (constants are in hdmi_package):
--      h_cnt:   0..109 FP | 110..149 SYNC | 150..369 BP | 370..1649 ACTIVE
--      v_cnt:   0..4   FP |   5..9   SYNC |  10..29  BP |  30..749  ACTIVE
--      v_cnt increments when h_cnt goes 109 -> 110 (the start of h-sync).
--
-- Documentation: <list any assistance you received here>
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.hdmi_package.all;       -- VIDEO_WIDTH_IN_BITS, H_*, V_* constants

entity videoSignalGenerator is
    PORT(
         clk: in  STD_LOGIC;
         resetn : in  STD_LOGIC;
         hs: out STD_LOGIC;
         vs: out STD_LOGIC;
         de: out STD_LOGIC;
         pixelHorz: out STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
         pixelVert: out STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0));
end videoSignalGenerator;

architecture behavior of videoSignalGenerator is

    -- First h_cnt value of the active (visible) part of a line: 110 + 40 + 220 = 370
    constant H_ACTIVE_START : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := H_FP + H_SYNC + H_BP;

    signal h_cnt, v_cnt : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := (others => '0');
    signal h_activeArea, v_activeArea: STD_LOGIC := '0';

    -- Registered outputs, with their power-up values
    signal hsReg, vsReg : STD_LOGIC := '1';
    signal deReg : STD_LOGIC := '0';
    signal pixelHorzReg, pixelVertReg : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0) := (others => '0');

begin

    hs <= hsReg;
    vs <= vsReg;
    de <= deReg;
    pixelHorz <= pixelHorzReg;
    pixelVert <= pixelVertReg;

    -- Register the de (active video area) signal.  A pixel is visible only when
    -- the beam is inside the active part of the line AND inside the active
    -- part of the frame.  Because de is registered it lags h_activeArea by one
    -- clock, which is the same one-clock lag scopeFace adds when it registers
    -- red/green/blue, so de and the RGB data line up at the hdmi_tx_0 inputs.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                deReg <= '0';
            else
                deReg <= h_activeArea and v_activeArea;
            end if;
        end if;
    end process;


    -- 1: Increment the horziontal count across the video screen
    --    Counts 0, 1, ..., 1649, 0, 1, ...  One full pass is one video line.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                h_cnt <= (others => '0');
            elsif(h_cnt = (H_TOTAL - 1)) then
                h_cnt <= (others => '0');
            else
                h_cnt <= h_cnt + 1;
            end if;
        end if;
    end process;

    -- 2: Assert the horziontal synch signal
    --    The sync pulse follows the front porch.  Decoding one count early
    --    (H_FP - 1 = 109) means hs is already '0' when h_cnt reaches 110,
    --    and decoding H_FP + H_SYNC - 1 = 149 puts hs back to '1' when h_cnt
    --    reaches 150.  So hs is low for exactly H_SYNC = 40 clocks, on every
    --    line.  (There is no v_cnt term here: every line has an h-sync.)
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                hsReg <= '1';
            elsif(h_cnt = H_FP - 1) then
                hsReg <= '0';
            elsif(h_cnt = H_FP + H_SYNC - 1) then
                hsReg <= '1';
            end if;
        end if;
    end process;


    -- 3: Generate the pixelHorz signal that is used by
    -- the scopeFace and other components to know which pixel on
    -- the screen is being drawn.
    --    pixelHorz <= h_cnt - 370 once h_cnt reaches 370, so it reads
    --    0, 1, ..., 1279 across the active part of the line.  During the
    --    blanking interval it holds its last value, 1279, which is harmless
    --    because de = '0' there.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                pixelHorzReg <= (others => '0');
            elsif(h_cnt >= H_ACTIVE_START) then
                pixelHorzReg <= h_cnt - H_ACTIVE_START;
            end if;
        end if;
    end process;


    -- 4. assert the h_activeArea signal.  This boolean is true when we are drawing pixels
    --    pixelHorz reads 0 when h_cnt reads 371, and scopeFace's color for
    --    that pixel comes out one clock later.  So h_activeArea is set when
    --    h_cnt = 370 and cleared when h_cnt = 0: it reads '1' for
    --    h_cnt = 371..1649 and 0, exactly 1280 clocks, and de (one clock
    --    later again) is '1' for exactly the 1280 colors of pixels 0..1279.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                h_activeArea <= '0';
            elsif(h_cnt = H_ACTIVE_START) then
                h_activeArea <= '1';
            elsif(h_cnt = 0) then
                h_activeArea <= '0';
            else
                h_activeArea <= h_activeArea;
            end if;
        end if;
    end process;


    -- 1: Increment the vertical count across the video screen
    --    v_cnt only moves once per line, at the h_cnt = H_FP - 1 decode, so it
    --    changes when h_cnt goes 109 -> 110.  It counts 0..749, then wraps.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                v_cnt <= (others => '0');
            elsif(h_cnt = H_FP - 1) then
                if(v_cnt = (V_TOTAL - 1)) then
                    v_cnt <= (others => '0');
                else
                    v_cnt <= v_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- 2: Assert the vertical synch signal
    --    Same idea as hs, but measured in lines.  The extra h_cnt = H_FP - 1
    --    term makes vs change on the same clock that v_cnt changes, so vs is
    --    low for v_cnt = 5..9, i.e. V_SYNC = 5 whole lines.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                vsReg <= '1';
            elsif((v_cnt = V_FP - 1) and (h_cnt = H_FP - 1)) then
                vsReg <= '0';
            elsif((v_cnt = V_FP + V_SYNC - 1) and (h_cnt = H_FP - 1)) then
                vsReg <= '1';
            end if;
        end if;
    end process;


    -- 3: Generate the pixelVert signal that is used by
    -- the scopeFace and other components to know which pixel on
    -- the screen is being drawn.
    --    This process (provided with the lab) updates on every clock, one clock
    --    after v_cnt changes.  With the "- 1" offset pixelVert reads 1 on the
    --    first active line (v_cnt = 30) and 720 on the last.  This matches the
    --    reference simulation (pixelVert = 1 when v_cnt = 30); the only effect
    --    is that the whole picture sits one row higher than the numbers suggest.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                pixelVertReg <= (others => '0');
            elsif(v_cnt >= V_FP + V_SYNC + V_BP - 1) then
                pixelVertReg <= v_cnt - (V_FP + V_SYNC + V_BP - 1);
            end if;
        end if;
    end process;

    -- 4. assert the v_activeArea signal.  This boolean is true when we are drawing pixels
    --    '1' for v_cnt = 30..749 (720 lines), changing together with v_cnt.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                v_activeArea <= '0';
            elsif((v_cnt = V_FP + V_SYNC + V_BP - 1) and (h_cnt = H_FP - 1))then
                v_activeArea <= '1';
            elsif((v_cnt = V_TOTAL - 1) and (h_cnt = H_FP - 1)) then
                v_activeArea <= '0';
            else
                v_activeArea <= v_activeArea;
            end if;
        end if;
    end process;

end behavior;