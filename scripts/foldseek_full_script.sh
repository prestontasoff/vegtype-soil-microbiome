#!/bin/bash

# Variables
COLABFOLD_BASE="/groups/banfield/projects/environmental/EastRiver/Vegtype/Preston/protein_clustering_v2/AOA_prot_cluster/colabfold_output"
PDB_DB="/groups/banfield/projects/environmental/EastRiver/hillslope/Foldseek/foldseek/pdb/pdb"
OUTPUT_BASE="/groups/banfield/projects/environmental/EastRiver/Vegtype/Preston/protein_clustering_v2/AOA_prot_cluster/foldseek_PDB_results"
TMP_DIR="/tmp/foldseek_pdb_$$"

# Create output and temp directories
mkdir -p $OUTPUT_BASE
mkdir -p $TMP_DIR

echo "Starting Foldseek searches against full PDB database..."
echo "Timestamp: $(date)"

# Counter for progress tracking
total_dirs=$(find $COLABFOLD_BASE -maxdepth 1 -type d -name "subfam*" | wc -l)
current=0

# Loop through each subfamily ColabFold output directory
for subfam_dir in $COLABFOLD_BASE/subfam*/; do
    if [[ -d "$subfam_dir" ]]; then
        current=$((current + 1))
        subfam_name=$(basename "$subfam_dir")
        
        echo "[$current/$total_dirs] Processing $subfam_name..."
        
        # Check if PDB files exist in this directory
        pdb_files=$(find "$subfam_dir" -name "*.pdb" | head -1)
        if [[ -z "$pdb_files" ]]; then
            echo "  No PDB files found in $subfam_name, skipping..."
            continue
        fi
        
        # Create output directory for this subfamily
        mkdir -p "$OUTPUT_BASE/$subfam_name"
        
        # Run Foldseek search with more conservative parameters for PDB
        foldseek easy-search \
            "$subfam_dir/*.pdb" \
            "$PDB_DB" \
            "$OUTPUT_BASE/$subfam_name/${subfam_name}_vs_PDB.m8" \
            "$TMP_DIR/${subfam_name}_tmp" \
            --format-output query,target,bits,evalue,qstart,qend,qlen,tstart,tend,tlen,theader,qcov,tcov,pident,alnle --threads \$SLRUM_CPUS_ON_NOD
        
        echo "  Completed $subfam_name"
        
        # Clean up temp files for this subfamily
        rm -rf "$TMP_DIR/${subfam_name}_tmp"
    fi
done

# Combine all results into a single master file
echo "Combining all results into master file..."
cat $OUTPUT_BASE/*/subfam*_vs_PDB.m8 > $OUTPUT_BASE/ALL_subfamilies_vs_PDB_combined.m8

# Clean up
rm -rf $TMP_DIR

echo "Foldseek search against PDB database completed!"
echo "Results saved in: $OUTPUT_BASE"
echo "Combined results: $OUTPUT_BASE/ALL_subfamilies_vs_PDB_combined.m8"
echo "Timestamp: $(date)"