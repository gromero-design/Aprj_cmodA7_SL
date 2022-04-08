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
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports pio_txd_in]
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports pio_rxd_out]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports pio_usb_sel]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports pio_bt_pwr]
#set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports { pio[04] }]; # Sch=pio[05]
#set_property -dict {PACKAGE_PIN H1  IOSTANDARD LVCMOS33} [get_ports { pio[05] }]; # Sch=pio[06]
#set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports { pio[06] }]; # Sch=pio[07]
#set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports { pio[07] }]; # Sch=pio[08]
#set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports { pio[08] }]; # Sch=pio[09]
#set_property -dict {PACKAGE_PIN J3  IOSTANDARD LVCMOS33} [get_ports { pio[09] }]; # Sch=pio[10]
#set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33} [get_ports { pio[10] }]; # Sch=pio[11]
#set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports { pio[11] }]; # Sch=pio[12]
#set_property -dict {PACKAGE_PIN L1  IOSTANDARD LVCMOS33} [get_ports { pio[12] }]; # Sch=pio[13]
#set_property -dict {PACKAGE_PIN L2  IOSTANDARD LVCMOS33} [get_ports { pio[13] }]; # Sch=pio[14]
#set_property -dict {PACKAGE_PIN M1  IOSTANDARD LVCMOS33} [get_ports { pio[14] }]; # Sch=pio[17]
#set_property -dict {PACKAGE_PIN N3  IOSTANDARD LVCMOS33} [get_ports { pio[15] }]; # Sch=pio[18]
#set_property -dict {PACKAGE_PIN P3  IOSTANDARD LVCMOS33} [get_ports { pio[16] }]; # Sch=pio[19]
#set_property -dict {PACKAGE_PIN M2  IOSTANDARD LVCMOS33} [get_ports { pio[17] }]; # Sch=pio[20]
#set_property -dict {PACKAGE_PIN N1  IOSTANDARD LVCMOS33} [get_ports { pio[18] }]; # Sch=pio[21]
#set_property -dict {PACKAGE_PIN N2  IOSTANDARD LVCMOS33} [get_ports { pio[19] }]; # Sch=pio[22]
#set_property -dict {PACKAGE_PIN P1  IOSTANDARD LVCMOS33} [get_ports { pio[20] }]; # Sch=pio[23]
#set_property -dict {PACKAGE_PIN R3  IOSTANDARD LVCMOS33} [get_ports { pio[21] }]; # Sch=pio[26]
#set_property -dict {PACKAGE_PIN T3  IOSTANDARD LVCMOS33} [get_ports { pio[22] }]; # Sch=pio[27]
#set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports { pio[23] }]; # Sch=pio[28]
#set_property -dict {PACKAGE_PIN T1  IOSTANDARD LVCMOS33} [get_ports { pio[24] }]; # Sch=pio[29]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports pwm_ch16]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports pwm_ch15]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports pwm_ch14]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports pwm_ch13]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports pwm_ch12]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports pwm_ch11]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports pwm_ch10]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports pwm_ch9]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports pwm_ch8]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports pwm_ch7]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports pwm_ch6]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports pwm_ch5]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports pwm_ch4]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports pwm_ch3]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports pwm_ch2]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports pwm_ch1]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports blu_led]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports grn_led]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports red_led]


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
