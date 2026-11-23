library(ggplot2)
library(maps)
library(tidyr)
library(dplyr)
library(readr)

################## READ DATA ##################

# Read covariance matrix
C_all <- as.matrix(read.table("pca_results/falcons_pcangsd.cov")) #93 results
C <- as.matrix(read.table("pca_wo_results/falcons_pcangsd_excluded.cov")) #89 results

# Eigendecomposition
e_all <- eigen(C_all)
e <- eigen(C)

# Get sample names from txt in order
samples_all <- gsub(".*/|.final.RG.bam", "", readLines("bam_files.txt"))
samples <- gsub(".*/|.final.RG.bam", "", readLines("bam_files_excluded.txt"))

# Read metadata
meta <- read.table("general_stats_plus_sup_info.tsv", header=TRUE, sep="\t")

# Create PCA dataframe
pca_all <- data.frame(
  sample = samples_all,
  PC1 = e_all$vectors[,1],
  PC2 = e_all$vectors[,2],
  PC3 = e_all$vectors[,3]
)
pca <- data.frame(
  sample = samples,
  PC1 = e$vectors[,1],
  PC2 = e$vectors[,2],
  PC3 = e$vectors[,3]
)

# Merge with metadata by sample name
pca_all <- merge(pca_all, meta, by="sample")
pca <- merge(pca, meta, by="sample")

#Add column to identify the outgroups
pca_all$is_outgroup <- ifelse(pca_all$sample %in% c("1947-17998", "BGI_Falco_cherrug",
                                                    "Falco_fasciinucha_Taita1",
                                                    "Falco_fasciinucha_Taita2"),
                                                    "Outgroup", "Ingroup")

#Mutate to distinguish betwhen Russia from Europe and Asia:
pca$Country <- ifelse(pca$Country == "Russia" & pca$Continent == "Asia", "RussiaA",
               ifelse(pca$Country == "Russia" & pca$Continent == "Europe", "RussiaE", 
               pca$Country))

# Fix empty/NA values
pca$Country[pca$Country == "" | is.na(pca$Country)] <- "Unknown"
pca$Migratory[is.na(pca$Migratory)] <- "NA"

continent_colors <- c("Africa"="#d4a017","Asia"="#7b2fbe","Europe"="#cc0000",
                      "North America"="#0066cc","Oceania"="#009999","South America"="#2d9e2d")
study_colors <- c("PRJNA686418"="#e69f00","PRJNA979930"="#0072b2")

##################PCA Variance explained##################

var_explained_all <- e_all$values / sum(e_all$values) * 100
cat(sprintf("PC1: %.1f%%\n", var_explained_all[1]))
cat(sprintf("PC2: %.1f%%\n", var_explained_all[2]))
cat(sprintf("PC3: %.1f%%\n", var_explained_all[3]))

var_explained <- e$values / sum(e$values) * 100
cat(sprintf("PC1: %.1f%%\n", var_explained[1]))
cat(sprintf("PC2: %.1f%%\n", var_explained[2]))
cat(sprintf("PC3: %.1f%%\n", var_explained[3]))

##################PLOTS##################

# Plot colored by Continent, marking the outgroup
p_continent_outgroup <- ggplot(pca_all, aes(x=PC1, y=PC2, color=Continent, shape=is_outgroup)) +
  geom_point(size=5, alpha = 0.8) +
  scale_shape_manual(values=c("Ingroup"=16, "Outgroup"=8)) +
  scale_color_manual(values=continent_colors) +
  theme_classic() +
  labs(title="Peregrine Falcon PCA with Outgroups",
       x=sprintf("PC1 (%.1f%%)", var_explained_all[1]),
       y=sprintf("PC2 (%.1f%%)", var_explained_all[2]),
       shape="Group")

ggsave("PCA_continent_outgroups.pdf", p_continent_outgroup, width=10, height=8)

# Continent + Migratory status
p_continent_migr <- ggplot(pca, aes(x=PC1, y=PC2, color=Continent, shape=Migratory)) +
  geom_point(size=5) +
  scale_shape_manual(values=c("Y"=0, "N"=1, "NA"=13)) +
  scale_color_manual(values=continent_colors) +
  theme_classic() +
  labs(title="Peregrine Falcon PCA by Continent and Migratory Status",
       x=sprintf("PC1 (%.1f%%)", var_explained[1]),
       y=sprintf("PC2 (%.1f%%)", var_explained[2]))

ggsave("PCA_continent_migratory.pdf", p_continent_migr, width=10, height=8)

# Define continent-grouped color palettes
country_colors <- c(
  # North America - blues
  "USA" = "#003f8a", "Canada" = "#0066cc", "Mexico" = "#4da6ff", "Greenland" = "#66b3ff",
  # South America - greens
  "Chile" = "#1a6b1a", "Argentina" = "#2d9e2d", "Falkland Island" = "#66cc66",
  # Europe - reds/oranges
  "Spain" = "#8b0000", "Sweden" = "#cc0000", "UK" = "#ff4444", "RussiaE" = "#e06666",
  # Asia - purples
  "Japan" = "#4b0082", "Kazakhstan" = "#7b2fbe", "Mongolia" = "#9b59b6", "RussiaA" = "#5e1a99",
  "India" = "#c39bd3", "Israel" = "#d7bde2", "UAE" = "#8e44ad", "Sri Lanka" = "#b07fd0",
  # Africa - yellows/browns
  "South Africa" = "#8b6914", "Zimbabwe" = "#c9a227", "Cape Verde" = "#f0c040",
  "Madagascar" = "#f5d76e", "Canary Islands" = "#d4a017",
  # Oceania - teals
  "Australia" = "#006666", "Fiji" = "#009999", "Vanuatu" = "#00cccc",
  # Unknown / missing - grey
  "Unknown" = "#999999", "-" = "#cccccc"
)

# Country color coded per Continent + Migratory status
p_country_migr_clr <- ggplot(pca, aes(x=PC1, y=PC2, color=Country, shape=Migratory)) +
  geom_point(size=5, alpha = 0.8) +
  scale_color_manual(values=country_colors) +
  scale_shape_manual(values=c("Y"=0, "N"=1, "NA"=13)) +
  theme_classic() +
  labs(title="Peregrine Falcon PCA by Country",
       x=sprintf("PC1 (%.1f%%)", var_explained[1]),
       y=sprintf("PC2 (%.1f%%)", var_explained[2]))

ggsave("PCA_country_continent_migratory_color.pdf", p_country_migr_clr, width=10, height=8)

# Thinning + Migratory status
russia <- subset(pca, Country == "RussiaA" | Country == "RussiaE")
p_russia <- ggplot(russia, aes(x=PC1, y=PC2, color=Region, label=sample)) +
  geom_point(size=5) +
  theme_classic() +
  labs(title="Peregrine Falcon PCA by Russian Region",
       x=sprintf("PC1 (%.1f%%)", var_explained[1]),
       y=sprintf("PC2 (%.1f%%)", var_explained[2]))

ggsave("PCA_russia.pdf", p_russia, width=10, height=8)


##################MAP PLOT##################

# Coordinates per region (approximate)
coords <- data.frame(
  Region = c(
    "Australia", "Australia_Southwest", "Australia_Victoria",
    "Canada_Alberta", "Canada_NWT", "Canada_Quebec",
    "CanaryIslands_Fuerteventura", "CanaryIslands_Lanzarote",
    "Cape Verde",
    "Chile_StraitsOfMagellen",
    "FalklandIsland_East",
    "Fiji",
    "Greenland_Kangerlussuaq", "Greenland_Thule",
    "India",
    "Israel",
    "Japan",
    "Kazakhstan",
    "Madagascar",
    "Mongolia_Ömnögovi",
    "Russia_Kola", "Russia_Kolguev", "Russia_Kolyma", "Russia_Yamal",
    "South Africa",
    "Spain_Cadiz", "Spain_Huelva",
    "Sri Lanka",
    "Sweden_North", "Sweden_Southwest",
    "UAE_Dubai",
    "UK_Scotland",
    "USA_Alaska", "USA_California", "USA_Oregon",
    "Vanuatu_Erromango", "Vanuatu_Tukutuku",
    "Zimbabwe_Harare"
  ),
  lon = c(
    134, 117, 144,
    -114, -120, -72,
    -14, -13.6,
    -23.5,
    -70,
    -58.5,
    178,
    -50, -68,
    78,
    35,
    138,
    67,
    47,
    104,
    33, 50.5, 161, 68,
    25,
    -6.3, -6.9,
    81,
    18, 12,
    55.3,
    -4,
    -153, -119, -120,
    169.5, 168.5,
    31
  ),
  lat = c(
    -25, -32, -37,
    53, 64, 52,
    28.3, 29,
    16,
    -53,
    -51.7,
    -18,
    67, 76,
    22,
    31.5,
    36,
    48,
    -20,
    43,
    68, 69, 68, 68,
    -30,
    36.5, 37.3,
    8,
    66, 58,
    25.2,
    57,
    64, 37, 44,
    -18.8, -17,
    -18
  )
)

# Count samples per region
region_counts <- as.data.frame(table(pca$Region))
colnames(region_counts) <- c("Region", "n")
coords <- merge(coords, region_counts, by="Region", all.x=TRUE)
coords$n[is.na(coords$n)] <- 0

# Add continent info
continent_map <- unique(pca[, c("Region", "Continent")])
coords <- merge(coords, continent_map, by="Region", all.x=TRUE)

# Plot
world <- map_data("world")

p_map <- ggplot() +
  geom_map(data=world, map=world,
           aes(long, lat, map_id=region),
           fill="lightgrey", color="white", linewidth=0.2) +
  geom_point(data=coords[coords$n > 0,],
             aes(x=lon, y=lat, color=Continent, size=n),
             alpha=0.8) +
  scale_size_continuous(range=c(3, 10), name="Samples") +
  scale_color_manual(values=continent_colors) +
  theme_classic() +
  labs(title="Peregrine Falcon Sampling Locations",
       x="Longitude", y="Latitude") +
  coord_fixed(1.3, xlim=c(-180, 180), ylim=c(-60, 85))

ggsave("map_samples.pdf", p_map, width=14, height=8)

###################BAR PLOTS####################

# Fix metadata for unknown samples
meta$Country[meta$sample == "Fp_brookei_unknown_Falco54"] <- "Spain"
meta$Region[meta$sample == "Fp_brookei_unknown_Falco54"] <- "Spain_unknown"
meta$Continent[meta$sample == "Fp_brookei_unknown_Falco54"] <- "Europe"

meta$Country[meta$sample == "Fp_peregrinator_unknown_FALCO8"] <- "Sri Lanka"
meta$Region[meta$sample == "Fp_peregrinator_unknown_FALCO8"] <- "Sri Lanka"
meta$Continent[meta$sample == "Fp_peregrinator_unknown_FALCO8"] <- "Asia"

meta$Country[meta$sample == "Fp_tundrius_m_Padre_migrant_JJ002"] <- "Canada"
meta$Region[meta$sample == "Fp_tundrius_m_Padre_migrant_JJ002"] <- "Canada_unknown"
meta$Continent[meta$sample == "Fp_tundrius_m_Padre_migrant_JJ002"] <- "North America"

# Create clean labels
meta <- meta %>%
  group_by(Country) %>%
  mutate(country_n = row_number()) %>%
  ungroup() %>%
  mutate(label = paste0(Country, "_", country_n))#FIX: maybe an issue (See 2.3)

BASE <- "pcangsd_results"

# Get sample order from bam file
samples <- gsub(".*/|.final.RG.bam", "", readLines("bam_files_excluded.txt"))

# Read metadata and define geographic order
meta_admix <- meta[meta$sample %in% samples, ]

# Define geographic order for x-axis
# Order samples by Continent then Country then Region
meta_ordered <- meta_admix %>%
  arrange(Continent, Country, Region)

sample_order <- meta_ordered$sample

# Read all Q files and combine
all_k <- lapply(2:8, function(kk) {
  qfile <- paste0(BASE, "/falcons_pcangsd_excluded_K", kk, ".admix.", kk, ".Q")
  q <- read.table(qfile)
  colnames(q) <- paste0("Pop", 1:kk)
  q$sample <- samples
  q$K <- kk
  q
})

# Plot each K
for (kk in 2:8) {
  q <- all_k[[kk-1]]
  
  # Reorder samples geographically
  q$sample <- factor(q$sample, levels=sample_order)
  
  # Add metadata
  q <- merge(q, meta[, c("sample", "Continent", "Country", "Region", "label")], by="sample")
  
  # Pivot to long format
  q_long <- pivot_longer(q, cols=starts_with("Pop"), 
                         names_to="Population", values_to="Proportion")
  
  p <- ggplot(q_long, aes(x=label, y=Proportion, fill=Population)) +#FIX: maybe an issu (2.2)
    geom_bar(stat="identity", width=1) +
    facet_grid(. ~ Continent, scales="free_x", space="free_x") +
    theme_classic() +
    theme(
      axis.text.x = element_text(angle=90, hjust=1, vjust=0.5, size=5),
      strip.text = element_text(size=8, face="bold"),
      strip.background = element_rect(fill="lightgrey"),
      panel.spacing = unit(0.1, "lines")
    ) +
    labs(title=paste0("Admixture K=", kk), x="", y="Ancestry Proportion")
  
  ggsave(paste0("admix_K", kk, ".pdf"), p, width=16, height=4)
}

################Plot heterozygocity
roh <- read.table("hearty/roh_summary.tsv", header=TRUE, sep="\t")
roh <- merge(roh, meta[, c("sample","Continent","Country","Migratory","avg_depth")], by="sample")

# samples that failed to match the metadata (e.g. the old names with dashes)
p_het <- ggplot(roh, aes(x=reorder(sample, mean_heterozygosity_all_windows),
                         y=mean_heterozygosity_all_windows, fill=Continent)) +
  scale_fill_manual(values=continent_colors) +
  geom_col() +
  theme_classic() +
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5, size=6)) +
  labs(x="", y="Mean heterozygosity")
ggsave("het_per_sample.pdf", p_het, width=14, height=5)

p_box <- ggplot(roh, aes(x=Continent, y=mean_heterozygosity_all_windows, fill=Continent)) +
  geom_boxplot(outlier.shape = NA, alpha=0.7) + geom_jitter(width=0.15) +
  scale_fill_manual(values=continent_colors) +
  theme_classic() + labs(y="Mean heterozygosity")
ggsave("het_by_continent.pdf", p_box, width=8, height=5)

# same idea for inbreeding
p_froh <- ggplot(roh, aes(x=Continent, y=bridged_froh_gt1Mb, fill=Continent)) +
  geom_boxplot(outlier.shape = NA, alpha=0.7) + geom_jitter(width=0.15) +
  scale_fill_manual(values=continent_colors) +
  theme_classic() + labs(y="FROH (>1 Mb)")
ggsave("froh_by_continent.pdf", p_froh, width=8, height=5)

cor_res <- cor.test(roh$avg_depth, roh$mean_heterozygosity_all_windows, method="spearman")

p1 <- ggplot(roh, aes(x=avg_depth, y=mean_heterozygosity_all_windows, color=Continent)) +
  geom_point(size=3) +
  scale_color_manual(values=continent_colors) +
  geom_smooth(aes(group=1), method="lm", color="black", linewidth=0.5) +
  annotate("text", x=Inf, y=Inf,
           label=paste0("Spearman rho = ", round(cor_res$estimate, 2),
                        "\np < 2.2e-16"),
           hjust=1.1, vjust=12.1, color="black", size=4) +
  theme_classic() +
  labs(x="Mean depth (x)", y="Mean heterozygosity")
ggsave("het_vs_depth.pdf", p1, width=8, height=6)

##############################Pathogen load##############################

k <- read_tsv("all_kraken_genus_filtered.tsv") %>% rename(genus = name)
k <- filter(k, sample %in% samples)

candidates <- c("Plasmodium","Babesia","Theileria","Leishmania","Trypanosoma","Toxoplasma",
                "Neospora","Besnoitia","Bartonella","Borreliella","Rickettsia","Leptospira","Francisella",
                "Chlamydia","Mycoplasma","Mycoplasmopsis","Trichomonas","Aspergillus","Candida","Candidozyma",
                "Cryptococcus","Salmonella","Escherichia","Klebsiella","Yersinia","Listeria","Campylobacter",
                "Staphylococcus","Streptococcus","Enterococcus","Clostridium","Clostridioides","Mycobacterium",
                "Bordetella","Acinetobacter","Aeromonas","Vibrio","Legionella","Proteus","Fusobacterium",
                "Alpharetrovirus","Mastadenovirus")
phage <- c("Chivirus","Drulisvirus","Gequatrovirus","Jouyvirus","Sharonstreetvirus","Crohivirus","Valbvirus")
artifacts <- c("Dictyostelium","Phaeodactylum","Thalassiosira","Cyanidioschyzon",
               "Bigelowiella","Neurospora","Blattabacterium","Buchnera")

k <- k %>% mutate(category = case_when(
  genus %in% candidates ~ "candidate",
  genus == "Homo"       ~ "human",
  genus %in% phage      ~ "phage",
  genus %in% artifacts  ~ "db artifact",
  TRUE                  ~ "other"))

# total reads per sample from your stats table (check the column name)
k <- left_join(k, meta, by="sample") %>% mutate(rpm = reads_clade / raw_fragments * 1e6)

# prevalence per genus (contaminants appear in many samples, or in a few at enormous levels)
prev <- k %>% group_by(genus, category) %>%
  summarise(n_samples = n_distinct(sample), max_rpm = max(rpm), median_rpm = median(rpm), .groups="drop") %>%
  arrange(category, desc(n_samples))
write_tsv(prev, "genus_prevalence.tsv")

# heatmap of candidates only
cand <- filter(k, category == "candidate")
ggplot(cand, aes(x=sample, y=genus, fill=log10(rpm+1))) +
  geom_tile() + scale_fill_viridis_c(name="log10(RPM+1)") +
  theme_classic(base_size = 14) + theme(axis.text.x = element_text(angle=90, hjust=1, size=5))
ggsave("candidate_heatmap.pdf", width=16, height=6)

sp <- read_tsv("all_kraken_species_filtered.tsv")

sp %>% filter(grepl("^(Bordetella|Klebsiella) ", name), reads_clade >= 50) %>%
  group_by(name) %>% summarise(n_samples=n(), max_reads=max(reads_clade)) %>% arrange(desc(n_samples))

study <- read_tsv("report.tsv") %>% distinct(sample = sample_alias, study = study_accession)
study <- study %>% mutate(sample = recode(sample,
                                          "Kola-4"   = "Kola4", "Kola-6"   = "Kola6",
                                          "Kolyma-3" = "Kolyma3","Kolyma-2" = "Kolyma2", 
                                          "Kolyma-1" = "Kolyma1")) %>% distinct()

# Heterozygosity vs depth within each study (depth is confounded with study)
roh_study <- left_join(roh, study, by="sample")
cor_study <- roh_study %>% filter(!is.na(study)) %>% group_by(study) %>%
  summarise(rho = cor(avg_depth, mean_heterozygosity_all_windows, method="spearman"),
            p   = cor.test(avg_depth, mean_heterozygosity_all_windows,
                           method="spearman", exact=FALSE)$p.value, n = n()) %>%
  mutate(label = paste0("rho = ", round(rho, 2), "\np = ", format.pval(p, digits=2), "\nn = ", n))

p_facets <- ggplot(filter(roh_study, !is.na(study)),
                   aes(x=avg_depth, y=mean_heterozygosity_all_windows, color=Continent)) +
  geom_point(size=3) +
  geom_smooth(aes(group=1), method="lm", color="black", linewidth=0.5) +
  geom_text(data=cor_study, aes(x=Inf, y=Inf, label=label),
            hjust=1.1, vjust=1.2, size=3.5, inherit.aes=FALSE) +
  scale_color_manual(values=continent_colors) +
  facet_wrap(~study, scales="free_x") +
  theme_classic() +
  labs(x="Mean depth (x)", y="Mean heterozygosity")
ggsave("het_vs_depth_facets.pdf", p_facets, width=12, height=5)



cand <- cand %>% left_join(study, by="sample") %>% left_join(meta[, c("sample","Continent")], by=c("sample","Continent"))

ggplot(cand, aes(x=sample, y=genus, fill=log10(rpm+1))) +
  geom_tile() + scale_fill_viridis_c(name="log10(RPM+1)") +
  facet_grid(. ~ study + Continent, scales="free_x", space="free_x") +
  theme_classic() + theme(axis.text.x = element_text(angle=90, hjust=1, size=5))
ggsave("candidate_heatmap_batch.pdf", width=18, height=6)

###########################Pathogen load P2##############################

#Generate general table with information (Reuses k (the genus table), meta, roh and candidates)
tot   <- read_tsv("kraken_input_totals.tsv", col_names=c("sample","kraken_input"))
tot <- filter(tot, sample %in% samples)

load_df <- k %>% filter(genus %in% candidates) %>%
  group_by(sample) %>% summarise(n_genera = n_distinct(genus), cand_reads = sum(reads_clade))

dat <- tot %>% left_join(load_df, by="sample") %>%
  mutate(across(c(n_genera, cand_reads), ~replace_na(.x, 0))) %>%
  left_join(study, by="sample") %>% left_join(meta, by="sample") %>%
  left_join(select(roh, sample, het = mean_heterozygosity_all_windows,
                   froh1 = bridged_froh_gt1Mb, froh5 = bridged_froh_gt5Mb), by="sample") %>%
  left_join(select(meta, sample, Continent, Migratory), by=c("sample","Continent","Migratory")) %>%
  mutate(load_rpm = cand_reads / raw_fragments * 1e6)

#Are hits proportional to the reads?
ggplot(dat, aes(kraken_input, cand_reads + 1, color=study)) +
  geom_point(size=3) + geom_smooth(method="lm", se=FALSE) +
  scale_x_log10() + scale_y_log10() + theme_classic()
ggsave("Input_classified_proportion.pdf", width=8, height=8)

ggplot(dat, aes(kraken_input, n_genera, color=study)) + geom_point(size=3) +
  scale_x_log10() + theme_classic()
ggsave("Hits_reads_proportion.pdf", width=8, height=8)

#the same continent, different study
d5 <- dat %>% filter(Continent %in% c("Europe","Asia"), !is.na(study))
#d5 %>% group_by(Continent) %>% summarise(p = wilcox.test(load_rpm ~ study)$p.value, n = n())
stats_labels <- d5 %>% group_by(Continent) %>% summarise(
    p = wilcox.test(load_rpm ~ study)$p.value, n = n()) %>% 
    mutate(label = ifelse(p < 0.001, "p < 0.001", sprintf("p = %.3f", p))) #ERASEsprintf("p = %.2f\nn = %d", p, n))
ggplot(d5, aes(study, load_rpm + 1)) +
  geom_boxplot(outlier.shape=NA) + geom_jitter(width=0.15) + scale_y_log10() +
  facet_wrap(~Continent) + theme_classic() + 
  geom_text(
    data = stats_labels, aes(x = Inf, y = Inf, label = label),
    hjust = 1.1, vjust = 57, size = 4, inherit.aes = FALSE
  )
ggsave("Load_comparison_similar_continents.pdf", width=8, height=8)

#Plots for correlations
long <- dat %>% pivot_longer(c(het, froh1, froh5), names_to="metric", values_to="value") %>%
  filter(!is.na(value), !is.na(study))
ggplot(long, aes(load_rpm + 1, value, color=study)) + geom_point(size=2) +
  geom_smooth(method="lm", se=FALSE) + scale_x_log10() +
  facet_wrap(~metric, scales="free_y") + theme_classic()
ggsave("Pathogen_load_correlations.pdf", width=15, height=5)

long %>% group_by(study, metric) %>%
  summarise(n = n(), rho = cor(load_rpm, value, method="spearman"),
            p = cor.test(load_rpm, value, method="spearman", exact=FALSE)$p.value, .groups="drop")

summary(lm(het ~ log10(load_rpm + 1) + study + log10(avg_depth), data = dat))   # adjusted

#Plots for correlations fixed?? Because its the amounf og genera right? not the load_rpm
long_genus <- dat %>% pivot_longer(c(het, froh1, froh5), names_to="metric", values_to="value") %>%
  filter(!is.na(value), !is.na(study), !is.na(n_genera))
ggplot(long_genus, aes(n_genera, value, color=study)) + geom_point(size=2) +
  geom_smooth(method="lm", se=FALSE) + facet_wrap(~metric, scales="free_y") + 
  theme_classic() +labs(x = "Number of relevant pathogen genera", y = "Genomic Metric")
ggsave("Pathogen_metrics_correlations.pdf", width=18, height=6)

long_genus %>% group_by(study, metric) %>%
  summarise(n = n(), rho = cor(n_genera, value, method="spearman", use="complete.obs"),
    p = cor.test(n_genera, value, method="spearman", exact=FALSE)$p.value, .groups="drop")

summary(lm(het ~ n_genera + study + log10(avg_depth), data = dat))

#Plot for pathogen load on migratory vs non migratory
table(dat$Migratory, dat$study, useNA="ifany")   # check group sizes first
ggplot(dat, aes(Migratory, load_rpm + 1)) + geom_boxplot(outlier.shape=NA) +
  geom_jitter(width=0.15, aes(color=study)) + scale_y_log10() +
  facet_wrap(~Continent) + theme_classic()
ggsave("Migratory_load.pdf", width=8, height=8)

################Check: does number of genera depend on reads?############

set.seed(1)
# f = 10 / avg_depth for samples above 10x, 1 for the rest
k_ds <- k %>% left_join(select(dat, sample, avg_depth), by=c("sample","avg_depth")) %>%
  mutate(f = pmin(1, 10 / avg_depth),
         reads_ds = rbinom(n(), reads_clade, f)) %>%
  filter(reads_ds >= 50)           # apply the 50-read cutoff after thinning

n_orig <- k  %>% count(sample, name="orig")
n_ds   <- k_ds %>% count(sample, name="thinned")

cmp <- dat %>% select(sample, study, avg_depth) %>%
  left_join(n_orig, by="sample") %>% left_join(n_ds, by="sample") %>%
  mutate(across(c(orig, thinned), ~replace_na(.x, 0))) %>%
  pivot_longer(c(orig, thinned), names_to="version", values_to="n_genera")

ggplot(cmp, aes(avg_depth, n_genera, color=version)) +
  geom_point(size=2) + facet_wrap(~study, scales="free_x") + theme_classic()
ggsave("genera_amount_vs_avg_depth.pdf", width=10, height=10)

n_orig %>% arrange(orig) %>% head(12) %>% left_join(dat, by="sample")

###################Pathogen load P3##############################
set.seed(1)
target <- quantile(dat$kraken_input, 0.10)   # common effort; samples below it stay unthinned
reps <- 20
rare <- bind_rows(lapply(1:reps, function(i)
  k %>% left_join(select(dat, sample, kraken_input), by="sample") %>%
    mutate(f = pmin(1, target / kraken_input),
           reads_ds = rbinom(n(), reads_clade, f)) %>%
    filter(reads_ds >= 50, genus %in% candidates) %>%
    count(sample, name="n_cand")
)) %>% group_by(sample) %>% summarise(n_cand_rare = sum(n_cand) / reps)   # absent in a rep counts as 0

dat <- left_join(dat, rare, by="sample") %>% mutate(n_cand_rare = replace_na(n_cand_rare, 0))

##################test for depth affecting hearty#############
###########Move this to just after "dat" if the results are as expected#########
#######################see 2.8##############################################

a <- read.table("hearty/roh_summary.tsv", header=TRUE, sep="\t") %>%
  select(sample, het_orig = mean_heterozygosity_all_windows)
b <- read.table("hearty_ds10/roh_summary.tsv", header=TRUE, sep="\t") %>%
  mutate(sample = sub("_ds10$", "", sample)) %>%
  select(sample, het_ds = mean_heterozygosity_all_windows)
cmp <- inner_join(a, b, by="sample") %>% left_join(select(dat, sample, avg_depth, study), by="sample")

ggplot(cmp, aes(het_orig, het_ds, color=study)) + geom_point(size=3) +
  geom_abline(slope=1, intercept=0, linetype=2) + theme_classic()