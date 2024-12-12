#!/bin/bash

base_dir="../data/pdb"

# make a dir for pdb files
mkdir -p "$base_dir"

# Path to the input file
input_file="../data/structure_search/build_profile.txt"

# Extract PDB codes using grep and regex
pdb_entry=$(grep -oE '\b[0-9][a-zA-Z0-9]{3}[A-Za-z]?\b' "$input_file")

# Save the codes in a file with the status of the download
status_file="$base_dir/pdb_codes.txt"
# Clear the output file if it exists
> "$status_file"

# Initialize counters
success_count=0
failure_count=0

# Iterate over the extracted codes
for entry in $pdb_entry; do
    code="${entry:0:4}"  # Extract the first 4 characters as the PDB code
    chain="${entry:4}"   # Extract the chain (if present)

    # Check if the PDB file already exists
    if [[ -f "$base_dir/${code}.pdb" ]]; then
        echo "$code $chain SUCCESS (already downloaded)" >> "$status_file"
        ((success_count++))
    else
        # Download files with wget
        if wget "https://files.rcsb.org/download/${code}.pdb" -O "$base_dir/${code}.pdb"; then
            echo "$code  $chain  SUCCESS" >> "$status_file"
            ((success_count++))
        else
            rm "$base_dir/${code}.pdb"
            echo "$code  $chain  FAILED" >> "$status_file"
            ((failure_count++))
        fi
    fi
done

# Print summary
echo "Download Summary:"
echo "Success: $success_count out of $((success_count + failure_count))"
echo "Failed: $failure_count out of $((success_count + failure_count))"
