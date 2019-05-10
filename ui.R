
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
      ),
      wellPanel(
        "Table1",
        DT::dataTableOutput("Table1")
      )
    ),
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("tab 1", 
         fluidRow(
           column(width = 10, offset = 1,
                  leafletOutput("arcs", height = 400))
           )
         ),
        tabPanel("tab 2",
           fluidRow(
             column(width = 10, offset = 1,
                    leafletOutput("choropleth", height = 400))
           )
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

