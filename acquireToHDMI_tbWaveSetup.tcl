#################################################################################
# acquireToHDMI_tbWaveSetup.tcl - EENG 484 Lab 4
#
# In the Vivado Tcl console, after the simulation has opened:
#   source C:/<path to this file>/acquireToHDMI_tbWaveSetup.tcl
#
# The wave window is laid out like the handout's reference waveforms.  The
# script ends at the first check point (500 ns).  To see the others, either
#   forced_check 2    restart and run to FORCED check point 2 (700 us)
#   trigger_check 3   restart and run to TRIGGER check point 3 (1413.82 us)
# or step forward from where you are with the handout's variables:
#   run $FORCED_T01toT02      (500 ns -> 700 us), run $FORCED_T02toT03, ...
#
# Note the units: check point 2 is 700 us (700,000 ns), not 700 ns.  The video
# signals do not start until the clocking wizard starts videoClk, about 10 us
# into the simulation.
#
# Indexed signal names are in braces, {.../sw[9]}, so Tcl does not try to run
# "[9]" as a command.
#################################################################################
restart
# remove_wave (singular) is the Vivado command; the handout template says remove_waves
catch {remove_wave [get_waves *]}

# Record these signals from time 0 so anything you drag into the wave window
# later still shows its whole history.
foreach scope {/acquireToHDMI_tb/uut /acquireToHDMI_tb/uut/datapath_inst /acquireToHDMI_tb/uut/control_inst /acquireToHDMI_tb/uut/datapath_inst/vsg} {
    catch {log_wave [get_objects $scope/*]}
}

# add_wave that reports a bad name instead of stopping the whole script
proc addw {args} {
    if {[catch {add_wave {*}$args} err]} {
        puts "Could not add wave: [lindex $args end]  ($err)"
    }
}

addw -color green /acquireToHDMI_tb/uut/clk
addw -color green /acquireToHDMI_tb/uut/resetn
addw -color green /acquireToHDMI_tb/uut/datapath_inst/clkLocked
addw -color green /acquireToHDMI_tb/uut/datapath_inst/videoClk

set groupColor YELLOW
set TOP_ID [add_wave_group "topLevelIO"]
addw -into $TOP_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/btn
addw -into $TOP_ID -color $groupColor /acquireToHDMI_tb/uut/forcedMode
addw -into $TOP_ID -color $groupColor -radix hex /acquireToHDMI_tb/uut/datapath_inst/ch1Data16bitSLV
addw -into $TOP_ID -color $groupColor -radix hex /acquireToHDMI_tb/uut/datapath_inst/firstCh1DataStdLogicVector
addw -into $TOP_ID -color $groupColor -radix hex /acquireToHDMI_tb/uut/datapath_inst/secondCh1DataStdLogicVector
addw -into $TOP_ID -color $groupColor /acquireToHDMI_tb/uut/datapath_inst/firstCh1GreaterThanTrigger
addw -into $TOP_ID -color $groupColor /acquireToHDMI_tb/uut/datapath_inst/secondCh1LessThanTrigger

addw -color aqua /acquireToHDMI_tb/uut/control_inst/state

set groupColor PURPLE
set COUNT_ID [add_wave_group "Counters"]
# Sample rate counter (timerCounter), then the delay counters.  The handout's
# waveforms list timerCounter at both ends of this group.
addw -into $COUNT_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/timerCounter
addw -into $COUNT_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/shortDelayCounter
addw -into $COUNT_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/longDelayCounter
addw -into $COUNT_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/timerCounter

set groupColor ORANGE
set AD7606_ID [add_wave_group "AD7606 Interface"]
addw -into $AD7606_ID -color $groupColor /acquireToHDMI_tb/uut/an7606reset
addw -into $AD7606_ID -color $groupColor /acquireToHDMI_tb/uut/an7606convst
addw -into $AD7606_ID -color $groupColor /acquireToHDMI_tb/uut/an7606cs
addw -into $AD7606_ID -color $groupColor /acquireToHDMI_tb/uut/an7606rd
addw -into $AD7606_ID -color $groupColor /acquireToHDMI_tb/uut/an7606busy
addw -into $AD7606_ID -color $groupColor -radix hex /acquireToHDMI_tb/uut/an7606data

set groupColor YELLOW
set BRAM_ID [add_wave_group "BRAM Interface"]
addw -into $BRAM_ID -color $groupColor -radix unsigned -name "Ch1 Write Address" /acquireToHDMI_tb/uut/datapath_inst/dataStorage_ch1/addra
# The first 4 words of the ch1 BRAM.  The memory array sits inside the Xilinx
# model, whose name has the IP version in it (blk_mem_gen_v8_4_5 in the
# handout, blk_mem_gen_v8_4_13 in Vivado 2026.1).  Each version is tried
# until one is found.
set bramFound 0
foreach ver {13 14 15 12 11 10 9 8 7 6 5 4} {
    set mem "/acquireToHDMI_tb/uut/datapath_inst/dataStorage_ch1/inst/native_mem_module.blk_mem_gen_v8_4_${ver}_inst/memory"
    if {[catch {add_wave -into $BRAM_ID -color $groupColor -radix hex "${mem}\[0\]"}] == 0} {
        for {set i 1} {$i < 4} {incr i} {
            addw -into $BRAM_ID -color $groupColor -radix hex "${mem}\[$i\]"
        }
        set bramFound 1
        break
    }
}
if {$bramFound == 0} {
    puts "BRAM memory array not found.  In the Scope window open uut/datapath_inst/dataStorage_ch1/inst and drag memory into the wave window."
}

set groupColor BLUE
set HDMI_ID [add_wave_group "Video Interface"]
addw -into $HDMI_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/vsg/h_cnt
addw -into $HDMI_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/vsg/pixelHorz
addw -into $HDMI_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/hs
addw -into $HDMI_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/vsg/v_cnt
addw -into $HDMI_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/vsg/pixelVert
addw -into $HDMI_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/vs
addw -into $HDMI_ID -color $groupColor -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/de
addw -into $HDMI_ID -color red -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/red
addw -into $HDMI_ID -color green -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/green
addw -into $HDMI_ID -color blue -radix unsigned /acquireToHDMI_tb/uut/datapath_inst/blue

set groupColor MAROON
set SW_ID [add_wave_group "Status Word"]
addw -into $SW_ID -color $groupColor -name "FORCED MODE"     {/acquireToHDMI_tb/uut/sw[9]}
addw -into $SW_ID -color $groupColor -name "AD7606 BUSY"     {/acquireToHDMI_tb/uut/sw[8]}
addw -into $SW_ID -color $groupColor -name "SINGLE FORCED"   {/acquireToHDMI_tb/uut/sw[7]}
addw -into $SW_ID -color $groupColor -name "STORE INTO BRAM" {/acquireToHDMI_tb/uut/sw[6]}
addw -into $SW_ID -color $groupColor -name "CH2 TRIG"        {/acquireToHDMI_tb/uut/sw[5]}
addw -into $SW_ID -color $groupColor -name "CH1 TRIG"        {/acquireToHDMI_tb/uut/sw[4]}
addw -into $SW_ID -color $groupColor -name "SAMPLE INTERVAL" {/acquireToHDMI_tb/uut/sw[3]}
addw -into $SW_ID -color $groupColor -name "MEM FULL"        {/acquireToHDMI_tb/uut/sw[2]}
addw -into $SW_ID -color $groupColor -name "LONG"            {/acquireToHDMI_tb/uut/sw[1]}
addw -into $SW_ID -color $groupColor -name "SHORT"           {/acquireToHDMI_tb/uut/sw[0]}

set groupColor LIME
set CW_ID [add_wave_group "Control Word"]
# Whole control word in hex; matches the hex column of controlWord.xlsx
addw -into $CW_ID -color $groupColor -radix hex -name "cw (hex)" /acquireToHDMI_tb/uut/cw
addw -into $CW_ID -color $groupColor -name "CLEAR STORE FLAG"        {/acquireToHDMI_tb/uut/cw[21]}
addw -into $CW_ID -color $groupColor -name "SET STORE FLAG"          {/acquireToHDMI_tb/uut/cw[20]}
addw -into $CW_ID -color $groupColor -name "TRIG CH2 WRITE"          {/acquireToHDMI_tb/uut/cw[19]}
addw -into $CW_ID -color $groupColor -name "TRIG CH1 WRITE"          {/acquireToHDMI_tb/uut/cw[18]}
addw -into $CW_ID -color $groupColor -name "CONVERSION PLUS READOUT" {/acquireToHDMI_tb/uut/cw[17]}
addw -into $CW_ID -color $groupColor -name "SAMPLE TIMER ROLLOVER"   {/acquireToHDMI_tb/uut/cw[16]}
addw -into $CW_ID -color $groupColor -name "DATA STORAGE CH2 WRITE"  {/acquireToHDMI_tb/uut/cw[15]}
addw -into $CW_ID -color $groupColor -name "DATA STORAGE CH1 WRITE"  {/acquireToHDMI_tb/uut/cw[14]}
addw -into $CW_ID -color $groupColor -name "CONVST"                  {/acquireToHDMI_tb/uut/cw[13]}
addw -into $CW_ID -color $groupColor -name "RD"                      {/acquireToHDMI_tb/uut/cw[12]}
addw -into $CW_ID -color $groupColor -name "CS"                      {/acquireToHDMI_tb/uut/cw[11]}
addw -into $CW_ID -color $groupColor -name "RESET AD7606"            {/acquireToHDMI_tb/uut/cw[10]}
# 2-bit fields, one wave per bit (00 hold, 01 load, 10 inc, 11 reset)
addw -into $CW_ID -color $groupColor -name "DATA STORAGE COUNTER 1"  {/acquireToHDMI_tb/uut/cw[9]}
addw -into $CW_ID -color $groupColor -name "DATA STORAGE COUNTER 0"  {/acquireToHDMI_tb/uut/cw[8]}
addw -into $CW_ID -color $groupColor -name "SAMPLING COUNTER 1"      {/acquireToHDMI_tb/uut/cw[7]}
addw -into $CW_ID -color $groupColor -name "SAMPLING COUNTER 0"      {/acquireToHDMI_tb/uut/cw[6]}
addw -into $CW_ID -color $groupColor -name "SAMPLING RATE SELECT 1"  {/acquireToHDMI_tb/uut/cw[5]}
addw -into $CW_ID -color $groupColor -name "SAMPLING RATE SELECT 0"  {/acquireToHDMI_tb/uut/cw[4]}
addw -into $CW_ID -color $groupColor -name "LONG DELAY COUNTER 1"    {/acquireToHDMI_tb/uut/cw[3]}
addw -into $CW_ID -color $groupColor -name "LONG DELAY COUNTER 0"    {/acquireToHDMI_tb/uut/cw[2]}
addw -into $CW_ID -color $groupColor -name "SHORT DELAY COUNTER 1"   {/acquireToHDMI_tb/uut/cw[1]}
addw -into $CW_ID -color $groupColor -name "SHORT DELAY COUNTER 0"   {/acquireToHDMI_tb/uut/cw[0]}

#################################################################################
# Check points.  The testbench is in FORCED mode as given.  For TRIGGER mode
# un-comment  btn_t <= "010";  in acquireToHDMI_tb.vhd, click Relaunch
# Simulation (restart alone does not recompile the testbench) and source this
# file again.
#################################################################################
set FORCED_CHECK01        500ns
set FORCED_CHECK02      700000ns
set FORCED_CHECK03    1311500ns
set FORCED_CHECK04    1340000ns
set FORCED_CHECK05    2900000ns
set FORCED_CHECK06    7360000ns

set FORCED_T01toT02    699500ns
set FORCED_T02toT03    611500ns
set FORCED_T03toT04     28500ns
set FORCED_T04toT05   1560000ns
set FORCED_T05toT06   4460000ns

set TRIGGER_CHECK01        500ns
set TRIGGER_CHECK02    1311200ns
set TRIGGER_CHECK03    1413820ns
set TRIGGER_CHECK04    7455000ns

set TRIGGER_T01toT02   1310700ns
set TRIGGER_T02toT03    102620ns
set TRIGGER_T03toT04   6041180ns

# forced_check N / trigger_check N: restart and run from 0 to check point N, so the
# simulation always stops exactly at the handout's time, wherever it was.
proc forced_check {n} {
    set name [format "FORCED_CHECK%02d" $n]
    if {![info exists ::$name]} { puts "forced_check takes a check point number from 1 to 6"; return }
    restart
    run [set ::$name]
    puts "FORCED check point $n: [current_time]"
}
proc trigger_check {n} {
    set name [format "TRIGGER_CHECK%02d" $n]
    if {![info exists ::$name]} { puts "trigger_check takes a check point number from 1 to 4"; return }
    restart
    run [set ::$name]
    puts "TRIGGER check point $n: [current_time]"
}

run $FORCED_CHECK01
puts "At check point 1 (500 ns).  Next: forced_check 2  (or  trigger_check 2  if the testbench is in trigger mode)."