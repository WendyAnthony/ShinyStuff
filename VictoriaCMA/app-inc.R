# https://shiny.rstudio.com/tutorial/written-tutorial/lesson5/
# https://mountainmath.github.io/cancensus/reference/get_census.html

# libraries needed ------------------------
library("cancensus") # get_census
library("sf") # as_Spatial sp_Transform
library("tmap") # choropleth maps
library("shiny") # create interactive shiny app
library("leaflet") # create leaflet map

# download Victoria household census data 2016 ------------------------
victoria_house_census_data <- get_census(dataset='CA16', regions=list(CMA="59935"), vectors=c("v_CA16_2246", "v_CA16_408","v_CA16_409","v_CA16_410","v_CA16_417","v_CA16_418","v_CA16_419","v_CA16_420","v_CA16_421","v_CA16_422","v_CA16_423","v_CA16_424","v_CA16_425"), level='CSD', geo_format = "sf", labels="short")

# find index number for each column ------------------------
head(victoria_house_census_data)
colnames(victoria_house_census_data) 

# rename columns ------------------------
names(victoria_house_census_data) [15] <- "Total_income"
names(victoria_house_census_data) [16] <- "Occupied_private_dwelling"
names(victoria_house_census_data) [17] <- "Occupied_single_detached_house"
names(victoria_house_census_data) [18] <- "Apt_build_greater_than_5_stories"
names(victoria_house_census_data) [19] <- "Moveable_dwelling"
names(victoria_house_census_data) [20] <- "Private_households"
names(victoria_house_census_data) [21] <- "1_person_household"
names(victoria_house_census_data) [22] <- "2_persons_household"
names(victoria_house_census_data) [23] <- "3_persons_household"
names(victoria_house_census_data) [24] <- "4_person_household"
names(victoria_house_census_data) [25] <- "5_or_more_persons_household"
names(victoria_house_census_data) [26] <- "Household_size_number_persons"
names(victoria_house_census_data) [27] <- "Avg_household_size"

# check to see renamed columns ------------------------
head(victoria_house_census_data)
colnames(victoria_house_census_data) 

# spatial transorm & reproject ------------------------
victoria_house_census_data_sp <- as_Spatial(victoria_house_census_data)
vic_cens <- spTransform(victoria_house_census_data_sp, CRS("+init=epsg:3005")) # bc albers

# User interface ----------------------------------
ui <- fluidPage(
  titlePanel("Victoria CMA 2016 Income Census Viz"),
    
#  sliderInput(inputId = "Total_income", "Total Income", 230, 96355, value = 21000),
  
    mainPanel(leafletOutput("map"))
  )

# Server logic ------------------------
# runs each time user visits/interacts with app, this is rendered
server <- function(input, output) {
  
  # reactive object
  output$map <- renderLeaflet({
      
    # choropleth map variable
    map <- tm_shape(vic_cens) +
      tm_polygons(col = "Total_income",
                  alpha = 0.5, 
                  title = "Total Income",
                  style = "fisher", 
                  palette = "viridis", n = 6,
                  border.col = "grey", 
                  border.alpha = 0.05) + 
      tm_compass(position = c("LEFT", "BOTTOM")) + 
      tm_scale_bar(width = 0.22, position = c("LEFT", "BOTTOM")) + 
      # add compass
      tm_layout(title = " Victoria CMA Total Income 2016", title.position = c("LEFT", "TOP"), inner.margins = c(.08, .03, .08, .03), legend.outside = TRUE, legend.outside.position = "left")
    # can't seem to get tmap to show plot mode vs view, and to have legend outside the plot
    
tmap_leaflet(map)
  })
}

# run once when app is launched ------------------------
shinyApp(ui, server)
