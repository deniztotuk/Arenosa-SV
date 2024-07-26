# Load necessary libraries
library(tidyr)
library(dplyr)
library(ggplot2)

# Read the distance data
distance_data <- read.table('~/Scatterplots/distance_between_geo_group.tsv', header = TRUE, row.names = 1, sep = "\t")

# Convert the distance data to long format
distance_long <- distance_data %>%
  rownames_to_column(var = "Pop1") %>%
  pivot_longer(-Pop1, names_to = "Pop2", values_to = "Distance_m") %>%
  filter(!is.na(Distance_m)) %>%
  mutate(Distance_km = Distance_m / 1000)

# Read the Fst data
fst_data <- read.table('~/Scatterplots/propotion_overlapping_cand.tsv', header = TRUE, row.names = 1, sep = "\t")

# Convert the Fst data to long format
fst_long <- fst_data %>%
  rownames_to_column(var = "Pop1") %>%
  pivot_longer(-Pop1, names_to = "Pop2", values_to = "Fst") %>%
  filter(!is.na(Fst))

# Merge the distance and Fst data
merged_data <- merge(distance_long, fst_long, by = c("Pop1", "Pop2"))

# Create labels for the points
merged_data <- merged_data %>%
  mutate(Label = paste(Pop1, Pop2, sep = "-"))

# Create the scatter plot
ggplot(merged_data, aes(x = Distance_km, y = Fst)) +
  geom_point() +
  geom_text(aes(label = Label), vjust = -0.5, hjust = 0.5) +
  labs(x = "Distance (km)", y = "Proportion") +
  theme_minimal() +
  ylim(0, max(merged_data$Fst))