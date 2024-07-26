# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)

# Load candidate genes
candidate_genes <- read_tsv('~/Candidates/NT_candidate.tsv')

# Load NCBI annotation file
arenosa_lyrata <- read_tsv('~/Downloads/A_arenosa__v__A_lyrata_NCBI.tsv')

# Separate A_arenosa genes into multiple rows if there are multiple genes in one cell
arenosa_lyrata <- arenosa_lyrata %>%
  separate_rows(A_arenosa, sep = ", ")

# Filter candidate genes to keep only those that have a match in the orthologue file
matching_genes <- candidate_genes %>%
  inner_join(arenosa_lyrata, by = c("annotation" = "A_arenosa")) %>%
  select(annotation, A_lyrata_NCBI)

# Save the matching genes to a new TSV file
write_tsv(matching_genes, '~/NCBI_Annotation/RO_NCBI.tsv')