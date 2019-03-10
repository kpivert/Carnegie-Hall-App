library(feather)
library(htmltools)
library(leaflet)
require(geosphere)
library(shinydashboard)
library(shiny)
library(tidyverse)

dat <- read_feather(here::here("data", "birth_locations.feather"))
m <- readRDS("data/continent_sf.RDS")


dashboardPage(
  dashboardHeader(title = "Carnegie Hall Performance Explorer"),
  dashboardSidebar(
    width = 350,
    selectizeInput(
      "names", "Performer:", dat$name
    ),
    h5("Continent:"),
    leafletOutput("selectmap", height = 200),
    selectizeInput(
      inputId = "continent",
      label = NULL,
      choices = m$region,
      selected = NULL
    )
  ),
  # Show a plot of the generated distribution
  dashboardBody(
    fluidRow(
      leafletOutput("continent_arcs"),
      leafletOutput("home_city")
    ),
    fluidRow(
      box(plotOutput()),
      box(plotOutput()),
      box(plotOutput())
>>>>>>> Stashed changes
    )
  )
)
