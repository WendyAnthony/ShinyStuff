########################
#  used for shiny app  #
########################
## To update app > Run App in RStudio, then Republish ------------------------
## using normalized polygon data == divided by # households of each polygon

# ------------------------
# code to get_census data ------------------------
# https://mountainmath.github.io/cancensus/reference/get_census.html
# code to select tmap variables ------------------------
# https://rdrr.io/cran/tmap/man/renderTmap.html
# code adapted - Wendy Anthony 2019-12-29 / 2020-01-02

# libraries needed ------------------------
library("cancensus") # get_census
library("sf") # as_Spatial sp_Transform
library("tmap") # choropleth maps
library("shiny") # create interactive shiny app
library("leaflet") # create leaflet map
library("rgdal") # needed for spTransform

# set working directory ------------------------
#dir <- "/Users/wendyanthony/Documents/R/VicCensusApp"
#setwd(dir)
#getwd()

# Cancensus api key ------------------------
options(cancensus.api_key="CensusMapper_ec4999c4af76e21646476719765e0491")
#options(cancensus.cache_path = "/Users/wendyanthony/Documents/R/VicCensusApp")

# download Victoria household census data 2016 ------------------------
victoria_house_census_data <- get_census(dataset='CA16', regions=list(CMA="59935"), vectors=c("v_CA16_2246", "v_CA16_408","v_CA16_409","v_CA16_410","v_CA16_417","v_CA16_418","v_CA16_419","v_CA16_420","v_CA16_421","v_CA16_422","v_CA16_423","v_CA16_424","v_CA16_425"), level='CSD', geo_format = "sf", labels="short")

# download with no vectors --------------------------
# victoria_house_census_data_simple <- get_census(dataset='CA16', regions=list(CMA="59935"), level='CSD', geo_format = "sf", labels="short")
# head(victoria_house_census_data_simple)

class(victoria_house_census_data)
# find index number for each column ------------------------
head(victoria_house_census_data)
colnames(victoria_house_census_data) 
names(victoria_house_census_data)

# rename columns ------------------------
names(victoria_house_census_data) [7] <- "Name" # name
names(victoria_house_census_data) [8] <- "Pop2011" #Adjusted Population (previous Census)
names(victoria_house_census_data) [14] <- "Area"
names(victoria_house_census_data) [15] <- "Income"
names(victoria_house_census_data) [16] <- "Occupied"
names(victoria_house_census_data) [17] <- "Detached"
names(victoria_house_census_data) [18] <- "Five_Stories"
names(victoria_house_census_data) [19] <- "Moveable"
names(victoria_house_census_data) [20] <- "Private_households"
names(victoria_house_census_data) [21] <- "One_Person"
names(victoria_house_census_data) [22] <- "Two_Person"
names(victoria_house_census_data) [23] <- "Three_Person"
names(victoria_house_census_data) [24] <- "Four_Person"
names(victoria_house_census_data) [25] <- "Five_Person"
names(victoria_house_census_data) [26] <- "House_Size"
names(victoria_house_census_data) [27] <- "Avg_House_Size"

# check to see renamed columns ------------------------
head(victoria_house_census_data)
names(victoria_house_census_data)

# spatial transorm & reproject ------------------------
victoria_house_census_data_sp <- as_Spatial(victoria_house_census_data)
vic_cens <- spTransform(victoria_house_census_data_sp, CRS("+init=epsg:3005")) # bc albers
names(vic_cens)
class(vic_cens)
summary(vic_cens) # 1 row NA's Esquimalt
vic_cens@data

# subset with some columns removed ------------------------
# this is the order that summary & data table will use
vic_cens2 <- subset(vic_cens, select = c(7, 4, 6, 8, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26))
names(vic_cens2)                    
head(vic_cens2)
summary(vic_cens2)
class(vic_cens2)
vic_cens2@data

## Normalize data to compare between polygons ------------------------
# to compare different polygon data, census data needs to be 'normalized'
# not to use raw count
# Household data by dividing by polygon # households > number per households in area
# mean/median income per household is already normalized
# https://www.esri.com/news/arcuser/0206/files/normalize2.pdf

vic_cens2$Occupied <- vic_cens2$Occupied / vic_cens2$Households
vic_cens2$Detached <- vic_cens2$Detached / vic_cens2$Households
vic_cens2$Five_Stories <- vic_cens2$Five_Stories / vic_cens2$Households
vic_cens2$Moveable <- vic_cens2$Moveable / vic_cens2$Households
vic_cens2$Private_households <- vic_cens2$Private_households / vic_cens2$Households
vic_cens2$One_Person <- vic_cens2$One_Person / vic_cens2$Households
vic_cens2$Two_Person <- vic_cens2$Two_Person / vic_cens2$Households
vic_cens2$Three_Person <- vic_cens2$Three_Person / vic_cens2$Households
vic_cens2$Four_Person <- vic_cens2$Four_Person / vic_cens2$Households
vic_cens2$Five_Person <- vic_cens2$Five_Person / vic_cens2$Households
names(vic_cens2)
summary(vic_cens2)
class(vic_cens2)

# names listed on drop-down list ------------------------
vic_cens2 <- subset(vic_cens2, select = c(1, 6, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18))

names(vic_cens2)
summary(vic_cens2)

# create a dataframe with newly named columns > data dictionary
# https://stackoverflow.com/questions/14620972/how-to-combine-two-vectors-into-a-data-frame
x <- c("Name", "Households", "Population", "Pop2011", "Area", "Income", "Occupied", "Detached", "Five_Stories", "Moveable", "One_Person", "Two_Person", "Three_Person", "Four_Person", "Five_Person", "House_Size", "Avg_House_Size")
y <- c("name", "Households", "Population", "Adjusted Population (previous Census)", "Area (sq km)", "Total_income", "Occupied_private_dwelling_Percent", "Occupied_single_detached_house_Percent", "Apt_build_greaterThan_5_stories_Percent", "Moveable_dwellings_Percent", "One_person_household_Percent", "Two_persons_household_Percent", "Three_persons_household_Percent", "Four_person_household_Percent", "Five_or_more_persons_household_Percent", "Household_size_number_persons_Percent", "Avg_household_size_Percent")
z <- c("name", "Households", "Population", "Adjusted Population (previous Census)", "Area (sq km)", "v_CA16_2246", "v_CA16_408", "v_CA16_409", "v_CA16_410", "v_CA16_417", "v_CA16_419", "v_CA16_420", "v_CA16_421", "v_CA16_422", "v_CA16_423", "v_CA16_424", "v_CA16_425")
x_name <- "New"
y_name <- "Normalized"
z_name <- "Original"
data_dic <- data.frame(x,y,z)
names(data_dic) <- c(x_name, y_name, z_name)
print(data_dic)
str(data_dic)
names(data_dic)
class(data_dic)

vic_cens3_var <- setdiff(names(vic_cens2), c("Shape.Area", "Type","GeoUID",  "PR_UID", "CD_UID", "CMA_UID", "Name", "Dwellings", "House_Size", "Avg_House_Size", "Private_households_Percent"))
class(vic_cens3_var)
summary(vic_cens3_var)
names(vic_cens3_var)

# User interface ----------------------------------
ui <- fluidPage(
  titlePanel("Victoria CMA 2016 Census Household Visualization"),
  # don't use sidebarLayout 
  # https://stackoverflow.com/questions/46372664/error-argument-mainpanel-is-missing-with-no-default
  sidebarPanel(position = "right",
               selectInput("var", "Choose a Variable to Map", vic_cens3_var, selected = "Income")
  ),
  mainPanel(
    tabsetPanel(
      tabPanel("Choropleth map", tmapOutput("map")),
      tabPanel("Data Dictionary", tableOutput("data_dic")),      
      tabPanel("Normalized % Table", tableOutput("table")),
      tabPanel("Raw Data Table", tableOutput("table_raw")),
      tabPanel("Summary Stats", verbatimTextOutput("summary")),
      tabPanel("About", tableOutput("text"))
    )
  )
)

# Server logic ------------------------
# runs each time user visits/interacts with app, this is rendered
server <- function(input, output, session) {
  
  # reactive object
  output$map <- renderTmap({
    # choropleth map variable
    tm_shape(vic_cens2) + 
      tm_scale_bar(width = 0.22, position = c("LEFT", "BOTTOM")) + 
      tm_polygons(vic_cens3_var[1], alpha = 0.5, palette = "viridis", zindex = 401)
  })
  observe({
    var <- input$var
    tmapProxy("map", session, {
      tm_remove_layer(401) +
        tm_shape(vic_cens2) + 
        tm_scale_bar(width = 0.22, position = c("LEFT", "BOTTOM")) + 
        tm_polygons(var, alpha = 0.5,  border.col = "grey", 
                    border.alpha = 0.05, palette = "viridis", zindex = 401)
    })
  })
  
  output$data_dic <- renderTable({
    print(data_dic)
  })
  
  output$table <- renderTable({
    vic_cens2@data
  })
  
  output$table_raw <- renderTable({
    vic_cens@data
  })
  
  output$summary <- renderPrint({
    summary(vic_cens2)
  })
  
  output$text <- renderUI({
    str1 <- paste("2016 Census Data from Statistics Canada.")
    str2 <- paste("In order to compare municipal polygon data, household stats have been normalized by dividing each municipality variable by the number of households in each municipality.")
    str3 <- paste("code source: ")
    str4 <- paste("Created by Wendy Anthony 2020-01-02")
    HTML(paste(str1, str2, str3, str4, sep = "<br /><br />"))
  })
  # https://stackoverflow.com/questions/23233497/outputting-multiple-lines-of-text-with-rendertext-in-r-shiny  
  
}
# run once when app is launched ------------------------
shinyApp(ui, server)

# ------------------------
