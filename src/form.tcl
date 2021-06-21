set hdlin_warn_on_mismatch_message {FMR_ELAB-147 FMR_ELAB-130 FMR_VLOG-079}
# TODO: We remove the lib path, you can add your own path here

# Synopsys Lib
set_svf ../rpt/CONV_ACC_formal.svf
read_db -tech your_own_db_file.db


read_verilog -r -vcs "-f ./filelist_synth.f"
set_top CONV_ACC
read_ddc -i ../rpt/CONV_ACC_mapped.ddc
set_top CONV_ACC
match
verify
report_guidance -summary
