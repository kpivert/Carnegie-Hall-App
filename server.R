
library(feather)
library(htmltools)
library(leaflet)
require(geosphere)
library(shiny)
library(tidyverse)

options(shiny.launch.browser = TRUE)

dat <- read_feather(here::here("data", "geolocated_performers.feather"))

## MUST FIX THIS IN ORIGINAL FEATHER FILE 
# dat <- dat %>% 
#   mutate(ch_lat = rep(40.764881, nrow(dat))) %>% 
#   mutate(ch_lon = rep(-73.980276, nrow(dat)))

m <- readRDS("data/continent_sf.RDS")

# Define server logic required to draw a map
shinyServer(function(input, output, session) {

  rv <- reactiveValues()
  
  observeEvent(input$names, {
    rv$map_dat <- filter(dat, name %in% input$names) %>%
      mutate(labl_html = paste(name, birthPlaceName, birthDate, sep = "<br/>"))
    
    rv$sp_lines <-  gcIntermediate(
      rv$map_dat[c('lon', 'lat')], ## Budapest
      c(-73.980276, 40.764881), ## Carenegie Hall
      n = 150,
      addStartEnd = TRUE, 
      sp = TRUE )
  })
  
  # output$home_city <- renderLeaflet({
  #   leaflet(rv$sp_lines) %>%
  #     addTiles() %>%
  #     addPolylines() %>%
  #     addMarkers(data = rv$map_dat, label = ~HTML(labl_html))
  # })
  

  # Map selector ------------------------------------------------------------
  
  output$selectmap <- renderLeaflet({
    pal <- colorFactor("Dark2", m$region)
    
    leaflet(m,
            options = leafletOptions(
              zoomControl = FALSE,
              dragging = FALSE,
              minZoom = 0,
              maxZoom = 0)
    )%>%
      addPolygons(layerId = ~region,
                  fillColor = ~pal(region),
                  fillOpacity = 1,
                  color = "black",
                  stroke = F,
                  highlight = highlightOptions(
                    fillOpacity = .5,
                    bringToFront = TRUE))
  })
  
  observe({
    click <- input$selectmap_shape_click
    if (is.null(click)) return()
    
    updateSelectizeInput(session, "continent",
                         selected = click$id)
  })
  
  observeEvent(input$continent, {
    leafletProxy("selectmap", session) %>%
      removeShape("selected") %>% 
      addPolylines(data = filter(m, region == input$continent),
                   layerId = "selected",
                   color = "black",
                   weight = 3)
    
    rv$cont_dat <- filter(dat, region %in% input$continent) %>%
        mutate(ch_lat = rep(40.764881, nrow(.))) %>%
        mutate(ch_lon = rep(-73.980276, nrow(.)))

    rv$cont_arc_lines <-  gcIntermediate(
      rv$cont_dat[c('lon', 'lat')],
      rv$cont_dat[c('ch_lon', 'ch_lat')], ## Carnegie Hall Data Must Be Added to Feather File
      n = 100,
      addStartEnd = TRUE,
      sp = TRUE )
    

  })


  #
   output$continent_arcs <- renderLeaflet({
     
     leaflet(rv$cont_arc_lines) %>%
       addProviderTiles('CartoDB.Positron') %>%
       addPolylines()
  })
  

  # Fluid Row Plots ---------------------------------------------------------
  
  

  

 })
