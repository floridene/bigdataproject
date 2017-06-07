#unpersonalised markov chain analysis

library(dplyr)
library(reshape2)

load("/home/Vera_Weidmann/Supermarket/00_Data/df_prior_markov.rda")
df_prior_markov <- df_prior_markov %>%
  arrange(user_id, order_number)

data <- df_prior_markov #train and test people
df <- as.data.frame(matrix(ncol=2))

for (i in unique(data$user_id)){
  x <- data %>% filter(user_id==i)
  for (j in unique(x$order_number)) {
    if (j ==max(x$order_number)) {break}
    
    vector1 <- x$product_id[x$order_number==j]
    vector2 <- x$product_id[x$order_number==j+1]
    
    tmp <- cbind(rep(vector1,each=length(vector2)), rep(vector2,length(vector1)))
    df <- rbind(df,tmp)
    print(paste(i,j,sep=" "))
  }
}

df <- df[-1,] %>% group_by(V1,V2) %>% summarise(n=n()) %>% mutate(p=n/max(n)) %>% dcast(V1 ~ V2, value.var="p")
df[is.na(df)] = 0

user_means <- data %>% group_by(user_id,order_number) %>% summarise(n=n()) %>% summarise(m=mean(n)) %>% round(0)

results <- as.data.frame(matrix(ncol=2))
r <- 1
qual <- as.vector(0)

for (i in unique(data$user_id)){
  x <- data %>% filter(user_id==i)
  trainvector <- x$product_id[(x$order_number==max(x$order_number))] #last basket for user i in data
  predictions <- df[df$V1 %in% trainvector,-1] %>% colMeans() %>% sort(decreasing=TRUE)
  preds <- names(predictions[1:user_means$m[user_means$user_id==i]]) #cutting predictions at the estimated length
  results[r,1] <- i
  results[r,2] <- paste(preds,collapse=" ")
  r=r+1
}

