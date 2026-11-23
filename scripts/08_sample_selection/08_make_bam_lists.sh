#!/bin/bash
# Step 08 — BAM lists used by ANGSD / PCAngsd.
# Exclusions were done by MOVING the individual's outputs out of mapping/ before this step:
#   - 7 museum toe-pad samples (F. p. furuitii x2, ernesti x3, peregrinator x2)      -> excluded_mapping/
#   - Fp_macropus_Australia_PEFAVIC206 (very low depth and coverage)                  -> excluded_mapping/low_coverage/
# Run directly from the repository root.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"

ls ${BASE}/mapping/*.bam > bam_files.txt                                     # 93 individuals (incl. 4 outgroup individuals)
grep -v "cherrug\|1947-17998\|fasciinucha" bam_files.txt > bam_files_excluded.txt   # 89 ingroup individuals
# outgroups: Saker (BGI_Falco_cherrug), Prairie falcon (1947-17998), Taita falcon (Falco_fasciinucha_Taita1/2)
wc -l bam_files.txt bam_files_excluded.txt
