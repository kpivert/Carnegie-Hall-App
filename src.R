# Library Calls -----------------------------------------------------------

# minimal function calls (not loaded entirely but individual function reqd)

# app
library(shiny)
library(htmltools)
library(glue)
library(DT)
library(shinydashboard)
library(shinythemes)

# viz
library(plotly)
library(mapdeck)
library(leaflet)
library(tidyverse)

# Data Sets ---------------------------------------------------------------

# Geolocated Performers
dat <- readRDS("data/geolocated_performers.rds")

# Continent Shapefiles
m <- readRDS("data/continent_sf.RDS") 

# Country Shapefiles (Don't Think They're Needed)
world <- read_rds("data/world_sf.RDS")

# Counts for Choropleth  
choro_dat <- read_rds("data/choro_dat.RDS")
  
# Instrumental Performers Dataset
instruments <- read_rds("data/name_instrument.RDS")

# Performer Roles Dataset
roles <- read_rds("data/name_role.RDS")

# Continent Centroids for Zooming

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

d3Treemap <- function(dat, label) {
  
  m <- list(
    l = 0,
    r = 0,
    b = 0,
    t = 0,
    autoexand=FALSE
  )
  ax <- list(
    title = "",
    zeroline = FALSE,
    showline = FALSE,
    showticklabels = FALSE,
    showgrid = FALSE
  )
  plot_ly(
    type='treemap',
    values = dat$n,
    labels=dat[[label]],
    parents="") %>% 
    layout(uniformtext=list(minsize=16, mode='hide'),
           margin = m,
           xaxis= ax,yaxis=ax)
  # 
  # plot_ly(data = dat,
  #         type='treemap',
  #         labels= dat[[label]],
  #         parents="",
  #         values= ~n,
  #         color = ~n,
  #         colors = "Blues",
  #         textinfo="label") %>% 
  #   layout(uniformtext=list(minsize=16, mode='hide'),
  #          margin = m,
  #          xaxis= ax,yaxis=ax) %>% 
  #   config(displayModeBar = F) %>% 
  #   hide_colorbar()
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

