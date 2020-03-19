# Library calls -----------------------------------------------------------

# app
library(htmltools)
library(glue)
library(shinydashboard)
library(shiny)
library(DT)
library(shinythemes)
library(sp)

# viz
library(packcircles)
# library(hrbrthemes)
library(plotly)
library(leaflet)
library(sf)
require(geosphere)
require(deckgl)
library(feather) # prolly not needed
library(tidyverse)

# Data sets ---------------------------------------------------------------

dat <- read_feather(here::here("data", "geolocated_performers_dt.feather"))

# Continent Shapefiles
m <- readRDS("data/continent_sf.RDS")

# Country Shapefiles
countries <- readRDS("data/country_sf.RDS")

world <- read_sf(
  dsn = here::here("data", "gis"),
  layer = "ne_110m_admin_0_countries"
) %>%
  mutate(
    ISO_A2 = replace(ISO_A2, NAME == "France", "FR")
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

# * Add Mapbox API Token for Session --------------------------------------

# Sys.setenv(MAPBOX_API_TOKEN = "your_super-secret_token")

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

# App functions -----------------------------------------------------------

# a wrapper for ggplot_circlepack %>% ggplotly
gg_circlepack <- function(dat, label) {
  packing <- circleProgressiveLayout(dat$n, sizetype = "area")
  layout <- circleLayoutVertices(packing, npoints = 6)
  
  dat <- bind_cols(dat, packing)
  dat$text <- paste0(dat[[1]], " (", dat[["n"]], ")")
  co <- quantile(dat[["n"]], .95)
  print(co)
  print(100 < co)
  dat[[label]] <- if_else(dat[["n"]] < co, "", dat[[label]])
  
  print(head(dat))
  
  kvm <- set_names(dat$text, 1:nrow(dat))
  layout$text <- kvm[layout$id]
  
  ggplot(dat, aes(x, y, text = text)) +
    geom_text(aes_(size = ~n, label = as.name(label))) +
    geom_polygon(data = layout, aes(color = as.factor(id), fill = as.factor(id), text = text), size = 3, alpha = .5) +
    scale_size_continuous(range = c(3,5)) +
    theme_void() +
    theme(legend.position = 'none') +
    coord_equal()
}

# build a vector for leaflet::fitBounds
fitBounds_bbox <- function(dat) {
  x <- st_bbox(dat) %>% unname()
  # meh but it's better
  if ("Europe" %in% unique(dat$region)) x[1] <- -10; x[3] <- 100
  x
}
