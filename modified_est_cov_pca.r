# Load necessary libraries
library(vcfR)
library(ggplot2)
library(ggrepel)
library(readr)

# Load VCF file
vcf <- read.vcfR("~/alp_arenosa_pruned.vcf") #Filtered and LD-pruned VCF file

# Transform VCF to numeric genotypes
df <- extract.gt(vcf)
df[df == "0|0"] <- 0
df[df == "0|1"] <- 1
df[df == "1|0"] <- 1
df[df == "1|1"] <- 2
df[df == "0/0"] <- 0
df[df == "0/1"] <- 1
df[df == "1/0"] <- 1
df[df == "1/1"] <- 2
df[df == "0/0/0/0"] <- 0
df[df == "0/0/0/1"] <- 1
df[df == "0/0/1/1"] <- 2
df[df == "0/1/1/1"] <- 3
df[df == "1/1/1/1"] <- 4
df[df == "0/0/0/0/0/0"] <- 0
df[df == "0/0/0/0/0/1"] <- 1
df[df == "0/0/0/0/1/1"] <- 2
df[df == "0/0/0/1/1/1"] <- 3
df[df == "0/0/1/1/1/1"] <- 4
df[df == "0/1/1/1/1/1"] <- 5
df[df == "1/1/1/1/1/1"] <- 6
df <- data.frame(apply(df, 2, function(y) as.numeric(as.character(y))))

# Remove samples with > 50% missing data
mis <- apply(df, 2, function(y) sum(is.na(y)) / length(y))
df <- df[, mis <= 0.5]

# Calculate allele frequencies
x <- apply(df, 2, max, na.rm = TRUE)
p <- apply(df, 1, function(y) sum(y, na.rm = TRUE) / sum(x[!is.na(y)]))

# Removing individuals can change allele frequencies, so we make sure that maf >= 0.05
df <- df[p >= 0.05 & p <= 0.95, ]
p <- p[p >= 0.05 & p <= 0.95]

# Estimate a covariance matrix
n <- ncol(df)
cov <- matrix(nrow = n, ncol = n)
for (i in 1:n) {
  for (j in 1:i) {
    cov[i, j] <- mean((df[, i] / x[i] - p) * (df[, j] / x[j] - p) / (p * (1 - p)), na.rm = TRUE)
    cov[j, i] <- cov[i, j]
  }
}

# Do PCA on the matrix and plot
pc <- prcomp(cov, scale = TRUE)
xlab <- paste0("PC1 (", round(summary(pc)$importance[2] * 100), "%)")
ylab <- paste0("PC2 (", round(summary(pc)$importance[5] * 100), "%)")
pcs <- data.frame(PC1 = pc$x[, 1], PC2 = pc$x[, 2], id = colnames(df), ploidy = x)

# Load the alpine and foothill data
ecotypes <- read_csv('~/PCA/alpine_foothill_inds.csv')

# Merge the PCA results with the ecotype data
pcs <- pcs %>% left_join(ecotypes, by = c("id" = "ID_SNPs"))

# Plot the PCA results with different shapes for alpine and foothill populations
ggplot(pcs, aes(PC1, PC2, color = as.factor(ploidy), shape = ecotype)) +
  geom_point(size = 2.0) +
  scale_color_manual(values = c("2" = "blue", "4" = "orange")) +
  labs(x = xlab, y = ylab, color = "Ploidy", shape = "Ecotype") +
  theme(panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(color = "black", linewidth = 0.5),
        axis.text = element_text(size = 5, color = "black"),
        axis.ticks.length = unit(.15, "cm"),
        axis.ticks = element_line(color = "black", linewidth = 0.5),
        axis.title = element_text(size = 12, color = "black"),
        plot.title = element_text(size = 14, color = "black", hjust = 0.5),
        legend.text = element_text(size = 11, color = "black"),
        legend.title = element_text(size = 12, color = "black"),
        legend.key = element_blank(),
        aspect.ratio = 1)