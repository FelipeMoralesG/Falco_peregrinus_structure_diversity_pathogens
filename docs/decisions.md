# Decisions and their reasons

## Data and samples

| # | Decision | Reason |
|---|---|---|
| 1 | Reference = falPer2 (`GCA_001887755.1`), own copy in a writable folder | Same species and the chromosome-level assembly, so reads map well and the autosomes can be selected by name |
| 2 | One PlainMap run (one manifest) per **individual**, not per file or per project | read groups, statistics and BAMs are per individual; paired and single-end runs of one individual go in the same manifest |
| 3 | Merge `Kola-6`+`Kola6` and `Kolyma-1`+`Kolyma1`; re-map them (`Kola-4`, `Kolyma-2`, `Kolyma-3` only had their outputs renamed without the dash, step 06c) | each is one individual registered under two aliases (one PE run, one SE run) |
| 4 | Exclude 7 museum toe-pad samples | Museum toe-pads are dried skin: no blood, so no blood-borne pathogens; microbial DNA there is post-mortem/environmental; the DNA is degraded and would need ancient-DNA mapping, not modern mode |
| 5 | Exclude `Fp_macropus_Australia_PEFAVIC206` | mean depth 1.43x and coverage 69.2 % (from its `*.stats.tsv`; the paper used a 3x cutoff) |
| 6 | Remove the 4 outgroup individuals for PCA, admixture and Kraken analyses | They are other species, so they tell us nothing about peregrine population structure. With MAF ≥ 0.05 across 93 birds, their private variants are filtered out, which is why they sit near the centre of the outgroup PCA instead of forming their own clusters |
| 7 | Keep individuals with 2.7-4.9x in the PCA/admixture | ANGSD works on genotype likelihoods, so low depth adds uncertainty instead of false genotypes; the paper used 3x; one bird at 2.7x was kept |
| 8 | Heterozygosity/ROH only for mean depth ≥ 9.6x (79 individuals) | Calling heterozygous sites needs enough reads per site; below ~10x heterozygotes are missed and heterozygosity is underestimated; 9.6x rounds to 10x |
| 9 | Yamal4: strip `/2` from the read names of its single-end file | PlainMap read it as an R2 file without an R1 |

## Population structure

| # | Decision | Reason |
|---|---|---|
| 10 | Autosomes only: chromosomes 1-18 (no Z, no unplaced scaffolds) | The Z is hemizygous in females (ZW), so it would add false homozygosity and sex-linked differences; unplaced scaffolds are short and error-prone |
| 11 | ANGSD: `-minq 25 -minmapq 25 -uniqueOnly 1 -minmaf 0.05 -SNP_pval 1e-6 -GL 1` |Standard ANGSD quality filters; keep polymorphic sites only (MAF ≥ 0.05, SNP p < 1e-6); -uniqueOnly drops multi-mapping reads |
| 12 | 80 GB for ANGSD | 30 GB was killed by the scheduler during the merge step (chromosome 6) |
| 13 | PCAngsd `--iter 500` | With 100 iterations it did not converge; with 500 it converged after 241 |
| 14 | Admixture inside PCAngsd (`--admix`), K = 2-8 | PCAngsd has no cross-validation; K chosen as the highest K that still adds a geographically meaningful cluster |

## Heterozygosity and ROH (HEARTY)

| # | Decision | Reason |
|---|---|---|
| 15 | `-t 0.25` | The MAF plots show the heterozygous peak above 0.25 and errors below it; same value for everyone for comparability |
| 16 | `-m` = round(mean depth / 2) per individual | Excludes low-coverage sites where heterozygotes can't be seen, while scaling with each individual's depth |
| 17 | ROH threshold 0.0001 (absolute), windows 100 kb, FROH cutoffs 100 kb / 1 Mb / 5 Mb | HEARTY's recommended defaults for modern, high-quality data; the 100 kb / 1 Mb / 5 Mb cutoffs separate old (short ROH) from recent (long ROH) inbreeding |
| 17b | Use the `windows` (all sites) summary for the figures; the transversion-only `windows_trv` files were generated but not used | transversions only give lower values, so the ROH threshold would need to be re-chosen |
| 18 | `--downsample-depth 10` (and `-m 10`) as a second, depth-controlled run | Heterozygosity of shallow samples is underestimated, and the studies differ in depth |
| 19 | HEARTY's internal ANGSD filters were left at its defaults: base/mapping quality 20, unique reads only, bad reads removed | Read from the `.arg` file of one individual; differs from the PCA run (25) |

## Pathogen load

| # | Decision | Reason |
|---|---|---|
| 20 | Kraken2 with the PlusPF database | Standard prebuilt database covering bacteria, viruses, protozoa and fungi, the groups pathogens come from |
| 21 | Classify only the unmapped read pairs (R1/R2) | Reads that do not belong to the host; the SE file was not screened for lack of time |
| 22 | 50-fragment cutoff; genus level | Low counts are mostly false-positive k-mer hits; 50 fragments removes most noise. Genus level, because species within a genus share k-mers and split the reads |
| 23 | Load = candidate-genus reads per million **sequenced** fragments (`raw_fragments`) | The unmapped fraction depends on host mapping, so it is a poor denominator |
| 24 | Candidate genera chosen by hand (avian/vector-borne, opportunistic, raptor-relevant); environmental, phage and database artefacts removed | Keep only genera with a plausible link to bird or raptor disease; remove environmental genera, phages and known database artefacts |
| 25 | Number of genera kept as **raw** counts; a rarefied count (10th percentile of Kraken input, 20 replicates, `n_cand_rare`) was computed only as a check | genera above a fixed read cutoff rise with depth (the thinning check in `Plots.R` shows ~3x more genera in the 30-60x samples), so genus counts are read as effort-dependent; study comparisons use `load_rpm` (decision 23) |
| 26 | Compare studies within the same continent and correlate within each study | Depth, lab and geography are mixed |

## Metadata

| # | Decision | Reason |
|---|---|---|
| 27 | Location, continent, country, region and migratory status typed in from the paper's supplementary table | ENA has no location fields for the Russian samples and no continent/migratory status for any sample, so all were taken from Table S1 for one consistent source |
| 28 | Three individuals of unknown origin placed in Spain / Sri Lanka / Canada | Nearest cluster in the PCA (for Canada, any of USA/Canada/Greenland fitted) |
| 29 | Russia split into two groups (European and Asian) in the country plots | Russia spans two continents |
