create_clock -period 20.000 -name Clk Clk
derive_pll_clocks
derive_clock_uncertainty

set_false_path -from [get_ports ARst_N]
