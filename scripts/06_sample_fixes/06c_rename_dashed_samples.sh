#!/bin/bash
# Step 06 — three aliases carry a dash in ENA (Kola-4, Kolyma-2, Kolyma-3). After mapping, their outputs were renamed
# without the dash so that every sample has the same naming as in the metadata.
# RECONSTRUCTED. The folder, log and fastp-report renames below are taken from the shell history; the loop for the
# top-level files (BAM, index, stats, coverage, unmapped FASTQ) is a reconstruction - the command used was not recorded.
# Not renamed: names INSIDE files (read-group tags in the BAM header, the "sample" column of the stats tables).
# Run directly inside mapping/.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}/mapping"
for pair in "Kola-4:Kola4" "Kolyma-2:Kolyma2" "Kolyma-3:Kolyma3"; do
    old="${pair%%:*}"; new="${pair##*:}"
    mv "${old}_plainmap.log" "${new}_plainmap.log"
    mv "${old}" "${new}"
    mv "${new}/fastp_reports/${old}.${old}.PE0000.R1_0000.fastp.json" "${new}/fastp_reports/${new}.${new}.PE0000.R1_0000.fastp.json"
    for f in "${old}".*; do mv "$f" "${new}${f#${old}}"; done      # e.g. Kola-4.final.RG.bam -> Kola4.final.RG.bam
done
