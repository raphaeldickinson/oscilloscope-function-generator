################################################################################
# acquireToHDMI.xdc - EENG 484 Lab 4 - ALINX AX7010 + AN706 on header J10
#
# Bus bits are written {name[0]} in braces so Tcl does not try to run [0]
# as a command.
################################################################################

#-------------------------------------------------------------------------------
# 50 MHz PL clock
#-------------------------------------------------------------------------------
set_property PACKAGE_PIN U18 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -period 20.000 -waveform {0.000 10.000} [get_ports clk]

#-------------------------------------------------------------------------------
# Push buttons (active low: '0' when pressed, so the design sees the
# release of a key as the 0 -> 1 "press")
#   PL_KEY1 N15 resetn
#   PL_KEY4 R17 btn[0]  SINGLE FORCED: fill the BRAMs (forced mode)
#   PL_KEY3 T17 btn[1]  toggle forced / trigger mode (forced after reset)
#   PL_KEY2 N16 btn[2]  not used
#-------------------------------------------------------------------------------
set_property PACKAGE_PIN N15 [get_ports {resetn}]
set_property IOSTANDARD LVCMOS33 [get_ports {resetn}]

set_property PACKAGE_PIN R17 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]

set_property PACKAGE_PIN T17 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]

set_property PACKAGE_PIN N16 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]

#-------------------------------------------------------------------------------
# PL LEDs.  These LEDs light when the pin is '0', so each LED is ON while
# its signal is '0'.  The pins can also be probed with a real scope.
#   triggerCh1                PL_LED1 M14
#   triggerCh2                PL_LED2 M15
#   conversionPlusReadoutTime PL_LED3 K16
#   sampleTimerRollover       PL_LED4 J16
#-------------------------------------------------------------------------------
set_property PACKAGE_PIN M14 [get_ports {triggerCh1}]
set_property IOSTANDARD LVCMOS33 [get_ports {triggerCh1}]

set_property PACKAGE_PIN M15 [get_ports {triggerCh2}]
set_property IOSTANDARD LVCMOS33 [get_ports {triggerCh2}]

set_property PACKAGE_PIN K16 [get_ports {conversionPlusReadoutTime}]
set_property IOSTANDARD LVCMOS33 [get_ports {conversionPlusReadoutTime}]

set_property PACKAGE_PIN J16 [get_ports {sampleTimerRollover}]
set_property IOSTANDARD LVCMOS33 [get_ports {sampleTimerRollover}]

#-------------------------------------------------------------------------------
# AN706 (AD7606) control and status
#   AN706 J9 pin -> AX7010 J10 pin (same number) -> net -> Zynq pin
#-------------------------------------------------------------------------------
# J10-5  EX_IO1_2N  CONVSTAB
set_property PACKAGE_PIN R14 [get_ports {an7606convst}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606convst}]
# J10-7  EX_IO1_3N  RD
set_property PACKAGE_PIN Y17 [get_ports {an7606rd}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606rd}]
# J10-8  EX_IO1_3P  RESET
set_property PACKAGE_PIN Y16 [get_ports {an7606reset}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606reset}]
# J10-9  EX_IO1_4N  BUSY
set_property PACKAGE_PIN W15 [get_ports {an7606busy}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606busy}]
# J10-10 EX_IO1_4P  CS
set_property PACKAGE_PIN V15 [get_ports {an7606cs}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606cs}]

# Oversampling select OS[2:0]
# J10-4  EX_IO1_1P  OS0
set_property PACKAGE_PIN W18 [get_ports {an7606od[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606od[0]}]
# J10-3  EX_IO1_1N  OS1
set_property PACKAGE_PIN W19 [get_ports {an7606od[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606od[1]}]
# J10-6  EX_IO1_2P  OS2
set_property PACKAGE_PIN P14 [get_ports {an7606od[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606od[2]}]

#-------------------------------------------------------------------------------
# AN706 (AD7606) data bus DB[15:0]
#-------------------------------------------------------------------------------
# J10-15 EX_IO1_7N  DB0
set_property PACKAGE_PIN U15 [get_ports {an7606data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[0]}]
# J10-16 EX_IO1_7P  DB1
set_property PACKAGE_PIN U14 [get_ports {an7606data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[1]}]
# J10-17 EX_IO1_8N  DB2
set_property PACKAGE_PIN P16 [get_ports {an7606data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[2]}]
# J10-18 EX_IO1_8P  DB3
set_property PACKAGE_PIN P15 [get_ports {an7606data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[3]}]
# J10-19 EX_IO1_9N  DB4
set_property PACKAGE_PIN U17 [get_ports {an7606data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[4]}]
# J10-20 EX_IO1_9P  DB5
set_property PACKAGE_PIN T16 [get_ports {an7606data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[5]}]
# J10-21 EX_IO1_10N DB6
set_property PACKAGE_PIN V18 [get_ports {an7606data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[6]}]
# J10-22 EX_IO1_10P DB7
set_property PACKAGE_PIN V17 [get_ports {an7606data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[7]}]
# J10-23 EX_IO1_11N DB8
set_property PACKAGE_PIN T15 [get_ports {an7606data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[8]}]
# J10-24 EX_IO1_11P DB9
set_property PACKAGE_PIN T14 [get_ports {an7606data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[9]}]
# J10-25 EX_IO1_12N DB10
set_property PACKAGE_PIN V13 [get_ports {an7606data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[10]}]
# J10-26 EX_IO1_12P DB11
set_property PACKAGE_PIN U13 [get_ports {an7606data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[11]}]
# J10-27 EX_IO1_13N DB12
set_property PACKAGE_PIN W13 [get_ports {an7606data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[12]}]
# J10-28 EX_IO1_13P DB13
set_property PACKAGE_PIN V12 [get_ports {an7606data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[13]}]
# J10-29 EX_IO1_14N DB14
set_property PACKAGE_PIN U12 [get_ports {an7606data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[14]}]
# J10-30 EX_IO1_14P DB15
set_property PACKAGE_PIN T12 [get_ports {an7606data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an7606data[15]}]

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

#-------------------------------------------------------------------------------
# Clock domain crossing
# clk (50 MHz) writes BRAM port A, videoClk (74.25 MHz) reads port B.  The
# only other signals that cross are the trigger volt / time, which are
# constants.  Treat clk as asynchronous to the clocking wizard outputs so
# Vivado does not report false failures between them; the videoClk <->
# videoClk5x paths inside the HDMI IP stay fully timed.
#-------------------------------------------------------------------------------
set_clock_groups -name clk_async -asynchronous -group [get_clocks -of_objects [get_ports clk]]
