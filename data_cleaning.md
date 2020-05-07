Data Source
===========

<br> Our data originates from Kaggle, where researchers compiled data
for [every play of every NFL game from
2009-2018](https://www.kaggle.com/maxhorowitz/nflplaybyplay2009to2016).
This dataset was massive, and cleaning it took up the maximum space on
our original github repo, which can be found here:
<a href="https://github.com/aelert2/StatsGroupProject" class="uri">https://github.com/aelert2/StatsGroupProject</a>.
<br> <br> Because we are unable to push the full file to this shiny app
repo, we want to showthe dplyr chains that we used to create our primary
datasets, post\_td\_plays.csv, and two\_point\_attempts.csv <br> <br>

post\_td\_plays.csv
-------------------

<br> We read in the play-by-play data, as well as a file that contained
Vegas oddsmaker’s betting data and weather data. Following a join, we
selected the columns that we felt provided valuable context to the two
point conversions. We kept most columns, but removed some that were
totally irrelevant. Afterwards, we filter it down to just the rows that
involve plays following a touchdown, which are extra-point kicks and
two-point conversions. We also filter out penalties.

    # nfl_data <-  read_csv("NFLPlaybyPlay 2009-2018.csv")
    # spread_data = read.csv("spreadspoke_scores.csv")
    # spread_data$newdate <- strptime((spread_data$schedule_date), "%m/%d/%Y")
    # spread_data$newdate = format(spread_data$newdate, "%Y-%m-%d")
    # spread_data$newdate = as.Date(as.character(spread_data$newdate))
    # 
    # spread_data$home_team_abbv <- ifelse(spread_data$team_home=="Arizona Cardinals", "ARI",
    #                                      ifelse(spread_data$team_home=="Atlanta Falcons", "ATL", 
    #                                             ifelse(spread_data$team_home=="Baltimore Ravens", "BAL",
    #                                                    ifelse(spread_data$team_home=="Buffalo Bills", "BUF",
    #                                                           ifelse(spread_data$team_home=="Carolina Panthers", "CAR",
    #                               ifelse(spread_data$team_home=="Chicago Bears", "CHI",
    #                                       ifelse(spread_data$team_home=="Cincinnati Bengals", "CIN",
    #                                             ifelse(spread_data$team_home=="Cleveland Browns", "CLE",
    #                                                    ifelse(spread_data$team_home=="Dallas Cowboys", "DAL",
    #                                                           ifelse(spread_data$team_home=="Denver Broncos", "DEN", 
    #                               ifelse(spread_data$team_home=="Detroit Lions", "DET",
    #                                      ifelse(spread_data$team_home=="Green Bay Packers", "GB",
    #                                             ifelse(spread_data$team_home=="Houston Texans", "HOU",
    #                                                    ifelse(spread_data$team_home=="Indianapolis Colts", "IND",
    #                               ifelse(spread_data$team_home=="Jacksonville Jaguars", "JAX",
    #                                      ifelse(spread_data$team_home=="Kansas City Chiefs", "KC",
    #                                             ifelse(spread_data$team_home=="Los Angeles Rams", "LA",
    #                                                    ifelse(spread_data$team_home=="Los Angeles Chargers", "LAC",
    #                               ifelse(spread_data$team_home=="Miami Dolphins", "MIA",
    #                                      ifelse(spread_data$team_home=="Minnesota Vikings", "MIN",
    #                                             ifelse(spread_data$team_home=="New England Patriots", "NE",
    #                                                 ifelse(spread_data$team_home=="New Orleans Saints", "NO",
    #                               ifelse(spread_data$team_home=="New York Giants", "NYG",
    #                                      ifelse(spread_data$team_home=="New York Jets", "NYJ",
    #                                             ifelse(spread_data$team_home=="Oakland Raiders", "OAK",
    #                                                    ifelse(spread_data$team_home=="Philadelphia Eagles", "PHI",
    #                               ifelse(spread_data$team_home=="Pittsburgh Steelers", "PIT",
    #                                      ifelse(spread_data$team_home=="San Diego Chargers", "SD",
    #                                             ifelse(spread_data$team_home=="Seattle Seahawks", "SEA",
    #                               ifelse(spread_data$team_home=="San Francisco 49ers", "SF",
    #                                      ifelse(spread_data$team_home=="St. Louis Rams", "STL",
    #                                             ifelse(spread_data$team_home=="Tampa Bay Buccaneers", "TB",
    #                               ifelse(spread_data$team_home=="Tennessee Titans", "TEN",
    #                                      ifelse(spread_data$team_home=="Washington Redskins", "WAS", "NA"
    #                                             ))))))))))))))))))))))))))))))))))
    # 
    # #Jacksonville's abbreviation changed from JAC to JAX in 2013
    # nfl_data$home_team <- ifelse(nfl_data$home_team == "JAC", "JAX", nfl_data$home_team)
    # 
    # colnames(spread_data)[19] <- "home_team"
    # colnames(spread_data)[18] <- "game_date"
    # glimpse(spread_data)
    # 
    # nfl_data <- nfl_data %>% 
    #                 left_join(spread_data, by=c("game_date", "home_team"))
    # 
    # post_td_plays <- nfl_data %>% 
    #   select(play_id,
    #          game_id,
    #          home_team,
    #          away_team,
    #          posteam,
    #          posteam_type,
    #          defteam,
    #          posteam_score,
    #          defteam_score,
    #          score_differential,
    #          posteam_score_post,
    #          defteam_score_post,
    #          score_differential_post,
    #          desc,
    #          game_date,
    #          qtr,
    #          game_seconds_remaining,
    #          play_type,
    #          yards_gained,
    #          contains("two_point"),
    #          kicker_player_name,
    #          kicker_player_id,
    #          blocked_player_id,
    #          blocked_player_name,
    #          contains("extra_point"),
    #          wp,
    #          def_wp,
    #          home_wp,
    #          away_wp,
    #          wpa,
    #          home_wp_post,
    #          away_wp_post,
    #          ydsnet, 
    #          ep, 
    #          epa,
    #          shotgun,
    #          qb_dropback,
    #          team_favorite_id, 
    #          spread_favorite, 
    #          over_under_line, 
    #          stadium,
    #          stadium_neutral, 
    #          weather_temperature,
    #          weather_wind_mph,
    #          weather_humidity,
    #          weather_detail, 
    #          score_differential_post)%>% 
    #   mutate(year = substr(game_id, 1, 4)) %>%
    #   filter(extra_point_attempt == 1 | two_point_attempt == 1 | defensive_extra_point_attempt == 1 | defensive_two_point_attempt == 1)
    # 
    # post_td_plays$home_team <- as.factor(as.character(post_td_plays$home_team))
    # post_td_plays$away_team <- as.factor(as.character(post_td_plays$away_team))
    # post_td_plays$team_favorite_id <- as.factor(as.character(post_td_plays$team_favorite_id))
    # 
    # #Create one column that separates the types of extra point(s) try
    # post_td_plays <- post_td_plays %>% 
    #   mutate(extra_point_type = ifelse(extra_point_attempt == 1,
    #                                "Kick", "Two-PointConversion"))
    # 
    # #str(post_td_plays)
    # post_td_plays$posteam <- as.factor(post_td_plays$posteam)
    # post_td_plays$defteam <- as.factor(post_td_plays$defteam)
    # post_td_plays$play_type <- as.factor(post_td_plays$play_type)
    # post_td_plays$two_point_attempt <- as.factor(post_td_plays$two_point_attempt)
    # post_td_plays$two_point_conv_result <- as.factor(post_td_plays$two_point_conv_result)
    # post_td_plays$kicker_player_id <- as.factor(post_td_plays$kicker_player_id)
    # post_td_plays$extra_point_attempt <- as.factor(post_td_plays$extra_point_attempt)
    # post_td_plays$extra_point_result <- as.factor(post_td_plays$extra_point_result)
    # post_td_plays$year <- as.factor(post_td_plays$year)
    # post_td_plays$weather_humidity <- as.numeric(as.character(post_td_plays$weather_humidity))
    # post_td_plays$extra_point_type <- as.factor(as.character(post_td_plays$extra_point_type))
    # glimpse(post_td_plays)
    # 
    # #Dropping the no_play play type from the data...it's all penalties
    # post_td_plays <- post_td_plays %>% 
    #   filter(play_type != "no_play")

<br> <br> <br>

two\_point\_attempts.csv
========================

<br> Here you can see a chain of mutations that we make to the
play-by-play dataset that cumulatively total different statistics as the
game progresses. Similar to the post\_td\_plays datset, we select them
into a smaller file, and filter it down into instances of two-point
attempts. This way, in each of our rows where a two-point attempt
happens, these columns provide statistics that show how successful teams
have been offesnively up to that point in the game.

    # #Data Cleaning for logistic regression
    # 
    # #Changing success/failure to 1/0
    # nfl_data$two_point_conv_result <- ifelse(nfl_data$two_point_conv_result == "success", 1,
    #                                          ifelse(nfl_data$two_point_conv_result == "failure", 0,
    #                                                 NA))
    # #Create column that sums to get the total yards gained
    # nfl_data <- nfl_data %>% 
    #   group_by(game_id,
    #            posteam) %>% 
    #   filter(play_type == "run" | play_type == "pass") %>%
    #   mutate(total_yards_gained = cumsum(yards_gained),
    #          play_num = row_number(),
    #          avg_yds_per_play = total_yards_gained/play_num) %>% 
    #     mutate(run_yards_gained = ifelse(play_type == "run", yards_gained, 0),
    #            pass_yards_gained = ifelse(play_type == "pass" & sack != 1, yards_gained, 0),
    #            run_greater_than_2yds = ifelse(run_yards_gained > 2, 1, 0),
    #            pass_greater_than_2yds = ifelse(pass_yards_gained >2, 1, 0),
    #            num_runs_greater_than_2yds = cumsum(run_greater_than_2yds),
    #            num_passes_greater_than_2yds = cumsum(pass_greater_than_2yds),
    #            run = ifelse(play_type=="run", 1, 0),
    #            pass = ifelse(play_type=="pass", 1, 0),
    #            num_runs = cumsum(run),
    #            num_passes = cumsum(pass), 
    #            prop_runs_greater_than_2_yards = num_runs_greater_than_2yds/num_runs,
    #            prop_passes_greater_than_2_yards = num_passes_greater_than_2yds/num_passes,
    #            incomplete_passes = cumsum(incomplete_pass),
    #            completion_percentage = 1-(incomplete_passes/num_passes),
    #            total_run_yards = cumsum(run_yards_gained),
    #            total_pass_yards = cumsum(pass_yards_gained),
    #            avg_yards_per_run = total_run_yards/num_runs,
    #            avg_yards_per_pass = total_pass_yards/num_passes,
    #            third_down_conv_percentage = cumsum(third_down_converted) /(cumsum(third_down_converted)+cumsum(third_down_failed)),
    #            fourth_down_conv_percentage = cumsum(fourth_down_converted) /(cumsum(fourth_down_converted)+cumsum(fourth_down_failed)))
    # 
    # table(nfl_data$play_type)
    #  nfl_data_small <- nfl_data %>% 
    #   select(play_id,
    #          game_id,
    #          home_team,
    #          away_team,
    #          posteam,
    #          posteam_type,
    #          defteam,
    #          posteam_score,
    #          defteam_score,
    #          score_differential,
    #          posteam_score_post,
    #          defteam_score_post,
    #          score_differential_post,
    #          desc,
    #          game_date,
    #          qtr,
    #          game_seconds_remaining,
    #          play_type,
    #          yards_gained,
    #          total_yards_gained,
    #          play_num, 
    #          avg_yds_per_play,
    #          play_type,
    #          run,
    #          pass,
    #          total_run_yards,
    #          total_pass_yards,
    #          num_runs,
    #          num_passes,
    #          run_yards_gained,
    #          pass_yards_gained, 
    #          run_greater_than_2yds,
    #          pass_greater_than_2yds,
    #          num_runs_greater_than_2yds,
    #          num_passes_greater_than_2yds, 
    #          prop_runs_greater_than_2_yards,
    #          prop_passes_greater_than_2_yards,
    #          avg_yards_per_run,
    #          avg_yards_per_pass,
    #          completion_percentage,
    #          contains("two_point"),
    #          two_point_conv_result,
    #          kicker_player_name,
    #          kicker_player_id,
    #          blocked_player_id,
    #          blocked_player_name,
    #          contains("extra_point"),
    #          wp,
    #          def_wp,
    #          home_wp,
    #          away_wp,
    #          wpa,
    #          home_wp_post,
    #          away_wp_post,
    #          ydsnet, 
    #          ep, 
    #          epa,
    #          shotgun,
    #          qb_dropback,
    #          team_favorite_id, 
    #          spread_favorite, 
    #          over_under_line, 
    #          stadium,
    #          stadium_neutral, 
    #          weather_temperature,
    #          weather_wind_mph,
    #          weather_humidity,
    #          weather_detail, 
    #          pass_location,
    #          run_location,
    #          third_down_converted,
    #          third_down_failed, 
    #          third_down_conv_percentage,
    #          fourth_down_conv_percentage)
    #  
    # nfl_data_small$two_point_conv_result <- as.factor(as.character(nfl_data_small$two_point_conv_result))
    # 
    # #Logistic Regression
    # two_points <- nfl_data_small %>% 
    #   filter(!is.na(two_point_conv_result))
    # 
    # #write.csv(two_points, two_point_attempts.csv)
