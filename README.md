### Arenosa-SV
# Unveiling the Role of Structural Variants in the Adaptive Evolution of Arabidopsis arenosa to Alpine Environments

Welcome to the GitHub repository for our study on the adaptive evolution of Arabidopsis arenosa in alpine environments. This research focuses on understanding how structural variants (SVs) contribute to the adaptation of A. arenosa populations to challenging alpine conditions.

### Project Overview
*Arabidopsis arenosa* inhabits diverse environments across Central Europe from lowland foothills to high-altitude alpine regions. By examining structural variants, we aim to uncover the genetic basis of adaptive traits that enable survival in alpine environments.

### Key Objectives
1- Identify structural variants involved in the adaptation to alpine environments.
2- Understand the role of gene reuse and functional parallelism in different populations.
3- Examine the relationship between geographic distance, genetic divergence, and adaptive traits.

### Major Findings
- Significant SVs contributing to alpine adaptation were identified, highlighting genes related to stress response and metabolic processes.
- Evidence of gene reuse across geographically separated populations, suggesting common adaptive strategies.

## Repository Contents
This repository contains data, scripts, and supplementary materials used in our analyses. We hope that our findings will contribute to the broader understanding of plant adaptation and the role of structural variants in evolutionary processes.

**All scripts used in this project can be found in Scripts folder as well as, folder named after their respective analysis**

Contact
For more information, please feel free to contact us at mbxdt3@nottingham.ac.uk

## Mapping Samples

Sample map that describes both geolocation, ecotype (alpine-foothill), and ploidy status for all collected samples are created by using the custom R script `Create_Map.R`

The script takes `Alp_Samples_for_map.xlsx` as input. This is a derivative file created from the more general `Alpine samples.xlsx` by copying the columns Ecotype, Ploidy, Latitude, and Longitude to another `.xslx.`

To specify the input file path and save the output graph, run this on the Rstudio environment for the best results. 

## Linkage Disequilibrium Pruning

Files are LD pruned via Hämälä's (2024) PCA script which is directly taken from https://github.com/thamala/polySV/blob/main/prune_ld.c

```Bash
# Load the required modules for C compilation
module load gcc-uoneasy/13.2.0

# Locating vcf file
VCF=~/alp_arenosa.fourfold.v2.vcf

# Navigate to the directory containing the C script
cd ~/pruning

# Compile the C script
gcc -o prune_ld ~/pruning/prune_ld.c -lm

# Run the compiled program with the specified parameters
~/pruning/prune_ld -vcf $VCF -mis 0.6 -maf 0.05 -r2 100 50 0.1 > ~/pruning/alp_arenosa_pruned.vcf
```
The script performs LD pruning on the VCF file and takes `.vcf` files as input.

Input vcf file can be changed by changing the file path of the VCF variable. 

The script was run in an HPC environment. Running it in any other environment requires installing GCC version 13.2.0. 

Correct usage of flags (`-vcf,` `-mis,` `-maf,` `-r2` ...) and their effects on the output file commented in the script file.

## Principle Component Analysis (PCA)

PCA analysis was performed on the LD pruned vcf file `alp_arenosa_pruned.vcf` with another script taken from Hämälä (2024): https://github.com/thamala/polySV/blob/main/est_cov_pca.r.

This script was modified for our research purposes and takes two input files, `alp_arenosa_pruned.vcf` and `alpine_foothill_inds.csv`.

Since the script was modified, it was renamed `modified_est_cov_pca.r`.

The original script only uses different colorings based on ploidy.

The modified script takes the input file `alpine_foothill_inds.csv` to separate the graph based on alpine and foothill populations (shape and color).

Slight modifications were made to the graph for better readability. (reducing `geom_point` size, reducing `element_text,` adding manual adjustment of color)

The script was run on the R studio environment.

### Phylogenetic Tree Construction via SplitsTree

Before tree construction, since SplitsTree cannot recognize `.vcf` files, they need to be converted to `.phy` format.

The `vcf2phylip.py` script, created by Ortiz (2019), is used to make this conversion. https://github.com/edgardomortiz/vcf2phylip].

```Python
python3 vcf2phylip.py -i alp_arenosa_pruned.vcf
```
This script outputs a phylip file named `alp_arenosa_pruned_c.min4.phy`, which can be loaded into SplitsTree.

SplitsTree app can be directly downloaded for MacOS, Windows, or Linux from https://software-ab.cs.uni-tuebingen.de/download/splitstree6/welcome.html. 

When the app is installed, open the SplitsTree app. Then, open the file by selecting `File > Open`. In the opened window, find and select `alp_arenosa_pruned_c.min4.phy`, then click open.

After the file is loaded to SplitsTree, the automatic creation of SplitNetwork initiates. This already shows phylogenetic relations between populations.

To construct a phylogenetic tree, select the `Tree` tab and choose the appropriate tree-building algorithm for your study. For this study, we have chosen the `NJ` method.

After the tree was constructed to see confidence levels, the bootstrap algorithm was run by `Analysis > Bootstrap Tree.`

**Note:** To improve the readability of the tree graph used in the thesis, random samples from each population were used instead of the entire dataset. This reduced the number of branches at the individual level and simplified the tree without changing the overall story.

## Fst Analysis

Fst, scans were firstly performed on samples within individual geographical groups between alpine and foothill populations using SV data (**not** pruned or unpruned 
SNV data).

Fst calculations were made in an HPC environment. If you want to make these calculations locally, you must install and activate `vcftools version 0.1.16`.
```bash
#locating VCF file
VCF=~/alpine_all_SV50_norm_rmdup_AN_AC.vcf.gz

#loading module vcftools
module load vcftools-uoneasy/0.1.16-G-12.3.0

# Set the VCF file path
VCF=~/alpine_all_SV50_norm_rmdup_AN_AC.vcf

# Run vcftools to calculate Fst
vcftools --vcf $VCF \
--weir-fst-pop ~/Fst/population_files/FG_alpine.txt \
--weir-fst-pop ~/Fst/population_files/FG_foothill.txt \
--out ~/Fst/Fst_results/FG_Fst_Results
```
The file takes SV data as input `alpine_all_SV50_norm_rmdup_AN_AC.vcf`.

Two population files are also required to run the script. These population files basically contain the names of all samples within the population in a column-wise manner. They are also provided in the repository (population_files) for reproducibility purposes. They are named after the local geographic groups to which samples belong and their respective ecotypes (alpine, foothill, both).

The script output file is a `.weir.fst`, which contains per site Fst values.

Furthermore, this command can be used to calculate mean Fst for populations. The direct output file does not contain any mean Fst value; instead, it only contains per-site Fst results. However, after the run is completed, vcftools shows these values directly in the terminal. These values (Weir and Cockerham weighted Fst estimate) are saved in `Fst_between_geo_group.tsv` for downstream analysis.
```bash
After filtering, kept 57 out of 203 Individuals
Outputting Weir and Cockerham Fst estimates.
Weir and Cockerham mean Fst estimate: 0.052424
Weir and Cockerham weighted Fst estimate: 0.0812
After filtering, kept 137322 out of a possible 137322 Sites
Run Time = 8.00 seconds
```
Manhattan plots for per site Fst values were plotted via the custom `Manhattan_plots.R` script. 

This script takes `.weir.fst` files as input and plots them. The top 1% of Fst values have red coloring, and each chromosome is highlighted by different colors.

This script saves the `fst_plot.png` file in the home directory as an output.

##  Genome Scans

To isolate the top 1% of outliers, a custom `Outliers_99.R` script was used.

This script takes `.weir.fst` files as inputs. Then, it saves the top 1st percentile of data (Fst scores) into a `.tsv` file.

After outliers are saved in a `.tsv` file, the `Find_candidate_genes.R` script can be used to annotate candidate genes. This script takes the midpoint of all genes within the gtf file, searches genes within a 5kb window in the outlier file, and saves the resulting genes into another `.tsv` file. 

The annotation script takes the `Arabidopsis_arenosa_genome.annotation.simple.gtf` and the tsv file, which are outliers, saved as input and outputs the `.tsv` file, which contains candidate genes.

**Note:** Since annotation of the *Arabidopsis Arenosa* genome is not fully completed, we have used orthologues of *A. Thaliana* and *A. Lyrata* in downstream analysis, which are sister species of *Arabidopsis Arenosa*. These species have far better annotation, which is indeed helpful for searching gene functions.

After genes are annotated based on *Arabidopsis Arenosa* genome `TAIR_Annotation.R` script was used to annotate genes on functional analogs of *A. Thaliana* and *A. Lyrata* sister species. The script contains gene names that can be searched in the TAIR database.

The script takes input of candidate genes `.tsv` file as input outputs another `.tsv` file contains TAIR IDs for respective genes. 

If you prefer the NCBI catalog for searching gene functions, `NCBI_Annotation.R` can also be used, but this method has certain drawbacks. While making GO analysis, the `org.At.tair.db` R package was used, which strictly requires TAIR database gene IDs.

The script takes input of candidate genes `.tsv` file as input outputs another `.tsv` file contains NCBI IDs for respective genes. 

### Searching Signs of Parallel Evolution 

To search for overlapping per site Fst outliers between populations, the `Find_Overlaping_Genes.R` script was used. This script compares candidate genes that are annotated by the `Find_candidate_genes.R` function, finds common variables, and saves them into another `.tsv` file. 

This script takes two input `.tsv` files and outputs another `.tsv` file, which has overlapping genes from both files.

**Important Notice:** This script does not look for matches in TAIR or NCBI annotation files. So, after the output file is produced, it needs to be annotated again by `TAIR_Annotation.R` or `NCBI_Annotation.R` for functional analysis.

We have created `Find_Geo_Distances.R` to calculate distances between two in real-life coordinates. This script takes input coordinate values manually. The coordinate values where samples were collected for any population can be found in the Alpine samples.xlsx file.

The script takes the latitude and altitude values of two coordinates and calculates the distance between them. After the coordinates are given, the script outputs the calculated distance between them in meters. The results were saved manually to a tsv file named `distance_between_geo_group.tsv`.

Since `Fst_between_geo_group.tsv` file were created previously `Fst_vs_Geodist.R` script can be used for creating a graph showing relationship between average Fst between populations and distance between two populations. 

This script (`Fst_vs_Geodist.R`) takes two input files `Fst_between_geo_group.tsv` and `distance_between_geo_group.tsv` then produces a scatterplot showing relationship between two variables.

Another scatterplot was produced with `Proportions_vs_Geodist.R`. This script outputs a scatterplot that shows the relationship between the proportion of candidate genes and the geographic distance between them. This script takes two input files, `propotion_overlapping_cand.tsv` and  `distance_between_geo_group.tsv`. The `propotion_overlapping_cand.tsv` is created by calculating the number of overlapping candidate genes for each group and dividing it by the total number of candidate genes annotated per geographic group. The file was created manually.  

### Gene Ontology

The GO.R script was used to perform GO analysis to find potential gene enrichments. This script takes TAIR annotated `.tsv` files as input and outputs GO results in `.tsv` format.


### References

Ortiz, E.M. 2019. vcf2phylip v2.0: convert a VCF matrix into several matrix formats for phylogenetic analysis. DOI:10.5281/zenodo.2540861

D. H. Huson and D. Bryant, Application of Phylogenetic Networks in Evolutionary Studies, Mol. Biol. Evol., 23(2):254-267, 2006.

Hämälä, T., Moore, C., Cowan, L., Carlile, M., Gopaulchan, D., Brandrud, M.K., Birkeland, S., Loose, M., Kolář, F., Koch, M.A. and Yant, L., 2024. Impact of whole-genome duplications on structural variant evolution in Cochlearia. Nature Communications, 15(1), p.5377. 








 
