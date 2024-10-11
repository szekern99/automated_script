#!/bin/csh
set block_name="vc9000d subsys"
set modes=("func" "llist" "mbist" "scan_slow_capture" "scan_fast_capture" "scan_shift")

# Define the directory where the output CSV should be stored
set output_dir="/proj/Aurora SG23701/WORK/v-jennie lee/$block name/run/r n20240918/testing"
set output_csv="Soutput_dir/QOR_${block_name}_all_modes_report.csv"

# Write the header to the CSV file
echo "mode, blk name, comment, ulvt_ratio, read_sdc_error,mem_num,min_period_pass, port_num, floating_ports_inputs, floating_ports_outputs, floating_ports_inouts, unconstrained_point, no_clock" > "Soutput_csv"

foreach mode ($modes)
# Define the search directory where to search for the file
set search_dir="/proj/Aurora_SG23701/WORK/v-jennie_lee/$block_name/run/r_n20240918/init_check/$mode.tt0p75v.wcl.cworst_ccworst_t_0c.setup"
# Find the required files in the directory
set link_log_file=`find "$search_dir" -name "link. log"'
set design_info_file=`find "Ssearch_dir" -name "DesignInfo.rpt"*
set sdc_log_file=`find "$search_dir" -name "$block_name. read sdc. log"'
set min_period_file=`find "Ssearch_dir" -name "Sblock_name.min_period.rpt"'

# Initialize the variables
set link status = "N/A"
set ulvt ratio = "N/A"
set mem num = "N/A"
set sdc status = "N/A"
set min_period_pass = "N/A"
set port_num = "N/A"
set floating_ports_inputs = "N/A"
Set floating_ports_outputs = "N/A
set floating_ports inouts = "N/A"
set unconstrained_point = "N/A"
set no_clock = "N/A"
set sdc_errors_count = 0
set sdc_warnings_count = 0
set min_period_errors_count = 0
set min_period_warnings_count = 0

# Check if the "link. log" file exists
