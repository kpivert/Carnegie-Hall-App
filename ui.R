
library(feather)
library(htmltools)
library(leaflet)
require(geosphere)
library(shiny)
library(tidyverse)

dat <- read_feather(here::here("data", "birth_locations.feather"))


# Define UI for application that draws a histogram
shinyUI(
  fluidPage(

    # Application title




    pageWithSidebar(
      headerPanel("Carnegie Hall Performance Explorer"),
      sidebarPanel(
        selectizeInput(
          inputId = "names",
          label = "Performer",
          choices = dat$name,
          selected = NULL
        ),
        dateInput(
            inputId = "date",
            label = "Performer Birth Date",
            value = "YYYY-MM-DD"

        )
      ),

      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("home_city")
      )
    )
  )
)
