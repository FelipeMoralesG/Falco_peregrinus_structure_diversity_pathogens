#!/bin/bash
#SBATCH --job-name=07_pcangsd
#SBATCH --output=logs/pcangsd_admix_%j.log
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
# Step 09 — admixture proportions for K = 2..8 (89 individuals, outgroups excluded).
# Origin: server file scripts/07_pcangsd/07_pcangsd.sh (paths parameterised, otherwise unchanged).
# Output: angsd/pcangsd/falcons_pcangsd_excluded_K<K>.admix.<K>.Q  (rows = individuals in bam_files_excluded.txt order)
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
source "${CONDA_SH}"
conda activate "${PCANGSD_ENV}"

for K in 2 3 4 5 6 7 8; do
    pcangsd \
        -b ${BASE}/angsd/falcons_excluded.beagle.gz \
        -o ${BASE}/angsd/pcangsd/falcons_pcangsd_excluded_K${K} \
        -t 10 \
        --admix \
        --admix-K $K \
        --iter 500
done
