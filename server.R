
source("src.R")
pal <- colorFactor(scales::hue_pal()(6), m$region)

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
  
  # Arc display ------------------------------------------------------------
  
  output$arcs <- renderLeaflet({
    leaflet(m) %>% 
    addPolygons(layerId = ~region,
                fillColor = ~pal(region),
                fillOpacity = .2,
                color = ~pal(region)
    )
  })
  
  
# Choropleth Map ----------------------------------------------------------

  ## Base Map
  output$choropleth <- renderLeaflet({
    leaflet(m) %>% 
      addPolygons(
        layerId = ~region,
        fillColor = ~pal(region),
        fillOpacity = 0,
        color = ~pal(region)
      )
  })
  

  # Map selector ------------------------------------------------------------
  
  output$selectmap <- renderLeaflet({
    
    leaflet(m,
            options = leafletOptions(
              zoomControl = FALSE,
              dragging = FALSE,
              minZoom = 0,
              maxZoom = 0)
    ) %>%
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
  
  # Respond to input --------------------------------------------------------

  observeEvent(input$continent, {
    leafletProxy("selectmap", session) %>%
      removeShape("selected") %>% 
      addPolylines(data = filter(m, region == input$continent),
                   layerId = "selected",
                   color = "black",
                   weight = 3)
    
    rv$cont_dat <- filter(dat, region %in% input$continent)
    
    rv$cont_counts <-  rv$cont_dat %>%
      mutate(ch_lat = rep(40.764881, nrow(.))) %>%
      mutate(ch_lon = rep(-73.980276, nrow(.))) %>% 
      count(lat, lon, ch_lat, ch_lon, sort = T)
    
    rv$cont_arc_lines <-  gcIntermediate(
      rv$cont_counts[c('lon', 'lat')],
      rv$cont_counts[c('ch_lon', 'ch_lat')], ## Carnegie Hall Data Must Be Added to Feather File
      n = 50,
      breakAtDateLine = T,
      addStartEnd = TRUE,
      sp = TRUE )
    
    rv$instrument_counts <- rv$cont_dat %>%
      inner_join(instruments) %>%
      count(inst, sort = T)
    
    rv$role_counts <- rv$cont_dat %>%
      inner_join(roles) %>%
      count(role, sort = T)
    
    # simulate a bounding box for zooming
    rv$bbox <- c(min(rv$cont_counts$lon),
                 min(rv$cont_counts$lat),
                 max(rv$cont_counts$lon),
                 max(rv$cont_counts$lat))
  
    # a hack for over-plotting arcs (multiple performers same city)
    alphas <- rv$cont_counts$n / max(rv$cont_counts$n)
    
    leafletProxy("arcs", session, data = rv$cont_arc_lines) %>%
      # must use 'group' not 'layerId'/removeShape()
      clearGroup("lines") %>%
       addPolylines(
         group = "lines",
         color = pal(input$continent),
         weight = log(rv$cont_counts$n),
         opacity = ifelse(alphas < .5, .5, alphas)
         ) %>%
      # zoom to bounding box
      fitBounds(lng1 = rv$bbox[1],
                  lat1 = rv$bbox[2],
                  lng2 = rv$bbox[3],
                  lat2 = rv$bbox[4])
    
  })

  # Data Table --------------------------------------------------------------
  
  output$Table1 <- DT::renderDataTable({
    dat %>% 
      filter(region %in% input$continent) %>%
      select(Name = name, Role = role, Country = ISO_Country, `Online Resource`)
    
    
  },
  escape = FALSE)
  
  
  # Fluid Row Plots ---------------------------------------------------------
  
  output$instrument_bubble <- renderPlotly({
    dat <- rv$instrument_counts
    p <- gg_circlepack(dat, "inst")
    
    ggplotly(p, tooltip = c("label", "size")) %>%
      config(displayModeBar = F)
  })
   
  output$role_bubble <- renderPlotly({
   dat <- rv$role_counts
   p <- gg_circlepack(dat, "role")
   
   ggplotly(p, tooltip = c("label", "size")) %>%
     config(displayModeBar = F)
  })


# Choropleth --------------------------------------------------------------

 observeEvent(input$continent, {
   
   rv$cont_dat_1 <- filter(dat, region %in% input$continent)

   ## 00: Subset Dataset, Make Counts and Hover Text
   rv$choropleth_counts <- 
     rv$cont_dat_1 %>%
     group_by(ISO_Country, region) %>%
     count() %>%
     select(
       ISO_A2 = ISO_Country,
       region,
       Number = n
     ) %>%
     ungroup() %>% 
     left_join(
       world,
       .
     ) %>% 
     mutate(
       Number = if_else(is.na(Number), 0, as.double(Number)),
       Hover = paste(
         NAME_EN,
         "Number of Performers: ",
         Number
       )
     ) %>% 
     select(
       region = CONTINENT, 
       Number,
       Hover, 
       NAME_EN,
       geometry
     )
     
   
   rv$cont_counts_1 <-  rv$cont_dat_1 %>%
     count(lat, 
           lon, 
           sort = TRUE
           ) 

   ## 02: Nate's Alpha hack

   alpha_choro <- rv$choropleth_counts$Number / max(rv$choropleth_counts$Number) * 10

   ## 03: Nate's Bounding Box
   
   rv$bbox_1 <- c(min(rv$cont_counts_1$lon),
                 min(rv$cont_counts_1$lat),
                 max(rv$cont_counts_1$lon),
                 max(rv$cont_counts_1$lat))

   ## 04: Leaflet Proxy for Choropleth
  
  leafletProxy("choropleth", session, data = rv$choropleth_counts) %>%
    # must use 'group' not 'layerId'/removeShape()
    clearGroup("choro") %>%
    addPolygons(
      group = "choro",
      color = pal(input$continent),
      fillOpacity = alpha_choro, #if_else(alpha_choro < .001, .025, alpha_choro),
      popup = ~Hover
     )  %>%
     # zoom to bounding box
     fitBounds(lng1 = rv$bbox_1[1],
               lat1 = rv$bbox_1[2],
               lng2 = rv$bbox_1[3],
               lat2 = rv$bbox_1[4])
  
})

})
