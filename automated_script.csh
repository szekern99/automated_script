#!/bin/csh
set block_name="enyo core"
set mode="func"
# Define the search directory where to search for the file
set search_dir="/proj/Aurora_SG23701/WORK/v-jennie_lee/$block_name/run/r_n20240918/init_check/$mode.tt0p75v.wcl.cworst_ccworst_t_0c.setup"

# Define the directory where the output CSV should be stored
set output_dir="/proj/Aurora_SG23701/WORK/v-jennie_lee/$block_name/run/r_n20240918/testing"

# Find the "link.log" file in the directory
set link_log_file=`find $search_dir -name "link.log"`
# Find the "$block_name.DesignInfo.rpt" file in the directory
set design_info_file=`find $search_dir -name "$block_name.DesignInfo.rpt"`
# Find the "enyo_core.read_sdc.log" file in the directory
set sdc_log_file=`find $search_dir -name "enyo_core.read_sdc.log"`
# Find the "enyo_core.min_period.rpt" file in the directory
set min_period_file=`find $search_dir -name "enyo_core.min_period.rpt"`

# Define the output CSV file path
set output_csv="$output_dir/QOR_${block_name}_${mode}_report.csv"

# Initialize the variables
set ulvt_ratio = "N/A"
set mem_num = "N/A"
set sdc_status = "clean"
set min_period_pass = "pass"
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

# Debugging: Print the variables
echo "link_log_file: $link_log_file"
echo "design_info_file: $design_info_file"
echo "sdc_log_file: $sdc_log_file"
echo "min_period_file: $min_period_file"

# Check if the "link.log" file exists
if ("$link_log_file" != "") then
    # Search for the keyword "successfully linked" in the file
    set success=`grep -i "successfully linked" $link_log_file`
    echo "success: $success"

    # Check if the design_info_file exists
    if ("$design_info_file" != "") then
        # Grep the specific line for uLVT ratio from the design_info_file
        set line_ulvt = `grep -i "init_check. Design. vtRatio. uLVT --- SUMMARY ---" $design_info_file`
        echo "line_ulvt: $line_ulvt"

        # Extract the ulvt_ratio value
        set ulvt_ratio = `echo $line_ulvt | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "ulvt_ratio: $ulvt_ratio"

        # Add the '%' sign to the ulvt_ratio value
        set ulvt_ratio = "$ulvt_ratio%"

        # Grep the specific line for MEM num from the design_info_file
        set line_mem = `grep -i "init check. inst. num: mem --- summary ---" $design_info_file`
        echo "line_mem: $line_mem"

        # Extract the mem_num value
        set mem_num = `echo $line_mem | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "mem_num: $mem_num"

        # Grep the specific line for port count from the design_info_file
        set line_port = `grep -i "init_check. Port. total: Count --- SUMMARY ---" $design_info_file`
        echo "line_port: $line_port"

        # Extract the port_num value
        set port_num = `echo $line_port | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "port_num: $port_num"

        # Grep the specific line for floating ports (inputs) from the design_info_file
        set line_floating_inputs = `grep -i "init_check. Port. input: Floating --- SUMMARY ---" $design_info_file`
        echo "line_floating_inputs: $line_floating_inputs"

        # Extract the floating_ports_inputs value
        set floating_ports_inputs = `echo $line_floating_inputs | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "floating_ports_inputs: $floating_ports_inputs"

        # Grep the specific line for floating ports (outputs) from the design_info_file
        set line_floating_outputs = `grep -i "init_check. Port. output: Floating --- SUMMARY ---" $design_info_file`
        echo "line_floating_outputs: $line_floating_outputs"

        # Extract the floating_ports_outputs value
        set floating_ports_outputs = `echo $line_floating_outputs | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "floating_ports_outputs: $floating_ports_outputs"

        # Grep the specific line for floating ports (inouts) from the design_info_file
        set line_floating_inouts = `grep -i "init_check. Port. inout : Floating --- SUMMARY ---" $design_info_file`
        echo "line_floating_inouts: $line_floating_inouts"

        # Extract the floating_ports_inouts value
        set floating_ports_inouts = `echo $line_floating_inouts | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "floating_ports_inouts: $floating_ports_inouts"

        # Grep the specific line for unconstrained point from the design_info_file
        set line_unconstrained = `grep -i "init_check. func. CheckTiming: unConstrains --- SUMMARY ---" $design_info_file`
        echo "line_unconstrained: $line_unconstrained"

        # Extract the unconstrained_point value
        set unconstrained_point = `echo $line_unconstrained | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "unconstrained_point: $unconstrained_point"

        # Grep the specific line for no clock from the design_info_file
        set line_no_clock = `grep -i "init_check. func. CheckTiming: noClock --- SUMMARY ---" $design_info_file`
        echo "line_no_clock: $line_no_clock"

        # Extract the no_clock value
        set no_clock = `echo $line_no_clock | awk -F ' --- SUMMARY --- ' '{print $2}'`
        echo "no_clock: $no_clock"
    else
        echo "Error: $block_name.DesignInfo.rpt file not found in the specified directory."
    endif

    # Determine the link status
    if ("$success" != "") then
        set link_status = "link pass"
    else
        set link_status = "link fail"
    endif
else
    echo "Error: link.log file not found in the specified directory."
endif

# Check if the "enyo_core.read_sdc.log" file exists
if ("$sdc_log_file" != "") then
    # Search for the keywords "error" and "warning" (case-insensitive) in the file
    set sdc_errors=`grep -ic "error" $sdc_log_file`
    set sdc_warnings=`grep -ic "warning" $sdc_log_file`
    echo "sdc_errors: $sdc_errors"
    echo "sdc_warnings: $sdc_warnings"
    
    # Update sdc_status if errors are found
    if ("$sdc_errors" != "0" || "$sdc_warnings" != "0") then
        set sdc_status = "error"
        set sdc_errors_count = $sdc_errors
        set sdc_warnings_count = $sdc_warnings
    endif
else
    echo "Error: enyo_core.read_sdc.log file not found in the specified directory."
endif

# Check if the "enyo_core.min_period.rpt" file exists
if ("$min_period_file" != "") then
    # Search for the keywords "error" and "warning" (case-insensitive) in the file
    set min_period_errors=`grep -ic "error" $min_period_file`
    set min_period_warnings=`grep -ic "warning" $min_period_file`
    echo "min_period_errors: $min_period_errors"
    echo "min_period_warnings: $min_period_warnings"
    
    # Update min_period_pass if errors are found
    if ("$min_period_errors" != "0" || "$min_period_warnings" != "0") then
        set min_period_pass = "no"
        set min_period_errors_count = $min_period_errors
        set min_period_warnings_count = $min_period_warnings
    endif
else
    echo "Error: enyo_core.min_period.rpt file not found in the specified directory."
endif

# Write to the CSV file
echo "comment,ulvt_ratio,mem_num,read sdc error,min_period_pass,port_num,floating ports (inputs),floating ports (outputs),floating ports (inouts),unconstrained point,no clock" > $output_csv
echo "$link_status,$ulvt_ratio,$mem_num,$sdc_status,$min_period_pass,$port_num,$floating_ports_inputs,$floating_ports_outputs,$floating_ports_inouts,$unconstrained_point,$no_clock" >> $output_csv

# Echo errors and warnings count
echo "SDC Log - Errors: $sdc_errors_count, Warnings: $sdc_warnings_count"
echo "Min Period Log - Errors: $min_period_errors_count, Warnings: $min_period_warnings_count"

echo "CSV file created: $output_csv"
