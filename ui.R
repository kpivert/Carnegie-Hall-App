#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(feather)
library(leaflet)
require(geosphere)
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
            plotOutput("home_city")
        )
    )
))
