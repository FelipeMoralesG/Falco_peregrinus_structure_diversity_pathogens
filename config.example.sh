#!/usr/bin/env bash
# Copy to config.sh (git-ignored) and edit. Every script sources it from the directory
# it is submitted from, so always run from the repository root:
#   cd falcon-pathogen-load && mkdir -p logs && sbatch scripts/<step>/<script>.sh
export BASE="/path/to/project"                    # data directory: raw/, manifests/, mapping/, angsd/, kraken_out/ ...
export REF_FNA="${BASE}/R/GCA_001887755.1_falPer2_genomic.fna"   # own copy of the reference (uncompressed)
export AUTOSOMES="${BASE}/R/autosomes.txt"        # regions file: chromosomes 1-18, no Z, no scaffolds
export PLAINMAP="${HOME}/PlainMap/plainmap.sh"
export HEARTY_PY="${BASE}/HEARTY/HEARTY.py"
export ANGSD_BIN="/path/to/angsd-0.935/angsd"
export KRAKEN_DB="${BASE}/kraken_db"
export CONDA_SH="/path/to/miniconda3/etc/profile.d/conda.sh"
export PCANGSD_ENV="pcangsd"
export SRV="user@login.example.org"               # only used to scp HEARTY outputs to a laptop
