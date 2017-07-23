library(dplyr)
library(markovchain)
library(purrr)
library(tidyr)
load("/home/Vera_Weidmann/Supermarket/00_Data/boing_test.rda")
load("/home/Max_Philipp/bigdata/cutofflookup.rda")
lookup <- lookup %>% group_by(user_id) %>% mutate(cutoff=max(round((user_reorder_ratio+(1-user_reorder_ratio)/2)*user_average_basket),1))
last_orders <- boing_test%>% group_by(user_id) %>% filter(order_number==max(order_number)) %>% select(user_id,vector2) %>% ungroup()
rm(boing_test)
gc()
load("/home/Max_Philipp/bigdataproject/00_R_scrits_bash/fittedmarkovs.rda")

mmc <- mmc %>%
  left_join(lookup, by="user_id")

get_preds <- function(data=markov,basket=vector2){
  data[basket,] %>% colMeans() %>% sort(decreasing=TRUE)
}

y <- get_preds(mmc$markov[[1]],mmc$vector2[[1]])
y= y[y>0]
x <- as.data.frame(cbind(user_id=mmc$user_id[1],
                         order_id=mmc$order_id[1], 
                         product_id=names(y),
                         reordered=as.numeric(y)),stringsAsFactors=FALSE)
preds <- x

for(i in 2:nrow(mmc)){
  y <- get_preds(mmc$markov[[i]],mmc$vector2[[i]])
  y= y[y>0]
  x <- as.data.frame(cbind(user_id=mmc$user_id[i],
                           order_id=mmc$order_id[i], 
                           product_id=names(y),
                           reordered=as.numeric(y)),stringsAsFactors=FALSE)
  preds <- bind_rows(preds,x)
}

save(preds, file="markovchainpreds.rda")