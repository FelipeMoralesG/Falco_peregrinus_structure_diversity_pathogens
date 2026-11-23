#!/bin/bash
#SBATCH --job-name=pcangsd_pca
#SBATCH --output=logs/pcangsd_pca_%j.log
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=50G
# Step 09 — PCA (covariance matrix) with PCAngsd, with and without the outgroups.
# RECONSTRUCTED from the commands used interactively. With the default 100 iterations PCAngsd did not converge
# on the 93-individual data; --iter 500 converged (241 iterations).
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
source "${CONDA_SH}"; conda activate "${PCANGSD_ENV}"
mkdir -p "${BASE}/angsd/pcangsd"

pcangsd -b "${BASE}/angsd/falcons.beagle.gz"          -o "${BASE}/angsd/pcangsd/falcons_pcangsd"          -t 10 --iter 500
pcangsd -b "${BASE}/angsd/falcons_excluded.beagle.gz" -o "${BASE}/angsd/pcangsd/falcons_pcangsd_excluded" -t 10 --iter 500
echo "Done at $(date)"
