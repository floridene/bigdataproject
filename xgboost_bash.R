
load("/home/Max_Philipp/bigdataproject/prior_test.rda")
library(xgboost)
subtrain <- prior_test %>% sample_frac(0.2)
X <- xgb.DMatrix(as.matrix(subtrain %>% select(-reordered)), label = subtrain$reordered)

best_param <- list()
best_seednumber <- 1234
best_logloss <- Inf
best_logloss_index <- 0
best_CVround <- 0

for (iter in 1:50) {
  param <- list(objective = "binary:logistic",
                eval_metric = "logloss",
                max_depth = sample(6:12, 1),
                eta = runif(1, .01, .3),
                gamma = runif(1, 0.0, 0.2),
                subsample = runif(1, .6, .9),
                colsample_bytree = runif(1, .5, .8),
                min_child_weight = sample(1:40, 1),
                max_delta_step = sample(1:10, 1)
  )
  
  ## cv_nround <- c(250, 500, 1000) # We first choose three different numbers of rounds. However, putting early_stopping in place made this step obsolete. Therefere, we were able to get rid of the nested for loop.
  cv_nround <- 150
  cv_nfold <- 5
  seed_number = sample.int(10000, 1)[[1]]
  set.seed(seed_number)
  message("Iteration Round: ", as.character(iter), appendLF = FALSE) ## Check at which iteration we are.
  
  ## for (validator in cv_nround) {
  mdcv <- xgb.cv(data = X,
                 params = param,
                 nfold = cv_nfold,
                 nrounds = cv_nround,
                 nthread = 32,
                 verbose = TRUE,
                 early_stopping_rounds = 20,
                 maximize = FALSE
  )
  
  min_logloss <- min(mdcv$evaluation_log$test_logloss_mean)
  min_logloss_index <- which.min(mdcv$evaluation_log$test_logloss_mean)
  
  if (min_logloss < best_logloss) {
    best_logloss = min_logloss
    best_logloss_index = min_logloss_index
    best_seednumber = seed_number
    best_param = param
    ## best_CVround = mdcv$niter
    
  }
  ## }
}

## Save the best parameters
write.csv(best_param, file = "best_parameters_FinalCV.csv")
