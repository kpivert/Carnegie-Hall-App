# Library calls -----------------------------------------------------------

# app
library(htmltools)
library(shinydashboard)
library(shiny)
library(DT)
library(shinythemes)

# viz
library(packcircles)
library(plotly)
library(leaflet)
library(sf)
require(geosphere)
require(deckgl)
library(feather) # prolly not needed
library(tidyverse)

# Data sets ---------------------------------------------------------------

dat <- read_feather(here::here("data", "geolocated_performers_dt.feather"))


# * Add Mapbox API Token for Session --------------------------------------

Sys.setenv(MAPBOX_API_TOKEN = "your_super-secret_token")


# Add Variables for DeckGL Vizes

dat <- dat %>% 
  mutate(
    from_lon = lon,
    from_lat = lat, 
    from_name = birthPlaceName,
    to_lon = ch_lon,
    to_lat = ch_lat
  ) %>% 
  mutate(
    to_name = "Carnegie Hall",
    # to_name = rep("CH", nrow(.)),
    tooltip = str_c(name, " Born in ", from_name),
    ch_color = "#F7002B",
    from_color = case_when(
      `continent code` == "AF" ~ "#8F9DCB",
      `continent code` == "AS" ~ "#DBA8AF",
      `continent code` == "EU" ~ "#f9f6f7",
      `continent code` == "NA" ~ "#1DA3CA",
      `continent code` == "OC" ~ "#BF346B",
      `continent code` == "SA" ~ "#767969"
    )
  )

m <- readRDS("data/continent_sf.RDS")
countries <- readRDS("data/country_sf.RDS")
instruments <- read_feather("data/name_instrument.feather")
roles <- read_feather("data/name_role.feather")
world <- read_sf(
  dsn = here::here("data", "gis"),
  layer = "ne_110m_admin_0_countries"
) %>%
  mutate(
    ISO_A2 = replace(ISO_A2, NAME == "France", "FR")
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


