#!/bin/bash
#SBATCH --job-name=ref_prep
#SBATCH --output=logs/%x_%j.log
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=3G
# Step 03 — reference genome: own copy, BWA index, samtools index, autosome list.
# RECONSTRUCTED: the commands were run separately (bwa index through "sbatch --wrap", the rest interactively).
# Usage : sbatch scripts/03_reference/03_prepare_reference.sh /path/to/GCA_001887755.1_falPer2_genomic.fna
# Why a copy: the supervisor's reference folder was read-only, so bwa could not write its index files there.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
SRC_REF="${1:?usage: sbatch 03_prepare_reference.sh /path/to/reference.fna}"

mkdir -p "$(dirname "${REF_FNA}")"
cp -n "${SRC_REF}" "${REF_FNA}"
bwa index "${REF_FNA}"
samtools faidx "${REF_FNA}"

# chromosomes 1-18 only: no Z chromosome (the grep drops "chromosome Z"), no unplaced scaffolds (KV...)
grep "Falco peregrinus chromosome [^Z]" "${REF_FNA}" | awk '{print $1}' | sed 's/>//' > "${AUTOSOMES}"
wc -l "${AUTOSOMES}"        # expect 18
