#!/bin/bash
#SBATCH --job-name=05_kraken
#SBATCH --output=logs/kraken_all_%j.log
#SBATCH --time=7-00:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=120G
# Step 11 — classify the unmapped READ PAIRS of every individual in mapping/ (about 7 h in total).
# Origin: server file scripts/05/05_kraken_files.sh (paths parameterised, otherwise unchanged).
# LIMITATION: only *.unmapped.R1/R2 are screened; *.unmapped.SE (merged and single reads) was NOT classified.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
DB="${KRAKEN_DB}"
MAPPING="${BASE}/mapping"
OUT="${BASE}/kraken_out"
mkdir -p "${OUT}"

for r1 in ${MAPPING}/*.unmapped.R1.fastq.gz; do
    sample=$(basename "$r1" .unmapped.R1.fastq.gz)

    echo "=========================================="
    echo "Starting $sample at $(date)"
    echo "Unmapped R1 size: $(du -h ${r1} | cut -f1)"
    echo "Unmapped R2 size: $(du -h ${MAPPING}/${sample}.unmapped.R2.fastq.gz | cut -f1)"
    echo "=========================================="

    start=$(date +%s)

    kraken2 --db $DB \
      --paired \
      --gzip-compressed \
      --threads 10 \
      --output ${OUT}/${sample}.kraken \
      --report ${OUT}/${sample}.report \
      ${MAPPING}/${sample}.unmapped.R1.fastq.gz \
      ${MAPPING}/${sample}.unmapped.R2.fastq.gz

    end=$(date +%s)
    elapsed=$(( (end - start) / 60 ))
    echo "Finished $sample at $(date) — took ${elapsed} minutes"
    echo ""
done

echo "All samples done at $(date)"
