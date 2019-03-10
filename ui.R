
source("src.R")

fluidPage(
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
        leafletOutput("continent_arcs")
        # leafletOutput("home_city")
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
