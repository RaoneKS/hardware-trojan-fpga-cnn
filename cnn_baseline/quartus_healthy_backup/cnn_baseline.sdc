# ============================================================
# CNN Hardware Trojan Detection - Healthy Baseline
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
#
# Reset is only used to initialize internal registers.
# It is not part of the functional CNN datapath.
# ------------------------------------------------------------
set_false_path -from [get_ports {rst}]

# ------------------------------------------------------------
# CNN output ports
#
# The current baseline exposes these for observation only.
# They are not driving external synchronous logic.
# ------------------------------------------------------------
set_false_path -to [get_ports {conv_result[*]}]
set_false_path -to [get_ports {relu_result[*]}]
set_false_path -to [get_ports {valid_out}]

# ------------------------------------------------------------
# End of SDC
# ============================================================
