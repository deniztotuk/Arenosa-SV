# Load necessary libraries
library(geosphere)

# Function to calculate distance
calculate_distance <- function(lat1, lon1, lat2, lon2) {
  # Combine latitude and longitude into two points
  point1 <- c(lon1, lat1)
  point2 <- c(lon2, lat2)
  
  # Calculate the distance using the Haversine formula
  distance <- distHaversine(point1, point2)
  return(distance)
}

# Example usage
lat1 <- 47.2817064   # Latitude of first point
lon1 <- 14.5000688  # Longitude of first point
lat2 <- 49.11540806   # Latitude of second point
lon2 <- 20.29905368 # Longitude of second point

distance <- calculate_distance(lat1, lon1, lat2, lon2)
print(paste("Distance:", distance, "meters"))