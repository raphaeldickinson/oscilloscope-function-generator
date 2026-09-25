restart

# Delete every wave already in the window with one command
remove_wave [get_waves *]

# Clocks and reset
add_wave -color green                  /scopeToHdmi_tb/uut/sysClk
add_wave -color green                  /scopeToHdmi_tb/uut/videoClk
add_wave -color green                  /scopeToHdmi_tb/uut/clkLocked
add_wave -color green                  /scopeToHdmi_tb/uut/resetn

# Horizontal timing (videoSignalGenerator)
add_wave -color yellow -radix unsigned /scopeToHdmi_tb/uut/vsg/h_cnt
add_wave -color yellow -radix unsigned /scopeToHdmi_tb/uut/vsg/pixelHorz
add_wave -color yellow                 /scopeToHdmi_tb/uut/vsg/h_activeArea
add_wave -color yellow                 /scopeToHdmi_tb/uut/vsg/hs

# Vertical timing (videoSignalGenerator)
add_wave -color orange -radix unsigned /scopeToHdmi_tb/uut/vsg/v_cnt
add_wave -color yellow -radix unsigned /scopeToHdmi_tb/uut/vsg/pixelVert
add_wave -color orange                 /scopeToHdmi_tb/uut/vsg/v_activeArea
add_wave -color orange                 /scopeToHdmi_tb/uut/vsg/vs

add_wave -color aqua                   /scopeToHdmi_tb/uut/vsg/de

# Pixel color (scopeFace)
add_wave -color red    -radix hex      /scopeToHdmi_tb/uut/sf/red
add_wave -color green  -radix hex      /scopeToHdmi_tb/uut/sf/green
add_wave -color blue   -radix hex      /scopeToHdmi_tb/uut/sf/blue

# HDMI outputs (top level ports)
add_wave -color orange -radix hex      /scopeToHdmi_tb/uut/tmdsDataP
add_wave -color orange -radix hex      /scopeToHdmi_tb/uut/tmdsDataN
add_wave -color orange                 /scopeToHdmi_tb/uut/tmdsClkP
add_wave -color orange                 /scopeToHdmi_tb/uut/tmdsClkN
add_wave -color orange                 /scopeToHdmi_tb/uut/hdmiOen

# Optional extras for debugging (uncomment to add)
# add_wave -color purple                 /scopeToHdmi_tb/uut/videoResetn
# add_wave -color purple -radix unsigned /scopeToHdmi_tb/uut/triggerVolt
# add_wave -color purple -radix unsigned /scopeToHdmi_tb/uut/triggerTime

# 3 ms covers every reference screenshot (10 us, 11.5 us, 32.5 us, 700 us, 3 ms).
# The HDMI serializer models make this take a few minutes; lower it to
# "run 50 us" for the horizontal-timing screenshots only.
run 3 ms
