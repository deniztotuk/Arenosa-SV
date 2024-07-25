# Load necessary libraries
library(dplyr)
library(readr)
library(ggplot2)

# Load the Fst results file
fst_results <- read_tsv('~/Fst/Fst_Results/NT_Fst_Results.weir.fst', col_names = TRUE)

# Calculate the 90th percentile threshold
threshold <- quantile(fst_results$WEIR_AND_COCKERHAM_FST, 0.99, na.rm = TRUE)

# Filter the Fst results to include only regions above the threshold
high_fst <- fst_results %>% filter(WEIR_AND_COCKERHAM_FST >= threshold)

# Save the filtered Fst results to a TSV file
write_tsv(high_fst, '~/Fst/Outliers/Aus_99.tsv')