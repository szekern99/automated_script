#!/bin/csh
set block_name="vc9000d_subsys"
set version="20240918"
set modes=("func" "llist" "mbist" "scan_slow_capture" "scan_fast_capture" "scan_shift")

# Define the directory where the output CSV should be stored
set output_dir="/proj/Aurora_SG23701/WORK/v-jennie lee/$block_name/run/r_n$version/testing"
set output_csv="$output_dir/QOR_${block_name}_all_modes_report.csv"

# Write the header to the CSV file
echo "mode,blk_name,version,comment,ulvt_ratio,read_sdc_error,mem_num,min_period_pass,port_num,floating_ports_inputs,floating_ports_outputs,floating_ports_inouts,unconstrained_point,no_clock" > "$output_csv"

foreach mode ($modes)
# Define the search directory where to search for the file
set search_dir="/proj/Aurora_SG23701/WORK/v-jennie_lee/$block_name/run/r_n${version}/init_check/$mode.tt0p75v.wcl.cworst_ccworst_t_0c.setup"
# Find the required files in the directory
set link_log_file=`find "$search_dir" -name "link.log"`
set design_info_file=`find "$search_dir" -name "DesignInfo.rpt"`
set sdc_log_file=`find "$search_dir" -name "$block_name.read_sdc.log"`
set min_period_file=`find "$search_dir" -name "$block_name.min_period.rpt"`

# Initialize the variables
set link_status = "N/A"
set ulvt_ratio = "N/A"
set mem_num = "N/A"
set sdc_status = "N/A"
set min_period_pass = "N/A"
set port_num = "N/A"
set floating_ports_inputs = "N/A"
set floating_ports_outputs = "N/A"
set floating_ports_inouts = "N/A"
set unconstrained_point = "N/A"
set no_clock = "N/A"
set sdc_errors_count = 0
set sdc_warnings_count = 0
set min_period_errors_count = 0
set min_period_warnings_count = 0

# Check if the "link. log" file exists
if ("$link_log_file" != "") then
set success_run=`grep -i "was successfully linked" "$link_log_file"`
if ("$success_run" != "") then
set link_status = "link pass"
else
set link_status = "link fail"
endif
endif

if ("$design_info_file" != "") then
set line_ulvt=`grep -i "init_check.vt_Ratio.AREA:uLVT---SUMMARY---" "$design_info_file"`
set ulvt_ratio=`echo "$line_ulvt" | awk -F '---SUMMARY---' '{print $2}'`
set ulvt_ratio="$ulvt_ratio%"

set line_mem=`grep -i "init_check.inst.NUM:MEM---SUMMARY---" "$design_info_file"`
set mem_num=`echo "$line_mem" | awk -F '---SUMMARY---' '{print $2}'`

set line_port=`grep -i "init_check.Port.total:Count---SUMMARY---" "$design_info_file"`
set port_num='echo "$line_port" | awk -F '---SUMMARY---' '{print $2}'`

set line_floating_inputs=`grep -i "init_check.Port.input:Floating---SUMMARY---" "$design_info_file"`
set floating_ports_inputs=`echo "$line_floating_inputs" | awk -F '---SUMMARY---' '{print $2}'`

set line_floating_outputs=`grep -i "init_check.Port.output:Floating---SUMMARY---" "$design_info file"`
set floating_ports_outputs=`echo "$line_floating_outputs" | awk -F '---SUMMARY---' '{print $2}'`

set line_floating_inouts=`grep -i "init_check.Port.inout:Floating---SUMMARY---" "$design_info_file"`
set floating_ports_inouts=`echo "$line_floating_inouts" | awk -F '---SUMMARY---' '{print $2}'`

set line_unconstrained=`grep -i "init_check.$mode.CheckTiming:unConstrains---SUMMARY---" "$design_info_file"`
set unconstrained_point=`echo "$line_unconstrained" | awk -F '---SUMMARY---' '{print $2}'`

set line_no_clock=`grep -i "init_check.$mode.CheckTiming:noClock---SUMMARY---" "$design_info_file"`
set no_clock=`echo "$line_no_clock" | awk -F '---SUMMARY---' '{print $2}'`
endif

if ("$sdc_log_file" != "") then
    set sdc_errors=`grep -ic "error" "$sdc_log_file"`
    set sdc_warnings=`grep -ic "warning" "$sdc_log_file"`
    set sdc_status = "clean"
    if ("$sdc_errors" != 0 || "$sdc_warnings" != 0) then
        set sdc_status = "error"
        set sdc_errors_count = $sdc_errors
        set sdc_warnings_count = $sdc_warnings
        echo "SDC errors: $sdc_errors_count, SDC warnings: $sdc_warnings_count"
        
        # Display errors
        if ("$sdc_errors" != 0) then
            echo "Errors found in $sdc_log_file:"
            grep -i -C 2 "error" "$sdc_log_file"
        endif

        # Display warnings
        if ("$sdc_warnings" != 0) then
            echo "Warnings found in $sdc_log_file:"
            grep -i -C 2 "warning" "$sdc_log_file"
        endif
    endif
endif

if ("$min_period_file" != "") then
    set min_period_errors=`grep -ic "error" "$min_period_file"`
    set min_period_warnings=`grep -ic "warning" "$min_period_file"`
    set min_period_pass = "pass"
    if ("$min_period_errors" != 0 || "$min_period_warnings" != 0) then
        set min_period_pass = "no"
        set min_period_errors_count = $min_period_errors
        set min_period_warnings_count = $min_period_warnings
        echo "Min period errors: $min_period_errors_count, Min period warnings: $min_period_warnings_count"
        
        # Display errors
        if ("$min_period_errors" != 0) then
            echo "Errors found in $min_period_file:"
            grep -i -C 2 "error" "$min_period_file"
        endif

        # Display warnings
        if ("$min_period_warnings" != 0) then
            echo "Warnings found in $min_period_file:"
            grep -i -C 2 "warning" "$min_period_file"
        endif
    endif
endif

echo "$mode, $block_name, $version, $link_status, $ulvt_ratio, $sdc_status, $mem_num, $min_period_pass, $port_num, $floating_ports_inputs, $floating_ports_outputs, $floating_ports_inouts, $unconstrained_point, $no_clock" >> "$output_csv"
end

# Now, append the setup violations information from the func mode at the end of the CSV
set global_timing_file=`find "/proj/Aurora_SG23701/WORK/v-jennie_lee/$block_name/run/r_n20240918/init_check/func.tt0p75v.wcl.cworst_ccworst_t_0c.setup" -name "$block_name.global_timing.rpt"`
if ("$global_timing_file" != "") then
# Extract each line for WNS, TNS, and NUM
set wns_data=`grep -A 6 "Setup violations" "$global_timing_file" | head -5 | tail -1`
set tns_data=`grep -A 6 "Setup violations" "$global_timing_file" | head -6 | tail -1`
set num_data=`grep -A 6 "Setup violations" "$global_timing_file" | head -7 | tail -1`

# Extract values for each column
set setup_reg_reg_wns=`echo "$wns_data" | awk '{print $3}'`
set setup_reg_reg_tns=`echo "$tns_data" | awk '{print $3}'`
set setup_reg_reg_num=`echo "$num_data" | awk '{print $3}'`
set setup_in_reg_wns=`echo "$wns_data" | awk '{print $4}'`
set setup_in_reg_tns=`echo "$tns_data" | awk '{print $4}'`
set setup_in_reg_num=`echo "$tns_data" | awk '{print $4}'`
set setup_reg_out_wns=`echo "$wns_data" | awk '{print $5}'`
set setup_reg_out_tns=`echo "$tns_data" | awk '{print $5}'`
set setup_reg_out_num=`echo "$num_data" | awk '{print $5}'`
set setup_in_out_wns=`echo "$wns_data" | awk '{print $6}'`
set setup_in_out_tns=`echo "$tns_data" | awk '{print $6}'`
set setup_in_out_num=`echo "$num_data" | awk '{print $6}'`

# Write the setup violations to the CSV file
echo "Setup violations: " >> "$output_csv"

echo "reg->reg (WNS), reg->reg (TNS), reg->reg (NUM), in->reg (WNS), in->reg (TNS), in->reg (NUM), reg->out (WNS), reg->out (TNS), reg->out (NUM), in->out (WNS), in->out (TNS), in->out (NUM)" >> "$output_csv"
echo "$setup_reg_reg_wns, $setup_reg_reg_tns, $setup_reg_reg_num, $setup_in_reg_wns, $setup_in_reg_tns, $setup_in_reg_num, $setup_reg_out_wns, $setup_reg_out_tn
s, $setup_reg_out_num, $setup_in_out_wns, $setup_in_out_tns, $setup_in_out_num" >> "$output_csv"

# Extract each line for WNS, TNS, and NUM for hold violations
set hold_wns_data=`grep -A 6 "Hold violations" "$global_timing_file" | head -5 | tail -1`
set hold_tns_data=`grep -A 6 "Hold violations" "$global_timing_file" | head -6 | tail -1`
set hold_num_data=`grep -A 6 "Hold violations" "$global_timing_file" | head -7 | tail -1`

# Extract values for each column in hold violations
set hold_reg_reg_wns=`echo "$hold_wns_data" | awk '{print $3}'`
set hold_reg_reg_tns=`echo "$hold_tns_data" | awk '{print $3}'`
set hold_reg_reg_num=`echo "$hold_num_data" | awk '{print $3}'`

# Write the hold violations to the csv file
echo "Hold violations:" >> "$output_csv"
echo "reg->reg (WNS) , reg->reg (TNS) , reg->reg (NUM)" >> "$output_csv"
echo "$hold_reg_reg_wns, $hold_reg_reg_tns, $hold_reg_reg_num" >> "$output_csv"

else
echo "Error: $block_name. global_timing. rpt file not found for func mode."
endif

echo "Setup violations data appended correctly to csv file: $output_csv"
