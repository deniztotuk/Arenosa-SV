# Load necessary libraries
library(tidyverse)

# Load the first annotation file
annotations1 <- read_tsv('~/Overlaps/VT_candidate.tsv')

# Load the second annotation file
annotations2 <- read_tsv('~/Overlaps/FG_candidate.tsv')

# Extract the annotation columns (gene names) from both files
genes1 <- annotations1 %>% pull(annotation)
genes2 <- annotations2 %>% pull(annotation)

# Find the common genes between the two files
common_genes <- intersect(genes1, genes2)

# Create a data frame of common genes
common_genes_df <- data.frame(common_genes)

# Save the common genes to a new file
write_tsv(common_genes_df, '~/Downloads/VT-FG_overlapping.tsv')

# Print the number of common genes found
print(paste("Number of common genes found:", length(common_genes)))