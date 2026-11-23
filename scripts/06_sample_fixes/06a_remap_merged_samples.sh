#!/bin/bash
#SBATCH --job-name=plainmap_missing
#SBATCH --output=logs/%x_%j.log
#SBATCH --time=120:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G
# Step 06 — re-map the two individuals whose manifests were merged in 04b (one PE run + one SE run each).
# Origin: server file missing_map.sh (paths parameterised, otherwise unchanged).
# Any earlier output of these two individuals was deleted from mapping/ beforehand.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"

for s in Kola6 Kolyma1; do
    bash "${PLAINMAP}" \
      --manifest ${BASE}/manifests/${s}_manifest.txt \
      --prefix ${s} \
      --ref ${REF_FNA} \
      --outdir ${BASE}/mapping \
      --threads 10 \
      --emit-unmapped-fastq
done
