
library(feather)
library(htmltools)
library(leaflet)
require(geosphere)
library(shiny)
library(tidyverse)

dat <- read_feather(here::here("data", "birth_locations.feather"))


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Carnegie Hall Performance Explorer"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectizeInput(
                inputId = "names",
                label = "Performer",
                choices = dat$name,
                selected = NULL)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("home_city")
        )
    )
))
