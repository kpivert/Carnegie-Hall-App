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
  

# Modal -------------------------------------------------------------------

  modal_func <- function() {
    modalDialog(
        HTML(
          "<p>So goes <a href = 'https://www.carnegiehall.org/Blog/2016/04/The-Joke'>'The Joke'</a>",
          "familiar to musicians across the world.",
          "Attributed to multiple people, its definitive origin story remains a mystery.",
          "<br>",
          "<p>This <a href = 'https://shiny.rstudio.com'>Shiny application</a>",
          "demonstrates how far each of the >8000 individual performers have traveled to grace",
          "the stage at <a href = 'https://www.carnegiehall.org'>Carnegie Hall</a>.</p>",
          "<br>",
          "<p>Using data from the <a href = 'https://github.com/CarnegieHall/linked-data'>Carnegie Hall Database</a>", 
          "you can explore past performers by their continent of birth by clicking in the sidebar map.",
          "Search the sidebar table to find a specific performer and click on",
          "available Online Resources to learn more about their journey.</p>"
        ),
        easyClose = TRUE
    )
  }
  
  showModal(modal_func())
 
  observeEvent(input$info_btn, { showModal(modal_func()) })

# Input Select Map --------------------------------------------------------
  
  # Input Map ---------------------------------------------
  
  output$selectmap <- renderLeaflet({

    leaflet(
      m,
      options = leafletOptions(
        zoomControl = FALSE,
        dragging = FALSE,
        minZoom = 0,
        maxZoom = 0)
    ) %>%
      addPolygons(
        layerId = ~region,
        fillColor = ~pal(region),
        fillOpacity = 1,
        color = "black",
        stroke = F,
        highlight = highlightOptions(
          fillOpacity = .5,
          bringToFront = TRUE)
      )
  })
  
  observe({
    
    click <- input$selectmap_shape_click
    
    if (is.null(click)) return()
    
    updateSelectizeInput(
      session, 
      "continent",
      selected = click$id)
    
  })
  
  # Respond to Input -------------------------------------------------
  
  observeEvent(
    c(input$continent, input$main_tabs), {
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
        count(lat, lon, ch_lat, ch_lon, birthPlaceName, sort = T) %>% 
        mutate(label = paste0(birthPlaceName, ": ", n))
      
      rv$instrument_counts <- rv$cont_dat %>%
        left_join(instruments) %>%
        replace_na(list(inst = "none")) %>%
        count(inst, sort = T)
      
      rv$role_counts <- rv$cont_dat %>%
        left_join(roles) %>%
        replace_na(list(role = "instrumentalist")) %>%
        count(role, sort = T)
      
    })

# * Tab 1: Arc Map --------------------------------------------------------
  
  # initialize baseMap
  output$arcs <- renderMapdeck({
    mapdeck(
      token = key) %>%
      add_arc(
        data = as.data.frame(dat),
        layer_id = "arc_layer3",
        origin = c("from_lon", "from_lat"),
        destination = c("to_lon", "to_lat"),
        stroke_from = "from_color",
        stroke_to = "ch_color",
        tooltip = "tooltip"
      )
  })
  
  observe({
    
    centroids_cont <- filter(centroids, continent == input$continent)
    
    mapdeck_update(map_id = "arcs") %>%
      mapdeck_view(
        location = c(centroids_cont$lon, centroids_cont$lat), 
        zoom = 2, 
        duration = 3000,
        transition = "fly"
      ) 
    
  })
  
# * Tab 2: Choropleth -----------------------------------------------------
  
  # initialize baseMap
  output$choropleth <- renderMapdeck({
    
    mapdeck(
      token = key,
      pitch = 20
    ) %>% 
      add_polygon(
        data = choro_dat,
        layer = "polygon_layer",
        fill_colour = "mapcolor13",
        elevation = "n",
        tooltip = "tooltip"
      )
    
  })
  
  observe({
    
    centroids_cont <- filter(centroids, continent == input$continent)
    
    mapdeck_update(map_id = "choropleth") %>%
      mapdeck_view(
        location = c(centroids_cont$lon, centroids_cont$lat), 
        zoom = 2, 
        duration = 3000,
        transition = "fly"
      ) 
    
  })

  # Data Table --------------------------------------------------------------
  
  output$Table1 <- DT::renderDT({
    dat %>% 
      filter(region %in% input$continent) %>% 
      distinct(name, .keep_all = TRUE) %>% 
      select(Name = name, Country = ISO_Country, `Online Resource`) %>% 
      datatable(
        options = list(
          paging = FALSE
          ),
        rownames = FALSE,
        escape = FALSE,
        fillContainer = TRUE
        ) %>% 
      formatStyle(
        color = "#000000",
        columns = c("Name", "Country")
        ) %>% 
      formatStyle(
        color = "#F7002B",
        columns = "Online Resource"
      )
  })
  
  # output$Table1 <- DT::renderDataTable({
  #   dat %>% 
  #     filter(region %in% input$continent) %>%
  #     select(Name = name, Role = role, Country = ISO_Country, `Online Resource`)
  # },
  # options = list(
  #   paging = FALSE,
  #   color = "red",
  #   backgroundColor = "black"),
  # rownames = FALSE,
  # escape = FALSE,
  # fillContainer = TRUE)
  
  # Fluid Row Plots ---------------------------------------------------------

  output$time_hist <- renderPlotly({
    p <- ggplot(rv$cont_dat, aes(birth_year)) +
      geom_histogram(aes(fill = ..count..), show.legend = FALSE) + 
      scale_x_continuous(limits = c(1800, NA)) +
      theme_minimal() +
      labs(x = NULL, y = NULL)
    ggplotly(p, tooltip = c("fill", "x")) %>% 
      config(displayModeBar = F)
  })
  
  output$instrument_tree <- renderPlotly({
    d3Treemap(rv$instrument_counts, "inst")
  })
  
  output$role_tree <- renderPlotly({
    d3Treemap(rv$role_counts, "role")
  })
  
})
  
  