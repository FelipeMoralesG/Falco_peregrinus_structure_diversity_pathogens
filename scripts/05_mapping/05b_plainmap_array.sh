#!/bin/bash
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G
#SBATCH --time=360:00:00
#SBATCH --array=1-103%4
#SBATCH --output=logs/plainmap_%A_%a.out
#SBATCH --error=logs/plainmap_%A_%a.err
# Step 05 — mapping array: task N runs line N of plainmap_commands.txt, 4 individuals at a time.
# Origin: server file scripts/03/03_plainmap.sh (paths parameterised, otherwise unchanged).
# The array size was set to 103 (manifests at the time); set it to the number of lines of plainmap_commands.txt.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
bash -c "$(sed -n ${SLURM_ARRAY_TASK_ID}p ${BASE}/plainmap_commands.txt)"
