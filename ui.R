
source("src.R")

fluidPage(
  theme = shinytheme("darkly"),
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
  
  # Possible content for modal dialog commented out
  # HTML(
  #   paste(
  #     "<p>So goes <a href = 'https://www.carnegiehall.org/Blog/2016/04/The-Joke'>'The Joke'</a>",
  #     "familiar to musicians across the world.",
  #     "Attributed to multiple people, its definitive origin story remains a mystery.</p>"
  #   )
  # ),
  # 
  # HTML(
  #   paste(
  #     "<p>This <a href = 'https://shiny.rstudio.com'>Shiny application</a>",
  #     "demonstrates how far each of the >8000 individual performers have traveled to grace",
  #     "the stage at <a href = 'https://www.carnegiehall.org'>Carnegie Hall</a>"
  #     
  #   )
  # ),
  
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
        DT::dataTableOutput("Table1", height = 580)
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
          title = "Instrument", width = 4,
          plotOutput("instrument_tree", height = 200)
          ),
        box(
          title = "Birth year", width = 4,
          plotOutput("time_hist", height = 200)
          ),
        box(
          title = "Role", width = 4,
          plotOutput("role_tree", height = 200)
        )
      )
    )
  )
)
