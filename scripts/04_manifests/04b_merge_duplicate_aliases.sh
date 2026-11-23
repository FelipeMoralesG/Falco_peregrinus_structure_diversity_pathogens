#!/bin/bash
# Step 04 — two individuals are registered in ENA under two aliases (one paired-end run, one single-end run each):
#   Kola6  = Kola-6 + Kola6        Kolyma1 = Kolyma-1 + Kolyma1
# RECONSTRUCTED from the commands used interactively. Result: 103 -> 101 manifests.
# Kola-4, Kolyma-2 and Kolyma-3 are single aliases (no duplicate), so they were not merged; they carry a dash in ENA
# (hence the recode in R/Plots.R) and their outputs in mapping/ were later renamed without the dash (06c).
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
MANIFEST_DIR="${BASE}/manifests"
for pair in "Kola-6:Kola6" "Kolyma-1:Kolyma1"; do
    old="${pair%%:*}"; new="${pair##*:}"
    cat "${MANIFEST_DIR}/${old}_manifest.txt" >> "${MANIFEST_DIR}/${new}_manifest.txt"
    rm  "${MANIFEST_DIR}/${old}_manifest.txt"
done
ls "${MANIFEST_DIR}" | wc -l      # 101
