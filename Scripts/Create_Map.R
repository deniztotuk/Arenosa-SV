# Load necessary libraries
library(ggplot2)
library(dplyr)
library(readxl)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

# Load the data from the Excel file
data <- read_excel("~/Map/Alp_Samples_for_map.xlsx")

# Rename columns to match the expected format
colnames(data) <- c("Ecotype", "Ploidy", "Latitude", "Longitude", "Altitude")

# Convert the data to an sf object
data_sf <- st_as_sf(data, coords = c("Longitude", "Latitude"), crs = 4326)

# Get the world map data
world <- ne_countries(scale = "medium", returnclass = "sf")

# Define the limits for the zoomed-in region
xlim <- c(14, 27)  # Longitude limits
ylim <- c(45, 50)  # Latitude limits

# Create the map
ggplot(data = world) +
  geom_sf(fill = "gray80", color = "white") +
  geom_sf(data = data_sf, aes(color = factor(Ploidy), shape = factor(Ecotype)), size = 3) +
  scale_color_manual(values = c("2" = "blue", "4" = "orange"), name = "Ploidy") +
  scale_shape_manual(values = c("foothill" = 16, "alpine" = 17), name = "Ecotype") +
  theme_minimal() +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  labs(x = "Longitude", y = "Latitude", title = "Distribution of Plant Samples by Ploidy and Ecotype") +
  theme(legend.position = "right")