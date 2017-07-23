library(dplyr)
library(markovchain)
library(purrr)
library(tidyr)
load("/home/Vera_Weidmann/Supermarket/00_Data/boing_test.rda")
last_orders <- boing_test%>% group_by(user_id) %>% filter(order_number==max(order_number)) %>% select(user_id,vector2) %>% ungroup()
rm(boing_test)
load("/home/Vera_Weidmann/Supermarket/00_Data/par_longdata_test.rda")
colnames(longdata_test) <- c("A","B","user_id")

mmc <- longdata_test %>% group_by(user_id) %>% nest(-user_id)
rm(longdata_test)
gc()
mmc <- mmc %>% mutate(user_id=as.numeric(as.character(user_id)))

create_minimarkov <- function(data=data){as.data.frame(markovchainFit(data)$estimate@transitionMatrix)}

get_preds <- function(data=markov,basket=vector2){
  data[basket,] %>% colMeans() %>% sort(decreasing=TRUE)
}

mmc <- mmc  %>% 
  group_by(user_id) %>% 
  mutate(markov= map(data,~ create_minimarkov(.))) %>% 
  select(user_id,markov) %>%
  ungroup()
mmc <- mmc %>%
  left_join(last_orders, by="user_id")

rm(last_orders)
gc()
y <- get_preds(mmc$markov[[1]],mmc$vector2[[1]])
x <- as.data.frame(cbind(user_id=mmc$user_id,
                         oder_id=mmc$order_id, 
                         product_id=names(y),
                         reordered=as.numeric(y)),stringsAsFactors=FALSE)
preds <- x

for(i in 2:nrow(mmc)){
  y <- get_preds(mmc$markov[[i]],mmc$vector2[[i]])
  x <- as.data.frame(cbind(user_id=mmc$user_id,
                           oder_id=mmc$order_id, 
                           product_id=names(y),
                           reordered=as.numeric(y)),stringsAsFactors=FALSE)
  preds <- bind_rows(preds,x)
}
save(preds, file="markovpredictions.rda")