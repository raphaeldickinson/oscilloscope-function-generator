library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.scopeToHdmi_package.all;       -- VIDEO_WIDTH_IN_BITS, H_*, V_* constants

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


    signal h_cnt, v_cnt : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
    signal h_activeArea, v_activeArea: STD_LOGIC;


begin

    -- Register the de (active video area) signal.  A pixel is visible only when
    -- the beam is inside the active part of the line AND inside the active
    -- part of the frame.  Because de is registered it lags h_activeArea by one
    -- clock, which is the same one-clock lag scopeFace adds when it registers
    -- red/green/blue, so de and the RGB data line up at the hdmi_tx_0 inputs.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then                
                de <= '0';
            else
                de <= h_activeArea and v_activeArea;
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
                hs <= '1';
            elsif(h_cnt = H_FP - 1) then
                hs <= '0';
            elsif(h_cnt = H_FP + H_SYNC - 1) then
                hs <= '1';            
            end if;
        end if;
    end process;


    -- 3: Generate the pixelHorz signal that is used by
    -- the scopeFace and other components to know which pixel on 
    -- the screen is being drawn.
    --    Active video starts at h_cnt = H_FP + H_SYNC + H_BP = 370.  Subtracting
    --    one less than that (369) from h_cnt, one clock early, makes pixelHorz
    --    read 0 at the same moment h_cnt reads 370 and h_activeArea goes high.
    --    During the blanking interval pixelHorz simply holds its last value
    --    (1280), which is harmless because de = '0' there.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                pixelHorz <= (others => '0');
            elsif(h_cnt >= H_FP + H_SYNC + H_BP - 1) then
                pixelHorz <= h_cnt - (H_FP + H_SYNC + H_BP - 1);
            end if;
        end if;
    end process;
            

    -- 4. assert the h_activeArea signal.  This boolean is true when we are drawing pixels
    --    Set one count before active video begins (369) so it reads '1' for
    --    h_cnt = 370..1649, and clear it on the last count of the line (1649)
    --    so it reads '0' when h_cnt wraps to 0.  That is exactly 1280 clocks.
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                h_activeArea <= '0';
            elsif(h_cnt = H_FP + H_SYNC + H_BP - 1) then
                h_activeArea <= '1';
            elsif(h_cnt = H_TOTAL - 1) then
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
                vs <= '1';
            elsif((v_cnt = V_FP - 1) and (h_cnt = H_FP - 1)) then
                vs <= '0';
            elsif((v_cnt = V_FP + V_SYNC - 1) and (h_cnt = H_FP - 1)) then
                vs <= '1';            
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
                pixelVert <= (others => '0');
            elsif(v_cnt >= V_FP + V_SYNC + V_BP - 1) then
                pixelVert <= v_cnt - (V_FP + V_SYNC + V_BP - 1);
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
