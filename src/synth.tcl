
sh  mkdir -p    ./work
set cache_write work
set cache_read  work
define_design_lib WORK -path work

# Elaborate Design
set DESIGN    "CONV_ACC"

# SVF For Formality
set_svf ../rpt/${DESIGN}_formal.svf



analyze -format verilog -vcs "-f ./filelist_synth.f"
elaborate        ${DESIGN}
current_design    ${DESIGN}

link

uniquify -force -dont_skip_empty_designs

# Operating Condition
# set_operating_conditions -analysis_type on_chip_variation
# set_wire_load_model -name smic18_wl10
# set_wire_load_mode  top

# DRC Rules
set_max_area        0
set_max_fanout        32  [get_designs $DESIGN]
set_max_transition  1.0 [get_designs $DESIGN]
set_max_capacitance 1.0 [get_designs $DESIGN]

# Constraints
set_drive    0.001000 [all_inputs]
set_load    0.0003 [all_outputs]

create_clock -name CCLK_CLK -period 1.2 [get_ports clk]

set_input_delay  .5 -max -clock {CCLK_CLK} [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay .5 -max -clock {CCLK_CLK} [all_outputs]

set_clock_uncertainty 0.0001 -setup [all_clocks]

# Check Design
check_design

redirect ../rpt/${DESIGN}_check_design.rpt "check_design"

# flatten it all, this forces all the hierarchy to be flattened out
set_flatten true -effort high
uniquify

# Compile Design
# compile
# compile_ultra -scan -timing -retime
compile_ultra


# Write Netlist
change_names -rules verilog -hierarchy
write_file -hierarchy -format verilog -output ../rpt/${DESIGN}.syn.v
write -format ddc -hierarchy -output ../rpt/${DESIGN}_mapped.ddc
write_sdf ../rpt/CONV_ACC_time.sdf
# Reports
redirect ../rpt/${DESIGN}_timing.rpt    "report_timing"
redirect ../rpt/${DESIGN}_area.rpt      "report_area -hier"
redirect ../rpt/${DESIGN}_qor.rpt       "report_qor"
redirect ../rpt/${DESIGN}_power.rpt      "report_power -hier"

set_svf -off