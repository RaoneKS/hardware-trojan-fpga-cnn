# ============================================================
# CNN Hardware Trojan Detection - Healthy PE/Interconnect
# Timing Constraints
# ============================================================

set_time_format -unit ns -decimal_places 3

# ------------------------------------------------------------
# Primary FPGA clock
# 50 MHz = 20 ns period
# ------------------------------------------------------------
create_clock \
    -name {clk} \
    -period 20.000 \
    -waveform {0.000 10.000} \
    [get_ports {clk}]

# ------------------------------------------------------------
# Reset
# Reset is used only for initialization.
# ------------------------------------------------------------

# ------------------------------------------------------------
# Output timing constraints
#
# The external outputs are observed synchronously.
# Assume a 5 ns external device/interface requirement.
# ------------------------------------------------------------
set_output_delay -clock {clk} -max 5.000 [get_ports {result[*]}]
set_output_delay -clock {clk} -min 0.000 [get_ports {result[*]}]

set_output_delay -clock {clk} -max 5.000 [get_ports {valid_out}]
set_output_delay -clock {clk} -min 0.000 [get_ports {valid_out}]

set_output_delay -clock {clk} -max 5.000 [get_ports {led}]
set_output_delay -clock {clk} -min 0.000 [get_ports {led}]

# ============================================================
# End of SDC
# ============================================================
