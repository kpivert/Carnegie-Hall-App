
source("src.R")

fluidPage(
  tags$head(
    tags$style(HTML(".leaflet-container { background: #fff; }"))
  ),
  titlePanel("Carnegie Hall Performance Explorer"),
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        h4("Continent:"),
        leafletOutput("selectmap", height = 200),
        selectizeInput(
          inputId = "continent",
          label = NULL,
          choices = m$region,
          selected = NULL
        )
      )
    ),
    # Show a plot of the generated distribution
    mainPanel(
      fluidRow(
        column(width = 10, offset = 1,
          leafletOutput("continent_arcs", height = 400)
          # leafletOutput("home_city")
        )
      ),
      br(),
      fluidRow(
        box(plotlyOutput("instrument_bubble"),
            title = "Instrument"),
        box(plotlyOutput("role_bubble"),
            title = "Role")
      )
    )
  )
)
