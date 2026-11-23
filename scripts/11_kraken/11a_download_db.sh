#!/bin/bash
#SBATCH --job-name=kraken_db
#SBATCH --output=logs/%x_%j.log
#SBATCH --time=72:00:00
#SBATCH --cpus-per-task=1
# Step 11 — Kraken2 PlusPF database (bacteria, archaea, viruses, plasmids, human, protozoa, fungi), build of 2026-06-26.
# Origin: server file scripts/04/04_download_kraken_db.sh (paths parameterised, otherwise unchanged).
# Size: ~91 GB archive, ~118 GB hash.k2d => loading it needs > 110 GB RAM (nodes with >= 120 GB were requested).
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
mkdir -p "${KRAKEN_DB}"
cd "${KRAKEN_DB}"
wget -c https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_20260626.tar.gz
tar -xzvf k2_pluspf_20260626.tar.gz
