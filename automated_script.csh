#!/bin/csh
set block_name="enyo core"
# Define the search directory where to search for the file
set search_dir="/proj/Aurora_SG23701/WORK/v-jennie_lee/$block_name/run/r_n20240918/init_check/func.tt0p75v.wcl.cworst_ccworst_t_0c.setup"

# Define the directory where the output CSV should be stored
set output_dir="/proj/Aurora_SG23701/WORK/v-jennie_lee/$block_name/run/r_n20240918/testing"

# Find the "link.log" file in the directory
set link_log_file=`find $search_dir -name "link.log"`
# Find the "$block_name.DesignInfo.rpt" file in the directory
set vt_group_file=`find $search_dir -name "$block_name.DesignInfo.rpt"`

# Define the output CSV file path
set output_csv="$output_dir/QOR_report.csv"

# Initialize the variable for uLVT ratio
set ulvt_ratio = "N/A"

# Check if the "link.log" file exists
if (-e $link_log_file) then
    # Search for the keyword "successfully linked" in the file
    set success=`grep -i "successfully linked" $link_log_file`

    # Check if the vt_group_file exists
    if (-e $vt_group_file) then
        # Grep the specific line from the vt_group_file
        set line = `grep "init check.vt Ratio. NUM: uLVT --- SUMMARY --- 14.840" $vt_group_file`

        # Extract the ulvt_ratio value
        set ulvt_ratio = `echo $line | awk -F ' --- SUMMARY --- ' '{print $2}'`
        set ulvt_ratio = "$ulvt_ratio%"
    else
        echo "Error: $block_name.DesignInfo.rpt file not found in the specified directory."
    endif

    # Write to the CSV file based on whether the keyword is found
    if ("$success" != "") then
        echo "comment,ulvt_ratio" > $output_csv
        echo "link pass,$ulvt_ratio" >> $output_csv
    else
        echo "comment,ulvt_ratio" > $output_csv
        echo "link fail,$ulvt_ratio" >> $output_csv
    endif
else
    echo "Error: link.log file not found in the specified directory."
endif

echo "CSV file created: $output_csv"
