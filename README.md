# Pathogen load and genetic diversity in peregrine falcons (*Falco peregrinus*)

Coursework project. Public whole-genome resequencing data from peregrine falcon subspecies
(re-analysis of the data of *Whole-genome survey reveals extensive variation in genetic diversity and inbreeding
levels among peregrine falcon subspecies*, doi:[10.1002/ece3.10347](https://doi.org/10.1002/ece3.10347)) are used to ask:

1. How are the individuals structured genetically (PCA, admixture)?
2. How much heterozygosity and how many runs of homozygosity (ROH) does each individual have?
3. How much non-host DNA with a possible pathogen origin is in the reads that do not map to the falcon genome, and does it relate to (2)?

This repository contains the **code and the reasoning**, not the data: FASTQ, BAM, beagle files and the Kraken database
are far too large and are listed in `.gitignore`.

## Pipeline

```
ENA ─► FASTQ ─► integrity check ─► PlainMap (fastp ─► BWA-MEM ─► duplicates)  ─► BAM + unmapped reads
                                                                         │                  │
                 89 individuals ─► ANGSD ─► PCAngsd (PCA, admixture K=2-8)                  └► Kraken2 (PlusPF) ─► genus table ─┐
                 79 individuals (≥9.6x) ─► HEARTY (heterozygosity, ROH) ──────────────────────────────────────────────────────┴► R/Plots.R
```

| Step | Folder | What it does | Main tool | Main output |
|---|---|---|---|---|
| 00 | `scripts/00_setup` | PATH and conda environment | conda, PCAngsd | `versions.txt` |
| 01 | `01_download` | build the download list from `report.tsv`; download FASTQ from ENA | GNU parallel | `raw/*.fastq.gz` |
| 02 | `02_integrity` | gzip test of all files; re-download and re-test the ones flagged | gzip | `integrity_results.log` |
| 03 | `03_reference` | own copy of the reference, BWA/samtools index, list of autosomes | bwa, samtools | `R/*.fna`, `autosomes.txt` |
| 04 | `04_manifests` | one manifest per individual; merge duplicated aliases | bash | `manifests/` (101) |
| 05 | `05_mapping` | one PlainMap command per individual; Slurm array | PlainMap | `mapping/*.final.RG.bam`, `*.unmapped.*.fastq.gz`, `*.stats.tsv` |
| 06 | `06_sample_fixes` | re-map Kola6 and Kolyma1 (merged manifests); fix Yamal4; rename 3 dashed samples | PlainMap | – |
| 07 | `07_mapping_summary` | one table of mapping statistics | awk | `general_stats.tsv` |
| 08 | `08_sample_selection` | BAM lists (93 and 89 individuals) | bash | `bam_files*.txt` |
| 09 | `09_popgen` | genotype likelihoods, PCA, admixture | ANGSD, PCAngsd | `.beagle.gz`, `.cov`, `.Q` |
| 10 | `10_hearty` | heterozygosity and ROH per individual; downsampled version | HEARTY | `*.windows.txt.gz`, `roh_summary.tsv` |
| 11 | `11_kraken` | classify unmapped reads; genus/species tables | Kraken2 + PlusPF | `all_kraken_genus_filtered.tsv` |
| 12 | `R/Plots.R` | all figures and statistics | R | PDFs |

Scripts marked **RECONSTRUCTED** in their header were run interactively; they were rewritten from the project notes
and command history. All other scripts are the server versions with paths replaced by `config.sh` variables.

## Sample flow

| Stage | n | Note |
|---|---|---|
| Manifests (one per ENA `sample_alias`) | 103 | array size of the first mapping run |
| After merging `Kola-6`→`Kola6`, `Kolyma-1`→`Kolyma1` | 101 | each pair = one individual with one paired-end and one single-end run |
| Minus 7 museum toe-pad samples | 94 | only blood is expected to contain the pathogens of interest |
| Minus `Fp_macropus_Australia_PEFAVIC206` | 93 | very low depth/coverage; `bam_files.txt` (includes 4 outgroup individuals) |
| Minus the outgroups | 89 | `bam_files_excluded.txt`: PCA, admixture, Kraken analyses |
| Mean depth ≥ 9.6x | 79 | heterozygosity/ROH (HEARTY) only |

By study, in `report.tsv` (one row per ENA alias): `PRJNA686418` 37 aliases = 35 individuals after the two merges; `PRJNA979930` 64 (57 after the toe-pads, 56 after `PEFAVIC206`); the two outgroup studies 1 each. 37 + 64 + 1 + 1 = 103 manifests.

Outgroups: Saker falcon (`BGI_Falco_cherrug`), Prairie falcon (`1947-17998`), Taita falcon (`Falco_fasciinucha_Taita1/2`).
The 89 are 35 Russian individuals (`PRJNA686418`) plus 54 from `PRJNA979930` (its 56 minus the 2 Taita outgroups).
Individuals between about 3x and 10x stay in the PCA/admixture (ANGSD works on genotype likelihoods) but are too shallow for heterozygosity.

## Data

* ENA projects `PRJNA686418` (Russian populations: Kola, Kolguev, Kolyma, Yamal), `PRJNA979930` (remaining subspecies),
  and the outgroup runs `SRR516282` (study `PRJNA168071`) and `SRR6807233` (study `PRJNA436967`).
* `report.tsv`: ENA read-run report (TSV) with the columns `run_accession, study_accession, sample_accession,
  experiment_accession, tax_id, scientific_name, fastq_ftp, submitted_ftp, sample_alias, bam_ftp`.
* `general_stats_plus_sup_info.tsv` : `general_stats.tsv` plus columns typed in by hand from the supplementary table of the paper
  (`Location, Continent, Country, Region, Russia` (sub-region of Russian samples), `Migratory` Y/N/NA).
* Reference: *F. peregrinus* assembly `GCA_001887755.1` (falPer2), autosomes = chromosomes 1-18 (accessions CM007505.1-CM007522.1).
  The Z chromosome (dropped by the `[^Z]` pattern in step 03) and the unplaced scaffolds are excluded.
* Tissue: museum toe-pads identified from the paper's methods; blood for the Russian samples (Gu et al. 2021; BioSample) and the
  prairie falcon (BioSample); not stated for the saker and the Taita falcons (outgroups, not used in the Kraken analyses).

## Environment

| Tool | Version |
|---|---|
| PlainMap | commit `d02d6ef` (2026-06-22) |
| fastp / BWA / samtools | 1.0.1 / 0.7.17-r1188 / 1.13 |
| ANGSD | 0.935 (htslib 1.13) |
| PCAngsd | 1.36.4 (conda, Python 3.11) |
| HEARTY | commit `f0f6998` (2026-10-28) |
| Kraken2 / database | 2.1.2 / PlusPF build 2026-06-26 |
| R | 4.5.1 |

Everything heavy ran through Slurm on DTU's cluster (nodes with ≥120 GB RAM for Kraken2).

## How to run

```bash
git clone <this repo> && cd falcon-pathogen-load
cp config.example.sh config.sh && nano config.sh      # paths of your system
mkdir -p logs
# always submit from the repository root; scripts source ./config.sh
sbatch scripts/02_integrity/02a_integrity_check.sh    # ... and so on, in the order of the table above
```
Steps 04, 05a, 07, 08, 10a, 10c and 11d are quick and run directly (not through `sbatch`).

## Key parameters (reasons in [docs/decisions.md](docs/decisions.md))

| Analysis | Parameters |
|---|---|
| PlainMap | default `modern` mode, MAPQ 20, `--emit-unmapped-fastq`, 10 threads |
| ANGSD (PCA, admixture) | `-minq 25 -minmapq 25 -uniqueOnly 1 -minmaf 0.05 -SNP_pval 1e-6 -GL 1 -doGlf 2`, autosomes only |
| PCAngsd | `--iter 500`; admixture K = 2-8 |
| HEARTY | `-t 0.25`, `-m` = round(mean depth / 2), autosomes; ROH threshold 0.0001 (absolute), windows 100 kb, FROH > 100 kb / 1 Mb / 5 Mb |
| Kraken2 | PlusPF, paired unmapped reads, default confidence; cutoff 50 fragments; load = reads per million sequenced fragments |

## Limitations and open items

* **Depth, study and sequencing lab are confounded.** Most of the Russian individuals (`PRJNA686418`) were sequenced at about 28-60x,
  most others at about 10x, the two Japanese ones on a MiSeq in a different lab. Heterozygosity rises with depth in the pooled data
  and the number of Kraken genera above a fixed read cutoff does too and the number of Kraken genera above a fixed read cutoff does too (thinning check in `Plots.R`). The genus counts in the figures are raw, so they partly reflect depth (a rarefied count is computed as a check only); the downsampled HEARTY run
  that addresses heterozygosity is not finished.
* **Kraken screened only the paired unmapped reads**, not `*.unmapped.SE` (merged or single reads).
* **Kraken hits are not infections.** Several samples carry huge single-genus signals typical of contamination (e.g. *Pseudomonas*
  in an outgroup, 74 % of the unclassified reads). PlusPF has no avian haemosporidian genomes: *Plasmodium* reads in one individual were
  assigned to *P. vivax* and probably belong to a related avian parasite. No minimizer or mapping validation was done.
  The list of "candidate" genera is hand-made.
* **Three individuals of unknown origin** (`Fp_brookei_unknown_Falco54`, `Fp_peregrinator_unknown_FALCO8`,
  `Fp_tundrius_m_Padre_migrant_JJ002`) were placed in Spain, Sri Lanka and Canada from their position in the PCA. That is circular if used to interpret
  the same PCA; the third assignment inside North America is a placeholder.
* **Renamed samples**: `Kola4`, `Kolyma2`, `Kolyma3` were renamed after mapping (file and folder names only). The read-group tags inside their BAM headers still carry the dashed name (checked on Kola4); this does not affect ANGSD, which uses file names.
* **Yamal4**: the header fix touched every line of the FASTQ (see `06b_fix_yamal4.sh`); not re-verified.
* **Filter inconsistency**: species table cut on direct reads, genus table on clade reads (see `11d_parse_reports.sh`).
* **Different quality filters**: ANGSD for PCA used base/mapping quality 25; HEARTY's internal ANGSD used 20.
* Heterozygosity of the shallowest individuals is unreliable; migratory status is tied to subspecies and region.

## Server file → repository file

| Server | Repository |
|---|---|
| `scripts/01/01_downloads.sh` | `01_download/01_downloads.sh` (+ `01a_make_ena_commands.sh`, new) |
| `scripts/02/02_integrity_check.sh`, `redownload_corrupted.sh`, `recheck_integrity.sh` | `02_integrity/02a…`, `02b…` |
| `m.sh`, `create_plainmap_commands.sh`, `ena.txt` (no longer on the server), `scripts/03/plainmap_commands.txt` | `04_manifests/04a…04b`, `05_mapping/05a…` (reconstructed) |
| `scripts/03/03_plainmap.sh` | `05_mapping/05b_plainmap_array.sh` |
| `missing_map.sh`, `fix_yamal4.sh` | `06_sample_fixes/06a…06b…` |
| `scripts/06/06.sh` | `09_popgen/09a_angsd.sh` |
| `scripts/07_pcangsd/07_pcangsd.sh` | `09_popgen/09c_pcangsd_admix.sh` |
| `08_hearty.sh`, `08_hearty_ds10.sh` | `10_hearty/10b…`, `10d…` |
| `scripts/04/04_download_kraken_db.sh`, `scripts/05/05_kraken_files.sh`, `kraken_yamal4.sh` | `11_kraken/11a…11c…` |

## Links

[PlainMap](https://github.com/BiodiversityExtinction/PlainMap) · [HEARTY](https://github.com/BiodiversityExtinction/HEARTY) ·
[PCAngsd](https://www.popgen.dk/software/index.php/PCAngsd) · 
Johnson JA, Athrey G, Anderson CM, et al. (2023) Whole-genome survey reveals extensive variation in genetic diversity and inbreeding levels among peregrine falcon subspecies. Ecology and Evolution 13(7): e10347.
· Gu Z, Pan S, Lin Z, et al. (2021) Climate-driven flyway changes and memory-based long-distance migration. Nature 591: 259–264. doi:10.1038/s41586-021-03265-0
· Zhan X, Pan S, Wang J, et al. (2013) Peregrine and saker falcon genome sequences provide insights into evolution of a predatory lifestyle. Nature Genetics 45: 563–566. doi:10.1038/ng.2588
· Doyle JM, Bell DA, Bloom PH, et al. (2018) New insights into the phylogenetics and population structure of the prairie falcon (Falco mexicanus). BMC Genomics 19: 233. doi:10.1186/s12864-018-4615-z. 
· ANGSD: Korneliussen TS, Albrechtsen A, Nielsen R (2014) BMC Bioinformatics 15: 356. doi:10.1186/s12859-014-0356-4
· PCAngsd: Meisner J, Albrechtsen A (2018) Genetics 210: 719–731. doi:10.1534/genetics.118.301336
· Kraken2: Wood DE, Lu J, Langmead B (2019) Genome Biology 20: 257. doi:10.1186/s13059-019-1891-0
· fastp: Chen S, Zhou Y, Chen Y, Gu J (2018) Bioinformatics 34: i884–i890. doi:10.1093/bioinformatics/bty560
· BWA: Li H, Durbin R (2009) Bioinformatics 25: 1754–1760. BWA-MEM: Li H (2013) arXiv:1303.3997
· samtools: Danecek P et al. (2021) GigaScience 10: giab008