    library(tidyverse)

    ## ── Attaching packages ────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.3
    ## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    library(lubridate)

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

    two_points <- read_csv("two_point_attempts.csv") %>% 
      mutate(play_type = as.factor(play_type),
             weather_detail = as.factor(weather_detail))

    ## Warning: Missing column names filled in: 'X1' [1]

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_double(),
    ##   home_team = col_character(),
    ##   away_team = col_character(),
    ##   posteam = col_character(),
    ##   posteam_type = col_character(),
    ##   defteam = col_character(),
    ##   desc = col_character(),
    ##   game_date = col_date(format = ""),
    ##   play_type = col_character(),
    ##   kicker_player_name = col_logical(),
    ##   kicker_player_id = col_logical(),
    ##   blocked_player_id = col_logical(),
    ##   blocked_player_name = col_logical(),
    ##   extra_point_result = col_logical(),
    ##   team_favorite_id = col_character(),
    ##   stadium = col_character(),
    ##   stadium_neutral = col_logical(),
    ##   weather_detail = col_character(),
    ##   pass_location = col_logical(),
    ##   run_location = col_logical()
    ## )

    ## See spec(...) for full column specifications.

    post_td_plays <- read.csv("post_td_plays.csv")

    #Data Vis

    #Uses a binomial modeling technique to graph relationship between probability of successful two-point conversion and changing x axis 

    #Increasing probability of two point conversion success based on number of total passing yards
    pass_yards_convprob <- ggplot(two_points, aes(x=total_pass_yards, y=two_point_conv_result)) + geom_point() + 
      stat_smooth(method="glm", method.args=list(family="binomial"), se=FALSE)

    pass_yards_convprob

    ## Warning: Removed 1 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 1 rows containing missing values (geom_point).

![](exploration_3_files/figure-markdown_strict/unnamed-chunk-2-1.png)

    #Plotting difference in success rates
    conv_rates <- two_points %>% 
      group_by(play_type) %>% 
      summarise(Conversion_Rate = mean(two_point_conv_result==1))

    conv_rates_play_types <- ggplot(conv_rates, aes(x=play_type, y=Conversion_Rate)) + 
      geom_bar(stat="identity", width = 0.5, fill="blue") +
      geom_text(aes(label=round(Conversion_Rate,3)), vjust=1.6, color="white", size=3.5)+
      theme_minimal() 

    conv_rates_play_types

![](exploration_3_files/figure-markdown_strict/unnamed-chunk-3-1.png)

\#Binned Graphing Process

    #Didn't pipe these new column creations because I have to level the factors for graphing purposes

    #Binned column describing how much time remaining based on seconds remaining
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

    #Graphing two-point attempt rates (proportion of time the two-point attempt is chosen over the extra point kick)
    post_td_plays %>% 
      filter(!is.na(time_remaining)) %>% 
      group_by(time_remaining,
               score_situation) %>% 
      summarise(Two_pt_attempt_rate = mean(two_point_attempt==1, na.rm = T),
                Extra_pt_attempt_rate = mean(extra_point_attempt==1, na.rm=T)) %>% 
      ggplot(., aes(x=time_remaining, y=Two_pt_attempt_rate, fill=score_situation, order=score_situation)) + geom_bar(stat="identity", position="dodge") + scale_x_discrete() +scale_fill_brewer(palette = "Spectral")

![](exploration_3_files/figure-markdown_strict/unnamed-chunk-5-1.png)

    #Graphing two-point success rates (proportion of time the two-point attempt is successful)
    post_td_plays %>% 
      filter(!is.na(time_remaining)) %>% 
      group_by(time_remaining,
               score_situation) %>% 
      summarise(Two_pt_conv_rate = mean(two_point_conv_result=="success", na.rm = T),
                Extra_pt_conv_rate = mean(extra_point_result=="success", na.rm=T)) %>% 
      ggplot(., aes(x=time_remaining, y=Two_pt_conv_rate, fill=score_situation, order=score_situation)) + geom_bar(stat="identity", position="dodge") + scale_x_discrete() +scale_fill_brewer(palette = "Spectral")

![](exploration_3_files/figure-markdown_strict/unnamed-chunk-6-1.png)

Conclusion Page Stuff

    # two_points$predicted_success_prob <- predict(glm_twopt, two_points)
    # 
    # two_points %>% 
    #   arrange(predicted_success_prob)

    #2010-11-07 San Diego Chargers at Houston Texans
    sd_at_hou <- two_points %>% 
      filter(game_id == 2010110703) 

    # table(sd_at_hou$predicted_success_prob, sd_at_hou$two_point_conv_result)

    #2018-10-08 Washington at New Orleans Saints
    was_at_no <- two_points %>% 
      filter(game_id == 2018100800) 

    # table(was_at_no$predicted_success_prob, was_at_no$two_point_conv_result)
