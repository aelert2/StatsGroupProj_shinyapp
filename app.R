# Example from https://shiny.rstudio.com/ 
# Navbar example: https://shiny.rstudio.com/gallery/navbar-example.html

# Load packages
library(shiny)
library(tidyverse)
#install.packages("shinythemes")
library(shinythemes)
library(dplyr)
library(readr)
library(lubridate)

# Load data
# This dataset contains the NFL pbp data, betting data, and weather data from Repo #1
post_td_plays <- read_csv("post_td_plays.csv")
wpa_shifts <- read_csv("wpa_shifts.csv")


# Define UI
ui <- navbarPage(theme = shinytheme("united"),
                 "2-point Conversions in the NFL",
                 tabPanel("Background",
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   includeMarkdown("desc_text.md")
                                   )
                            )
                          ),
                 tabPanel("Exploration",
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   includeMarkdown("exploration_1.md")
                            )
                          ),
                          
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   sidebarLayout(
                                     sidebarPanel(width = 2,
                                       # Chose what post-td play results you want to see
                                       checkboxGroupInput("prop_options", "Post-TD Play Type:",
                                                          c("Kick" = "ExtraPoint",
                                                            "Two-point Conversion" = "TwoPoint"))
                                       ),
                                     mainPanel(width = 10,
                                       plotOutput(outputId = "expl_1")
                                       )
                                     )
                                   )
                            ),
                          
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   includeMarkdown("exploration_2.md")
                            )
                          ),
                          
                          fluidRow(
                            column(width = 12,
                                   style = 'padding:1em;',
                                   sidebarLayout(
                                     sidebarPanel(width = 3,
                                       checkboxGroupInput("play_type_options", "Two-Point Conversion Play Type:",
                                                          c("Run" = "run",
                                                            "Pass" = "pass"))
                                       ),
                                     
                                     mainPanel(width = 9,
                                       plotOutput(outputId = "expl_2")
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
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   includeMarkdown("logistic_mod.md")
                                   # sidebarLayout(
                                   #   sidebarPanel(
                                   #     checkboxGroupInput("play_type", "Post-TD Play Type:",
                                   #                        c("Kick" = "kick",
                                   #                          "Two-point Conversion" = "two_pt_conv")),
                                   #   ),
                                   #   
                                   #   mainPanel(
                                   #     plotOutput(outputId = "linegraphWPAShifts")
                                   #   )
                                   # )
                            )
                          )
                 ),
                 tabPanel("Conclusion",
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   includeMarkdown("conclusion.md")
                                   )
                          )
                 )
)



server <- function(input, output) {
  
  # Create bar graph of proportion of post-td plays from 2009-2018
  output$expl_1 <- renderPlot({
    post_td_plays %>% 
      group_by(year, extra_point_type) %>% 
      summarise(n = n()) %>% 
      pivot_wider(names_from = "extra_point_type", values_from = "n") %>% 
      rename(ex_pt_attempt = Kick,
             two_pt_attempt = `Two-PointConversion`) %>% 
      mutate(ExtraPoint = ex_pt_attempt / (ex_pt_attempt + two_pt_attempt),
             TwoPoint = two_pt_attempt / (ex_pt_attempt + two_pt_attempt)) %>% 
      pivot_longer(cols = c('ExtraPoint', 'TwoPoint'), names_to = 'PlayType', values_to = "proportion") %>% 
      filter(PlayType %in% input$prop_options) %>% 
      ggplot(aes(x = year, y = proportion, color = PlayType)) +
      geom_line() +
      geom_point(size = 2) +
      #geom_bar(stat='identity', position='dodge') +
      scale_color_discrete(name ="Play Type",
                            breaks=c("ExtraPoint", "TwoPoint"),
                            labels=c("Kick", "Two-Point Conv.")) +
      geom_vline(xintercept = 2015, linetype="dashed", color = "darkgray", size = 1) +
      labs(x="Year", y = "Proportion") +
      theme(legend.position="top")
  })
  
  output$expl_2 <- renderPlot({
    post_td_plays %>% 
      filter(extra_point_type == "Two-PointConversion",
             play_type %in% input$play_type_options) %>% 
      group_by(year, play_type, two_point_conv_result) %>% 
      summarise(n = n()) %>% 
      pivot_wider(names_from = "two_point_conv_result", values_from = "n") %>% 
      mutate(success_rate = success / (success + failure)) %>% 
      ggplot(aes(x = year, y = success_rate, color = play_type)) +
      geom_line() +
      geom_point(size = 2) +
      scale_colour_discrete(name  ="Play Type",
                            breaks=c("run", "pass"),
                            labels=c("Run", "Pass")) +
      scale_x_continuous() +
      labs(x = "Year", y = "Success Rate") +
      theme(legend.position="top")
  })

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
