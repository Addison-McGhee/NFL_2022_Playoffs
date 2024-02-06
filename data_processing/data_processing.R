library(nflreadr)
library(tidyverse)

# Load play-by-play data using "nflfastR" package
nfl_data = readRDS("full_pbp_data.RDS")
saveRDS(nfl_data, "full_pbp_data.RDS")

# Remove unhelpful variables
filt_nfl_data = nfl_data %>% 
  mutate(home_team_winner = ifelse(result > 0, 1, 0),
         game_flag = game_id) %>% 
  select(-c(result,
            total,
            colnames(nfl_data)[str_detect(colnames(nfl_data), "id")],
            colnames(nfl_data)[str_detect(colnames(nfl_data), "prob")],
            ep,
            colnames(nfl_data)[str_detect(colnames(nfl_data), "epa")],
            colnames(nfl_data)[str_detect(colnames(nfl_data), "wp")],
            colnames(nfl_data)[str_detect(colnames(nfl_data), "wpa")],
            colnames(nfl_data)[str_detect(colnames(nfl_data), "number")],
            cp, 
            cpoe,
            colnames(nfl_data)[str_detect(colnames(nfl_data), "fantasy")],
            colnames(nfl_data)[str_detect(colnames(nfl_data), "xyac")],
            xpass, 
            pass_oe,
            time_of_day,
            start_time,
            drive_real_start_time,
            weather,
            stadium)) 
  

# Convert variables to factors 
factor_col_names <- sapply(filt_nfl_data, function(col) length(unique(col)) <= 6)

filt_nfl_data <- filt_nfl_data %>%
  mutate(across(names(factor_col_names)[factor_col_names], as.factor))

str(filt_nfl_data)

# Save dataset
saveRDS(filt_nfl_data, "pbp_data.RDS")



# Dictionary for model data
mod_dictionary = dictionary_pbp %>% 
  filter(Field %in% colnames(filt_nfl_data))

# Save dataset
saveRDS(mod_dictionary, "mod_dictionary.RDS")






