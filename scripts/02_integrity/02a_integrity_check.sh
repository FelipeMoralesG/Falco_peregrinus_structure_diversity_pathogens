#!/bin/bash
#SBATCH --job-name=check_integrity
#SBATCH --output=logs/integrity_results.log
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=4
# Step 02 — gzip integrity test of every FASTQ, 2 at a time.
# Origin: server file scripts/02/02_integrity_check.sh (paths parameterised, otherwise unchanged).
# CAUTION: a file that needs more than 600 s to test is reported as CORRUPTED_OR_TIMEOUT even if it is fine.
#          Every flagged file is therefore re-tested without a time limit in 02b.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"

find "${BASE}/raw/" -name "*.fastq.gz" | \
  xargs -P 2 -I {} bash -c '
    start=$(date +%s)
    if timeout 600 gzip -t "{}" 2>/dev/null; then
      status="OK"
    else
      status="CORRUPTED_OR_TIMEOUT"
    fi
    end=$(date +%s)
    stdbuf -oL echo "$status: {} ($((end-start))s)"
  '

echo "Check complete"
