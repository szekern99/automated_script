#!/bin/bash

# Define the directories to process
directories=("init" "place" "clock" "clock_opt" "route" "route_opt" "chip_finish" "ext" "sta")

# Define the base path
base_path="/proj/Aurora_SG23701/WORK/v-jennie_lee/vc9000d_subsys/run/r_n20240918/N0918_DFT_FP0910/rpt"

# Define the output CSV file
output_csv="/proj/Aurora_SG23701/WORK/v-jennie_lee/vc9000d_subsys/run/r_n20240918/script_for_stages_QoR/output.csv"

# Clear the output CSV file before writing to it
> "$output_csv"

# Function to check for file existence, with warning
check_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "$file"
    else
        echo "Warning: $file not found." >&2
        echo "N/A"
    fi
}

# Function to extract setup violations
extract_setup_violations() {
    local setup_file_path="$1"

    # Extract data using more precise grep/awk commands
    wns_data=$(zcat "$setup_file" | grep -A 6 "Setup mode" | grep "WNS" | awk '{print $6, $10, $12, $14}')
    tns_data=$(zcat "$setup_file" | grep -A 6 "Setup mode" | grep "TNS" | awk '{print $6, $10, $12, $14}')
    num_data=$(zcat "$setup_file" | grep -A 6 "Setup mode" | grep -E "Violating Paths|All Paths" | awk '{print $6, $10, $12, $14}')

    # Split and map extracted data to variables
    read -r reg_reg_wns in_reg_wns reg_out_wns in_out_wns <<<"$wns_data"
    read -r reg_reg_tns in_reg_tns reg_out_tns in_out_tns <<<"$tns_data"
    read -r reg_reg_num in_reg_num reg_out_num in_out_num <<<"$num_data"

    # Create the output CSV
    echo "Setup Violations:" >> "$output_csv"
    echo "reg->reg (WNS),reg->reg (TNS),reg->reg (NUM),in->reg (WNS),in->reg (TNS),in->reg (NUM),reg->out (WNS),reg->out (TNS),reg->out (NUM),in->out (WNS),in->out (TNS),in->out (NUM)" >> "$output_csv"
    echo "$reg_reg_wns,$reg_reg_tns,$reg_reg_num,$in_reg_wns,$in_reg_tns,$in_reg_num,$reg_out_wns,$reg_out_tns,$reg_out_num,$in_out_wns,$in_out_tns,$in_out_num" >> "$output_csv"
}

# Function to extract hold violations
extract_hold_violations() {
    local hold_file="$1"

    wns_data=$(zcat "$hold_file" | grep -A 6 "Hold mode" | grep "WNS" | awk '{print $6, $10, $12, $14}')
    tns_data=$(zcat "$hold_file" |grep -A 6 "Hold mode" | grep "TNS" | awk '{print $6, $10, $12, $14}')
    num_data=$(zcat "$hold_file" |grep -A 6 "Hold mode" | grep -E "Violating Paths|All Paths" | awk '{print $6, $10, $12, $14}')

    # Split and map extracted data to variables
    read -r reg_reg_wns in_reg_wns reg_out_wns <<<"$wns_data"
    read -r reg_reg_tns in_reg_tns reg_out_tns <<<"$tns_data"
    read -r reg_reg_num in_reg_num reg_out_num <<<"$num_data"

    # Append the hold violations data to the output CSV
    echo "Hold Violations:" >> "$output_csv"
    echo "reg->reg (WNS),reg->reg (TNS),reg->reg (NUM)" >> "$output_csv"
    echo "$reg_reg_wns,$reg_reg_tns,$reg_reg_num" >> "$output_csv" 
}



# Function to extract MBFF statistics and VT usage
extract_mbdff_statistics() {
    local mbdff_file="$1"
    local vt_usage_file="$2"
    local setup_file="$3"

    bits_per_flop=$(grep "Bits Per Flop" "$mbdff_file" | awk '{print $5}' || echo "N/A")
    mb_conversion_ratio=$(grep "Multibit Conversion Ratio(%)" "$mbdff_file" | awk '{print $5}' | head -1 || echo "N/A")
    density=$(zcat "$setup_file" 2>/dev/null | grep "Density:" | awk '{print $2}' || echo "N/A")
    ulvt_ratio=$(grep -A 2 "#Area" "$vt_usage_file" | grep "Percentage(%)" | awk '{print $8}' || echo "N/A")

    echo "Bits per flops,MB ratio,Utilization,uLVT ratio" >> "$output_csv"
    echo "$bits_per_flop,$mb_conversion_ratio,$density,$ulvt_ratio" >> "$output_csv"
}

# Function to process each directory
process_directory() {
    local dir="$1"
    local prefix="$dir"

    if [ ! "$(ls -A "$base_path/$dir" 2>/dev/null)" ]; then
        echo "Alert: $dir is still running and is currently empty." >&2
        return
    fi

    setup_file=$(check_file "$base_path/$dir/${prefix}.summary.gz")
    hold_file=$(check_file "$base_path/$dir/${prefix}_hold.summary.gz")
    mbdff_file=$(check_file "$base_path/$dir/vc9000d_subsys.mbdff_status.rpt")
    vt_usage_file=$(check_file "$base_path/$dir/vc9000d_subsys.vt_usage.rpt")

    echo "Processing directory: $dir" >> "$output_csv"
    extract_setup_violations "$setup_file"
    extract_hold_violations "$hold_file"
    extract_mbdff_statistics "$mbdff_file" "$vt_usage_file" "$setup_file"
}

# Main loop to process all directories
for dir in "${directories[@]}"; do
    process_directory "$dir"
done

