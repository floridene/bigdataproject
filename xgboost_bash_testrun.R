load("/home/Max_Philipp/bigdataproject/prior_test.rda")
load("/home/Max_Philipp/bigdataproject/test.rda") 
library(xgboost) 
library(dplyr) 
library(data.table) 
library(tidyr) 

subtrain <- prior_test %>% sample_frac(0.2) 
X <- xgb.DMatrix(as.matrix(subtrain %>% select(-reordered)), label = subtrain$reordered) 

param <- list(objective = "binary:logistic", 
              eval_metric = "logloss", 
              max_depth = 9, 
              eta = 0.08910454, 
              gamma = 0.1459201,
              subsample = 0.7306826, 
              colsample_bytree = 0.6887265,
              min_child_weight = 32,
              max_delta_step = 8) 

cv_nround <- 1000
cv_nfold <- 5 

mdcv <- xgboost(data = X, 
               params = param, 
               nfold = cv_nfold, 
               nrounds = cv_nround,
               nthread = 16, 
               verbose = TRUE, 
               early_stopping_rounds = 20, 
               maximize = FALSE ) 

Y <- xgb.DMatrix(as.matrix(test)) 
test$reordered <- predict(mdcv, Y) 
preds_xgb <- test %>% ungroup() %>% select(user_id, product_id,reordered) 

save(preds_xgb,file="test_with_preds_xgb1207_rounds1000.rda")




