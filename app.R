# Example from https://shiny.rstudio.com/ 

# Load packages
library(shiny)
#install.packages("shinythemes")
library(tidyverse)
library(shinythemes)
library(dplyr)
library(readr)

# Load data
# This dataset contains the NFL pbp data, betting data, and weather data from Repo #1
post_td_plays <- read_csv("post_td_plays.csv")

# Define UI
ui <- fluidPage(theme = shinytheme("lumen"),
                titlePanel("NFL Post-TD PLays: Win Probability Shifts after XPT or 2PT"),
                sidebarLayout(
                  # Sidebar panel for inputs ----
                  sidebarPanel(
                    
                    # Input: Select the random distribution type ----
                    checkboxGroupInput("extra_point_type_options", "Post-TD Play Type:",
                                 c("Kick" = "Kick",
                                   "Two-point Conversion" = "Two-PointConversion")),
                    
                    # br() element to introduce extra vertical spacing ----
                    br(),
                    
                    # Input: Slider for the number of observations to generate ----
                    sliderInput("game_minutes_remaining",
                                "Game Minutes Remaining:",
                                value = 15, # start of 4th quarter
                                min = 0,
                                max = 60)
                    
                  ),
                  
                  # Output: Description, lineplot, and reference
                  mainPanel(
                    plotOutput(outputId = "scatterplot"), #, height = "300px"),
                    tags$a(href = "https://www.kaggle.com/maxhorowitz/nflplaybyplay2009to2016", "Source: Kaggle's NFL play-by-play data from 2009-2018", target = "_blank")
                  )
                )
)

# Define server function
server <- function(input, output) {
  
  
  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    #color = "#434343"
    #par(mar = c(4, 4, 1, 1))
    # plot(x = selected_trends()$date, y = selected_trends()$close, type = "l",
         # xlab = "Date", ylab = "Trend index", col = color, fg = color, col.lab = color, col.axis = color)
    post_td_plays %>% 
      filter(extra_point_type %in% input$extra_point_type_options) %>% 
      mutate(game_minutes_remaining = game_seconds_remaining / 60) %>% 
      filter(game_minutes_remaining <= input$game_minutes_remaining) %>% 
      ggplot(aes(x = game_minutes_remaining, y = wpa, color = extra_point_type)) + 
      geom_point() + 
      scale_x_reverse()
  })
}

# Create Shiny object
shinyApp(ui = ui, server = server)
