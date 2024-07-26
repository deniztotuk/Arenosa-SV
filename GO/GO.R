# Load necessary libraries
library(biomaRt)
library(topGO)
library(org.At.tair.db)
library(dplyr)
library(readr)

# Load candidate genes with TAIR ID
candidate_genes <- read_tsv('~/TAIR_Annotation/ZT_TAIR.tsv')

# Strip version numbers from TAIR IDs
candidate_genes <- candidate_genes %>%
  mutate(A_thaliana = gsub("\\..*", "", A_thaliana))

# Print a few TAIR IDs from your dataset after stripping version numbers
print(head(candidate_genes$A_thaliana))

# List some valid TAIR IDs from org.At.tair.db
valid_tair_ids <- keys(org.At.tair.db, keytype = "TAIR")

# Check if any TAIR IDs from your dataset match the valid TAIR IDs
matching_tair_ids <- intersect(candidate_genes$A_thaliana, valid_tair_ids)
print(matching_tair_ids)

# Filter candidate genes to keep only those with valid TAIR IDs
filtered_candidate_genes <- candidate_genes %>%
  filter(A_thaliana %in% matching_tair_ids)

# Print the number of valid genes
print(length(matching_tair_ids))

# Prepare gene list
gene_list <- ifelse(filtered_candidate_genes$A_thaliana %in% valid_tair_ids, 1, 0)
gene_list <- factor(gene_list, levels = c(0, 1))
names(gene_list) <- filtered_candidate_genes$A_thaliana

# Function to map gene IDs to GO terms
geneID2GO <- function(ids) {
  mapIds(org.At.tair.db, keys = ids, column = "GO", keytype = "TAIR", multiVals = "list")
}

# Convert the geneID2GO output to a list of GO terms
geneID2GO_map <- geneID2GO(filtered_candidate_genes$A_thaliana)
valid_ids <- names(geneID2GO_map)
geneID2GO_list <- lapply(geneID2GO_map, function(x) if (is.null(x)) NA else unlist(x))
geneID2GO_list <- geneID2GO_list[valid_ids]

# Filter out genes without GO annotations
geneID2GO_list <- Filter(function(x) !is.na(x), geneID2GO_list)

# Create topGO data object
go_data <- new("topGOdata",
               description = "GO Enrichment Analysis",
               ontology = "BP",  # Biological Process
               allGenes = gene_list,
               geneSel = function(x) x == 1,
               annot = annFUN.gene2GO,
               gene2GO = geneID2GO_list)

# Run enrichment analysis
result_elim <- runTest(go_data, algorithm = "elim", statistic = "fisher")

# Extract significant GO terms
go_results <- GenTable(go_data, elimFisher = result_elim, orderBy = "elimFisher", topNodes = 20)

# Filter GO terms based on gene count criteria
filtered_go_results <- go_results %>%
  filter(as.numeric(Significant) > 5 & as.numeric(Significant) < 500)

# Save results to a TSV file
write_tsv(filtered_go_results, "~/GO/ZT_GO_Enrichment_Results.tsv")