
library(shiny)
library(sf)
library(leaflet)

# set working directory
#dir <- "/Users/wendyanthony/Documents/RStats/NeighbourhoodsSHP"
#setwd(dir)
#getwd()

# read shapefile
vicn <- st_read("Neighbourhoods.shp")

# transform projection to WGS84 latlong, needed for leaflet
vicn.wgs84 <- st_transform(vicn, 4326)
st_crs(vicn.wgs84)


# Define UI for application that draws a map
ui <- fluidPage(
   
   # Application title
   titlePanel("inputMap Victoria's Neighbourhoods"),
   
   # Sidebar
   sidebarLayout(
      sidebarPanel(
        leafletOutput("inputMap", height = 200)
      ),
      # Show a plot of the generated distribution
      mainPanel(
         dataTableOutput("filteredResults")
      )
   )
)

# Define server logic required 
server <- function(input, output, session) {
   rv <- reactiveValues()
   
   output$inputMap <- renderLeaflet({
     leaflet(vicn.wgs84, 
             options = leafletOptions(
               zoomControl = FALSE, # no zoom
               dragging = FALSE,
               minZoom = 6,
               maxZoom = 13) ) %>%
       addPolygons(
         layerId = ~Neighbourh,  
         label = ~Neighbourh,
         highlight = highlightOptions(
           color = "white",
           weight = 2,
           fillOpacity = 1,
           bringToFront = TRUE) )
   })

observeEvent(input$inputMap_shape_click, {
  click <- input$inputMap_shape_click
  req(click)
  
  rv$vicn.wgs84 <- filter(vicn.wgs84, Neighbourh == click$id)
  
  leafletProxy("inputMap", session, data = rv$vicn.wgs84) %>% 
    removeShape("selected") %>% 
    addPolygons(layerId = "selected",
                fillColor = "red",
                fillOpacity = 1)
})
output$filteredResults <- renderDataTable({
  if (is.null(rv$vicn.wgs84)){
    return(st_set_geometry(vicn.wgs84, NULL))
  } else {return(st_set_geometry(rv$vicn.wgs84, NULL))}
})
}

# Run the application 
shinyApp(ui = ui, server = server)

