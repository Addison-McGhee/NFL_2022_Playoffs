# Visualizing the 2022 NFL Playoffs
The following repo contains the R code used to generate the play-by-play Win Probabilities for each of the 13 NFL playoff games of 2022. An XGBoost model was trained using historical NFL play-by-play from 1999 to 2022, with 80% of the data used as the training set, and the remaining 20% used as the test set. 

## Data
The data cleaning/processing code is in the `data_processing` folder. All data was obtained using the `NFLfastr` package.

## Model Code
The modeling code is contained in the `xgboost` folder. The model was fit using the R `xgboost` package. 
