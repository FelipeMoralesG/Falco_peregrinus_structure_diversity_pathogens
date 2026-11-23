#!/bin/bash
#SBATCH --job-name=hearty_ds10
#SBATCH --output=logs/hearty_ds10_%A_%a.out
#SBATCH --error=logs/hearty_ds10_%A_%a.err
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G
#SBATCH --time=72:00:00
#SBATCH --array=1-79%4
# Step 10 — downsampled HEARTY array (STATUS: still running when this repository was written, about 18 h per individual).
# Origin: server file 08_hearty_ds10.sh (paths parameterised, otherwise unchanged).
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
bash -c "$(sed -n ${SLURM_ARRAY_TASK_ID}p ${BASE}/hearty_ds10_commands.txt)"
