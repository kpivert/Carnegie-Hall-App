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
    wellPanel(
      h4("Continent:"),
      leafletOutput("selectmap", height = 200),
      selectizeInput(
        inputId = "continent",
        label = NULL,
        choices = m$region,
        selected = NULL
      )
    )
  ),
  # Show a plot of the generated distribution
  dashboardBody(
    fluidRow(
      leafletOutput("continent_arcs")
      # leafletOutput("home_city")
    ),
    br(),
    fluidRow(
      box(plotlyOutput("instrument_bubble")),
      box(plotlyOutput("role_bubble"))
    )
  )
)
