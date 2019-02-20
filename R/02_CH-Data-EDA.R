
# Explore Geocoded Data from Nate's SPARQL Data Pull ----------------------

# Carnegie Hall Lat = 40.764881, Long = -73.980276
# <a href="https://www.latlong.net/c/?lat=40.764881&long=-73.980276" target="_blank">(40.764881, -73.980276)</a>

# 00 Load Packages --------------------------------------------------------

require(tidyverse)
require(feather)
require(leaflet)
require(geosphere)

# 01 Load Data ------------------------------------------------------------

dat <- readRDS(
  here::here("data", "birth_locations.RDS")
  ) %>% 
  select(-lon, - city)

geonames <- read_csv(
  here::here("data", "cities15000.csv"),
  col_names = FALSE
  ) %>% 
  select(
    birthPlace = X1, 
    city = X3, 
    lat = X5, 
    lon = X6
    )

# 02 Add Longitude to Dataset  --------------------------------------------

dat <- dat %>% 
  left_join(
    ., 
    geonames,
    by = c("birthPlace" = "birthPlace")
  ) %>% 
  select(
    birthPlace,
    city,
    performer,
    name,
    birthDate, 
    lat, 
    lon)

saveRDS(dat, here::here("data", "birth_locations.RDS"))
write_feather(dat, here::here("data", "birth_locations.feather"))

# 03 Leaflet POC ----------------------------------------------------------

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-73.980276, lat=40.764881, popup="Carnegie Hall")
m 

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


leaflet() %>% 
  addTiles() %>% 
  addMarkers(
    lng = dat %>% 
      filter(name == "Lady Gaga") %>% 
      select(lon) %>% 
      pluck(lon), 
    lat = dat %>% 
      filter(name == "Lady Gaga") %>% 
      select(lat), 
    popup = dat %>% 
      filter(name == "Lady Gaga") %>% 
      select(city)
  )


