#markov chain just for train users

library(foreach)
library(doParallel)
library(markovchain)

load("/home/Vera_Weidmann/Supermarket/00_Data/test_orders.rda")
load("/home/Vera_Weidmann/Supermarket/00_Data/boing.rda")
boing_train<- boing[!boing$user_id %in% test_orders$user_id,]
rm(boing)
rm(test_orders)
save(boing_train, file="/home/Vera_Weidmann/Supermarket/00_Data/boing_train.rda")

num_cores <- detectCores()-10 #number of possible cores - 10, so that others can use them still
cluster <- makeCluster(num_cores) #creating cluster
registerDoParallel(cluster) #initializing cluster

#added user_id to the longdata df for use of markov chain later on
longdata_train <- foreach(row=1:nrow(boing_train), .combine=rbind) %dopar% cbind(rep(boing_train$vector1[[row]], each=length(boing_train$vector2[[row]])),rep(boing_train$vector2[[row]],length(boing_train$vector1[[row]])), rep(boing_train$user_id[row],length.out=length(boing_train$vector2[[row]])*length(boing_train$vector1[[row]])))

stopCluster(cluster) #cancel cluster

longdata_train <- as.data.frame(longdata_train)
save(longdata_train, file = "/home/Vera_Weidmann/Supermarket/00_Data/par_longdata_train.rda")
