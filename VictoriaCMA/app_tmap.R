# -------------------------
# code to get_census data ------------------------
# https://mountainmath.github.io/cancensus/reference/get_census.html
# code to select tmap variables ------------------------
# https://rdrr.io/cran/tmap/man/renderTmap.html
# code adapted - Wendy Anthony 2019-12-29

# libraries needed ------------------------
library("cancensus") # get_census
library("sf") # as_Spatial sp_Transform
library("tmap") # choropleth maps
library("shiny") # create interactive shiny app
library("leaflet") # create leaflet map

# download Victoria household census data 2016 ------------------------
victoria_house_census_data <- get_census(dataset='CA16', regions=list(CMA="59935"), vectors=c("v_CA16_2246", "v_CA16_408","v_CA16_409","v_CA16_410","v_CA16_417","v_CA16_418","v_CA16_419","v_CA16_420","v_CA16_421","v_CA16_422","v_CA16_423","v_CA16_424","v_CA16_425"), level='CSD', geo_format = "sf", labels="short")

# download with no vectors --------------------------
victoria_house_census_data_simple <- get_census(dataset='CA16', regions=list(CMA="59935"), level='CSD', geo_format = "sf", labels="short")
head(victoria_house_census_data_simple)

class(victoria_house_census_data)
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
names(victoria_house_census_data) [21] <- "One_person_household"
names(victoria_house_census_data) [22] <- "Two_persons_household"
names(victoria_house_census_data) [23] <- "Three_persons_household"
names(victoria_house_census_data) [24] <- "Four_person_household"
names(victoria_house_census_data) [25] <- "Five_or_more_persons_household"
names(victoria_house_census_data) [26] <- "Household_size_number_persons"
names(victoria_house_census_data) [27] <- "Avg_household_size"

# check to see renamed columns ------------------------
head(victoria_house_census_data)
colnames(victoria_house_census_data) 
names(victoria_house_census_data)

# spatial transorm & reproject ------------------------
victoria_house_census_data_sp <- as_Spatial(victoria_house_census_data)
vic_cens <- spTransform(victoria_house_census_data_sp, CRS("+init=epsg:3005")) # bc albers
names(vic_cens)
class(vic_cens)

# set a variable for column names ------------------------
# this seems to be including all columns - use y value to list columns to get omitted
vic_cens_var <- setdiff(names(vic_cens), c("Type","GeoUID",  "PR_UID", "CD_UID", "CMA_UID", "name"))

# User interface ----------------------------------
ui <- fluidPage(
  titlePanel("Victoria CMA 2016 Census Household Visualization"),
    tmapOutput("map"),
  br(), # space between map and selectInput
    selectInput("var", "Choose a Variable to Map", vic_cens_var, selected = "Total_income")
  )

# Server logic ------------------------
# runs each time user visits/interacts with app, this is rendered
server <- function(input, output, session) {
  
  # reactive object
  output$map <- renderTmap({
    # choropleth map variable
    tm_shape(vic_cens) + 
      tm_scale_bar(width = 0.22, position = c("LEFT", "BOTTOM")) + 
      tm_polygons(vic_cens_var[1], alpha = 0.5, palette = "viridis", zindex = 401)
      })
  observe({
    var <- input$var
    tmapProxy("map", session, {
      tm_remove_layer(401) +
        tm_shape(vic_cens) + 
        tm_scale_bar(width = 0.22, position = c("LEFT", "BOTTOM")) + 
        tm_polygons(var, alpha = 0.5, palette = "viridis", zindex = 401)
    })
  })
}

# run once when app is launched ------------------------
shinyApp(ui, server)

# ------------------------
