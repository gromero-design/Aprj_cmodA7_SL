
set_property MARK_DEBUG false [get_nets uC16_0/uart_i/s_uart_cs]


set_property MARK_DEBUG true [get_nets uC16_0/opus1_0/opus16_core_i/inst_execute/c_aucc]
set_property MARK_DEBUG true [get_nets uC16_0/opus1_0/opus16_core_i/inst_execute/co_aucc]
set_property MARK_DEBUG true [get_nets uC16_0/opus1_0/opus16_core_i/inst_execute/s_aucc]
set_property MARK_DEBUG true [get_nets uC16_0/opus1_0/opus16_core_i/inst_execute/xld_flags]
set_property MARK_DEBUG true [get_nets uC16_0/opus1_0/opus16_core_i/inst_execute/z_aucc]
connect_debug_port u_ila_0/probe2 [get_nets [list {uC16_0/uC_oport[8]} {uC16_0/uC_oport[9]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list {s_uC_page[0]} {s_uC_page[1]} {s_uC_page[2]} {s_uC_page[3]} {s_uC_page[4]} {s_uC_page[5]} {s_uC_page[6]} {s_uC_page[7]} {s_uC_page[8]} {s_uC_page[9]} {s_uC_page[10]} {s_uC_page[11]} {s_uC_page[12]} {s_uC_page[13]} {s_uC_page[14]} {s_uC_page[15]}]]
connect_debug_port u_ila_0/probe9 [get_nets [list s_uC_pagewr]]

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
set_property port_width 14 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {uC16_0/opus1_0/s_pm_addr[0]} {uC16_0/opus1_0/s_pm_addr[1]} {uC16_0/opus1_0/s_pm_addr[2]} {uC16_0/opus1_0/s_pm_addr[3]} {uC16_0/opus1_0/s_pm_addr[4]} {uC16_0/opus1_0/s_pm_addr[5]} {uC16_0/opus1_0/s_pm_addr[6]} {uC16_0/opus1_0/s_pm_addr[7]} {uC16_0/opus1_0/s_pm_addr[8]} {uC16_0/opus1_0/s_pm_addr[9]} {uC16_0/opus1_0/s_pm_addr[10]} {uC16_0/opus1_0/s_pm_addr[11]} {uC16_0/opus1_0/s_pm_addr[12]} {uC16_0/opus1_0/s_pm_addr[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {uC16_0/opus1_0/s_pm_dout[0]} {uC16_0/opus1_0/s_pm_dout[1]} {uC16_0/opus1_0/s_pm_dout[2]} {uC16_0/opus1_0/s_pm_dout[3]} {uC16_0/opus1_0/s_pm_dout[4]} {uC16_0/opus1_0/s_pm_dout[5]} {uC16_0/opus1_0/s_pm_dout[6]} {uC16_0/opus1_0/s_pm_dout[7]} {uC16_0/opus1_0/s_pm_dout[8]} {uC16_0/opus1_0/s_pm_dout[9]} {uC16_0/opus1_0/s_pm_dout[10]} {uC16_0/opus1_0/s_pm_dout[11]} {uC16_0/opus1_0/s_pm_dout[12]} {uC16_0/opus1_0/s_pm_dout[13]} {uC16_0/opus1_0/s_pm_dout[14]} {uC16_0/opus1_0/s_pm_dout[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list uC16_0/opus1_0/opus16_core_i/inst_execute/c_aucc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list uC16_0/opus1_0/opus16_core_i/inst_execute/co_aucc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list uC16_0/opus1_0/opus16_core_i/inst_execute/s_aucc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list uC16_0/opus1_0/s_pm_genb]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list uC16_0/opus1_0/s_pm_wenb]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list uC16_0/opus1_0/opus16_core_i/stop]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list uC16_0/opus1_0/opus16_core_i/sync]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list uC16_0/opus1_0/opus16_core_i/inst_execute/xld_flags]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list uC16_0/opus1_0/opus16_core_i/inst_execute/z_aucc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list uC16_0/opus1_0/opus16_core_i/inst_decode/ub_flag]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
