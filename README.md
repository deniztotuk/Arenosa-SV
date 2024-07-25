### Arenosa-SV
#### Introduction





#### Mapping Samples

Sample map which describes both geolocation, ecotype (alpine-foothill) and polidy status for all collected samples are created by using custom R script `Create_Map.R`

Script takes `Alp_Samples_for_map.xlsx` as input which is a derivative file created from more general `Alpine samples.xlsx` by copying columns Ecotype, Ploidy, Latitude, Longitude to another `.xslx` .

To specify input file path and since script does not save any output file it should run on Rstudio enviornment for best results.

### Linkage Disequilibrium Pruning

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
The script performs LD pruning on VCF file and takes `.vcf` files as an input.

Input vcf file can be changed by changing file path of VCF variable 

The script was run on HPC enviornment. Running script on any other enviornment requires installation of gcc version 13.2.0. 

Correct usage of flags (`-vcf`, `-mis`, `-maf`, `-r2` ...) and their effects on output file commented in the script file.

### Principle Component Analysis (PCA)

PCA analysis were performed on LD pruned vcf file `alp_arenosa_pruned.vcf` with another script taken from Hämälä (2024) https://github.com/thamala/polySV/blob/main/est_cov_pca.r.

Since script was modified it was renamed `modified_est_cov_pca.r`.

This script was modified for our research purposes and takes two input files `alp_arenosa_pruned.vcf` and `alpine_foothill_inds.csv`.

The original script only does different coloring based on ploidy.

The modified script takes input file `alpine_foothill_inds.csv` to further seperate graph based on alpine and foothill pouplations (shape and color).

Small modifications were made for better readibility of graph. (reducing `geom_point` size, reducing `element_text`, adding manual adjustment of color)

The script was run on R studio enviornment.

### Phylogenetic Tree Construction via SplitsTree

Before tree construction since SplitsTree cannot recognize `.vcf` files they need to be converted to `.phy` format.

To make this conversion `vcf2phylip.py` script is used. The script is created by Ortiz (2019) https://github.com/edgardomortiz/vcf2phylip].

```Python
python3 vcf2phylip.py -i alp_arenosa_pruned.vcf
```
This script outputs a phylip file named `alp_arenosa_pruned_c.min4.phy` which can be loaded into SplitsTree.

SplitsTree app can be directly downloaded for MacOS, Windows or Linux from https://software-ab.cs.uni-tuebingen.de/download/splitstree6/welcome.html. 

When app is installed open the SplitsTree app. Then open the file by selecting `File > Open` then in the opened window find and select `alp_arenosa_pruned_c.min4.phy` then click open.

After file is loaded to SplitsTree this initiate automatic creation of SplitNetwork which already shows phylogenetic relations between populations.

To construct a phylogenetic tree select `Tree` tab and choose appropriate tree building algorithm for your study. For this study we have choosen `NJ` method.

After tree is constructed to see confidence levels bootstrap algorithm was run by `Analysis > Bootstrap Tree`.

**Note:** While creating tree graph used in thesis random samples from each population were used insted of entire dataset for beter readibilty. 
 
