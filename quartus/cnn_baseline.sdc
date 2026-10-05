create_clock -name {clk} -period 20.000 -waveform {0.000 10.000} [get_ports {clk}]

set_false_path -from [get_ports {reset_n}]

set_output_delay -clock {clk} -max 5.000 [get_ports {result[*]}]
set_output_delay -clock {clk} -min 0.000 [get_ports {result[*]}]
set_output_delay -clock {clk} -max 5.000 [get_ports {valid_out}]
set_output_delay -clock {clk} -min 0.000 [get_ports {valid_out}]
set_output_delay -clock {clk} -max 5.000 [get_ports {led}]
set_output_delay -clock {clk} -min 0.000 [get_ports {led}]
