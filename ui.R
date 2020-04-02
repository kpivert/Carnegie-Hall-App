
source("src.R")

fluidPage(
  theme = shinytheme("paper"),
  tags$head(
    tags$style(HTML(".leaflet-container { background: #fff; }"))
  ),
  tags$head(
    HTML(
      '<link href="https://fonts.googleapis.com/css?family=Neuton&display=swap" rel="stylesheet">'
      )
    ),
  HTML("<h1>How did they get to <span style='color:#F7002B; font-family:Neuton; font-size:140%'>Carnegie Hall</span>?</h1>"),
  h1("Practice, Practice, Practice"),

  sidebarLayout(
    sidebarPanel(
      actionButton("info_btn", "App Info", icon = icon("help")),
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
        DT::DTOutput("Table1", height = 580)
      )
    ),
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        id = "main_tabs",
        tabPanel(
          "Arcs",
          fluidRow(
            column(
              width = 10, 
              offset = 1,
              mapdeckOutput("arcs", height = 400)
              )
            )
          ),
        tabPanel(
          "Choropleth",
          fluidRow(
            column(
              width = 10, 
              offset = 1,
              mapdeckOutput("choropleth", height = 400)
              )
            )
          )
      ),
      br(),
      fluidRow(
        box(
          title = "Instrument", width = 6,
          plotlyOutput("instrument_tree", height = 300)
          ),
        box(
          title = "Role", width = 6,
          plotlyOutput("role_tree", height = 300)
        )
      ),
      fluidRow(
        box(
          title = "Birth year", width = 12,
          plotlyOutput("time_hist", height = 200)
        )
      )
    )
  )
)
