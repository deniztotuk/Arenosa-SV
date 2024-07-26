# Load necessary libraries
library(ggplot2)
library(dplyr)
library(readr)

# Load the Fst data
fst_data <- read_tsv('~/Fst/Fst_results/NT_Fst_Results.weir.fst')

# Replace #NAME? with NA and convert to numeric
fst_data <- fst_data %>%
  mutate(WEIR_AND_COCKERHAM_FST = as.numeric(WEIR_AND_COCKERHAM_FST))

# Set Fst values below 0 to 0
fst_data <- fst_data %>%
  mutate(WEIR_AND_COCKERHAM_FST = ifelse(WEIR_AND_COCKERHAM_FST < 0, 0, WEIR_AND_COCKERHAM_FST))

# Calculate the 99th percentile threshold
threshold <- quantile(fst_data$WEIR_AND_COCKERHAM_FST, 0.99, na.rm = TRUE)

# Create a new column to indicate outliers
fst_data <- fst_data %>%
  mutate(outlier = ifelse(WEIR_AND_COCKERHAM_FST >= threshold, "Top 1%", "Other"))

# Ensure all scaffolds are displayed in the correct order
fst_data$CHROM <- factor(fst_data$CHROM, levels = unique(fst_data$CHROM))

# Assign colors to each chromosome
chromosome_colors <- setNames(rainbow(length(unique(fst_data$CHROM))), unique(fst_data$CHROM))

# Define function to plot with adjustable height, width, and colors
plot_fst <- function(data, plot_height = 8, plot_width = 12, colors = chromosome_colors) {
  data <- data %>%
    mutate(color_group = ifelse(outlier == "Top 1%", "Top 1%", as.character(CHROM)))
  
  all_colors <- c(colors, "Top 1%" = "red")
  
  p <- ggplot(data, aes(x = POS, y = WEIR_AND_COCKERHAM_FST, color = color_group)) +
    geom_point(size = 0.5) +
    scale_color_manual(values = all_colors) +
    labs(title = "Fst values across scaffolds",
         x = "Position",
         y = "Weir and Cockerham Fst",
         color = "Category") +
    theme_minimal() +
    facet_grid(~ CHROM, scales = "free_x", space = "free_x") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          panel.spacing = unit(0.1, "lines"),
          plot.margin = unit(c(1, 1, 1, 1), "cm"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          strip.background = element_blank(),
          strip.text = element_text(size = 10))
  
  # Save the plot with specified dimensions
  ggsave("fst_plot.png", p, height = plot_height, width = plot_width)
}

# Plot with default settings
plot_fst(fst_data)

# Example: Plot with custom height, width, and colors
custom_colors <- setNames(c("blueviolet", "blue", "coral", "yellow", "brown", "orange", "pink", "cyan"), unique(fst_data$CHROM))
plot_fst(fst_data, plot_height = 8, plot_width = 16, colors = custom_colors)
