----------------------------------------------------------------------------------
--	Ascii art showing monitor and O'scope face
--				(0,0)-----------------------------------(1279,0)
--				|										|
--				|	|-------------------------------|	|
--				|	|(UL)					    (UR)|	|
--				|	|								|	|
--				|	|								|	|
--				|	|								|	|
--				|	|								|	|
--				|	|								|	|
--				|	|(LL)					    (LR)|	|
--				|	|-------------------------------|	|
--				|										|
--				|										|
--				(0,719)---------------------------------(1279,719)
--
--				The scope face is centered on the 1280 x 720 screen:
--				UL = Upper Left  = 140, 60
--				UR = Upper Right = 1140, 60
--				LL = Lower Left  = 140, 660
--				LR = Lower Right = 1140, 660
--				Total scope display is 1000 x 600
--				There are 10 major horiziontal divisions (100 pixels between divisions)	
--					Each division is split into 5 parts by 4 hatch marks (20 pixels between hatches)
--				There are 10 major vertcal divisions (60 pixels between divisions)
--					Each division is split into 5 parts by 4 hatch marks (12 pixels between hatches)
--
--				The face width and height must each be a multiple of 50
--				(10 divisions x 5 hatch parts) so every line is evenly spaced.
--				Change SCOPE_WIDTH / SCOPE_HEIGHT and the face stays centered;
--				scopeFace and scopeToHdmi work out all spacing from the four edges.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

package scopeToHdmi_package is


    constant VIDEO_WIDTH_IN_BITS: NATURAL := 11;        -- 1650 "pixels" wide, this include FP, SYNCH and BP

    constant H_ACTIVE : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(1280, VIDEO_WIDTH_IN_BITS));
    constant H_FP : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(110, VIDEO_WIDTH_IN_BITS));
    constant H_SYNC : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(40, VIDEO_WIDTH_IN_BITS));
    constant H_BP : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(220, VIDEO_WIDTH_IN_BITS));
    constant H_TOTAL : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := H_ACTIVE + H_FP + H_SYNC + H_BP;

    constant V_ACTIVE : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(720, VIDEO_WIDTH_IN_BITS));
    constant V_FP : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(5, VIDEO_WIDTH_IN_BITS));
    constant V_SYNC : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(5, VIDEO_WIDTH_IN_BITS));
    constant V_BP :  STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(20, VIDEO_WIDTH_IN_BITS));
    constant V_TOTAL : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := V_ACTIVE + V_FP + V_SYNC + V_BP;
        
    -- Scope face size in pixels (each must be a multiple of 50)
    constant SCOPE_WIDTH  : NATURAL := 1000;
    constant SCOPE_HEIGHT : NATURAL := 600;

    -- Scope face outline, centered on the screen: the space left over in each
    -- direction is split evenly between the two sides.
    --   left  = (1280 - 1000) / 2 = 140      top    = (720 - 600) / 2 = 60
    --   right = 140 + 1000        = 1140     bottom = 60 + 600        = 660
    constant L_EDGE : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) :=
        std_logic_vector(to_unsigned((to_integer(unsigned(H_ACTIVE)) - SCOPE_WIDTH) / 2, VIDEO_WIDTH_IN_BITS));   -- 140
    constant R_EDGE : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := L_EDGE + SCOPE_WIDTH;           -- 1140
    constant WIDTH : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := R_EDGE - L_EDGE;                 -- 1000

    constant T_EDGE : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) :=
        std_logic_vector(to_unsigned((to_integer(unsigned(V_ACTIVE)) - SCOPE_HEIGHT) / 2, VIDEO_WIDTH_IN_BITS));  -- 60
    constant B_EDGE : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := T_EDGE + SCOPE_HEIGHT;          -- 660
    constant HEIGHT : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := B_EDGE - T_EDGE;                -- 600
	
    -- This is actually half of the width.  (Not used by scopeFace, which
    -- defines its own 5-pixel border; kept from the starter template.)
    constant BORDER_LINE_WIDTH : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(3, VIDEO_WIDTH_IN_BITS));

	-- RGB color values
    constant BORDER_R : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant BORDER_G : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant BORDER_B : STD_LOGIC_VECTOR(7 downto 0) := X"FF";

    constant GRID_R : STD_LOGIC_VECTOR(7 downto 0) := X"88";
    constant GRID_G : STD_LOGIC_VECTOR(7 downto 0) := X"88";
    constant GRID_B : STD_LOGIC_VECTOR(7 downto 0) := X"88";

    constant CH1_R : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant CH1_G : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant CH1_B : STD_LOGIC_VECTOR(7 downto 0) := X"00";

    constant CH2_R : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    constant CH2_G : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant CH2_B : STD_LOGIC_VECTOR(7 downto 0) := X"00";

    constant TRIGGER_R : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant TRIGGER_G : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    constant TRIGGER_B : STD_LOGIC_VECTOR(7 downto 0) := X"FF";


component videoSignalGenerator is
    PORT(	clk: in  STD_LOGIC;
         resetn : in  STD_LOGIC;
         hs: out STD_LOGIC;
         vs: out STD_LOGIC;
         de: out STD_LOGIC;
         pixelHorz: out STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0);
         pixelVert: out STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0));
end component;

component scopeFace is
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
end component;

component clk_wiz_0 is
    PORT( 
        clk_out1: out STD_LOGIC;
        clk_out2: out STD_LOGIC;
        resetn: in STD_LOGIC;
        locked: out STD_LOGIC;
        clk_in1: in STD_LOGIC);
end component;


component hdmi_tx_0 is
    PORT (
        pix_clk: in STD_LOGIC;
        pix_clkx5: in STD_LOGIC;           
        pix_clk_locked: in STD_LOGIC;       
        rst: in STD_LOGIC;                  
        red : in STD_LOGIC_VECTOR(7 downto 0);
        green : in STD_LOGIC_VECTOR(7 downto 0);
        blue : in STD_LOGIC_VECTOR(7 downto 0);
        hsync: in STD_LOGIC;
        vsync: in STD_LOGIC;
        vde: in STD_LOGIC;
        aux0_din: in STD_LOGIC_VECTOR(3 downto 0);
        aux1_din: in STD_LOGIC_VECTOR(3 downto 0);
        aux2_din: in STD_LOGIC_VECTOR(3 downto 0);
        ade: in STD_LOGIC;            
        TMDS_CLK_P: out STD_LOGIC;
        TMDS_CLK_N: out STD_LOGIC;
        TMDS_DATA_P: out STD_LOGIC_VECTOR(2 downto 0);
        TMDS_DATA_N: out STD_LOGIC_VECTOR(2 downto 0));
end component;

component scopeToHdmi is
    PORT ( sysClk : in  STD_LOGIC;
         resetn : in  STD_LOGIC;
         btn: in	STD_LOGIC_VECTOR(2 downto 0);
         tmdsDataP : out  STD_LOGIC_VECTOR (2 downto 0);
         tmdsDataN : out  STD_LOGIC_VECTOR (2 downto 0);
         tmdsClkP : out STD_LOGIC;
         tmdsClkN : out STD_LOGIC;
         hdmiOen:    out STD_LOGIC);
end component;
        	
end package;
