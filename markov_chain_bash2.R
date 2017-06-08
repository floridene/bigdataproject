library(dplyr)
library(reshape2)

load("/home/Vera_Weidmann/Supermarket/00_Data/df_prior_markov.rda")
df_prior_markov <- df_prior_markov %>%
  arrange(user_id, order_number)

data <- df_prior_markov 
df <- as.data.frame(matrix(ncol=2))

boing <- data %>% 
  group_by(user_id,order_number) %>%
  summarise(basket=paste(product_id, collapse=" ")) %>%
  group_by(user_id) %>%
  mutate(vector1= basket %>%
           strsplit(split = " "), vector2=lead(basket) %>% strsplit(split = " ")) %>%
  ungroup() %>% 
  filter(!is.na(vector2)) 

save(boing, file = "/home/Vera_Weidmann/Supermarket/00_Data/boing.rda")