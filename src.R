# Library Calls -----------------------------------------------------------

# app
library(htmltools)
library(glue)
library(shiny)
library(DT)
library(shinydashboard)
library(shinythemes)
library(sp)

# viz
library(plotly)
library(treemapify)
library(sf)
library(geosphere)
library(rnaturalearth)
library(rnaturalearthdata)
library(mapdeck)
library(leaflet)
library(feather) # prolly not needed
library(tidyverse)

# Data Sets ---------------------------------------------------------------

# Geolocated Performers
dat <- read_feather(here::here("data", "geolocated_performers_dt.feather")) %>% 
  mutate(birth_year = as.numeric(gsub("-.*", "", birthDate)))

# Continent Shapefiles
m <- readRDS("data/continent_sf.RDS") 

# Country Shapefiles
world <- ne_countries(scale = "medium", returnclass = "sf")

# Counts for Choropleth  
choro_dat <- dat %>% 
  count(ISO_Country) %>%
  mutate(n = n * 1000) %>% 
  right_join(world, ., by = c("iso_a2" = "ISO_Country")) %>% 
  mutate(
    tooltip = str_c(
      formal_en, 
      "\u2013",
      n / 1000,
      " Performers"
    )
  )  

# Instrumental Performers Dataset
instruments <- read_feather("data/name_instrument.feather")

# Performer Roles Dataset
roles <- read_feather("data/name_role.feather")

# Join Datasets for App Use
dat <- left_join(
  dat, 
  instruments
) %>% 
  mutate(
    inst = str_to_title(inst),
    role = str_to_title(role)
  )

# * Add Variables for DeckGL Vizes and Tooltip ----------------------------

# Edit Names
dat <- dat %>% 
  mutate(
    from_lon = lon,
    from_lat = lat, 
    from_name = birthPlaceName,
    to_lon = ch_lon,
    to_lat = ch_lat
  ) 

# Add Distances, Tooltip, and Continental Color Scheme  
dat <- dat %>%   
  mutate(
    distance_miles = distGeo(
      dat %>% 
        select(starts_with("from_l")) %>% 
        as.matrix(),
      dat %>% 
        select(starts_with("to_l")) %>% 
        as.matrix()
    ) / 1609.344
  ) %>% 
  mutate(
    to_name = "Carnegie Hall",
    tooltip = str_c(
      name, 
      ": Born in ", 
      from_name,
      ", ",
      round(distance_miles),
      " miles from Carnegie Hall"
      ),
    ch_color = "#F7002B",
    from_color = case_when(
      `continent code` == "AF" ~ "#8F9DCB",
      `continent code` == "AS" ~ "#DBA8AF",
      `continent code` == "EU" ~ "#f9f6f7",
      `continent code` == "NA" ~ "#1DA3CA",
      `continent code` == "OC" ~ "#BF346B",
      `continent code` == "SA" ~ "#767969"
    ),
    cont_lon = case_when(
      `continent code` == "AF" ~ 18.77,
      `continent code` == "AS" ~ 100.16,
      `continent code` == "EU" ~ 11.61,
      `continent code` == "NA" ~ -101,
      `continent code` == "OC" ~ 133.7,
      `continent code` == "SA" ~ -59.4
    ),
    cont_lat = case_when(
      `continent code` == "AF" ~ 10.86,
      `continent code` == "AS" ~ 39.39,
      `continent code` == "EU" ~ 48.8,
      `continent code` == "NA" ~ 41.86,
      `continent code` == "OC" ~ -20.9,
      `continent code` == "SA" ~ -14
    )
  )

centroids <- tibble(
  continent = c(
    "Africa", "Asia", "Europe", "North America", "Australia", "South America"
    ),
  lon = c(
    26.17, 87.331, 23.106111, -99.99611, 133.4166, -56.1004
  ),
  lat = c(
    5.65, 43.681, 53.5775, 48.367222222222225, -24.25, -15.6006
  )
)

# * Key -------------------------------------------------------------------

key <- Sys.getenv("MAPBOX_API_TOKEN")

# App functions -----------------------------------------------------------

ggTreemap <- function(dat, label) {
  ggplot(dat, aes(area = n, fill = n, label = {{label}})) +
    geom_treemap() +
    geom_treemap_text(color = "white") +
    theme(legend.position = "none")
}

# build a vector for leaflet::fitBounds
fitBounds_bbox <- function(dat) {
  x <- st_bbox(dat) %>% unname()
  # meh but it's better
  if ("Europe" %in% unique(dat$region)) x[1] <- -10; x[3] <- 100
  x
}

findCenter <- function(dat) {
  x <- st_centroid(st_union(dat)) %>% unlist()
  if ("Europe" %in% unique(dat$region)) x[1] <- 5
  x
}

