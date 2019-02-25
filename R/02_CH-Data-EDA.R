
# Explore Geocoded Data from Nate's SPARQL Data Pull ----------------------

# Carnegie Hall Lat = 40.764881, Long = -73.980276
# <a href="https://www.latlong.net/c/?lat=40.764881&long=-73.980276" target="_blank">(40.764881, -73.980276)</a>

# 00 Load Packages --------------------------------------------------------

require(feather)
require(leaflet)
require(geosphere)
require(tidyverse)

# 01 Load Data ------------------------------------------------------------

dat <- readRDS(here::here("data", "birth_locations.RDS"))

# save a feather
write_feather(dat, here::here("data", "birth_locations.feather"))

# 03 Leaflet POC ----------------------------------------------------------

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-73.980276, lat=40.764881, popup="Carnegie Hall")
m 

## Build Spatial line object to based on traversing a great circle (arc)
## Code Stolen from 
## https://stackoverflow.com/questions/34499212/adding-curved-flight-path-using-rs-leaflet-package

gcIntermediate(
  c(19.0, 47.5), ## Budapest
  c(-73.980276, 40.764881), ## Carenegie Hall
  n = 150,
  addStartEnd = TRUE, 
  sp = TRUE
  ) %>%
  leaflet() %>% 
  addTiles() %>% 
  addPolylines()

dat %>%
  filter(name == "Lady Gaga") %>% 
  leaflet(map_dat) %>% 
  addTiles() %>% 
  addMarkers(lng = ~lon, lat = ~lat, popup = ~city)
