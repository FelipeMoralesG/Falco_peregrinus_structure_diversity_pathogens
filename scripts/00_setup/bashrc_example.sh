# Step 00 — tool setup (lines added to ~/.bashrc on the cluster).
# RECONSTRUCTED: the cluster provided shared installations; only the tools used by this project are listed.
CTOOLS="/path/to/shared/ctools"            # TODO: adapt
export PATH="${CTOOLS}/bwa-0.7.17:$PATH"
export PATH="${CTOOLS}/samtools-1.13:$PATH"
export PATH="${CTOOLS}/angsd-0.935:$PATH"
export PATH="${CTOOLS}/kraken2:$PATH"
export PATH="/path/to/project-software:$PATH"   # contains the fastp binary
export PATH="$HOME/PlainMap:$PATH"              # git clone https://github.com/BiodiversityExtinction/PlainMap
# GNU parallel is the system one. HEARTY: git clone https://github.com/BiodiversityExtinction/HEARTY into ${BASE}/HEARTY
