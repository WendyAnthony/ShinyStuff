# http://www.baoruidata.com/examples/082-word-cloud/

fluidPage(
  # Application title
  titlePanel("Word Cloud"),
  
  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      selectInput("selection", "Choose a book:",
                  choices = books),
      actionButton("update", "Change"),
      hr(),
      sliderInput("freq",
                  "Minimum Frequency:",
                  min = 1,  max = 100, value = 35),
      sliderInput("max",
                  "Maximum Number of Words:",
                  min = 1,  max = 500,  value = 200)
#      ,
      # https://gallery.shinyapps.io/016-knitr-pdf/
#      radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
#                   inline = TRUE),
#      downloadButton('downloadReport')
    ),
    
    # Show Word Cloud
    mainPanel(
      plotOutput("plot", height = "600px")
    )
  )
)