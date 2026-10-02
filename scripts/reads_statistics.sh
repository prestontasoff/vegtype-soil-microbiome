#!/bin/bash

# Directory containing BAM files
BAM_DIR="/groups/banfield/projects/environmental/EastRiver/Vegtype/Preston/coverages/bam"

# Output file
OUTPUT_FILE="/groups/banfield/projects/environmental/EastRiver/Vegtype/Preston/coverages/bam_stats.csv"

# Write header to the output file
echo "File,Total Reads,Mapped Reads,Unmapped Reads" > $OUTPUT_FILE

# Function to process a single BAM file
process_bam_file() {
    local bam_file=$1
    local total_reads=$(samtools view -c "$bam_file")
    local mapped_reads=$(samtools view -c -F 4 "$bam_file")
    local unmapped_reads=$(samtools view -c -f 4 "$bam_file")
    echo "$(basename "$bam_file"),$total_reads,$mapped_reads,$unmapped_reads"
}

export -f process_bam_file

# Find all BAM files and process them in parallel using 10 threads
find "$BAM_DIR" -name "*.bam" | parallel -j 10 process_bam_file >> $OUTPUT_FILE
