
library(feather)
library(htmltools)
library(leaflet)
require(geosphere)
library(shiny)
library(tidyverse)

options(shiny.launch.browser = TRUE)

dat <- read_feather(here::here("data", "birth_locations.feather"))

# Define server logic required to draw a map
shinyServer(function(input, output) {

  
  rv <- reactiveValues()
  
  observeEvent(input$names, {
    rv$map_dat <- filter(dat, name %in% input$names) %>%
      mutate(labl_html = paste(name, city, birthDate, sep = "<br/>"))
    
    rv$sp_lines <-  gcIntermediate(
      rv$map_dat[c('lon', 'lat')], ## Budapest
      c(-73.980276, 40.764881), ## Carenegie Hall
      n = 150,
      addStartEnd = TRUE, 
      sp = TRUE )
  })
  
  output$home_city <- renderLeaflet({
    leaflet(rv$sp_lines) %>% 
      addTiles() %>% 
      addPolylines() %>%
      addMarkers(data = rv$map_dat, label = ~HTML(labl_html))
  })


   
})
