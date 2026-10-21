set_property PACKAGE_PIN U18 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -period 20.000 -waveform {0.000 10.000} [get_ports clk]

#-------------------------------------------------------------------------------
# Push buttons (active low: '0' when pressed)
#   PL_KEY1 N15 resetn
#   PL_KEY4 R17 btn[0]  trigger: a conversion starts when it is released
#   PL_KEY3 T17 btn[1]  (not used in this lab)
#   PL_KEY2 N16 btn[2]  (not used in this lab)
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
# PL LEDs (an LED lights when its pin is '0')
#   reg0Magnitude[0] PL_LED1 M14   above 2.64V
#   reg0Magnitude[1] PL_LED2 M15   above 1.98V
#   reg0Magnitude[2] PL_LED3 K16   above 1.32V
#   reg0Magnitude[3] PL_LED4 J16   above 0.66V
#-------------------------------------------------------------------------------
set_property PACKAGE_PIN M14 [get_ports {reg0Magnitude[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg0Magnitude[0]}]
set_property PACKAGE_PIN M15 [get_ports {reg0Magnitude[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg0Magnitude[1]}]
set_property PACKAGE_PIN K16 [get_ports {reg0Magnitude[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg0Magnitude[2]}]
set_property PACKAGE_PIN J16 [get_ports {reg0Magnitude[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg0Magnitude[3]}]

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
