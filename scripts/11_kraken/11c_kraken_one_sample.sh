#!/bin/bash
#SBATCH --job-name=kraken_one
#SBATCH --output=logs/kraken_one_%j.log
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=120G
# Step 11 — same classification for a single individual (used for Yamal4, which was re-mapped after 11b had run).
# Origin: server file kraken_yamal4.sh, generalised with the sample name as argument.
# Usage : sbatch 11c_kraken_one_sample.sh Yamal4
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
SAMPLE="${1:?usage: sbatch 11c_kraken_one_sample.sh SAMPLE}"

kraken2 --db ${KRAKEN_DB} \
  --paired \
  --gzip-compressed \
  --threads 10 \
  --output ${BASE}/kraken_out/${SAMPLE}.kraken \
  --report ${BASE}/kraken_out/${SAMPLE}.report \
  ${BASE}/mapping/${SAMPLE}.unmapped.R1.fastq.gz \
  ${BASE}/mapping/${SAMPLE}.unmapped.R2.fastq.gz

echo "Done at $(date)"
