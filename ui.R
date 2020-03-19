
source("src.R")

shinyUI(fluidPage(
  theme = shinytheme("darkly"),
  # tags$head(HTML('<link href="https://fonts.googleapis.com/css?family=Neuton&display=swap" rel="stylesheet">')),
  # tags$head(HTML("<style>* {font-size: 100%; font-family: 'Neuton', serif;}</style>")),
  # Application title
  titlePanel("How did they get to Carnegie Hall?"),
  h1("Practice, Practice, Practice"),
  HTML(
    paste(
      "<p>So goes <a href = 'https://www.carnegiehall.org/Blog/2016/04/The-Joke'>'The Joke'</a>",
      "familiar to musicians across the world.",
      "Attributed to multiple people, its definitive origin story remains a mystery.</p>"
    )
  ),
  HTML(
    paste(
      "<p>This <a href = 'https://shiny.rstudio.com'>Shiny application</a>",
      "demonstrates how far each of the >8000 individual performers have traveled to grace",
      "the stage at <a href = 'https://www.carnegiehall.org'>Carnegie Hall</a>"
      
    )
  ),
  
  
  # Show a plot of the generated distribution
  mainPanel(
    tabsetPanel(
      tabPanel(
        "Routes To Carnegie Hall",
        deckglOutput(
          "arc_map", 
          width = "100%", 
          height = "800px"
        )
      ),
      # tabPanel(
      #   "Scatter",
      #   deckglOutput(
      #     "scatter_map",
      #     width = "100%",
      #     height = "800px"
      #   )
      # ),
      tabPanel(
        "Performer Density",
        deckglOutput(
          "hex_map",
          width = "100%",
          height = "800px"
        )
      ),
      tabPanel(
        "Continents",
        fluidRow(
          column(
            4,
            wellPanel(
              h4("Continent:"),
              leafletOutput("selectmap", height = 200),
              selectizeInput(
                inputId = "continent",
                label = NULL,
                choices = m$region,
                selected = NULL
              ),
              plotOutput(
                "top_instruments"
              )
            )
          ),
          column(
            8,
            deckglOutput(
              "filtered-map",
              width = "auto",
              height = "800px"
            )
          )
        )
      ), 
      tabPanel(
        "Performers",
        fluidRow(
          column(
            5,
            wellPanel(
              h4("Performer"),
              selectizeInput(
                inputId = "name",
                label = NULL,
                choices = sort(dat$name),
                selected = NULL
              ),
              verbatimTextOutput(
                outputId = "performer-info"
              ),
              textOutput(
                outputId = "performer-birthplace"
              ),
              DT::dataTableOutput("table_2")
            )
          ),
          column(
            7,
            deckglOutput(
              "name_map",
              width = "auto",
              height = "800px"
            )
          )
        )
      ),
      tabPanel(
        "Detail Table",
        fluidPage(
          wellPanel(
          h4("Performer:"),
          selectInput(
                inputId = "performer",
                label = "Performer",
                choices = c(
                  "All",
                  unique(dat$name)
                  )
                )
          ),
            # selectInput(
            #     inputId = "role",
            #     label = "Role",
            #     choices = c(
            #       # "All",
            #       unique(dat$role) %>% str_to_title()
            #     )
            #   ),
            # selectInput(
            #     inputId = "instrument",
            #     label = "Instrument",
            #     choices = c(
            #       # "All",
            #       unique(dat$inst) %>% str_to_title()
            #     )
            # ),
          
            DT::dataTableOutput("table_1")
          )
        )
      )
    )
  )
)

