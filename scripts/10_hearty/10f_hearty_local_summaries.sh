#!/bin/bash
# Step 10 — minor-allele-frequency plots and ROH / heterozygosity summary (HEARTY's own R scripts), run on the laptop.
# RECONSTRUCTED from the notes. Needs R with tidyverse/ggplot2.
# Usage : ./10f_hearty_local_summaries.sh windows        (all sites)
#         ./10f_hearty_local_summaries.sh windows_trv    (transversions only: robustness check)
# Plots.R reads hearty/roh_summary.tsv (the default windows run).
# transversions only give lower values, so the ROH threshold (0.0001) would have to be adapted.
SUFFIX="${1:-windows}"
TAG=""; [ "$SUFFIX" != "windows" ] && TAG="_${SUFFIX}"
mkdir -p plots

for f in "$PWD"/*.minorfreq.txt; do
    printf "%s\tplots/%s\n" "$f" "$(basename "$f" .minorfreq.txt)"
done > minorfreq_batch.txt
Rscript Plot_MinorFreq.R --sample-list minorfreq_batch.txt --format pdf --y-cap-after-x 0.25

printf "sample\tfile\n" > roh_samples_${SUFFIX}.tsv
for f in "$PWD"/*_het0.25.mincov*.${SUFFIX}.txt.gz; do
    printf "%s\t%s\n" "$(basename "$f" | sed 's/_het0.25.*//')" "$f"
done >> roh_samples${TAG}.tsv

Rscript ROH_Window_Summary.R --mode batch \
  --sample-list roh_samples${TAG}.tsv \
  --summary-out roh_summary${TAG}.tsv \
  --combined-pdf roh_combined${TAG}.pdf \
  --min-length-mb 4 --max-scaffolds 18 \
  --fill-cap 0.0005 --bin-size-bp 500000 \
  --roh-threshold 0.0001 --roh-threshold-mode absolute \
  --froh-cutoffs "100kb,1mb,5mb"
