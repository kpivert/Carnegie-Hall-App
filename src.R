# Library calls -----------------------------------------------------------

# viz
library(packcircles)
library(plotly)
library(leaflet)
require(geosphere)

# app
library(feather)
library(htmltools)
library(shinydashboard)
library(shiny)

library(tidyverse)


# Data sets ---------------------------------------------------------------

dat <- read_feather(here::here("data", "geolocated_performers.feather"))

## MUST FIX THIS IN ORIGINAL FEATHER FILE 
# dat <- dat %>% 
#   mutate(ch_lat = rep(40.764881, nrow(dat))) %>% 
#   mutate(ch_lon = rep(-73.980276, nrow(dat)))

m <- readRDS("data/continent_sf.RDS")
instruments <- read_feather("data/name_instrument.feather")
roles <- read_feather("data/name_role.feather")


# App functions -----------------------------------------------------------

gg_circlepack <- function(dat, label) {
  packing <- circleProgressiveLayout(dat$n, sizetype = "area")
  layout <- circleLayoutVertices(packing, npoints = 50)
  
  dat <- bind_cols(dat, packing)
  
  ggplot(dat, aes(x, y)) +
    geom_polygon(data = layout, aes(fill = as.factor(id)), ) +
    geom_text(data = dat, aes_(size = ~n, label = as.name(label))) +
    scale_size_continuous(range = c(3,5)) +
    theme_void() +
    theme(legend.position = 'none') +
    coord_equal()
}
