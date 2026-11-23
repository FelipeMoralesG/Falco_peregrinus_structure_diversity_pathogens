#!/bin/bash
# Step 10 — copy the small HEARTY outputs to a laptop (the .basecall/.counts/.pos files are huge and stay on the cluster).
# RECONSTRUCTED from the notes. Run on the laptop, in an empty working folder, with config.sh containing SRV and BASE.
source ./config.sh
scp "${SRV}:${BASE}/hearty/*.minorfreq.txt" .
scp "${SRV}:${BASE}/hearty/*_het0.25.mincov*.windows.txt.gz" .
scp "${SRV}:${BASE}/hearty/*_het0.25.mincov*.windows_trv.txt.gz" .
scp "${SRV}:${BASE}/HEARTY/Plot_MinorFreq.R" "${SRV}:${BASE}/HEARTY/ROH_Window_Summary.R" .
