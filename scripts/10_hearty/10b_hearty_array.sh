#!/bin/bash
#SBATCH --job-name=hearty
#SBATCH --output=logs/hearty_%A_%a.out
#SBATCH --error=logs/hearty_%A_%a.err
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G
#SBATCH --time=72:00:00
#SBATCH --array=1-79%4
# Step 10 — HEARTY, one individual per task: runs ANGSD on the BAM, then summarises heterozygosity and ROH windows.
# Origin: server file 08_hearty.sh (paths parameterised, otherwise unchanged).
# ANGSD inside HEARTY used: -minq 20 -minmapq 20 -uniqueOnly 1 -remove_bads 1 -docounts 1 -dumpCounts 4 (see the .arg files).
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
bash -c "$(sed -n ${SLURM_ARRAY_TASK_ID}p ${BASE}/hearty_commands.txt)"
