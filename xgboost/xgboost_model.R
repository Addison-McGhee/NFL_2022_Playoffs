library(nflreadr)
library(tidyverse)
library(xgboost)
library(caret)
library(SHAPforxgboost)
library(varhandle)
library(zoo)

# Load data
pbp_data = readRDS("pbp_data.RDS")

# Obtain Tie + Overtime games
# There have been 411 Overtime games since 1999
overtime_games = pbp_data %>% 
  filter(game_half == "Overtime") %>%
  .$game_flag %>% 
  unique() 

# Remove Ties + Overtime games
pbp_data = pbp_data %>% 
  filter(!game_flag %in% overtime_games) 
  
# Add game winner/over variables
pbp_data = pbp_data %>% 
  mutate(home_team_winner = unfactor(home_team_winner),
         game_over = factor(ifelse(game_seconds_remaining == 0, 1, 0)),
         two_minute_warning = factor(ifelse(game_seconds_remaining == 120, 1, 0)))


  
# Get game_id for each 2022 playoff game
playoff_games = pbp_data %>% 
  filter(season == 2022, week > 18) %>% 
  select(game_flag, home_score, away_score) %>% 
  distinct()

# Filter data to be before 2022 playoffs
mod_data = pbp_data %>% 
  filter(season != 2023, week <= 18 | season != 2022) %>% 
  select(-c(home_score, away_score, desc, time, yrdln))

#make this example reproducible
set.seed(0)

#split into training (80%) and testing set (20%)
parts = createDataPartition(mod_data$home_team_winner, p = .8, list = F)
train = mod_data[parts, ]
test = mod_data[-parts, ]

#define predictor and response variables in training set
train_x = data.matrix(train %>% select(-home_team_winner))
train_y = train$home_team_winner

#define predictor and response variables in testing set
test_x = data.matrix(test %>% select(-home_team_winner))
test_y = test$home_team_winner

#define final training and testing sets
xgb_train = xgb.DMatrix(data = train_x, label = train_y)
xgb_test = xgb.DMatrix(data = test_x, label = test_y)


#define watchlist
watchlist = list(train=xgb_train, test=xgb_test)

#fit XGBoost model and display training and testing data at each round
model = xgb.train(data = xgb_train, 
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 70,
                  objective = "binary:logistic",
                  verbose = F)


# define final model
best_rounds = which.min(model$evaluation_log$test_logloss)

final = xgboost(data = xgb_train, 
                max.depth = 3, 
                nrounds = best_rounds, 
                verbose = 0,
                objective = "binary:logistic")


 
# Generate predictions for 2022 Playoffs
pred_data = pbp_data %>%
  filter(season == 2022, week > 18) %>% 
  select(-c(home_score, away_score))

pred_x = data.matrix(pred_data %>% select(-home_team_winner))
pred_y = pred_data$home_team_winner

temp_pred_data = xgb.DMatrix(data = pred_x, 
                             label = pred_y)

# Get predictions
pred_data$prob = predict(final, pred_x)

pred_data = pred_data %>% 
  mutate(prob = case_when(
    game_seconds_remaining == 0 & total_home_score > total_away_score ~ 1,
    game_seconds_remaining == 0 & total_away_score > total_home_score ~ 0,
    TRUE ~ prob
    )
  )

# Save model output for ALL playoff games
write.csv(pred_data, "wp_data.csv")



######################################
# Load output for ALL playoff games
######################################
wp_data = read.csv("wp_data.csv")

wp_data = wp_data %>% 
  left_join(pbp_data %>% select(game_flag, game_seconds_remaining, 
                                play_type, desc, time, yrdln), 
            by = c("game_flag", "game_seconds_remaining", "play_type"))

wp_data = wp_data %>% 
  mutate(quarter = case_when(
    qtr == 1 ~ "1st",
    qtr == 2 ~ "2nd",
    qtr == 3 ~ "3rd",
    qtr == 4 ~ "4th"
  ))

write.csv(wp_data, "wp_data.csv")


# Save model output for each playoff game separately
for(game in unique(playoff_games$game_flag)) {
  wp_temp = wp_data %>% 
    filter(game_flag == game) %>% 
    mutate(prob_new = runner::mean_run(prob, k = 3, lag = -1),
           game_index = row_number())
  
  write.csv(wp_temp, paste("2022_model_output/", game, ".csv", sep = ""))
}







