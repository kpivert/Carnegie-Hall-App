
source("src.R")
pal <- colorFactor(
  c("#8F9DCB", 
    "#DBA8AF", 
    "#BF346B", 
    "#f9f6f7", 
    "#1DA3CA", 
    "#767969"
  ), 
  m$region
)

shinyServer(function(input, output, session) {
  
  rv <- reactiveValues()
  
  observeEvent(input$continent, {
    rv$map_dat <- filter(dat, region %in% input$continent) 
    
    output$`filtered-map` <- renderDeckgl({
      
      properties = list(
        pickable = TRUE,
        getStrokeWidth = 2,
        cellSize = 200,
        elevationScale = 4,
        getSourcePosition = get_position("from_lat", "from_lon"),
        getTargetPosition = get_position("to_lat", "to_lon"),
        getTargetColor = get_color_to_rgb_array("ch_color"),
        getSourceColor = get_color_to_rgb_array("from_color"),
        getTooltip = get_property("tooltip")
      )
      
      deckgl(
        latitude = 40.7,
        longitude = -74,
        zoom = 11,
        pitch = 0
      ) %>%
        add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9") %>%
        add_arc_layer(
          data = rv$map_dat,
          id = 'arc-layer',
          properties = properties
        )
    })
    
    
  })
  
  output$arc_map <- renderDeckgl({
    
    properties = list(
      pickable = TRUE,
      getStrokeWidth = 2,
      cellSize = 200,
      elevationScale = 4,
      getSourcePosition = get_position("from_lat", "from_lon"),
      getTargetPosition = get_position("to_lat", "to_lon"),
      getTargetColor = get_color_to_rgb_array("ch_color"),
      getSourceColor = get_color_to_rgb_array("from_color"),
      getTooltip = get_property("tooltip")
    )
    
    deckgl(
      latitude = 40.7,
      longitude = -74,
      zoom = 11, 
      pitch = 0
    ) %>% 
      add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9") %>%   
      add_arc_layer(
        data = dat,
        id = 'arc-layer',
        properties = properties
      )
  })
  
  output$scatter_map <- renderDeckgl({
    
    properties <- list(
      getPosition = get_position("from_lat", "from_lon"),
      getRadius = JS("data => Math.sqrt(data.exits)"),
      radiusScale = 1000,
      getColor = get_color_to_rgb_array("from_color"),
      getTooltip = get_property("tooltip")
    )
    
    deckgl(
      latitude = 40.7,
      longitude = -74,
      zoom = 11, 
      pitch = 0
    ) %>% 
      add_scatterplot_layer(
        data = dat, 
        properties = properties
      ) %>% 
      add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9")
    
  })
  
  output$hex_map <- renderDeckgl({
    
    properties <- list(
      extruded = TRUE,
      radius = 10000,
      elevationScale = 4,
      getPosition = get_position("from_lat", "from_lon"),
      getTooltip = JS("object => `${object.centroid.join(', ')}<br/>Count: ${object.points.length}`"),
      fixedTooltip = TRUE
    )
    
    deckgl() %>%
      add_hexagon_layer(data = dat, properties = properties) %>%
      add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9")
  })
  
  # Input Map ---------------------------------------------
  
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
  
  # Respond to Input -------------------------------------------------
  
  observeEvent(c(input$continent, input$main_tabs), {
    print("triggered Observe")
    leafletProxy("selectmap", session) %>%
      removeShape("selected") %>% 
      addPolylines(data = filter(m, region == input$continent),
                   layerId = "selected",
                   color = "black",
                   weight = 3)
    

    
  })    
  
  
})