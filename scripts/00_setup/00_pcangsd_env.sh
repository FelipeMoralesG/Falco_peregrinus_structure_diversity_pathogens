#!/usr/bin/env bash
# Step 00 — conda environment for PCAngsd.
# RECONSTRUCTED from the shell history (the commands were typed interactively).
# The shared conda installation was not writable, so environments and packages go to $HOME.
# Python 3.9 failed (current PCAngsd needs >= 3.10), hence 3.11.
source "${SLURM_SUBMIT_DIR:-$PWD}/config.sh"
source "${CONDA_SH}"
conda config --add envs_dirs "$HOME/.conda/envs"
conda config --add pkgs_dirs "$HOME/.conda/pkgs"
conda create -n "${PCANGSD_ENV}" python=3.11 -y
conda activate "${PCANGSD_ENV}"
conda install -c bioconda pcangsd -y
pcangsd --version          # v1.36.4 was used
