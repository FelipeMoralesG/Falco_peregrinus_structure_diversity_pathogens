#!/bin/bash
# Step 04 — one PlainMap manifest per individual (ENA sample_alias): one FASTQ path per line.
# RECONSTRUCTED from the project notes (the original script, m.sh, is not in the final script folder).
# Run directly (fast), from the repository root, on an EMPTY manifests/ folder: the output is appended.
# Paired runs contribute _1 and _2; runs without ';' in fastq_ftp are single-end.
# cut is used instead of "read a b c ..." because the TSV has empty fields (e.g. submitted_ftp) and, with
# IFS=tab, read collapses consecutive tabs, which shifts every later field by one.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"
RAW="${BASE}/raw"
MANIFEST_DIR="${BASE}/manifests"
mkdir -p "${MANIFEST_DIR}"
[ -z "$(ls -A "${MANIFEST_DIR}")" ] || { echo "manifests/ is not empty - aborting"; exit 1; }

tail -n +2 report.tsv | while IFS=$'\t' read -r line; do
    run_acc=$(echo "$line" | cut -f1)
    fastq_ftp=$(echo "$line" | cut -f7)
    sample_alias=$(echo "$line" | cut -f9)

    if [[ "$fastq_ftp" == *";"* ]]; then
        echo "${RAW}/${run_acc}_1.fastq.gz" >> "${MANIFEST_DIR}/${sample_alias}_manifest.txt"
        echo "${RAW}/${run_acc}_2.fastq.gz" >> "${MANIFEST_DIR}/${sample_alias}_manifest.txt"
    else
        echo "${RAW}/${run_acc}.fastq.gz"   >> "${MANIFEST_DIR}/${sample_alias}_manifest.txt"
    fi
done

ls "${MANIFEST_DIR}" | wc -l      # 103 manifests at this point
