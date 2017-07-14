library(dplyr)
library(markovchain)
library(purrr)
load("/home/Vera_Weidmann/Supermarket/00_Data/boing_test.rda")
load("/home/Max_Philipp/bigdataproject/cutofflookup.rda")
lookup <- lookup %>% group_by(user_id) %>% mutate(cutoff=max(round((user_reorder_ratio+(1-user_reorder_ratio)/2)*user_average_basket),1))
last_orders <- boing_test%>% group_by(user_id) %>% filter(order_number==max(order_number)) %>% select(user_id,vector2) %>% ungroup()
rm(boing_test)
load("/home/Vera_Weidmann/Supermarket/00_Data/par_longdata_test.rda")
colnames(longdata_test) <- c("A","B","user_id")

mmc <- longdata_test %>% group_by(user_id) %>% nest(-user_id)

create_minimarkov <- function(data=data){as.data.frame(markovchainFit(data)$estimate@transitionMatrix)}

secure_trans <- function(x){as.numeric(as.character(x))}

get_preds <- function(data=markov,basket=vector2){
  data[basket,] %>% colMeans() %>% sort(decreasing=TRUE)
}

mmcm <- mmc  %>% 
  group_by(user_id) %>% 
  mutate(markov= map(data,~ create_minimarkov(.))) %>% 
  ungroup() %>% 
  mutate(user_id=secure_trans(user_id)) %>%
  left_join(last_orders, by="user_id") %>% 
  left_join(lookup[,c(1,4)], by="user_id")

mmcpreds <- list()

for(i in 1:nrow(mmcm)){
  mmcpreds[[i]] <- names(get_preds(mmcm$markov[[i]],mmcm$vector2[[i]]))[1:mmcm$cutoff[i]]
}
submission <- as.data.frame(cbind(predictions=mmcpreds,user_id=mmcm$user_id)) %>% 
  mutate(user_id=secure_trans(user_id)) %>% 
  left_join(lookup[,c(1,5)],by="user_id") %>% 
  group_by(user_id) %>% 
  mutate(products =paste(unlist(predictions), collapse = " ")) %>% 
  ungroup() %>% 
  select(order_id,products)


write.csv(submission, file = "sub_minimarkov_1307.csv", row.names = F)