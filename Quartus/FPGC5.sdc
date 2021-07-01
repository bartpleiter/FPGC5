
set_time_format -unit ns -decimal_places 3

create_clock -name {clock} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clock}]
#create_generated_clock -name {clkdiv4:cdiv4|clk_track} -source [get_pins {pll|altpll_component|auto_generated|pll1|clk[0]}] -divide_by 4 -master_clock {pll|altpll_component|auto_generated|pll1|clk[0]} {clkdiv4:cdiv4|clk_track}

derive_pll_clocks -create_base_clocks
derive_clock_uncertainty