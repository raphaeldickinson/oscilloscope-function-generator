set_property PACKAGE_PIN U18 [get_ports {sysClk}]
set_property IOSTANDARD LVCMOS33 [get_ports {sysClk}]
create_clock -period 20.000 -waveform {0.000 10.000} [get_ports sysClk]

#------------------------------------------------------------------------------
# Push buttons (active low: '1' released, '0' pressed)
#   PL_KEY1 N15 -> resetn
#   PL_KEY2 N16 -> btn[0]  modifier (hold for +10)
#   PL_KEY3 T17 -> btn[1]  triggerVolt
#   PL_KEY4 R17 -> btn[2]  triggerTime
#------------------------------------------------------------------------------
set_property PACKAGE_PIN N15 [get_ports {resetn}]
set_property IOSTANDARD LVCMOS33 [get_ports {resetn}]

set_property PACKAGE_PIN N16 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]

set_property PACKAGE_PIN T17 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]

set_property PACKAGE_PIN R17 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]

#------------------------------------------------------------------------------
# HDMI TMDS differential pairs.  Only the P side needs a PACKAGE_PIN; Vivado
# places the matching N side of each pair automatically.  The OBUFDS buffers
# that drive these pins are inside the hdmi_tx_0 IP.
#------------------------------------------------------------------------------
set_property IOSTANDARD TMDS_33 [get_ports {tmdsDataN[0]}]
set_property PACKAGE_PIN V20 [get_ports {tmdsDataP[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmdsDataP[0]}]

set_property IOSTANDARD TMDS_33 [get_ports {tmdsDataN[1]}]
set_property PACKAGE_PIN T20 [get_ports {tmdsDataP[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmdsDataP[1]}]

set_property IOSTANDARD TMDS_33 [get_ports {tmdsDataN[2]}]
set_property PACKAGE_PIN N20 [get_ports {tmdsDataP[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmdsDataP[2]}]

set_property IOSTANDARD TMDS_33 [get_ports {tmdsClkN}]
set_property PACKAGE_PIN N18 [get_ports {tmdsClkP}]
set_property IOSTANDARD TMDS_33 [get_ports {tmdsClkP}]

#------------------------------------------------------------------------------
# HDMI output enable (driven '1' by the design)
#------------------------------------------------------------------------------
set_property PACKAGE_PIN V16 [get_ports {hdmiOen}]
set_property IOSTANDARD LVCMOS33 [get_ports {hdmiOen}]

#------------------------------------------------------------------------------
# Clock domain crossing
# triggerVolt/triggerTime are registered on sysClk (50 MHz) and read by
# scopeFace on videoClk (74.25 MHz).  Both clocks come from the same crystal,
# so by default Vivado times paths between them, but their periods
# (20 ns and 13.468 ns) only line up every few thousand cycles and the
# tool would report a false failure.  The trigger values change at most
# once per button press, so these paths do not need timing.
# With a single -group, sysClk is treated as asynchronous to every other
# clock (the clocking wizard outputs), while the videoClk <-> videoClk5x
# paths inside the HDMI IP stay fully timed.
#------------------------------------------------------------------------------
set_clock_groups -name sysClk_async -asynchronous -group [get_clocks -of_objects [get_ports sysClk]]
