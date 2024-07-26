# Load necessary libraries
library(tidyverse)

# Load GTF file
gtf <- read_tsv('~/Downloads/Arabidopsis_arenosa_genome.annotation.simple.gtf', col_names = FALSE)
colnames(gtf) <- c("scaffold", "start", "end", "dot", "strand", "score", "annotation")

# Load your candidate regions (Fst results)
fst_results <- read_tsv('~/Outliers/NT_99.tsv')

# Select genes only and make a gene mid-point variable
new_gtf <- gtf %>% 
  arrange(start, end) %>%
  mutate(mid = start + (end - start) / 2)

# Find the nearest genes to all high Fst regions within 50 Kb
all_gene_hits <- fst_results %>%
  rowwise() %>%
  mutate(genes = list(new_gtf %>% 
                        filter(scaffold == CHROM & abs(mid - POS) < 5000) %>%
                        mutate(hit_dist = abs(mid - POS)))) %>%
  unnest(cols = c(genes))

# Select relevant columns
all_gene_hits <- all_gene_hits %>% select(CHROM, POS, scaffold, start, end, annotation, hit_dist)

# Print the result
print(head(all_gene_hits))

# Save candidate genes to a file
write_tsv(all_gene_hits, '~/Candidate/NT_candidate_99.tsv')