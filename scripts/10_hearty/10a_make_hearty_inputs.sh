#!/bin/bash
# Step 10 — HEARTY inputs: which individuals, which minimum depth, one command per individual.
# RECONSTRUCTED from the project notes. Run directly from the repository root.
# Rules : individuals with mean depth >= 9.6x (counts as "10x"); per-individual minimum depth -m = round(depth / 2).
#         Only individuals that have a BAM in the 89-individual list are kept (=> outgroups excluded). Result: 79.
# The depth lookup uses the header name "avg_depth" (column 21 of general_stats.tsv, which is what the notes used).
# CAUTION: the first column of general_stats.tsv must use the same names as the BAM files (Kola4, not Kola-4), otherwise
#         those individuals are silently dropped by the intersection below - always check that the count is 79.
# -t 0.25 (heterozygosity threshold) was confirmed by the supervisor as final; -f = autosomes only.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"

awk -F'[ \t]+' 'NR==1{for(i=1;i<=NF;i++) if($i=="avg_depth") d=i; next}
                {gsub(/\r/,""); if($d>=9.6) printf "%s\t%d\n", $1, int($d/2+0.5)}' general_stats.tsv > depth_ok.tsv

sed 's#.*/##; s/\.final\.RG\.bam$//' bam_files_excluded.txt > bam_samples.txt
awk -F'\t' 'NR==FNR{ok[$1]; next} ($1 in ok)' bam_samples.txt depth_ok.tsv > hearty_samples.tsv
wc -l hearty_samples.tsv                 # expect 79

while IFS=$'\t' read -r s m; do
  echo "python3 ${HEARTY_PY} -b ${BASE}/mapping/${s}.final.RG.bam -o ${s} -d ${BASE}/hearty -c 10 -m ${m} -t 0.25 -f ${AUTOSOMES} --ref ${REF_FNA} --angsd ${ANGSD_BIN}"
done < hearty_samples.tsv > hearty_commands.txt
head -2 hearty_commands.txt
