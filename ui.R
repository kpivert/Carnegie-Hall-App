
library(feather)
library(htmltools)
library(leaflet)
require(geosphere)
library(shiny)
library(tidyverse)

dat <- read_feather(here::here("data", "birth_locations.feather"))
m <- readRDS("data/continent_sf.RDS")

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    pageWithSidebar(
      headerPanel("Carnegie Hall Performance Explorer"),
      sidebarPanel(
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
      mainPanel(
        leafletOutput("home_city")
      )
    )
  )
)
