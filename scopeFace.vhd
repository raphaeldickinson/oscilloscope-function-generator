----------------------------------------------------------------------------------
-- Include proper comment header block
-- ***Do not use mod operator in this code***
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.scopeToHdmi_package.all;       -- geometry + color constants

entity scopeFace is
    PORT ( 	clk: in  STD_LOGIC;
         resetn : in  STD_LOGIC;
         pixelHorz : in  STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
         pixelVert : in  STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
         triggerVolt: in STD_LOGIC_VECTOR (VIDEO_WIDTH_IN_BITS - 1 downto 0);
         triggerTime: in STD_LOGIC_VECTOR (VIDEO_WIDTH_IN_BITS - 1 downto 0);
         red : out  STD_LOGIC_VECTOR(7 downto 0);
         green : out  STD_LOGIC_VECTOR(7 downto 0);
         blue : out  STD_LOGIC_VECTOR(7 downto 0);
         ch1: in STD_LOGIC;
         ch1Enb: in STD_LOGIC;
         ch2: in STD_LOGIC;
         ch2Enb: in STD_LOGIC);
end scopeFace;


architecture Behavioral of scopeFace is

    -- Set these signals to '1' when the features should be drawn at the current pixelHorz, pixelVert 
    -- cordinate.  These act like Feature Booleans which you will use in the process(clk) to set the 
    -- correct RGB for this pixel location.
    signal borderH, borderV : STD_LOGIC;
    signal gridH, gridV : STD_LOGIC;
    signal hatchH, hatchV : STD_LOGIC;
    signal triggerTimeMarker, triggerVoltMarker : STD_LOGIC;
    signal ch1Draw, ch2Draw : STD_LOGIC;

    -- Helpers
    signal insideFace : STD_LOGIC;         -- strictly inside the white border
    signal onGridColumn, onGridRow : STD_LOGIC;     -- pixel sits on a major division line
    signal onHatchColumn, onHatchRow : STD_LOGIC;   -- pixel sits on a hatch mark position

    -- Distance (in pixels) from the tip of each trigger triangle
    signal timeMarkerDepth, voltMarkerDepth : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);

begin


    ---------------------------------------------------------------------
    -- Use the Feature Booleans to set the RGB at this pixel location.
    -- The waveforms should sit "on top" of the grid.
    ---------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                red <= (others => '0');
                green <= (others => '0');
                blue <= (others => '0');
            else
                if ((borderH = '1') or (borderV = '1')) then
                    red <= BORDER_R;
                    green <= BORDER_G;
                    blue <= BORDER_B;
                elsif ((triggerTimeMarker = '1') or (triggerVoltMarker = '1')) then
                    red <= TRIGGER_R;
                    green <= TRIGGER_G;
                    blue <= TRIGGER_B;
                elsif (ch1Draw = '1') then
                    red <= CH1_R;
                    green <= CH1_G;
                    blue <= CH1_B;
                elsif (ch2Draw = '1') then
                    red <= CH2_R;
                    green <= CH2_G;
                    blue <= CH2_B;
                elsif ((gridH = '1') or (gridV = '1')) then
                    red <= GRID_R;
                    green <= GRID_G;
                    blue <= GRID_B;
                elsif ((hatchH = '1') or (hatchV = '1')) then
                    red <= HATCH_R;
                    green <= HATCH_G;
                    blue <= HATCH_B;
                else
                    red <= BACKGROUND_R;
                    green <= BACKGROUND_G;
                    blue <= BACKGROUND_B;
                end if;
            end if;
        end if;
    end process;


    ---------------------------------------------------------------------
    -- BORDER
    -- Horizontal border lines (top and bottom) are 5 rows thick, centered
    -- on T_EDGE and B_EDGE, and only as wide as the face.  The vertical
    -- lines (left and right) are the same idea turned sideways.  Limiting
    -- each line to the extent of the face keeps it from streaking across
    -- the entire screen.
    ---------------------------------------------------------------------
    borderH <=	'1' when (((pixelVert > T_EDGE - BORDER_LINE_WIDTH) and (pixelVert < T_EDGE + BORDER_LINE_WIDTH)) or
                          ((pixelVert > B_EDGE - BORDER_LINE_WIDTH) and (pixelVert < B_EDGE + BORDER_LINE_WIDTH))) and
                          ((pixelHorz > L_EDGE - BORDER_LINE_WIDTH) and (pixelHorz < R_EDGE + BORDER_LINE_WIDTH)) else '0';

    borderV <=	'1' when (((pixelHorz > L_EDGE - BORDER_LINE_WIDTH) and (pixelHorz < L_EDGE + BORDER_LINE_WIDTH)) or
                          ((pixelHorz > R_EDGE - BORDER_LINE_WIDTH) and (pixelHorz < R_EDGE + BORDER_LINE_WIDTH))) and
                          ((pixelVert > T_EDGE - BORDER_LINE_WIDTH) and (pixelVert < B_EDGE + BORDER_LINE_WIDTH)) else '0';

    insideFace <= '1' when (pixelHorz > L_EDGE) and (pixelHorz < R_EDGE) and
                           (pixelVert > T_EDGE) and (pixelVert < B_EDGE) else '0';


    ---------------------------------------------------------------------
    -- GRID AND HATCH POSITIONS (no mod operator)
    -- xPos / yPos start at the left / top edge and are stepped forward one
    -- division (or one hatch spacing) per loop iteration.  Each iteration
    -- adds one "pixel = constant" comparator.  The border edges themselves
    -- are skipped (loops stop one short) because the border covers them.
    --   Major columns: x = 200, 300, ..., 1000         (9 compares)
    --   Major rows:    y = 160, 220, ..., 640          (9 compares)
    --   Hatch columns: x = 120, 140, ..., 1080         (49 compares)
    --   Hatch rows:    y = 112, 124, ..., 688          (49 compares)
    ---------------------------------------------------------------------
    gridPositions: process(pixelHorz, pixelVert)
        variable xPos, yPos : NATURAL;
        variable hitColumn, hitRow, hitHatchColumn, hitHatchRow : STD_LOGIC;
    begin
        -- Major division lines
        hitColumn := '0';
        xPos := L_EDGE_INT;
        for i in 1 to NUM_DIVISIONS - 1 loop
            xPos := xPos + H_DIVISION_INT;
            if (unsigned(pixelHorz) = xPos) then
                hitColumn := '1';
            end if;
        end loop;

        hitRow := '0';
        yPos := T_EDGE_INT;
        for i in 1 to NUM_DIVISIONS - 1 loop
            yPos := yPos + V_DIVISION_INT;
            if (unsigned(pixelVert) = yPos) then
                hitRow := '1';
            end if;
        end loop;

        -- Hatch mark positions (every 1/5 of a division)
        hitHatchColumn := '0';
        xPos := L_EDGE_INT;
        for i in 1 to NUM_HATCHES - 1 loop
            xPos := xPos + H_HATCH_INT;
            if (unsigned(pixelHorz) = xPos) then
                hitHatchColumn := '1';
            end if;
        end loop;

        hitHatchRow := '0';
        yPos := T_EDGE_INT;
        for i in 1 to NUM_HATCHES - 1 loop
            yPos := yPos + V_HATCH_INT;
            if (unsigned(pixelVert) = yPos) then
                hitHatchRow := '1';
            end if;
        end loop;

        onGridColumn  <= hitColumn;
        onGridRow     <= hitRow;
        onHatchColumn <= hitHatchColumn;
        onHatchRow    <= hitHatchRow;
    end process;


    ---------------------------------------------------------------------
    -- GRID: 1-pixel grey lines, clipped to the face.
    ---------------------------------------------------------------------
    gridV <= '1' when (onGridColumn = '1') and (pixelVert >= T_EDGE) and (pixelVert <= B_EDGE) else '0';
    gridH <= '1' when (onGridRow = '1')    and (pixelHorz >= L_EDGE) and (pixelHorz <= R_EDGE) else '0';


    ---------------------------------------------------------------------
    -- HATCH MARKS: short ticks that cross the two center axes.
    --   hatchH = ticks along the horizontal center axis (row V_CENTER);
    --            each tick is a short vertical dash at a hatch column.
    --   hatchV = ticks along the vertical center axis (column H_CENTER);
    --            each tick is a short horizontal dash at a hatch row.
    ---------------------------------------------------------------------
    hatchH <= '1' when (onHatchColumn = '1') and
                       (pixelVert >= V_CENTER - HATCH_HALF_LENGTH) and (pixelVert <= V_CENTER + HATCH_HALF_LENGTH) else '0';

    hatchV <= '1' when (onHatchRow = '1') and
                       (pixelHorz >= H_CENTER - HATCH_HALF_LENGTH) and (pixelHorz <= H_CENTER + HATCH_HALF_LENGTH) else '0';


    ---------------------------------------------------------------------
    -- TRIGGER TIME MARKER: downward-pointing triangle hanging from the top
    -- edge.  Its wide end sits on T_EDGE (partly under the border) and its
    -- tip is TRIGGER_MARKER_SIZE rows lower, centered on column triggerTime.
    -- timeMarkerDepth = rows between this pixel and the tip (0 at the tip).
    ---------------------------------------------------------------------
    timeMarkerDepth <= (T_EDGE + TRIGGER_MARKER_SIZE) - pixelVert;

    triggerTimeMarker <= '1' when (pixelVert >= T_EDGE) and (pixelVert <= T_EDGE + TRIGGER_MARKER_SIZE) and
                                  (pixelHorz + timeMarkerDepth >= triggerTime) and
                                  (pixelHorz <= triggerTime + timeMarkerDepth) else '0';


    ---------------------------------------------------------------------
    -- TRIGGER VOLT MARKER: right-pointing triangle sticking out of the left
    -- edge, centered on row triggerVolt.  Same math as above with the roles
    -- of pixelHorz and pixelVert swapped.
    ---------------------------------------------------------------------
    voltMarkerDepth <= (L_EDGE + TRIGGER_MARKER_SIZE) - pixelHorz;

    triggerVoltMarker <= '1' when (pixelHorz >= L_EDGE) and (pixelHorz <= L_EDGE + TRIGGER_MARKER_SIZE) and
                                  (pixelVert + voltMarkerDepth >= triggerVolt) and
                                  (pixelVert <= triggerVolt + voltMarkerDepth) else '0';


    ---------------------------------------------------------------------
    -- WAVEFORM TRACES: draw a channel only when its sample is present at
    -- this pixel, the channel is enabled, and the pixel is inside the face.
    ---------------------------------------------------------------------
    ch1Draw <= ch1 and ch1Enb and insideFace;
    ch2Draw <= ch2 and ch2Enb and insideFace;
  

end Behavioral;
