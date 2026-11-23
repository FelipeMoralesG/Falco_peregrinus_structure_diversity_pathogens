#!/bin/bash
# Step 05 — one PlainMap command per manifest (= per individual) -> plainmap_commands.txt
# RECONSTRUCTED from the project notes (original: create_plainmap_commands.sh). Run directly.
# PlainMap runs with its default "modern" library type (BWA-MEM), MAPQ 20, and exports the unmapped reads.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
MANIFEST_DIR="${BASE}/manifests"
COMMANDS="${BASE}/plainmap_commands.txt"

for manifest in ${MANIFEST_DIR}/*_manifest.txt; do
    sample=$(basename "$manifest" _manifest.txt)
    echo "bash ${PLAINMAP} --manifest ${manifest} --prefix ${sample} --ref ${REF_FNA} --outdir ${BASE}/mapping --threads 10 --emit-unmapped-fastq"
done > "$COMMANDS"

wc -l "$COMMANDS"
head -2 "$COMMANDS"
