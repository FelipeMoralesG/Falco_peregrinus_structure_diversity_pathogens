#!/bin/bash
# Step 11 — Kraken reports -> species table, genus table, filtered tables, and the number of sequences Kraken saw.
# RECONSTRUCTED from the shell history and the notes. Run directly in kraken_out/.
# Report columns: percent, reads_clade (taxon + everything below), reads_direct (assigned exactly here), rank, taxid, name.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
cd "${BASE}/kraken_out"

parse_rank () {   # $1 = rank code (S or G), $2 = output table
    echo -e "sample\tpercent\treads_clade\treads_direct\trank\ttaxid\tname" > "$2"
    for report in *.report; do
        sample=$(basename "$report" .report)
        awk -v s="$sample" -v r="$1" 'BEGIN{OFS="\t"} $4 == r {
            name=""
            for(i=6; i<=NF; i++) name=name $i " "
            gsub(/^[ \t]+|[ \t]+$/, "", name)
            print s, $1, $2, $3, $4, $5, name
        }' "$report"
    done >> "$2"
}
parse_rank S all_kraken_species.tsv
parse_rank G all_kraken_genus.tsv

# cutoff: 50 fragments.
# NOTE: as run, the species filter uses column 4 (reads_direct) while the genus filter uses column 3 (reads_clade).
#       The intent was clade reads for both. A genus whose reads all sit on species nodes has reads_direct = 0 and would
#       be lost with the species-style filter (this happened with Homo and Plasmodium before the genus filter was fixed).
awk -F'\t' 'NR==1 || $4 >= 50' all_kraken_species.tsv > all_kraken_species_filtered.tsv
awk -F'\t' 'NR==1 || $3 >= 50' all_kraken_genus.tsv   > all_kraken_genus_filtered.tsv

# number of sequences (read pairs) Kraken processed per individual = unclassified + root
for r in *.report; do
    awk -v s="${r%.report}" '$4=="U" || $4=="R" {t+=$2} END{print s"\t"t}' "$r"
done > kraken_input_totals.tsv
