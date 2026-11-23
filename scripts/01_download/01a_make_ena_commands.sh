#!/bin/bash
# Step 01 — build ena.txt (one wget command per FASTQ file) from report.tsv. Run directly.
# NEW, written for this repository: the original ena.txt was not kept and how it was generated is not recorded.
# fastq_ftp (column 7 of report.tsv) holds one or two ';'-separated paths per run, without the ftp:// prefix.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"
mkdir -p raw
tail -n +2 report.tsv | cut -f7 | tr ';' '\n' | grep -v '^$' | \
    sed "s|^|wget -nc -q -P ${BASE}/raw ftp://|" > ena.txt
wc -l ena.txt
