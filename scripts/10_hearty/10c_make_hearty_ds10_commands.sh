#!/bin/bash
# Step 10 — downsampled HEARTY (every site down-sampled to 10 reads) from the basecall tables of 10b.
# RECONSTRUCTED; the generated lines are identical to those in the server's hearty_ds10_commands.txt (checked, including -c 10).
# --basecall-file replaces -b/--ref/--angsd/-f: no ANGSD run, the regions are already those of the first run.
# -m 10 for every individual (the effective cutoff is max(-m, --downsample-depth)). Output names end in _ds10.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"
mkdir -p hearty_ds10

cut -f1 hearty_samples.tsv | while read -r s; do
  echo "python3 ${HEARTY_PY} --basecall-file ${BASE}/hearty/${s}.basecall.txt.gz -o ${s}_ds10 -d ${BASE}/hearty_ds10 -c 10 -m 10 -t 0.25 --downsample-depth 10 --downsample-reps 10"
done > hearty_ds10_commands.txt
head -1 hearty_ds10_commands.txt
