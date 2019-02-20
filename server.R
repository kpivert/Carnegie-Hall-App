#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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

# Define server logic required to draw a map
shinyServer(function(input, output) {

    output$home_city <- renderPlot({
        
        m_lat <- dat %>% 
            filter(name == input$names) %>% 
            select(lat) %>% 
            pluck("lat")
        
        m_long <- dat %>% 
            filter(name == input$names) %>% 
            select(lon) %>% 
            pluck("lon")
        
        m_name <- dat %>% 
            filter(name == input$names) %>% 
            select(name) %>% 
            pluck("name")
        
    # leaflet() %>%
    #         addTiles() %>%  # Add default OpenStreetMap map tiles
    #         addMarkers(
    #             lng = dat %>% 
    #                 filter(name == input$names) %>% 
    #                 select(lon) %>% 
    #                 pluck("lon"), 
    #             lat = dat %>% 
    #                 filter(name == input$names) %>% 
    #                 select(lat) %>% 
    #                 pluck("lat"), 
    #             popup = dat %>% 
    #                 filter(name == input$names) %>% 
    #                 select(name) %>% 
    #                 pluck("name")
    #             )
        
        gcIntermediate(
            c(m_long, m_lat), ## Budapest
            c(-73.980276, 40.764881), ## Carenegie Hall
            n = 150,
            addStartEnd = TRUE, 
            sp = TRUE
        ) %>% 
            leaflet() %>% 
            addTiles() %>% 
            addPolylines()
        

    })

})
