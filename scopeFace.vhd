library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.scopeToHdmi_package.all;       -- L_EDGE, R_EDGE, T_EDGE, B_EDGE, colors

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

    ------------------------------------------------------------------------------
    -- SCOPE FACE LENGTHS (all in pixels)
    -- All of this arithmetic happens once, when the design is elaborated.
    -- None of it turns into hardware.
    ------------------------------------------------------------------------------

    -- Outline of the face, taken from the package and turned into integers
    constant FACE_LEFT   : NATURAL := to_integer(unsigned(L_EDGE));     -- 140
    constant FACE_RIGHT  : NATURAL := to_integer(unsigned(R_EDGE));     -- 1140
    constant FACE_TOP    : NATURAL := to_integer(unsigned(T_EDGE));     -- 60
    constant FACE_BOTTOM : NATURAL := to_integer(unsigned(B_EDGE));     -- 660
    constant FACE_WIDTH  : NATURAL := FACE_RIGHT - FACE_LEFT;           -- 1000
    constant FACE_HEIGHT : NATURAL := FACE_BOTTOM - FACE_TOP;           -- 600

    -- Border: 5 pixels thick, centered on each edge (edge-2 .. edge+2)
    constant BORDER_WIDTH  : NATURAL := 5;
    constant BORDER_BEFORE : NATURAL := (BORDER_WIDTH - 1) / 2;         -- 2 pixels on the outside
    constant BORDER_AFTER  : NATURAL := BORDER_WIDTH / 2;               -- 2 pixels on the inside

    -- Grid: 10 equal divisions each way, separated by 9 grid lines each way
    constant NUM_DIVISIONS   : NATURAL := 10;
    constant NUM_GRID_LINES  : NATURAL := NUM_DIVISIONS - 1;            -- 9
    constant H_DIVISION      : NATURAL := FACE_WIDTH  / NUM_DIVISIONS;  -- 100 pixels between vertical lines
    constant V_DIVISION      : NATURAL := FACE_HEIGHT / NUM_DIVISIONS;  -- 60 pixels between horizontal lines
    constant GRID_LINE_WIDTH : NATURAL := 1;
    constant GRID_BEFORE     : NATURAL := (GRID_LINE_WIDTH - 1) / 2;    -- 0
    constant GRID_AFTER      : NATURAL := GRID_LINE_WIDTH / 2;          -- 0

    -- Hatch marks: 4 marks split each division into 5 equal parts.
    -- They are drawn only along the two center axes, like a real scope.
    constant HATCH_PARTS          : NATURAL := 5;
    constant HATCHES_PER_DIVISION : NATURAL := HATCH_PARTS - 1;             -- 4
    constant H_HATCH_SPACING      : NATURAL := H_DIVISION / HATCH_PARTS;    -- 20 pixels
    constant V_HATCH_SPACING      : NATURAL := V_DIVISION / HATCH_PARTS;    -- 12 pixels
    constant HATCH_LINE_WIDTH     : NATURAL := 1;
    constant HATCH_BEFORE         : NATURAL := (HATCH_LINE_WIDTH - 1) / 2;  -- 0
    constant HATCH_AFTER          : NATURAL := HATCH_LINE_WIDTH / 2;        -- 0
    constant HATCH_LENGTH         : NATURAL := 7;                           -- tick length across the axis (odd)
    constant HATCH_REACH          : NATURAL := HATCH_LENGTH / 2;            -- 3 pixels each side of the axis

    -- Center axes of the face; the hatch marks sit on these
    constant H_CENTER : NATURAL := FACE_LEFT + FACE_WIDTH  / 2;         -- column 640
    constant V_CENTER : NATURAL := FACE_TOP  + FACE_HEIGHT / 2;         -- row 360

    -- Trigger markers: triangle height, measured from the face edge to its tip
    constant TRIGGER_MARKER_SIZE : NATURAL := 10;
    constant TIME_MARKER_TIP     : NATURAL := FACE_TOP  + TRIGGER_MARKER_SIZE;   -- row 70
    constant VOLT_MARKER_TIP     : NATURAL := FACE_LEFT + TRIGGER_MARKER_SIZE;   -- column 150

    -- Colors that are not in the package
    constant HATCH_R : STD_LOGIC_VECTOR(7 downto 0) := GRID_R;          -- hatch marks match the grid
    constant HATCH_G : STD_LOGIC_VECTOR(7 downto 0) := GRID_G;
    constant HATCH_B : STD_LOGIC_VECTOR(7 downto 0) := GRID_B;

    constant BACKGROUND_R : STD_LOGIC_VECTOR(7 downto 0) := X"22";      -- very dark grey, as in the
    constant BACKGROUND_G : STD_LOGIC_VECTOR(7 downto 0) := X"22";      -- reference simulation;
    constant BACKGROUND_B : STD_LOGIC_VECTOR(7 downto 0) := X"22";      -- X"00" gives pure black


    -- Set these signals to '1' when the features should be drawn at the current pixelHorz, pixelVert 
    -- cordinate.  These act like Feature Booleans which you will use in the process(clk) to set the 
    -- correct RGB for this pixel location.
    signal borderH, borderV : STD_LOGIC;
    signal gridH, gridV : STD_LOGIC;
    signal hatchH, hatchV : STD_LOGIC;
    signal triggerTimeMarker, triggerVoltMarker : STD_LOGIC;
    signal ch1Draw, ch2Draw : STD_LOGIC;

    -- Helpers
    signal insideFace : STD_LOGIC;                  -- strictly inside the border
    signal onGridColumn, onGridRow : STD_LOGIC;     -- pixel is on a grid line position
    signal onHatchColumn, onHatchRow : STD_LOGIC;   -- pixel is on a hatch mark position

    -- Rows / columns between this pixel and the tip of each trigger triangle
    signal timeMarkerDepth, voltMarkerDepth : unsigned(VIDEO_WIDTH_IN_BITS - 1 downto 0);

begin

    ---------------------------------------------------------------------
    -- Warn (in simulation and synthesis) if the face does not split evenly.
    -- The face width and height must each be a multiple of 50
    -- (10 divisions x 5 hatch parts) for the lines to be evenly spaced.
    ---------------------------------------------------------------------
    assert (H_DIVISION * NUM_DIVISIONS = FACE_WIDTH) and (H_HATCH_SPACING * HATCH_PARTS = H_DIVISION)
        report "scopeFace: R_EDGE - L_EDGE is not a multiple of 50, so the vertical grid lines / hatch marks are not evenly spaced"
        severity warning;

    assert (V_DIVISION * NUM_DIVISIONS = FACE_HEIGHT) and (V_HATCH_SPACING * HATCH_PARTS = V_DIVISION)
        report "scopeFace: B_EDGE - T_EDGE is not a multiple of 50, so the horizontal grid lines / hatch marks are not evenly spaced"
        severity warning;


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
    -- BORDER: 5 pixels thick (edge-2 .. edge+2).  The top and bottom lines
    -- only span the width of the face, and the left and right lines only
    -- span its height, so the outline is a closed rectangle.
    ---------------------------------------------------------------------
    borderH <= '1' when (((unsigned(pixelVert) >= FACE_TOP - BORDER_BEFORE)    and (unsigned(pixelVert) <= FACE_TOP + BORDER_AFTER)) or
                         ((unsigned(pixelVert) >= FACE_BOTTOM - BORDER_BEFORE) and (unsigned(pixelVert) <= FACE_BOTTOM + BORDER_AFTER))) and
                        (unsigned(pixelHorz) >= FACE_LEFT - BORDER_BEFORE) and (unsigned(pixelHorz) <= FACE_RIGHT + BORDER_AFTER) else '0';

    borderV <= '1' when (((unsigned(pixelHorz) >= FACE_LEFT - BORDER_BEFORE)  and (unsigned(pixelHorz) <= FACE_LEFT + BORDER_AFTER)) or
                         ((unsigned(pixelHorz) >= FACE_RIGHT - BORDER_BEFORE) and (unsigned(pixelHorz) <= FACE_RIGHT + BORDER_AFTER))) and
                        (unsigned(pixelVert) >= FACE_TOP - BORDER_BEFORE) and (unsigned(pixelVert) <= FACE_BOTTOM + BORDER_AFTER) else '0';

    insideFace <= '1' when (unsigned(pixelHorz) > FACE_LEFT) and (unsigned(pixelHorz) < FACE_RIGHT) and
                           (unsigned(pixelVert) > FACE_TOP)  and (unsigned(pixelVert) < FACE_BOTTOM) else '0';


    ---------------------------------------------------------------------
    -- GRID AND HATCH POSITIONS
    -- linePos starts at an edge and steps forward one spacing per loop
    -- pass.  Each pass adds one "is the pixel on this line?" compare.
    -- The edges themselves are skipped because the border covers them.
    ---------------------------------------------------------------------
    gridPositions: process(pixelHorz, pixelVert)
        variable linePos, divisionStart : NATURAL;
        variable hitColumn, hitRow, hitHatchColumn, hitHatchRow : STD_LOGIC;
    begin
        -- 9 vertical grid lines: x = 240, 340, ..., 1040
        hitColumn := '0';
        linePos := FACE_LEFT;
        for i in 1 to NUM_GRID_LINES loop
            linePos := linePos + H_DIVISION;
            if (unsigned(pixelHorz) >= linePos - GRID_BEFORE) and (unsigned(pixelHorz) <= linePos + GRID_AFTER) then
                hitColumn := '1';
            end if;
        end loop;

        -- 9 horizontal grid lines: y = 120, 180, ..., 600
        hitRow := '0';
        linePos := FACE_TOP;
        for i in 1 to NUM_GRID_LINES loop
            linePos := linePos + V_DIVISION;
            if (unsigned(pixelVert) >= linePos - GRID_BEFORE) and (unsigned(pixelVert) <= linePos + GRID_AFTER) then
                hitRow := '1';
            end if;
        end loop;

        -- 4 hatch columns inside each of the 10 divisions (40 in all):
        -- x = 160, 180, 200, 220,  260, 280, 300, 320,  ...
        hitHatchColumn := '0';
        divisionStart := FACE_LEFT;
        for d in 1 to NUM_DIVISIONS loop
            linePos := divisionStart;
            for h in 1 to HATCHES_PER_DIVISION loop
                linePos := linePos + H_HATCH_SPACING;
                if (unsigned(pixelHorz) >= linePos - HATCH_BEFORE) and (unsigned(pixelHorz) <= linePos + HATCH_AFTER) then
                    hitHatchColumn := '1';
                end if;
            end loop;
            divisionStart := divisionStart + H_DIVISION;
        end loop;

        -- 4 hatch rows inside each of the 10 divisions (40 in all):
        -- y = 72, 84, 96, 108,  132, 144, 156, 168,  ...
        hitHatchRow := '0';
        divisionStart := FACE_TOP;
        for d in 1 to NUM_DIVISIONS loop
            linePos := divisionStart;
            for h in 1 to HATCHES_PER_DIVISION loop
                linePos := linePos + V_HATCH_SPACING;
                if (unsigned(pixelVert) >= linePos - HATCH_BEFORE) and (unsigned(pixelVert) <= linePos + HATCH_AFTER) then
                    hitHatchRow := '1';
                end if;
            end loop;
            divisionStart := divisionStart + V_DIVISION;
        end loop;

        onGridColumn  <= hitColumn;
        onGridRow     <= hitRow;
        onHatchColumn <= hitHatchColumn;
        onHatchRow    <= hitHatchRow;
    end process;


    ---------------------------------------------------------------------
    -- GRID: lines run the full height / width of the face.
    ---------------------------------------------------------------------
    gridV <= '1' when (onGridColumn = '1') and (unsigned(pixelVert) >= FACE_TOP)  and (unsigned(pixelVert) <= FACE_BOTTOM) else '0';
    gridH <= '1' when (onGridRow = '1')    and (unsigned(pixelHorz) >= FACE_LEFT) and (unsigned(pixelHorz) <= FACE_RIGHT)  else '0';


    ---------------------------------------------------------------------
    -- HATCH MARKS: short ticks crossing the two center axes.
    --   hatchH: ticks along the horizontal center axis (row V_CENTER),
    --           each a short vertical dash HATCH_LENGTH pixels tall.
    --   hatchV: ticks along the vertical center axis (column H_CENTER),
    --           each a short horizontal dash HATCH_LENGTH pixels wide.
    ---------------------------------------------------------------------
    hatchH <= '1' when (onHatchColumn = '1') and
                       (unsigned(pixelVert) >= V_CENTER - HATCH_REACH) and (unsigned(pixelVert) <= V_CENTER + HATCH_REACH) else '0';

    hatchV <= '1' when (onHatchRow = '1') and
                       (unsigned(pixelHorz) >= H_CENTER - HATCH_REACH) and (unsigned(pixelHorz) <= H_CENTER + HATCH_REACH) else '0';


    ---------------------------------------------------------------------
    -- TRIGGER TIME MARKER: downward-pointing triangle hanging from the top
    -- edge, centered on column triggerTime.  A row that is d rows above
    -- the tip is 2d+1 pixels wide, so a pixel is inside when
    -- |pixelHorz - triggerTime| <= d.  That is split into two unsigned
    -- compares so nothing goes negative:
    --     pixelHorz + d >= triggerTime   and   pixelHorz <= triggerTime + d
    ---------------------------------------------------------------------
    timeMarkerDepth <= to_unsigned(TIME_MARKER_TIP, VIDEO_WIDTH_IN_BITS) - unsigned(pixelVert);

    triggerTimeMarker <= '1' when (unsigned(pixelVert) >= FACE_TOP) and (unsigned(pixelVert) <= TIME_MARKER_TIP) and
                                  (unsigned(pixelHorz) + timeMarkerDepth >= unsigned(triggerTime)) and
                                  (unsigned(pixelHorz) <= unsigned(triggerTime) + timeMarkerDepth) else '0';


    ---------------------------------------------------------------------
    -- TRIGGER VOLT MARKER: right-pointing triangle sticking out of the left
    -- edge, centered on row triggerVolt.  Same math with the roles of
    -- pixelHorz and pixelVert swapped.
    ---------------------------------------------------------------------
    voltMarkerDepth <= to_unsigned(VOLT_MARKER_TIP, VIDEO_WIDTH_IN_BITS) - unsigned(pixelHorz);

    triggerVoltMarker <= '1' when (unsigned(pixelHorz) >= FACE_LEFT) and (unsigned(pixelHorz) <= VOLT_MARKER_TIP) and
                                  (unsigned(pixelVert) + voltMarkerDepth >= unsigned(triggerVolt)) and
                                  (unsigned(pixelVert) <= unsigned(triggerVolt) + voltMarkerDepth) else '0';


    ---------------------------------------------------------------------
    -- WAVEFORM TRACES: draw a channel only when its sample is present at
    -- this pixel, the channel is enabled, and the pixel is inside the face.
    ---------------------------------------------------------------------
    ch1Draw <= ch1 and ch1Enb and insideFace;
    ch2Draw <= ch2 and ch2Enb and insideFace;


end Behavioral;
