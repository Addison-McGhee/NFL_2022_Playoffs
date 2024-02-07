# Visualizing the 2022 NFL Playoffs
The following repo contains the R code used to generate the play-by-play Win Probabilities for each of the 13 NFL playoff games of 2022. An XGBoost model was trained using historical NFL play-by-play from 1999 to 2022, with 80% of the data used as the training set, and the remaining 20% used as the test set. The Tableau dashboard showing the results is available [here](https://public.tableau.com/app/profile/addison.mcghee/viz/2022_playoffs/2022_Super_Bowl?publish=yes).

## Data
The data cleaning/processing code is in the `data_processing` folder. All data was obtained using the `nflreadr` package. IMPORTANT: The datasets used for training contained > 1 million rows, so it could not be stored on this GitHub repo. The following links lead to those datasets: [pbp_data.csv](https://drive.google.com/file/d/17p-QDiLuX-zl6sUpAl3kVsZm2ikGpgF2/view?usp=drive_link) (model data; used in XGBoost script) and [full_pbp_data.csv](https://drive.google.com/file/d/1ANvg-SeyEW3CwgZtOGX9HmsVcnLqbS-Y/view?usp=drive_link) (original, unprocessed data; used in data processing script).

## Model Code
The modeling code is contained in the `xgboost` folder. The model was fit using the R `xgboost` package. 
