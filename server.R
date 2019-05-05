
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
  
  # Arc map display set-up ------------------------------------------------------
  
  output$arcs <- renderLeaflet({
    leaflet(m) %>% 
    addPolygons(layerId = ~region,
                fillColor = ~pal(region),
                fillOpacity = .2,
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
    # rv$bbox <- 
    print(st_bbox(rv$cont_arc_lines))
    
    # a hack for over-plotting arcs (multiple performers same city)
    alphas <- rv$cont_counts$n / max(rv$cont_counts$n)
    
    print(class(
      st_as_sf(rv$cont_arc_lines)
    ))
    
    leafletProxy("arcs", session, data = st_as_sf(rv$cont_arc_lines)) %>%
      # must use 'group' not 'layerId'/removeShape()
      clearGroup("lines") %>%
       addPolylines(
         group = "lines",
         color = pal(input$continent),
         weight = log(rv$cont_counts$n),
         opacity = ifelse(alphas < .5, .5, alphas)
         )
  })
  
  #  output$continent_arcs <- renderLeaflet({
  #    
  #    alphas <- rv$cont_counts$n / max(rv$cont_counts$n)
  #    
  #    leaflet(rv$cont_arc_lines,
  #            # options = leafletOptions(
  #            #   minZoom = 1)
  #            ) %>%
  #      # addProviderTiles(
  #      #   provider = "OpenStreetMap.BlackAndWhite",
  #      #   options = providerTileOptions(noWrap = T)
  #      #   ) %>% 
  #      # addPolygons(data = m,
  #      #             layerId = ~region,
  #      #             fillColor = ~pal(region),
  #      #             fillOpacity = .2,
  #      #             color = ~pal(region)
  #      #             ) %>%
  #      # addPolylines(color = pal(input$continent),
  #      #              weight = log(rv$cont_counts$n),
  #      #              opacity = ifelse(alphas < .5, .5, alphas))
  # })

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
})
