#!/bin/bash
#SBATCH --job-name=06_angsd
#SBATCH --output=logs/angsd_%j.log
#SBATCH --time=5-00:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=80G
# Step 09 — genotype likelihoods (beagle format) on autosomes.
# Origin: server file scripts/06/06.sh (89-individual run), parameterised. The 93-individual run (with outgroups)
#   used the same flags with bam_files.txt and output prefix angsd/falcons.
# Usage : sbatch 09a_angsd.sh [BAMLIST] [OUT_PREFIX]      defaults: bam_files_excluded.txt, angsd/falcons_excluded
# Memory: 80 GB (an earlier run with 30 GB was killed by the scheduler while merging chromosome 6).
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
BAMLIST="${1:-${BASE}/bam_files_excluded.txt}"
OUTPFX="${2:-${BASE}/angsd/falcons_excluded}"
mkdir -p "$(dirname "${OUTPFX}")"

"${ANGSD_BIN}" \
    -bam "${BAMLIST}" \
    -ref "${REF_FNA}" \
    -rf  "${AUTOSOMES}" \
    -out "${OUTPFX}" \
    -minmaf 0.05 \
    -minq 25 \
    -minmapq 25 \
    -docounts 1 \
    -GL 1 \
    -doGlf 2 \
    -doMajorMinor 1 \
    -doMaf 1 \
    -SNP_pval 1e-6 \
    -nThreads 10 \
    -uniqueOnly 1
