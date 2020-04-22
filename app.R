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
ui <- fluidPage(theme = shinytheme("united"),
                titlePanel("NFL Post-TD Plays: Win Probability Shifts after XPT or 2PT"),
                
                # Project description
                fluidRow(
                  column(width = 12, 
                         style = 'padding:1em;',
                         includeMarkdown("desc_text.md")
                  )
                ),
                br(),
                br(),
                br(),
                
                fluidRow(
                  
                  # XPT graph
                  column(width = 6,
                         style = 'padding:1em;',
                         sidebarLayout(
                           sidebarPanel(
                             
                             # Chose what post-td play results you want to see
                             checkboxGroupInput("extra_point_result_options", "XPT Result:",
                                                c("Good" = "good",
                                                  "Failed" = "failed",
                                                  "Blocked" = "blocked",
                                                  "aborted" = "aborted"))
                           ),
                           
                           # Output: Linegraph
                           mainPanel(
                             plotOutput(outputId = "linegraphXPT")
                           )
                         ),
                  ),
                  
                  # 2PT graph
                  column(width = 6,
                         style = 'padding:1em;',
                         sidebarLayout(
                           sidebarPanel(
                             
                             # Chose what years to show
                             # sliderInput("year_range", "Year Range:",
                             #             min = 2009, max = 2018, 
                             #             value = c(2012,2016)),
                             # numericInput(inputId = "year_lb",
                             #              label = "First year of data to gather:",
                             #              value = 2009,
                             #              min = 2009, max = 2018),
                             # numericInput(inputId = "year_ub",
                             #              label = "Last year of data to gather:",
                             #              value = 2018,
                             #              min = 2009, max = 2018),
                             
                             # Chose what post-td play results you want to see
                             checkboxGroupInput("two_point_conv_result_options", "2PT Conv. Result:",
                                                c("Success" = "success",
                                                  "Failure" = "failure"))
                           ),
                           
                           # Output: Linegraph
                           mainPanel(
                             plotOutput(outputId = "linegraph2PT")
                           )
                         ),
                  )
                ),
                
                br(),
                br(),
                br(),
                br(),
                
                fluidRow(
                  column(width = 12,
                         style = 'padding:1em;',
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
                             plotOutput(outputId = "scatterplot")
                           )
                         )
                  )
                )
)


# Define server function
server <- function(input, output) {
  
  # Create linegraph of frequency of XPT conv from 2009-2018
  output$linegraphXPT <- renderPlot({
    post_td_plays %>% 
      filter(extra_point_attempt == 1) %>% 
      filter(extra_point_result %in% input$extra_point_result_options) %>%
      group_by(year, extra_point_result) %>% 
      summarise(n = n()) %>% 
      ggplot(aes(x = year, y = n, group = extra_point_result)) +
      geom_line(aes(color = extra_point_result)) +
      geom_point(aes(color = extra_point_result)) +
      #annotate(geom="text", x='2016', y=1100, label="2015: XPT moved from 2YL to 15YL", color="darkgray") +
      labs(title="Extra Points in the NFL from 2009 to 2018", x="Year", y = "Count")
  })
  
  # Create linegraph of frequency of 2PT conv from 2009-2018
  output$linegraph2PT <- renderPlot({
    post_td_plays %>%
      #filter(two_point_attempt == 1) %>%
      #filter(year >= input$year_lb & year <= input$year_ub) %>%
      #filter(year >= input$year_range[1] & year <= input$year_range[2]) %>%
      filter(two_point_conv_result %in% input$two_point_conv_result_options) %>%
      group_by(year, two_point_conv_result) %>%
      summarise(n = n()) %>%
      ggplot(aes(x = year, y = n, group = two_point_conv_result)) +
      geom_line(aes(color = two_point_conv_result)) +
      geom_point(aes(color = two_point_conv_result)) +
      labs(title="2-pt Conversions in the NFL from 2009 to 2018",x="Year", y = "Count")
  })
  
  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    post_td_plays %>% 
      filter(extra_point_type %in% input$extra_point_type_options) %>% 
      mutate(game_minutes_remaining = game_seconds_remaining / 60) %>% 
      filter(game_minutes_remaining <= input$game_minutes_remaining) %>% 
      ggplot(aes(x = game_minutes_remaining, y = wpa, color = extra_point_type)) + 
      geom_point() + 
      scale_x_reverse() +
      labs(title="Win Probability Added (WPA) Based on Post-TD Play Type Over the Course of a NFL Game",x="Game Time Remaining (Minutes)", y = "WPA")
  })
}

# Create Shiny object
shinyApp(ui = ui, server = server)

