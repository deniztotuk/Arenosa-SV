# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)

# Load candidate genes
candidate_genes <- read_tsv('~/Candidates/FG_candidate.tsv')

# Load NCBI annotation file
arenosa_thaliana <- read_tsv('~/TAIR_Annotation/A_arenosa__v__A_thaliana.tsv')

# Separate A_arenosa genes into multiple rows if there are multiple genes in one cell
arenosa_thaliana <- arenosa_thaliana %>%
  separate_rows(A_arenosa, sep = ", ")

# Filter candidate genes to keep only those that have a match in the orthologue file
matching_genes <- candidate_genes %>%
  inner_join(arenosa_thaliana, by = c("annotation" = "A_arenosa")) %>%
  select(annotation, A_thaliana)

# Save the matching genes to a new TSV file
write_tsv(matching_genes, '~/TAIR_Annotation/FG_TAIR.tsv')