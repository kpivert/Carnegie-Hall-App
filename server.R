
source("src.R")
pal <- colorFactor(scales::hue_pal()(6), m$region)

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
  
  # Arc map ------------------------------------------------------------
  
  output$arcs <- renderLeaflet({
    leaflet(m) %>% 
    addPolygons(layerId = ~region,
                fillColor = ~pal(region),
                fillOpacity = .2,
                color = ~pal(region)
    )
  })
  
  
# Choropleth Map -----------------------------------------------

  output$choropleth <- renderLeaflet({
    leaflet(m) %>% 
      addPolygons(
        layerId = ~region,
        fillColor = ~pal(region),
        fillOpacity = 0,
        color = ~pal(region)
      )
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

    # * data prep ----------------------------------------
    
    rv$cont_dat <- filter(dat, region %in% input$continent)
    
    rv$loc_counts <-  rv$cont_dat %>%
      mutate(ch_lat = rep(40.764881, nrow(.))) %>%
      mutate(ch_lon = rep(-73.980276, nrow(.))) %>% 
      count(lat, lon, ch_lat, ch_lon, birthPlaceName, sort = T) %>% 
      mutate(label = paste0(birthPlaceName, ": ", n))
    
    rv$loc_arc_lines <-  gcIntermediate(
      rv$loc_counts[c('lon', 'lat')],
      rv$loc_counts[c('ch_lon', 'ch_lat')], 
      n = 50,
      breakAtDateLine = T,
      addStartEnd = TRUE,
      sp = TRUE ) %>% 
      st_as_sf() %>% 
      bind_cols(rv$loc_counts) %>% 
      mutate(thick = n / max(n) * 15,
             thick = case_when(thick < 1 ~ 1,
                               TRUE ~ thick),
             alpha = n / max(n), # deal with over-plotting arcs (multiple performers same city)
             alpha = case_when(alpha < .3 ~ .3,
                               alpha > .6 ~ .6,
                               TRUE ~ alpha)) %>% 
      arrange(thick)
    
    # chloropleth data
    rv$country_dat <- rv$cont_dat %>% 
      count(region, iso_country = ISO_Country) %>% 
      inner_join(countries, .) %>%
      select(region, name, n) %>%
      ungroup() %>% 
      mutate(alpha = n / max(n),
             alpha = case_when(alpha < .1 ~ .1,
                               alpha >.9 ~ .9,
                               TRUE ~ alpha),
             label = paste0(name, ": ", n))
    
    rv$instrument_counts <- rv$cont_dat %>%
      left_join(instruments) %>%
      replace_na(list(inst = "none")) %>%
      count(inst, sort = T)
    
    rv$role_counts <- rv$cont_dat %>%
      left_join(roles) %>%
      replace_na(list(role = "instrumentalist")) %>%
      count(role, sort = T)
    
    # * update leaflets -------------------------------------------------------

    # a single bounding box for zooming (same on both maps)
    bbox <- fitBounds_bbox(rv$country_dat)
    
    leafletProxy("arcs", session) %>%
      # must use 'group' not 'layerId'/removeShape()
      clearGroup("lines") %>%
       addPolylines(
         data = rv$loc_arc_lines,
         group = "lines",
         color = pal(input$continent),
         weight = ~thick,
         opacity = ~alpha,
         label = ~label
         ) %>%
      fitBounds(lng1 = bbox[1], 
                lat1 = bbox[2],
                lng2 = bbox[3],
                lat2 = bbox[4])
    
    leafletProxy("choropleth", session, data = rv$country_dat) %>%
      clearGroup("choro") %>%
      addPolygons(
        group = "choro",
        color = pal(input$continent),
        fillOpacity = ~alpha,
        label = ~label
      ) %>% 
      fitBounds(lng1 = bbox[1], 
                lat1 = bbox[2],
                lng2 = bbox[3],
                lat2 = bbox[4])
  })

  # Data Table --------------------------------------------------------------
  
  output$Table1 <- DT::renderDataTable({
    dat %>% 
      filter(region %in% input$continent) %>%
      select(Name = name, Role = role, Country = ISO_Country, `Online Resource`)
  },
  options = list(paging = FALSE),
  rownames = FALSE,
  escape = FALSE,
  fillContainer = TRUE)
  
  # Fluid Row Plots ---------------------------------------------------------
  
  output$instrument_bubble <- renderPlotly({
    dat <- rv$instrument_counts
    p <- gg_circlepack(dat, "inst")
    
    ggplotly(p, tooltip = c("text")) %>%
      config(displayModeBar = F)
  })
   
  output$role_bubble <- renderPlotly({
   dat <- rv$role_counts
   p <- gg_circlepack(dat, "role")
   
   ggplotly(p, tooltip = c("text")) %>%
     config(displayModeBar = F)
  })

})
