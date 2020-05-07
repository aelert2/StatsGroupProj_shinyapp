################################################################
# RUN THIS ENTIRE SECTION BELOW BEFORE RUNNING THE APPLICATION #
###############################################################################################################################################################################################
# Load packages
library(shiny)
library(tidyverse)
library(shinythemes)
library(dplyr)
library(readr)
library(lubridate)

# Load data
# This dataset contains the NFL pbp data, betting data, and weather data all filtered to only include the post-td plays (i.e. extra point kicks and two-pt conv attempts)
post_td_plays <- read_csv("post_td_plays.csv")

# Adding these columns for Figure 3 on the Exploration tab
post_td_plays$time_remaining <- ifelse(post_td_plays$game_seconds_remaining < 120, "<2Min", 
                                       ifelse(post_td_plays$game_seconds_remaining < 300, "2-5min left",
                                              ifelse(post_td_plays$game_seconds_remaining < 600, "5-10min left",
                                                     ifelse(post_td_plays$game_seconds_remaining < 900, "10-15min left",
                                                            "Before 4th Quarter"))))

#Binned column describing score situation of the game based on score differential
post_td_plays <- post_td_plays %>% 
  mutate(score_situation = ifelse(score_differential < -7, "Losing by >7",
                                  ifelse(score_differential >= -7 & score_differential <=-4, "Losing by 4-7",
                                         ifelse(score_differential >= -3 & score_differential <=-1, "Losing by 1-3",
                                                ifelse(score_differential ==0, "Tied",
                                                       ifelse(score_differential >=1 & score_differential <=3, "Winning by 1-3",
                                                              ifelse(score_differential >=4 & score_differential <=7, "Winning by 4-7",
                                                                     ifelse(score_differential >7, "Winning by >7", "NA"
                                                                     ))))))))

#Level the factors so they're graphed in order
post_td_plays$time_remaining <- factor(post_td_plays$time_remaining,levels = c("<2Min", "2-5min left", "5-10min left", "10-15min left","Before 4th Quarter"))
post_td_plays$score_situation <- factor(post_td_plays$score_situation,levels = c("Losing by >7", "Losing by 4-7", "Losing by 1-3", "Tied", "Winning by 1-3", "Winning by 4-7","Winning by >7"))

# Might delete this table if we don't use it anymore
wpa_shifts <- read_csv("wpa_shifts.csv")

###############################################################################################################################################################################################
###############################################################################################################################################################################################


###########################################################
# CREATING THE SHINY APP WITH THE UI AND SERVER VARIABLES #
###########################################################
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
                                                            "Two-point Conversion" = "TwoPoint"),
                                                          selected = "TwoPoint")
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
                                     sidebarPanel(width = 2,
                                       checkboxGroupInput("play_type_options", "Two-Point Conversion Play Type:",
                                                          c("Run" = "run",
                                                            "Pass" = "pass"),
                                                          selected = "run")
                                       ),
                                     
                                     mainPanel(width = 10,
                                       plotOutput(outputId = "expl_2")
                                       )
                                     )
                                   )
                          ),
                          
                          fluidRow(
                            column(width = 12, 
                                   style = 'padding:1em;',
                                   includeMarkdown("exploration_3.md")
                            )
                          ),
                          
                          fluidRow(
                            column(width = 12,
                                   style = 'padding:1em;',
                                   sidebarLayout(
                                     sidebarPanel(width = 2,
                                                  checkboxGroupInput("score_situation_options", "Score Differential Range:",
                                                                     c("Losing by >7" = "Losing by >7",
                                                                       "Losing by 4-7" = "Losing by 4-7",
                                                                       "Losing by 1-3" = "Losing by 1-3",
                                                                       "Tied" = "Tied",
                                                                       "Winning by 1-3" = "Winning by 1-3",
                                                                       "Winning by 4-7" = "Winning by 4-7",
                                                                       "Winning by >7" = "Winning by >7"),
                                                                     selected = c("Losing by >7", "Losing by 4-7", "Losing by 1-3", "Tied", "Winning by 1-3", "Winning by 4-7", "Winning by >7"))
                                     ),
                                     
                                     mainPanel(width = 10,
                                               plotOutput(outputId = "expl_3")
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
                 
                 tabPanel("Modeling",
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
      labs(x = "Year", y = "Proportion") +
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
  
  output$expl_3 <- renderPlot({
    post_td_plays %>% 
      filter(!is.na(time_remaining),
             score_situation %in% input$score_situation_options) %>% 
      group_by(time_remaining, score_situation) %>% 
      summarise(two_pt_conv_rate = mean(two_point_conv_result == "success", na.rm = T)) %>% 
      ggplot(aes(x = time_remaining, y = two_pt_conv_rate, fill = score_situation, order = score_situation)) +
      geom_bar(stat = "identity", position = "dodge") + 
      scale_x_discrete() +
      scale_fill_brewer(palette = "Spectral") +
      scale_colour_discrete(name  = "Score Differential") +
      labs(x = "Time Remaining (min)", y = "Two-point Conv. Success Rate")
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
