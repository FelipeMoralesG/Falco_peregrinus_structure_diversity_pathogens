#!/bin/bash
#SBATCH --job-name=downloads
#SBATCH --output=logs/%x_%j.log
#SBATCH --time=3-00:00:00
#SBATCH --cpus-per-task=4
# Step 01 — download FASTQ files from ENA.
# Origin: server file scripts/01/01_downloads.sh (paths parameterised, otherwise unchanged).
# Input : ${BASE}/ena.txt — one download command per line, run 8 at a time (built by 01a; the original file was not kept).
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"
parallel -j 8 < ena.txt
