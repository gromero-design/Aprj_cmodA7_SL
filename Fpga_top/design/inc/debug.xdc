## This file is a general .xdc for the CmodA7 rev. B
## Board: CmodA7 Artix 7 xcA35T-1CPG236G
## Flash memory : Micron n25q32-3.3v-spi-x1_x2_x4
## Clock signal 12 MHz
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -period 83.330 -name sys_clk_pin -waveform {0.000 41.660} -add [get_ports sysclk]
#create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports {clk}];

## LEDs
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {led[1]}]

set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports led0_r]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports led0_g]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports led0_b]

## Buttons
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports sysrst]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports btn1]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sysrst]

## Pmod Header JA
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {ja[0]}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {ja[1]}]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {ja[2]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {ja[3]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {ja[4]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {ja[5]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {ja[6]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {ja[7]}]

## Analog XADC Pins
## Only declare these if you want to use pins 15 and 16 as single ended analog inputs. pin 15 -> vaux4, pin16 -> vaux12
#set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS33 } [get_ports { xa_n[0] }]; #IO_L1N_T0_AD4N_35 Sch=ain_n[15]
#set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { xa_p[0] }]; #IO_L1P_T0_AD4P_35 Sch=ain_p[15]
#set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { xa_n[1] }]; #IO_L2N_T0_AD12N_35 Sch=ain_n[16]
#set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { xa_p[1] }]; #IO_L2P_T0_AD12P_35 Sch=ain_p[16]

## GPIO Pins
## Pins 15 and 16 should remain commented if using them as analog inputs
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports pwm_ch5]
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports pwm_ch6]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports pwm_ch7]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports pwm_ch8]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports pio_txd_in]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports pio_rxd_out]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports pio_bt_pwr]
#set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports pio[07]]       ; # Sch=pio[08]
#set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports pio[08]]       ; # Sch=pio[09]
#set_property -dict {PACKAGE_PIN J3  IOSTANDARD LVCMOS33} [get_ports pio[09]]       ; # Sch=pio[10]
#set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33} [get_ports pio[10]]       ; # Sch=pio[11]
#set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports pio[11]]       ; # Sch=pio[12]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports pwm_ch13]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports pwm_ch14]
# ANALOG                                                                            ; # Sch=pio[15]
# ANALOG                                                                            ; # Sch=pio[16]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports pwm_ch15]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports pwm_ch16]
#set_property -dict {PACKAGE_PIN P3  IOSTANDARD LVCMOS33} [get_ports pio[16]]       ; # Sch=pio[19]
#set_property -dict {PACKAGE_PIN M2  IOSTANDARD LVCMOS33} [get_ports pio[17]]       ; # Sch=pio[20]
#set_property -dict {PACKAGE_PIN N1  IOSTANDARD LVCMOS33} [get_ports pio[18]]       ; # Sch=pio[21]
#set_property -dict {PACKAGE_PIN N2  IOSTANDARD LVCMOS33} [get_ports pio[19]]       ; # Sch=pio[22]
#set_property -dict {PACKAGE_PIN P1  IOSTANDARD LVCMOS33} [get_ports pio[20]]       ; # Sch=pio[23]
# VCC                                                                               ; # Sch=pio[24]
# GND                                                                               ; # Sch=pio[25]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports pwm_ch4]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports pwm_ch3]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports pwm_ch2]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports pwm_ch1]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports pwm_ch12]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports pwm_ch11]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports pwm_ch10]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports pwm_ch9]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports redled1]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports redled2]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports redled3]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports redled4]
#set_property -dict {PACKAGE_PIN U4  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[38]
#set_property -dict {PACKAGE_PIN V5  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[39]
#set_property -dict {PACKAGE_PIN W4  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[40]
#set_property -dict {PACKAGE_PIN U5  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[41]
#set_property -dict {PACKAGE_PIN U2  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[42]
#set_property -dict {PACKAGE_PIN W6  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[43]
#set_property -dict {PACKAGE_PIN U3  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[44]
#set_property -dict {PACKAGE_PIN U7  IOSTANDARD LVCMOS33} [get_ports { }]           ; # Sch=pio[45]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports pio_usb_sel]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports spare_led2]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports blueled]

## UART
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports uart_rxd_out]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports uart_txd_in]

## Crypto 1 Wire Interface
#set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { crypto_sda }]; #IO_0_14 Sch=crypto_sda

## QSPI
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { qspi_cs    }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_cs
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]

## Cellular RAM
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {MemAdr[0]}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {MemAdr[1]}]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {MemAdr[2]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {MemAdr[3]}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {MemAdr[4]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {MemAdr[5]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {MemAdr[6]}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {MemAdr[7]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {MemAdr[8]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {MemAdr[9]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {MemAdr[10]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {MemAdr[11]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {MemAdr[12]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {MemAdr[13]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {MemAdr[14]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {MemAdr[15]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {MemAdr[16]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {MemAdr[17]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {MemAdr[18]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {MemDB[0]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {MemDB[1]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {MemDB[2]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {MemDB[3]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {MemDB[4]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {MemDB[5]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {MemDB[6]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {MemDB[7]}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports RamOEn]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports RamWEn]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports RamCEn]


connect_debug_port u_ila_0/probe9 [get_nets [list uC16_0/s_opus1_inta2]]
connect_debug_port u_ila_0/probe13 [get_nets [list uC16_0/opus1_0/OPUS1_INTA2]]


set_property MARK_DEBUG false [get_nets uC16_0/uart_i/s_uart_cs]
connect_debug_port u_ila_0/probe9 [get_nets [list uC16_0/opus1_0/OPUS1_INT2]]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk1_12to100/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {uC16_0/opus1_0/s_pm_dinp[0]} {uC16_0/opus1_0/s_pm_dinp[1]} {uC16_0/opus1_0/s_pm_dinp[2]} {uC16_0/opus1_0/s_pm_dinp[3]} {uC16_0/opus1_0/s_pm_dinp[4]} {uC16_0/opus1_0/s_pm_dinp[5]} {uC16_0/opus1_0/s_pm_dinp[6]} {uC16_0/opus1_0/s_pm_dinp[7]} {uC16_0/opus1_0/s_pm_dinp[8]} {uC16_0/opus1_0/s_pm_dinp[9]} {uC16_0/opus1_0/s_pm_dinp[10]} {uC16_0/opus1_0/s_pm_dinp[11]} {uC16_0/opus1_0/s_pm_dinp[12]} {uC16_0/opus1_0/s_pm_dinp[13]} {uC16_0/opus1_0/s_pm_dinp[14]} {uC16_0/opus1_0/s_pm_dinp[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 5 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {uC16_0/opus1_0/OPUS1_OPORT[1]} {uC16_0/opus1_0/OPUS1_OPORT[2]} {uC16_0/opus1_0/OPUS1_OPORT[3]} {uC16_0/opus1_0/OPUS1_OPORT[4]} {uC16_0/opus1_0/OPUS1_OPORT[6]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 14 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {uC16_0/opus1_0/s_pm_addr[0]} {uC16_0/opus1_0/s_pm_addr[1]} {uC16_0/opus1_0/s_pm_addr[2]} {uC16_0/opus1_0/s_pm_addr[3]} {uC16_0/opus1_0/s_pm_addr[4]} {uC16_0/opus1_0/s_pm_addr[5]} {uC16_0/opus1_0/s_pm_addr[6]} {uC16_0/opus1_0/s_pm_addr[7]} {uC16_0/opus1_0/s_pm_addr[8]} {uC16_0/opus1_0/s_pm_addr[9]} {uC16_0/opus1_0/s_pm_addr[10]} {uC16_0/opus1_0/s_pm_addr[11]} {uC16_0/opus1_0/s_pm_addr[12]} {uC16_0/opus1_0/s_pm_addr[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {uC16_0/opus1_0/s_pm_dout[0]} {uC16_0/opus1_0/s_pm_dout[1]} {uC16_0/opus1_0/s_pm_dout[2]} {uC16_0/opus1_0/s_pm_dout[3]} {uC16_0/opus1_0/s_pm_dout[4]} {uC16_0/opus1_0/s_pm_dout[5]} {uC16_0/opus1_0/s_pm_dout[6]} {uC16_0/opus1_0/s_pm_dout[7]} {uC16_0/opus1_0/s_pm_dout[8]} {uC16_0/opus1_0/s_pm_dout[9]} {uC16_0/opus1_0/s_pm_dout[10]} {uC16_0/opus1_0/s_pm_dout[11]} {uC16_0/opus1_0/s_pm_dout[12]} {uC16_0/opus1_0/s_pm_dout[13]} {uC16_0/opus1_0/s_pm_dout[14]} {uC16_0/opus1_0/s_pm_dout[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list uC16_0/opus1_0/OPUS1_DOWN]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list uC16_0/opus1_0/OPUS1_INT1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list uC16_0/opus1_0/OPUS1_INTA1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list uC16_0/opus1_0/OPUS1_RESET]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list uC16_0/opus1_0/s_pm_genb]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list uC16_0/opus1_0/s_pm_wenb]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list uC16_0/opus1_0/opus16_core_i/stop]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list uC16_0/opus1_0/opus16_core_i/sync]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
