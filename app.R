# Example from https://shiny.rstudio.com/ 
# Navbar example: https://shiny.rstudio.com/gallery/navbar-example.html

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
wpa_shifts <- read_csv("wpa_shifts.csv")


# Define UI
ui <- navbarPage(theme = shinytheme("united"),
                 "2-point Conversions in the NFL",
                 tabPanel("Background",
                          includeMarkdown("desc_text.md")
                 ),
                 tabPanel("Exploration",
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   sidebarLayout(
                                     sidebarPanel(
                                       # Chose what post-td play results you want to see
                                       checkboxGroupInput("prop_options", "Post-TD Play Type:",
                                                          c("Kick" = "prop_expt",
                                                            "Two-point Conversion" = "prop_twopt"))
                                       ),
                                     mainPanel(
                                       plotOutput(outputId = "bargraph")
                                       )
                                     )
                                   )
                            ),
                          
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   sidebarLayout(
                                     sidebarPanel(
                                       checkboxGroupInput("extra_point_type_options", "Post-TD Play Type:",
                                                         c("Kick" = "Kick",
                                                           "Two-point Conversion" = "Two-PointConversion")),
                                       br(),
                                       sliderInput("game_minutes_remaining",
                                                  "Game Minutes Remaining:",
                                                  value = 15, # start of 4th quarter
                                                  min = 0,
                                                  max = 60)
                                       ),
                                     
                                     mainPanel(
                                       plotOutput(outputId = "scatterplot")
                                       )
                                     )
                                   )
                          )
                       ),
                 
                 tabPanel("Logistic Model",
                          sidebarLayout(
                            sidebarPanel(
                              checkboxGroupInput("play_type", "Post-TD Play Type:",
                                                 c("Kick" = "kick",
                                                   "Two-point Conversion" = "two_pt_conv")),
                            ),
                            
                            mainPanel(
                              plotOutput(outputId = "linegraphWPAShifts")
                            )
                          )
                 ),
                 tabPanel("Conclusion")
)



server <- function(input, output) {
  
  # Create bar graph of proportion of post-td plays from 2009-2018
  output$bargraph <- renderPlot({
    post_td_plays %>% 
      group_by(year, extra_point_type) %>% 
      summarise(n = n()) %>% 
      pivot_wider(names_from = "extra_point_type", values_from = "n") %>% 
      rename(ex_pt_attempt = Kick,
             two_pt_attempt = `Two-PointConversion`) %>% 
      mutate(prop_expt = ex_pt_attempt / (ex_pt_attempt + two_pt_attempt),
             prop_twopt = two_pt_attempt / (ex_pt_attempt + two_pt_attempt)) %>% 
      pivot_longer(cols = c('prop_expt', 'prop_twopt'), names_to = 'play_type2', values_to = "proportion") %>% 
      filter(play_type2 %in% input$prop_options) %>% 
      ggplot(aes(x = year, y = proportion, fill = play_type2)) +
      geom_bar(stat='identity', position='dodge') +
      geom_vline(xintercept = 2015, linetype="dashed", color = "darkgray", size = 1) +
      labs(title="All Post-TD Plays in the NFL from 2009 to 2018", x="Year", y = "Proportion") +
      guides(fill = guide_legend(title=NULL))
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
  
  output$linegraphWPAShifts <- renderPlot({
    wpa_shifts %>% 
      pivot_longer(c(kick, two_pt_conv), names_to = "play_type", values_to = "wpa") %>% 
      filter(play_type %in% input$play_type) %>% 
      ggplot(aes(x = point_differential, y = wpa, color = play_type)) +
      geom_line() +
      labs(title="WPA Shifts By Point Differential",x="Point Differential (PostTeam's Perspective)", y = "WPA")
  })
}

# Create Shiny object
shinyApp(ui = ui, server = server)

# library(shiny)
# runGitHub("StatsGroupProject_shinyapp", "aelert2")
