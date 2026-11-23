#!/bin/bash
#SBATCH --job-name=redownload
#SBATCH --output=logs/%x_%j.log
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
# Step 02 — delete the files flagged by 02a, download them again from ENA, re-test them without a time limit.
# RECONSTRUCTED: generalised from two throw-away scripts (redownload_corrupted.sh, recheck_integrity.sh)
#                that hard-coded the six affected files.
# Input : ${BASE}/failed_files.txt — one FASTQ file name per line, built from the 02a log with
#   grep CORRUPTED_OR_TIMEOUT logs/integrity_results.log \
#     | sed -E 's/^CORRUPTED_OR_TIMEOUT: (.*) \([0-9]+s\)$/\1/' | xargs -n1 basename > failed_files.txt
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"
RAW="${BASE}/raw"

while read -r f; do rm -f "${RAW}/${f}"; done < failed_files.txt

# run accessions of the failed files -> ENA URLs of both mates (wget -nc skips the mate that is already there)
pattern=$(sed 's/_[12]\.fastq\.gz$//; s/\.fastq\.gz$//' failed_files.txt | sort -u | paste -sd'|')
grep -E "${pattern}" report.tsv | cut -f7 | tr ';' '\n' | sed 's|^|ftp://|' | \
    xargs -P 3 -I {} wget -nc -q -P "${RAW}" {}

while read -r f; do
    gzip -t "${RAW}/${f}" 2>/dev/null && echo "OK: ${f}" || echo "CORRUPTED: ${f}"
done < failed_files.txt
echo "Done"
