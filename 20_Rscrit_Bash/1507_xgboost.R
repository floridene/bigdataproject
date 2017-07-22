load("test_xboost_vera.rda")
load("train_xboost_vera.rda")
     
library(data.table)
library(dplyr)
library(tidyr)
library(xgboost)
library(ggplot2))


params <- list(
  "objective"           = "reg:logistic",
  "eval_metric"         = "logloss",
  "eta"                 = 0.1,
  "max_depth"           = 6,
  "min_child_weight"    = 10,
  "gamma"               = 0.70,
  "subsample"           = 0.76,
  "colsample_bytree"    = 0.95,
  "alpha"               = 2e-05,
  "lambda"              = 10
)


subtrain <- data_train #%>% sample_frac(0.1) #train just on a fraction due to computation probs
X <- xgb.DMatrix(as.matrix(subtrain %>% select(-reordered)), label = subtrain$reordered) #create xgb matrix
model <- xgboost(data = X, 
                 params = params, 
                 nrounds = 1000,
                 nthread = 20
)

