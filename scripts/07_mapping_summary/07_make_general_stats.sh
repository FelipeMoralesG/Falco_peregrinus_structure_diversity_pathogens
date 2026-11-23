#!/bin/bash
# Step 07 — one table with the PlainMap statistics of all mapped individuals.
# Run directly from the repository root, after mapping/ contains only the individuals you want to keep.
# Columns (22): sample library_type seq_mode pilot_fragments max_reads_per_chunk mapq raw_R1_reads raw_R2_reads
#   raw_fragments trimmed_fragments merged_reads unpaired_reads mapped_reads_all mapped_reads_unique
#   mapped_fragments_all mapped_fragments_unique endog duprate avg_readlen mapped_bp avg_depth pct_covered
# NOTE: "column -t" aligns the columns with SPACES, so general_stats.tsv is whitespace-aligned, not tab-delimited;
#       downstream awk therefore splits on -F'[ \t]+'. (The original command also piped through "less -S",
#       which has no effect when the output is redirected, so it is omitted here.)
# general_stats_plus_sup_info.tsv = this table + columns entered by hand from the supplementary table of the paper
#       (Location, Continent, Country, Region, Russia, Migratory) - see README.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}"
# The sed (added in the repository version) writes Kola-4/Kolyma-2/Kolyma-3 as Kola4/Kolyma2/Kolyma3: those three stats files still
# carry the dashed name in their first column after the renaming in 06c, and the names must match the BAM file names (step 10a).
awk 'FNR==1 && NR!=1 {next} {print}' mapping/*.stats.tsv \
  | sed -E 's/^(Kola|Kolyma)-([0-9]+)([[:space:]])/\1\2\3/' | column -t > general_stats.tsv
wc -l general_stats.tsv
