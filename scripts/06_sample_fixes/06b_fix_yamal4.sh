#!/bin/bash
#SBATCH --job-name=fix_Yamal4
#SBATCH --output=logs/%x_%j.log
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G
# Step 06 — Yamal4 failed in the array: "Found R2 without matching R1 for key 'SRR13326544.1'".
# Cause : SRR13326544.fastq.gz is a single-end file whose read names end in "/2" ("@SRR13326544.1 1/2"),
#         so PlainMap classified it as an R2 file.
# Fix   : remove the "/2" suffix and point the manifest to the corrected file.
# Origin: server file fix_yamal4.sh (paths parameterised, otherwise unchanged).
# LIMITATION: the sed is applied to EVERY line of the FASTQ, not only to the read-name lines, so a quality line
#         ending in "/2" would lose two characters. Not re-verified (see README, Limitations). A header-only
#         version would be:  awk 'NR%4==1{sub(/\/2$/,"")} {print}'
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"

zcat ${BASE}/raw/SRR13326544.fastq.gz | \
    sed 's|/2$||' | \
    gzip > ${BASE}/raw/SRR13326544_fixed.fastq.gz

sed -i 's/SRR13326544.fastq.gz/SRR13326544_fixed.fastq.gz/' ${BASE}/manifests/Yamal4_manifest.txt

bash "${PLAINMAP}" \
  --manifest ${BASE}/manifests/Yamal4_manifest.txt \
  --prefix Yamal4 \
  --ref ${REF_FNA} \
  --outdir ${BASE}/mapping \
  --threads 10 \
  --emit-unmapped-fastq
