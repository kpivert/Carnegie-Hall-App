# * Source Functions and Data ---------------------------------------------

source("src.R")


# * Continent Colors ------------------------------------------------------

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


# * Server  ---------------------------------------------------------------

shinyServer(function(input, output, session) {
  
  rv <- reactiveValues()
  
# * Tab 1: Arc Map of Entire Dataset --------------------------------------

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
      zoom = 2, 
      pitch = 0
    ) %>% 
      add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9") %>%   
      add_arc_layer(
        data = dat,
        id = 'arc-layer',
        properties = properties
      )
  })
  

# * Tab 2: Scatterplot ----------------------------------------------------
  
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
      zoom = 3, 
      pitch = 0
    ) %>% 
      add_scatterplot_layer(
        data = dat, 
        properties = properties
      ) %>% 
      add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9")
    
  })
  

# * Tab 3: Hex Map --------------------------------------------------------

  output$hex_map <- renderDeckgl({
    
    properties <- list(
      extruded = TRUE,
      radius = 10000,
      elevationScale = 4,
      getPosition = get_position("from_lat", "from_lon"),
      getTooltip = JS("object => `${object.centroid.join(', ')}<br/>Count: ${object.points.length}`"),
      fixedTooltip = TRUE
    )
    
    deckgl(
      latitude = 40.7,
      longitude = -74,
      zoom = 2, 
      pitch = 0
    ) %>%
      add_hexagon_layer(data = dat, properties = properties) %>%
      add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9")
  })
  

# * Tab 4: Filtered by Continent ------------------------------------------

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
  
  # Output DeckGL Continent Specific  -------------------------------
  
  
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
        # latitude = 40.7,
        # longitude = -74,
        latitude = 38,
        longitude = -105,
        # latitude = rv$map_dat$cont_lat,
        # longitude = rv$map_dat$cont_lon,
        zoom = 1,
        pitch = 3
      ) %>%
        add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9") %>%
        add_arc_layer(
          data = rv$map_dat,
          id = 'arc-layer',
          properties = properties
        )
    })
    
    output$top_instruments <- renderPlot(
      ggplot(
        rv$map_dat %>% 
          filter(!is.na(inst)) %>% 
          count(inst) %>% 
          arrange(desc(n)) %>% 
          slice(1:10), 
        aes(
          x = reorder(inst, n),
          y = n
          # fill = rv$map_dat$from_color
        )
      ) +
        geom_col(
          width = .5,
          fill = "#F7002B"
        ) +
        coord_flip() +
        # theme_ft_rc()
        theme_dark()
    )
    
    
  })

# * Tab 5: Detail Table ---------------------------------------------------

  # output$table_1 <- DT::renderDataTable(DT::datatable({
  #   data <- dat %>% 
  #     select(
  #       Name = name, 
  #       `Birth Place` = birthPlaceName,
  #       `Birth Date` = birthDate,
  #       `Online Resource`,
  #       Instruments = inst
  #     )
  #   if (input$performer != "All") {
  #     data <- data[data$Name == input$performer, ]
  #   } 
  #   
  #   # 
  #   # if (input$role != "All") {
  #   #   data <- data[data$role == input$role, ]
  #   # }
  #   # if (input$instrument != "All") {
  #   #   data <- data[data$instrument == input$instrument, ]
  #   # }
  #   data  
  #   }, 
  #   options = list(
  #     initComplete = JS(
  #       "function(settings, json) {",
  #       "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
  #       "}")
  #   ),
  #   rownames = FALSE,
  #   escape = FALSE
  #   # fillContainer = TRUE
  # ))
  
  output$table_1 <- renderDT({
    data <- dat %>% 
      select(
        Name = name, 
        `Birth Place` = birthPlaceName,
        `Birth Date` = birthDate,
        `Online Resource`,
        Instruments = inst, 
        Role = role
      )
    if (input$performer != "All") {
      data <- data[data$Name == input$performer, ]
    } 
    
    # 
    # if (input$role != "All") {
    #   data <- data[data$role == input$role, ]
    # }
    # if (input$instrument != "All") {
    #   data <- data[data$instrument == input$instrument, ]
    # }
    data  
  }, 
  options = list(
    initComplete = JS(
      "function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
      "}")
  ),
  rownames = FALSE,
  escape = FALSE
  # fillContainer = TRUE
  )
  

# * Tab 6: Filtered by Performer ------------------------------------------

  observeEvent(input$name, {
    
    rv$name_dat <- filter(dat, name %in% input$name) 
    
    output$`name_map` <- renderDeckgl({
      
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
        # latitude = 40.7,
        # longitude = -74,
        latitude = rv$name_dat$from_lat,
        longitude = rv$name_dat$from_lon,
        zoom = 5,
        pitch = 0
      ) %>%
        add_mapbox_basemap(style = "mapbox://styles/mapbox/dark-v9") %>%
        add_arc_layer(
          data = rv$name_dat,
          id = 'arc-layer',
          properties = properties
        )
    
  })
  
  # output$text2 <- renderUI({
  #     HTML(paste("hello", "world", sep="<br/>"))
  #   })
        
  output$`performer-info` <- renderText({
    
      glue::glue("
               
               Birthplace: {rv$name_dat$birthPlaceName} 
               
               Birthdate: {rv$name_dat$birthDate} 
               
               Instrument(s): {rv$name_dat$inst} 
               
               Role: {rv$name_dat$role}
               
               ") 
        
    })
  
  # output$`performer-info` <- renderText(
  #   glue::glue("
  #              
  #              Birthplace: {rv$name_dat$birthPlaceName} \n
  #              
  #              Birthdate: {rv$name_dat$birthDate}
  #              
  #              Instrument(s): {rv$name_dat$inst} 
  #              
  #              Role: {rv$name_dat$role}
  #              
  #              ") 
  # )
  
  performer_birth_place <- unique(rv$name_dat$birthPlaceName)
  
  output$`performer-birthplace` <- renderText(
    glue::glue("
               
               Also from: {performer_birth_place}
               
               ")
  )
  
  output$table_2 <- renderDT({
    dat %>%
      filter(
        birthPlaceName %in% rv$name_dat$birthPlaceName,
        name != rv$name_dat$name
        ) %>%
      distinct(name, .keep_all = TRUE) %>% 
      select(
        Name = name,
        `Online Resource`,
        Instruments = inst
      )
    },
      filter = "none",
    options = list(
      dom = "t"
      # initComplete = JS(
      #   "function(settings, json) {",
      #   "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
      #   "}")
      ),
    rownames = FALSE,
    escape = FALSE
    # fillContainer = TRUE

  )
  
})
  
})